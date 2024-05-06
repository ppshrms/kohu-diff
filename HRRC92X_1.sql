--------------------------------------------------------
--  DDL for Package Body HRRC92X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC92X" AS

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
--  index parameter
        p_codcomp        := hcm_util.get_string_t(data_obj,'p_codcomp');
        p_year           := hcm_util.get_string_t(data_obj,'p_year');

  end initial_params;

  function check_index return boolean as
    v_temp      varchar(1 char);
  begin
--  check codcomp
    begin
        select 'X' into v_temp
        from tcenter
        where codcomp like p_codcomp || '%'
          and rownum = 1;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang,'TCENTER');
        return false;
    end;



--  check secur7
    if secur_main.secur7(p_codcomp, global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return false;
    end if;

    return true;

  end;

  procedure clear_ttemprpt is
  begin
    begin
        delete
        from  ttemprpt
        where codempid = global_v_codempid
        and   codapp   = 'HRRC92X';
    exception when others then
        null;
    end;
  end clear_ttemprpt;

  function get_max_numseq return number is
    v_numseq    ttemprpt.numseq%type;
  begin
    select max(numseq) into v_numseq
    from  ttemprpt
    where codempid = global_v_codempid
    and   codapp   = 'HRRC92X';

    if v_numseq is null then
        v_numseq := 1;
    else
        v_numseq := v_numseq + 1;
    end if;

    return v_numseq;

  end;

  procedure insert_graph_qtyact(v_row number, v_month number, v_value number) as
    v_item1     ttemprpt.item1%type;
    v_item5     ttemprpt.item4%type;
    v_item7     ttemprpt.item7%type;
  begin

    v_item1 :=  get_label_name('HRRC92XC1',global_v_lang,'30');
    v_item5 := get_nammthabb(v_month, global_v_lang);
    v_item7 := 1;

    insert into ttemprpt
        (
            codempid, codapp, numseq, item1, item4, item5,
            item7, item8, item9, item10, item14
        )
    values
        (
            global_v_codempid, 'HRRC92X', v_row, v_item1, v_month, v_item5,
            v_item7, v_item1, v_item1, v_value, 'A'
        );

  end insert_graph_qtyact;

  procedure insert_graph_amtsalavg(v_row number, v_month number, v_value number) as
    v_item1     ttemprpt.item1%type;
    v_item5     ttemprpt.item4%type;
    v_item7     ttemprpt.item7%type;
  begin

    v_item1 := get_label_name('HRRC92XC1',global_v_lang,'40');
    v_item5 := get_nammthabb(v_month, global_v_lang);
    v_item7 := 2;

    insert into ttemprpt
        (
            codempid, codapp, numseq, item1, item4, item5,
            item7, item8, item9, item10, item14
        )
    values
        (
            global_v_codempid, 'HRRC92X', v_row, v_item1, v_month, v_item5,
            v_item7, v_item1, v_item1, v_value, 'A'
        );

  end insert_graph_amtsalavg;

  procedure gen_index(json_str_output out clob) as
    obj_rows        json_object_t;
    obj_data        json_object_t;
    v_row           number := 0;
    v_count         number := 12;
    v_count_secur   number := 0;
    v_month         varchar2(2 char);
    v_qtyact        number := 0;
    v_amtsalavg     number := 0;

  begin
    if secur_main.secur7(p_codcomp, global_v_coduser) = false then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    clear_ttemprpt;
    obj_rows := json_object_t();

    for i in 1..12 loop
        begin
            select to_char(dtereqm,'mm') ,sum( nvl(qtyact,0) ) ,sum( nvl(qtyact,0) * nvl(amtsalavg,0) )
              into v_month,v_qtyact,v_amtsalavg
              from treqest2
             where codcomp like p_codcomp || '%'
               and to_char(dtereqm, 'yyyy') = p_year
               and to_char(dtereqm,'mm') = to_char(lpad(i,2,0))
             group by to_char(dtereqm,'mm')
             order by to_char(dtereqm,'mm');
         exception when no_data_found then
             v_month        := to_char(lpad(i,2,0));
             v_qtyact       := 0;
             v_amtsalavg    := 0;
             v_count        := v_count - 1;
         end;
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('nammth',get_nammthabb(v_month,global_v_lang));
        obj_data.put('totalrem', v_amtsalavg);
        obj_data.put('numpeple', v_qtyact);
        obj_rows.put(to_char(v_row-1),obj_data);

    end loop;

    if v_count = 0 then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'TREQEST2');
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

END HRRC92X;

/
