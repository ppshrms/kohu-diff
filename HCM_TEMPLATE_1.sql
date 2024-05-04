--------------------------------------------------------
--  DDL for Package Body HCM_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_TEMPLATE" is
  procedure get_tinitial(json_str_input in clob,json_str_output out clob) is
    json_obj      json := json(json_str_input);
    obj_row       json;
    obj_data      json;
    v_rcnt        number;

    cursor c1 is
      select codapp, numseq, datainit1, datainit2
        from tinitial
       where codapp = p_codapp
       order by codapp, numseq;
  begin
    obj_row  := json();
    v_rcnt   := 0;
    p_codapp := json_ext.get_string(json_obj,'p_codapp');
    global_v_lang  := hcm_util.get_string(json_obj,'p_lang');
    for r1 in c1 loop
      v_rcnt       := v_rcnt+1;
      obj_data     := json();
      obj_data.put('coderror', '200');
      obj_data.put('codapp', r1.codapp);
      obj_data.put('numseq', r1.numseq);
      obj_data.put('datainit1', r1.datainit1);
      obj_data.put('datainit2', r1.datainit2);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tinitial;

  procedure get_tfolder(json_str_input in clob,json_str_output out clob) is
    json_obj      json := json(json_str_input);
    obj_row       json;
    obj_data      json;
    v_rcnt        number;
    v_main        varchar2(1000) := get_tsetup_value('PATHFILEPHP');
    v_temp        varchar2(1000) := get_tsetup_value('PATHTMPPHP');

    cursor c1 is
      select codapp, folder
        from tfolderd
       where codapp = p_codapp
       order by codapp, folder;
  begin
    obj_row  := json();
    v_rcnt   := 0;
    p_codapp := json_ext.get_string(json_obj,'p_codapp');
    global_v_lang  := hcm_util.get_string(json_obj,'p_lang');
    for r1 in c1 loop
      v_rcnt       := v_rcnt+1;
      obj_data     := json();
      obj_data.put('coderror', '200');
      obj_data.put('main', v_main);
      obj_data.put('temp', v_temp);
      obj_data.put('codapp', r1.codapp);
      obj_data.put('folder', r1.folder);
      obj_row.put(to_char(v_rcnt-1), obj_data);
    end loop;

    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tfolder;
end;

/
