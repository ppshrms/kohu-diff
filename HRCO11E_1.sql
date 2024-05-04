--------------------------------------------------------
--  DDL for Package Body HRCO11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRCO11E" AS

  procedure check_index is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if p_codcompy is not null then
      begin
        select codcompy
        into   p_codcompy
        from   tcompny
        where  codcompy = p_codcompy;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'codcompy');
        return;
      end;
      error_secur := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if error_secur is not null then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang,'codcompy');
        return;
      end if;
    end if;
  end;

  procedure check_save is
  error_secur VARCHAR2(4000 CHAR);
  begin
    if
      p_codinitit is null
      and p_codinitie is null
      and p_codiniti3 is null
      and p_codiniti4 is null
      and p_codiniti5 is null
    then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_numlastdoc is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
  end;

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);

    param_msg_error     := '';
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    p_codcompy          := hcm_util.get_string_t(json_obj,'p_codcompy');
    p_typdoc            := hcm_util.get_string_t(json_obj,'p_typdoc');

    p_rowid             := hcm_util.get_string_t(json_obj,'p_rowid');
    p_flg               := hcm_util.get_string_t(json_obj,'p_flg');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;

  procedure gen_data (json_str_output out clob) is
  obj_data        json_object_t;
  obj_row         json_object_t;
  v_rcnt          number      := 0;
  v_secure        boolean     := false;
  v_chk_secure    varchar2(1) := 'N';

  cursor c1 is
   Select rowid as indexid,tdocrnum.*
     From tdocrnum
    Where codcompy = NVL(p_codcompy,codcompy)
      And typdoc = NVL(p_typdoc,typdoc);
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_secure    := secur_main.secur7(r1.codcompy, global_v_coduser);
      if v_secure then
        v_chk_secure  := 'Y';
        v_rcnt        := v_rcnt+1;
        obj_data      := json_object_t();

        obj_data.put('indexid', r1.indexid);
        obj_data.put('codcompy', r1.codcompy);
        obj_data.put('desc_codcompy', r1.codcompy||' - '||get_tcenter_name(r1.codcompy,global_v_lang));
  --      obj_data.put('typdoc', r1.typdoc);
        obj_data.put('typdoc', get_tlistval_name('TYPDOC', r1.typdoc , global_v_lang));
        if(global_v_lang = '101') then
          obj_data.put('codiniti', r1.codinitie);
        elsif (global_v_lang = '102') then
          obj_data.put('codiniti', r1.codinitit);
        elsif (global_v_lang = '103') then
          obj_data.put('codiniti', r1.codiniti3);
        elsif (global_v_lang = '104') then
          obj_data.put('codiniti', r1.codiniti4);
        elsif (global_v_lang = '105') then
          obj_data.put('codiniti', r1.codiniti5);
        else
          obj_data.put('codiniti', '');
        end if;
        obj_data.put('codinitie', r1.codinitie);
        obj_data.put('codinitit', r1.codinitit);
        obj_data.put('codiniti3', r1.codiniti3);
        obj_data.put('codiniti4', r1.codiniti4);
        obj_data.put('codiniti5', r1.codiniti5);
        obj_data.put('dtelstprn', to_char(r1.dtelstprn,'dd/mm/yyyy'));
        obj_data.put('numlastdoc', r1.numlastdoc);
  --      obj_data.put('dtecreate', r1.dtecreate);
  --      obj_data.put('codcreate', r1.codcreate);
        obj_data.put('dteupd', to_char(r1.dteupd,'dd/mm/yyyy'));
        obj_data.put('coduser', r1.coduser);

        obj_row.put(to_char(v_rcnt-1),obj_data);
      end if;
    end loop;
    if v_chk_secure = 'N' then
      param_msg_error   := get_error_msg_php('HR3007',global_v_lang);
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_predata is
  v_rowcheck VARCHAR2(20 CHAR) ;
  cursor c1 is
    Select list_value From  TLISTVAL
    Where  codapp = 'TYPDOC' and CODLANG = global_v_lang and list_value is not null;
  begin
    begin
        select rowid
        into   v_rowcheck
        from   tdocrnum
        Where codcompy = NVL(p_codcompy,codcompy) And typdoc = NVL(p_typdoc,typdoc) FETCH FIRST 1 ROWS ONLY;
    exception when no_data_found then
        begin
            for r1 in c1 loop
                insert into tdocrnum (codcompy, typdoc, codcreate, coduser) values (p_codcompy, r1.list_value, global_v_coduser, global_v_coduser);
            end loop;
        end;
    end;
