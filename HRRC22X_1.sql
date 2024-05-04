--------------------------------------------------------
--  DDL for Package Body HRRC22X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC22X" AS

  procedure initial_current_user_value(json_str_input in clob) as
   json_obj json_object_t;
    begin
        json_obj          := json_object_t(json_str_input);
        global_v_coduser  := hcm_util.get_string_t(json_obj,'p_coduser');
        global_v_codempid := hcm_util.get_string_t(json_obj,'p_codempid');
        global_v_lang     := hcm_util.get_string_t(json_obj,'p_lang');

  end initial_current_user_value;

  procedure initial_params(data_obj json_object_t) as
    begin
        p_codcomp        := hcm_util.get_string_t(data_obj,'p_codcomp');
        p_dtereqst       := to_date(hcm_util.get_string_t(data_obj,'p_dtereqst'),'dd/mm/yyyy');
        p_dtereqen       := to_date(hcm_util.get_string_t(data_obj,'p_dtereqen'),'dd/mm/yyyy');

  end initial_params;

  function check_index return boolean as
    v_temp  varchar(1 char);
  begin
--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return false;
    end;

--  check secur7
    if secur_main.secur7(p_codcomp,global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return false;
    end if;

--  check date
    if p_dtereqst > p_dtereqen then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return false;
    end if;

    return true;

  end check_index;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_count         number := 0;
    v_count_secur   number := 0;

    cursor c1 is
        select a.dtereq, a.numreqst, a.codcomp, b.codpos,
               b.amtincom, b.qtyreq, b.qtyact, b.amtsalavg
        from treqest1 a, treqest2 b
        where a.numreqst = b.numreqst
          and a.codcomp like p_codcomp || '%'
          and a.dtereq between p_dtereqst and p_dtereqen
          and ((nvl(b.qtyact,0)>b.qtyreq) or (b.amtsalavg > b.amtincom))
        order by a.dtereq, a.numreqst;
  begin
     obj_rows := json_object_t();
    for i in c1 loop
        v_count := v_count + 1;
        if secur_main.secur7(p_codcomp,global_v_coduser) then
            v_count_secur := v_count_secur + 1;
            v_row := v_row+1;
            obj_data := json_object_t();
            obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
            obj_data.put('numreqst',i.numreqst);
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('codpos',i.codpos);
            obj_data.put('desc_codpos',get_tpostn_name(i.codpos,global_v_lang));
            obj_data.put('ratesalary',i.amtincom);
            obj_data.put('qtyreq',i.qtyreq);
            obj_data.put('qtysalary',i.qtyact);
            obj_data.put('salary',i.amtsalavg);
            obj_data.put('total',i.qtyact * i.amtsalavg);
            obj_data.put('overbudg',(i.amtsalavg * i.qtyact) - (i.amtincom * i.qtyreq));
            obj_rows.put(to_char(v_row-1),obj_data);
        end if;
    end loop;

    if v_count != 0 and v_count_secur = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    elsif v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TREQEST1');
    end if;

    if param_msg_error is null then
        dbms_lob.createtemporary(json_str_output, true);
        obj_rows.to_clob(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;

  end gen_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_current_user_value(json_str_input);
    initial_params(json_object_t(json_str_input));
    if check_index then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_index;

END HRRC22X;

/
