--------------------------------------------------------
--  DDL for Package Body STD_TJOBCODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "STD_TJOBCODE" as
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_jobcode           := hcm_util.get_string_t(json_obj,'p_jobcode');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  procedure get_tjobcode(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_tjobcode(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tjobcode(json_str_output out clob)as
    obj_data        json_object_t;
    tjobcode_rec    tjobcode%ROWTYPE;
  begin
    begin
      select * into tjobcode_rec
        from tjobcode
       where codjob = p_jobcode;
    exception when no_data_found then
      tjobcode_rec := null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('response', '');
    obj_data.put('codjob', p_jobcode);
    obj_data.put('desc_codjob',get_tjobcode_name(p_jobcode,global_v_lang));
    obj_data.put('resp', tjobcode_rec.desjob ); 
    obj_data.put('secur_value', to_char(tjobcode_rec.amtcolla,'fm999,999,990.00') ); 
    obj_data.put('period', '' ); 
    obj_data.put('amount_guar', tjobcode_rec.qtyguar ); 
    obj_data.put('exp', tjobcode_rec.desguar ); 
    obj_data.put('dteupdte', to_char(tjobcode_rec.dteupd,'dd/mm/yyyy') ); 
    obj_data.put('editer', get_temploy_name(get_codempid(tjobcode_rec.coduser),global_v_lang) ); 
    obj_data.put('codupdte', get_codempid(tjobcode_rec.coduser) ); 
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_tjobcode;
  --

  procedure gen_tjobdet(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    cursor c1 is
      select * 
        from tjobdet
       where codjob = p_jobcode;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response','');
      obj_data.put('topic',r1.namitem);
      obj_data.put('description',r1.descrip);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end ;

  procedure get_tjobdet(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_tjobdet(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_tjobresp(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    cursor c1 is
      select * 
        from tjobresp
       where codjob = p_jobcode;
  begin
    obj_row := json_object_t();
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response','');
      obj_data.put('topic',r1.namitem);
      obj_data.put('description',r1.descrip);

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt := v_rcnt + 1;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end ;

  procedure get_tjobresp(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    gen_tjobresp(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end std_tjobcode;

/
