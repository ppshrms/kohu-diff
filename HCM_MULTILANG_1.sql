--------------------------------------------------------
--  DDL for Package Body HCM_MULTILANG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_MULTILANG" as
  function get_multilang(json_str_input clob) return clob is
    json_obj        json_object_t;
    json_codapp     json_object_t;
    json_str_output clob;

    obj_row         json_object_t;
    obj_lang1       json_object_t;
    obj_lang2       json_object_t;
    obj_lang3       json_object_t;
    obj_lang4       json_object_t;
    obj_lang5       json_object_t;
    obj_desc_label1 json_object_t;
    obj_desc_label2 json_object_t;
    obj_desc_label3 json_object_t;
    obj_desc_label4 json_object_t;
    obj_desc_label5 json_object_t;
    v_codapp        varchar2(100 char);
    o_codapp        varchar2(100 char);
    v_first         boolean := false;
    v_rcnt          number;
    v_descode       tcodlang.descode%type;
    v_descodt       tcodlang.descodt%type;
    v_descod3       tcodlang.descod3%type;
    v_descod4       tcodlang.descod4%type;
    v_descod5       tcodlang.descod5%type;

    cursor c_tlanguage is
      select codlang2
        from tlanguage
       where codlang2 is not null
    order by codlang;
  begin
    json_obj      := json_object_t(json_str_input);
    json_codapp   := json_object_t(hcm_util.get_string_t(json_obj, 'p_codapp'));
    o_codapp      := '';
    obj_row       := json_object_t();
    obj_lang1     := json_object_t();
    obj_lang2     := json_object_t();
    obj_lang3     := json_object_t();
    obj_lang4     := json_object_t();
    obj_lang5     := json_object_t();
    obj_desc_label1     := json_object_t();
    obj_desc_label2     := json_object_t();
    obj_desc_label3     := json_object_t();
    obj_desc_label4     := json_object_t();
    obj_desc_label5     := json_object_t();
    v_rcnt := 0;
    for r1 in c_tlanguage loop
      begin
        select DESCODE,DESCODT,DESCOD3,DESCOD4,DESCOD5
          into v_descode, v_descodt, v_descod3, v_descod4, v_descod5
          from tcodlang
          where codcodec = r1.codlang2;
      exception when no_data_found then
        v_descode := '';
        v_descodt := '';
        v_descod3 := '';
        v_descod4 := '';
        v_descod5 := '';
      end;
      v_first := false;
      obj_desc_label1.put(to_char(v_rcnt), v_descode);
      obj_desc_label2.put(to_char(v_rcnt), nvl(v_descodt,v_descode));
      obj_desc_label3.put(to_char(v_rcnt), nvl(v_descod3,v_descode));
      obj_desc_label4.put(to_char(v_rcnt), nvl(v_descod4,v_descode));
      obj_desc_label5.put(to_char(v_rcnt), nvl(v_descod5,v_descode));

      v_rcnt := v_rcnt + 1;
    end loop;
    -- set obj_desc_label to obj_lang
    obj_lang1.put(upper('CHANGE_LABEL'), obj_desc_label1);
    obj_lang2.put(upper('CHANGE_LABEL'), obj_desc_label2);
    obj_lang3.put(upper('CHANGE_LABEL'), obj_desc_label3);
    obj_lang4.put(upper('CHANGE_LABEL'), obj_desc_label4);
    obj_lang5.put(upper('CHANGE_LABEL'), obj_desc_label5);

    obj_row.put('coderror','200');
    obj_row.put('objLang1',obj_lang1);
    obj_row.put('objLang2',obj_lang2);
    obj_row.put('objLang3',obj_lang3);
    obj_row.put('objLang4',obj_lang4);
    obj_row.put('objLang5',obj_lang5);

    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;

end hcm_multilang;

/
