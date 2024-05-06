--------------------------------------------------------
--  DDL for Package Body HRRC3IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC3IX" is
-- last update: 06/11/2020 17:00
 procedure initial_value (json_str in clob) is
    json_obj   json_object_t := json_object_t(json_str);
  begin
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_dtestrt           := hcm_util.get_string_t(json_obj,'p_dtestrt');
    p_dteend            := hcm_util.get_string_t(json_obj,'p_dteend');
    json_params         := hcm_util.get_json_t(json_obj, 'p_condition');

  end initial_value;
  ----------------------------------------------------------------------------------
  procedure get_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;
----------------------------------------------------------------------------------
  procedure gen_detail(json_str_output out clob) is
    obj_data    json;
    obj_row     json;
    v_rcnt      number := 0;
    json_row           json_object_t;
    json_syncond       json_object_t;
    v_syncond          varchar2(200);
    v_description      varchar2(200);
    v_statement        varchar2(4000 char);
    v_count            number ;
  begin
    obj_row     := json();
    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRRC3IX'; -- softberry || 13/02/2023 || #8839

    for i in 0..json_params.get_size - 1 loop
      json_row          := hcm_util.get_json_t(json_params, to_char(i));
      json_syncond            := hcm_util.get_json_t(json_row,'syncond');
      v_syncond               := hcm_util.get_string_t(json_syncond, 'code');
      v_description           := hcm_util.get_string_t(json_syncond, 'description');

       v_statement := 'select count(distinct(numappl)) as cnt from  V_HRRC3I where dteappl between to_date(''' || p_dtestrt || ''',''dd/mm/yyyy'') and to_date(''' || p_dteend || ''',''dd/mm/yyyy'') and ' || v_syncond ;
       EXECUTE IMMEDIATE v_statement INTO v_count;

       v_rcnt      := v_rcnt+1;
       obj_data    := json();
       obj_data.put('coderror', '200');
       obj_data.put('description', v_description);
       obj_data.put('qtyreg', v_count);
       obj_row.put(to_char(v_rcnt-1),obj_data);

       --<< softberry || 13/02/2023 || #8839
       insert into ttemprpt(codempid,codapp,numseq,item1,item4,item5,item7,item8,item9,item10)
       values(global_v_codempid,
            'HRRC3IX',
            v_rcnt,
            get_label_name('HRRC93XC1',global_v_lang,70),
            v_description,v_description,
            1,
            get_label_name('HRRC3IXC2',global_v_lang,20),
            get_label_name('HRRC93XC1',global_v_lang,70),v_count);
       -->> softberry || 13/02/2023 || #8839


   end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);

  end gen_detail;
----------------------------------------------------------------------------------

end HRRC3IX;

/
