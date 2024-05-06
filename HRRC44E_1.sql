--------------------------------------------------------
--  DDL for Package Body HRRC44E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC44E" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj, 'p_codpos');
    -- save detail
    obj_tnempaset       := hcm_util.get_json_t(json_obj, 'tnempaset');
    obj_tnempdoc        := hcm_util.get_json_t(json_obj, 'tnempdoc');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy          tcenter.codcompy%type;
    v_codpos            tpostn.codpos%type;
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcompy
          from tcenter
         where codcomp = hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codpos is not null then
      begin
        select codpos
          into v_codpos
          from tpostn
         where codpos = p_codpos;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpostn');
        return;
      end;
    end if;
  end check_index;

  procedure get_tnempaset (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_tnempaset(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tnempaset;

  procedure gen_tnempaset (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select numcolla, codcomp
        from tnempaset
       where codcomp = p_codcomp
         and codpos  = p_codpos
       order by numcolla;
  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numcolla', i.numcolla);
      obj_data.put('codcomp', i.codcomp);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_tnempaset;

  procedure get_tnempdoc (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_tnempdoc(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tnempdoc;

  procedure gen_tnempdoc (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select coddoc, codcomp
        from tnempdoc
       where codcomp = p_codcomp
         and codpos  = p_codpos
       order by coddoc;
  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('coddoc', i.coddoc);
      obj_data.put('codcomp', i.codcomp);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_tnempdoc;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_flg               varchar2(10 char);
    v_check_flg         boolean := false;
    v_codcomp           tnempaset.codcomp%type;
    v_numcolla          tnempaset.numcolla%type;
    v_coddoc            tnempdoc.coddoc%type;
  begin
    initial_value(json_str_input);
    for i in 0 .. obj_tnempaset.get_size - 1 loop
      obj_data        := hcm_util.get_json_t(obj_tnempaset, to_char(i));
      if param_msg_error is null then
        v_flg             := hcm_util.get_string_t(obj_data, 'flg');
        v_codcomp         := hcm_util.get_string_t(obj_data, 'codcomp');
        v_numcolla        := hcm_util.get_string_t(obj_data, 'numcolla');
        if v_flg = 'delete' then
          begin
            delete from tnempaset
             where codcomp  = v_codcomp
               and codpos   = p_codpos
               and numcolla = v_numcolla;
          exception when others then
            null;
          end;
        else
          v_check_flg := true;
          begin
            insert into tnempaset
                   (codcomp, codpos, numcolla, dtecreate, codcreate, coduser)
            values (p_codcomp, p_codpos, v_numcolla, sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
        end if;
      end if;
    end loop;
    for j in 0 .. obj_tnempdoc.get_size - 1 loop
      obj_data        := hcm_util.get_json_t(obj_tnempdoc, to_char(j));
      if param_msg_error is null then
        v_flg             := hcm_util.get_string_t(obj_data, 'flg');
        v_codcomp         := hcm_util.get_string_t(obj_data, 'codcomp');
        v_coddoc          := hcm_util.get_string_t(obj_data, 'coddoc');
        if v_flg = 'delete' then
          begin
            delete from tnempdoc
             where codcomp  = v_codcomp
               and codpos   = p_codpos
               and coddoc = v_coddoc;
          exception when others then
            null;
          end;
        else
          v_check_flg := true;
          begin
            insert into tnempdoc
                   (codcomp, codpos, coddoc, dtecreate, codcreate, coduser)
            values (p_codcomp, p_codpos, v_coddoc, sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
        end if;
      end if;
    end loop;
    if param_msg_error is null then
      commit;
      if v_check_flg then
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2425', global_v_lang);
      end if;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;
end HRRC44E;

/