--
--    if v_rowcheck is not null then
--        param_msg_error_check := get_error_msg_php('HR2005',global_v_lang,'TEMPROUTE');
--        return;
--    end if;
  end;
  procedure get_data (json_str_input in clob, json_str_output out clob) as
      obj_row json_object_t;
  begin
      initial_value(json_str_input);
      check_index;

      if p_codcompy is not null and p_typdoc is null then
        check_predata;
      end if;

      if param_msg_error is null then
        gen_data(json_str_output);
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
  exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

--  procedure add_data (json_str_input in clob, json_str_output out clob) as
--    param_json      json;
--    param_json_row  json;
--  begin
--    param_json := json(hcm_util.get_string(json(json_str_input),'json_input_str'));
--
--    for i in 0..param_json.count-1 loop
--      param_json_row  := json(param_json.get(to_char(i)));
--
--      p_codcompy    := hcm_util.get_string(param_json_row,'p_codcompy');
--      p_typdoc      := hcm_util.get_string(param_json_row,'p_typdoc');
--      p_codinitie   := hcm_util.get_string(param_json_row,'p_codinitie');
--      p_codinitit   := hcm_util.get_string(param_json_row,'p_codinitit');
--      p_codiniti3   := hcm_util.get_string(param_json_row,'p_codiniti3');
--      p_codiniti4   := hcm_util.get_string(param_json_row,'p_codiniti4');
--      p_codiniti5   := hcm_util.get_string(param_json_row,'p_codiniti5');
--      p_numlastdoc  := hcm_util.get_string(param_json_row,'p_numlastdoc');
--
--      p_rowid       := hcm_util.get_string(param_json_row,'p_rowid');
--      p_flg         := hcm_util.get_string(param_json_row,'p_flg');
--
--      check_save;
--
--      if(p_flg = 'add') then
--        begin
--          insert into tdocrnum (codcompy, typdoc, codinitie, codinitit, codiniti3, codiniti4, codiniti5,
--          numlastdoc, coduser, dtecreate)
--          values(p_codcompy, p_typdoc, p_codinitie, p_codinitit, p_codiniti3, p_codiniti4, p_codiniti5,
--          p_numlastdoc, global_v_coduser, CURRENT_DATE);
--        exception when others then
--          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--          rollback;
--        end;
--      end if;
--    end loop;
--
--    if param_msg_error is null then
--      json_str_output := get_error_msg_php('HR2401',global_v_lang);
--      commit;
--    else
--      json_str_output := param_msg_error;
--      rollback;
--    end if;
--    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--  end;
  procedure update_data is
  begin
    begin
      update tdocrnum
      set codinitit  = p_codinitit,
      codinitie = p_codinitie,
      codiniti3 = p_codiniti3,
      codiniti4 = p_codiniti4,
      codiniti5 = p_codiniti5,
      numlastdoc = p_numlastdoc,
      coduser   = global_v_coduser
      where rowid = p_rowid;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      rollback;
    end;
  end;
  procedure edit_data(json_str_input in clob, json_str_output out clob) as
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');

    if param_msg_error is null then

      for i in 0..param_json.get_size-1 loop
        param_json_row  := hcm_util.get_json_t(param_json,to_char(i));

        p_codinitit   := hcm_util.get_string_t(param_json_row,'p_codinitit');
        p_codinitie   := hcm_util.get_string_t(param_json_row,'p_codinitie');
        p_codiniti3   := hcm_util.get_string_t(param_json_row,'p_codiniti3');
        p_codiniti4   := hcm_util.get_string_t(param_json_row,'p_codiniti4');
        p_codiniti5   := hcm_util.get_string_t(param_json_row,'p_codiniti5');
        p_numlastdoc  := to_number(hcm_util.get_string_t(param_json_row,'p_numlastdoc'));

        p_rowid           := hcm_util.get_string_t(param_json_row,'p_rowid');
        p_flg             := hcm_util.get_string_t(param_json_row,'p_flg');

        check_save;
        if(p_flg = 'edit') then
         update_data;
        end if;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        json_str_output := param_msg_error;
        rollback;
      end if;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

END HRCO11E;

/
