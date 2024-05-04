--------------------------------------------------------
--  DDL for Package Body HCM_LABELS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_LABELS" is
-- last update: 01/12/2017 13:57
  function get_labels(json_str_input clob) return clob is
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

    cursor c_tapplscr is
    select  codapp,numseq,desclabele,desclabelt,desclabel3,desclabel4,desclabel5
      from  tapplscr
     where  codapp like (v_codapp||'%')
     order by  codapp,numseq;
     
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
    for i in 0..json_codapp.get_size-1 loop
      v_codapp            := upper(hcm_util.get_string_t(json_codapp, to_char(i)));
      v_first             := true;
      obj_desc_label1     := json_object_t();
      obj_desc_label2     := json_object_t();
      obj_desc_label3     := json_object_t();
      obj_desc_label4     := json_object_t();
      obj_desc_label5     := json_object_t();
      o_codapp := v_codapp;

      for r1 in c_tapplscr loop
        if o_codapp <> r1.codapp and v_first = false then
          -- set obj_desc_label to obj_lang
          obj_lang1.put(upper(o_codapp), obj_desc_label1);
          obj_lang2.put(upper(o_codapp), obj_desc_label2);
          obj_lang3.put(upper(o_codapp), obj_desc_label3);
          obj_lang4.put(upper(o_codapp), obj_desc_label4);
          obj_lang5.put(upper(o_codapp), obj_desc_label5);
          -- clear obj_desc_label
          obj_desc_label1 := json_object_t();
          obj_desc_label2 := json_object_t();
          obj_desc_label3 := json_object_t();
          obj_desc_label4 := json_object_t();
          obj_desc_label5 := json_object_t();
        end if;
        v_first := false;
        obj_desc_label1.put(to_char(r1.numseq), r1.desclabele);
        obj_desc_label2.put(to_char(r1.numseq), r1.desclabelt);
        obj_desc_label3.put(to_char(r1.numseq), r1.desclabel3);
        obj_desc_label4.put(to_char(r1.numseq), r1.desclabel4);
        obj_desc_label5.put(to_char(r1.numseq), r1.desclabel5);
        o_codapp := r1.codapp;
      end loop;
      if o_codapp is not null then
        -- set obj_desc_label to obj_lang
        obj_lang1.put(upper(o_codapp), obj_desc_label1);
        obj_lang2.put(upper(o_codapp), obj_desc_label2);
        obj_lang3.put(upper(o_codapp), obj_desc_label3);
        obj_lang4.put(upper(o_codapp), obj_desc_label4);
        obj_lang5.put(upper(o_codapp), obj_desc_label5);
        -- clear obj_desc_label
        obj_desc_label1 := json_object_t();
        obj_desc_label2 := json_object_t();
        obj_desc_label3 := json_object_t();
        obj_desc_label4 := json_object_t();
        obj_desc_label5 := json_object_t();
      end if;
    end loop;

    obj_row.put('coderror', '200');
    obj_row.put('objLang1', obj_lang1);
    obj_row.put('objLang2', obj_lang2);
    obj_row.put('objLang3', obj_lang3);
    obj_row.put('objLang4', obj_lang4);
    obj_row.put('objLang5', obj_lang5);

    return obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
    return json_str_output;
  end;
end;

/
