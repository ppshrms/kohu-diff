--------------------------------------------------------
--  DDL for Package Body HRRC3LX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC3LX" AS

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
        p_codcomp         := hcm_util.get_string_t(data_obj,'p_codcomp');
        p_dteclosest      := to_date(hcm_util.get_string_t(data_obj,'p_dteclosest'),'dd/mm/yyyy');
        p_dtecloseen      := to_date(hcm_util.get_string_t(data_obj,'p_dtecloseen'),'dd/mm/yyyy');
        p_codjobpost      := hcm_util.get_string_t(data_obj,'p_codjobpost');

  end initial_params;

  function check_index return boolean as
    v_temp     varchar(1 char);
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
    if p_dteclosest > p_dtecloseen then
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
    c1_numreqst     treqest1.numreqst%type;
    c1_codpos       treqest2.codpos%type;

    cursor c1 is
        select numreqst, codpos, codjobpost, dtepost, dteclose
        from tjobpost
        where codcomp like p_codcomp || '%'
          and codjobpost = nvl(p_codjobpost,codjobpost)
          and trunc(dteclose) between p_dteclosest and p_dtecloseen
        order by codjobpost, dtepost, numreqst, codpos;

    cursor c2 is
        select numreqst, codpos, (sum(nvl(qtyreq,0))) qtyreq,
              (sum(nvl(qtyact,0))) qtyact
        from treqest2
        where numreqst = c1_numreqst
          and codpos = c1_codpos
          and nvl(qtyact,0 ) < nvl(qtyreq,0)
        group by numreqst, codpos
        order by numreqst,codpos;

    cursor c3 is
        select codemprc, count(nvl(codempid,0)) cs_emp
        from tapplinf
        where numreql = c1_numreqst
          and codposl = c1_codpos
        group by codemprc
        order by codemprc;
  begin
    obj_rows := json_object_t();
    for i in c1 loop
    --    v_count := v_count + 1;--<<user25 Date:14/10/2021 #4252
        c1_numreqst := i.numreqst;
        c1_codpos := i.codpos;
        for i2 in c2 loop
            for i3 in c3 loop
                v_count := v_count + 1;--<<user25 Date:14/10/2021 #4252
                v_row := v_row+1;
                obj_data := json_object_t();
                obj_data.put('coderror', '200'); --<<user25 Date:14/10/2021 #4252
                obj_data.put('codjobpost',i.codjobpost);
                obj_data.put('desc_codjobpost',get_tcodec_name('TCODJOBPOST',i.codjobpost,global_v_lang));
                obj_data.put('dtepost',to_char(i.dtepost,'dd/mm/yyyy'));
                obj_data.put('dteclose',to_char(i.dteclose,'dd/mm/yyyy'));
                obj_data.put('numreqst',i2.numreqst);
                obj_data.put('codpos',i2.codpos);
                obj_data.put('desc_codpos',get_tpostn_name(i2.codpos,global_v_lang));
                obj_data.put('codemprc',i3.codemprc);
                obj_data.put('desc_codemprc',get_temploy_name(i3.codemprc,global_v_lang));
                obj_data.put('qtyreq',i2.qtyreq);
                obj_data.put('cs_emp',i3.cs_emp);
                obj_data.put('qtyact',i2.qtyact);
                obj_rows.put(to_char(v_row-1),obj_data);
            end loop;
        end loop;
    end loop;

    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TJOBPOST');
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

END HRRC3LX;

/
