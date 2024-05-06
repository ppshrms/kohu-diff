--------------------------------------------------------
--  DDL for Package Body HRRC1HE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC1HE" AS
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
    p_codexam           := hcm_util.get_string_t(json_obj, 'p_codexam');
    -- save detail
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy          tcenter.codcompy%type;
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
  end check_index;

  function check_delete (v_codcomp treqest2.codcomp%type, v_codexam tappoinf.codexam%type, v_codpos treqest2.codpos%type default null) return varchar2 is
    v_count               number := 0;
  begin
    begin
      select count(*)
        into v_count
        from tappoinf a, treqest2 b
       where a.numreqrq = b.numreqst
         and a.codposrq = b.codpos
         and b.codcomp  like v_codcomp || '%'
         and a.codexam  = v_codexam
         and b.codpos   = nvl(v_codpos, codpos);
    exception when no_data_found then
      null;
    end;
    if v_count = 0 then
      return 'Y';
    else
      return 'N';
    end if;
  end check_delete;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select codexam, min(dtecreate) dtecreate
        from texampos
       where codcomp like p_codcomp || '%'
       group by codexam
       order by codexam;

  begin
    obj_rows            := json_object_t();

    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codexam', i.codexam);
      obj_data.put('desc_codexam', get_tcodec_name('TCODEXAM', i.codexam, global_v_lang));
      obj_data.put('dtecreate', to_char(i.dtecreate, 'DD/MM/YYYY'));
      obj_data.put('isDelete', check_delete(p_codcomp, i.codexam));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_index;

  procedure check_detail is
    v_codcodec          tcodexam.codcodec%type;
  begin
    if p_codexam is not null then
      begin
        select codcodec
          into v_codcodec
          from tcodexam
         where codcodec = p_codexam;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodexam');
        return;
      end;
    end if;
  end check_detail;

  procedure get_texampos (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_texampos(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_texampos;

  procedure gen_texampos (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select codexam, codcomp, codpos, scorfull, scorpass, codexamchk
        from texampos
       where codexam = p_codexam
         and codcomp like p_codcomp || '%'
       order by codcomp, codpos;

  begin
    obj_rows            := json_object_t();

    for i in c1 loop
      if secur_main.secur7(i.codcomp, global_v_coduser) then
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codexam', i.codexam);
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('codpos', i.codpos);
        obj_data.put('scorfull', i.scorfull);
        obj_data.put('scorpass', i.scorpass);
        obj_data.put('codexamchk', i.codexamchk);
        obj_data.put('isDelete', check_delete(i.codcomp, i.codexam, i.codpos));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_texampos;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail;

  procedure gen_detail (json_str_output out clob) AS
    obj_data            json_object_t;
    v_scorfull          texampos.scorfull%type := 100;

  begin
    begin
      select scorfull
        into v_scorfull
        from texampos
       where codexam = p_codexam
         and codcomp like p_codcomp || '%'
       group by scorfull
       fetch first row only;
    exception when no_data_found then
      null;
    end;
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('scorfull', v_scorfull);

    json_str_output := obj_data.to_clob;
  end gen_detail;

  procedure save_index (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_flg               varchar2(10 char);
  begin
    initial_value(json_str_input);
    for i in 0 .. json_params.get_size - 1 loop
      obj_data            := hcm_util.get_json_t(json_params, to_char(i));
      v_flg               := hcm_util.get_string_t(obj_data, 'flg');
      p_codexam           := hcm_util.get_string_t(obj_data, 'codexam');
      if param_msg_error is null then
        if v_flg = 'delete' then
          begin
            delete from texampos
             where codexam = p_codexam
               and codcomp like p_codcomp || '%';
          exception when others then
            null;
          end;
        end if;
      end if;
    end loop;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2425', global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;

  procedure check_save (v_codcomp texampos.codcomp%type, v_codpos texampos.codpos%type, v_codexamchk texampos.codexamchk%type) as
    v_codcompy          tcenter.codcompy%type;
    b_codpos            tpostn.codpos%type;
    v_staemp            temploy1.staemp%type;
    b_codcomp           temploy1.codcomp%type;
  begin
    if v_codcomp is not null then
      begin
        select codcompy
          into v_codcompy
          from tcenter
         where codcomp = hcm_util.get_codcomp_level(v_codcomp, null, null, 'Y');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      if not secur_main.secur7(v_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
      if v_codcomp not like p_codcomp || '%' then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end if;
    end if;
    if v_codpos is not null then
      begin
        select codpos
          into b_codpos
          from tpostn
         where codpos = v_codpos;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpostn');
        return;
      end;
    end if;
    if v_codexamchk is not null then
      begin
        select staemp, codcomp
          into v_staemp, b_codcomp
          from temploy1
         where codempid = v_codexamchk
           and staemp   in ('1', '3');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur7(b_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
  end check_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_flg               varchar2(10 char);
    v_check_flg         boolean := false;
    v_codcomp           texampos.codcomp%type;
    v_codcompOld        texampos.codcomp%type;
    v_codpos            texampos.codpos%type;
    v_codposOld         texampos.codpos%type;
    v_scorfull          texampos.scorfull%type;
    v_scorpass          texampos.scorpass%type;
    v_codexamchk        texampos.codexamchk%type;
  begin
    initial_value(json_str_input);
    for i in 0 .. json_params.get_size - 1 loop
      obj_data            := hcm_util.get_json_t(json_params, to_char(i));
      v_flg               := hcm_util.get_string_t(obj_data, 'flg');
      v_codcomp           := hcm_util.get_string_t(obj_data, 'codcomp');
      v_codcompOld        := hcm_util.get_string_t(obj_data, 'codcompOld');
      v_codpos            := hcm_util.get_string_t(obj_data, 'codpos');
      v_codposOld         := hcm_util.get_string_t(obj_data, 'codposOld');
      v_scorfull          := hcm_util.get_string_t(obj_data, 'scorfull');
      v_scorpass          := hcm_util.get_string_t(obj_data, 'scorpass');
      v_codexamchk        := hcm_util.get_string_t(obj_data, 'codexamchk');
      check_save(v_codcomp, v_codpos, v_codexamchk);
      if param_msg_error is null then
        if v_flg = 'delete' then
          begin
            delete from texampos
             where codcomp = nvl(v_codcompOld, v_codcomp)
               and codpos  = nvl(v_codposOld, v_codpos)
               and codexam = p_codexam;
          exception when others then
            null;
          end;
        else
          v_check_flg := true;
          begin
            insert into texampos (codcomp, codpos, codexam, scorfull, scorpass, codexamchk, codcreate, dtecreate, coduser)
            values (v_codcomp, v_codpos, p_codexam, v_scorfull, v_scorpass, v_codexamchk, global_v_coduser, trunc(sysdate), global_v_coduser);
          exception when dup_val_on_index then
            update texampos
               set scorpass   = v_scorpass,
                   codexamchk = v_codexamchk,
                   coduser    = global_v_coduser,
                   dteupd     = sysdate
             where codcomp    = v_codcomp
               and codpos     = v_codpos
               and codexam    = p_codexam;
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
end HRRC1HE;

/
