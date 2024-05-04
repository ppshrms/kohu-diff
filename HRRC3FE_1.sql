--------------------------------------------------------
--  DDL for Package Body HRRC3FE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC3FE" AS
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
    p_codform           := hcm_util.get_string_t(json_obj, 'p_codform');
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

  function check_delete (v_codcomp treqest2.codcomp%type, v_codform tappoinf.codform%type, v_codpos treqest2.codpos%type default null) return varchar2 is
    v_count               number := 0;
  begin
    begin
      select count(*)
        into v_count
        from tappoinf a, treqest2 b
       where a.numreqrq = b.numreqst
         and a.codposrq = b.codpos
         and b.codcomp  like v_codcomp || '%'
         and a.codform  = v_codform
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
      select codform, max(scorfull) scorfull
        from tintvewp
       where codcomp like p_codcomp || '%'
       group by codform
       order by codform;

  begin
    obj_rows            := json_object_t();

    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codform', i.codform);
      obj_data.put('desc_codform', get_tintview_name(i.codform, global_v_lang));
      obj_data.put('scorfull', i.scorfull);
      obj_data.put('isDelete', check_delete(p_codcomp, i.codform));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_index;

  procedure check_detail is
    v_codform          tintview.codform%type;
  begin
    if p_codform is not null then
      begin
        select codform
          into v_codform
          from tintview
         where codform = p_codform;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tintview');
        return;
      end;
    end if;
  end check_detail;

  procedure get_tintvewp (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_tintvewp(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tintvewp;

  procedure gen_tintvewp (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select codform, codcomp, codpos, scorfull, qtyscore
        from tintvewp
       where codform = p_codform
       order by codcomp, codpos;

  begin
    obj_rows            := json_object_t();

    for i in c1 loop
      if secur_main.secur7(i.codcomp, global_v_coduser) then
        v_rcnt              := v_rcnt + 1;
        obj_data            := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codform', i.codform);
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
        obj_data.put('codpos', i.codpos);
        obj_data.put('scorfull', i.scorfull);
        obj_data.put('qtyscore', i.qtyscore);
        obj_data.put('isDelete', check_delete(i.codcomp, i.codform, i.codpos));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_tintvewp;

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
    v_scorfull          tintvewp.scorfull%type;

  begin
    begin
      select max(scorfull)
        into v_scorfull
        from tintvewp
       where codform = p_codform;
    exception when no_data_found then
      null;
    end;
    if v_scorfull is null then ----
      begin
        select sum(nvl(qtyfscor,0))
          into v_scorfull
          from tintvews
         where codform = p_codform;
      exception when no_data_found then
        null;
      end;
    end if;
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
      p_codform           := hcm_util.get_string_t(obj_data, 'codform');
      if param_msg_error is null then
        if v_flg = 'delete' then
          begin
            delete from tintvewp
             where codform = p_codform
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

  procedure check_save (v_codpos tintvewp.codpos%type, v_codcomp in out tintvewp.codcomp%type) as
    v_codform           tintview.codform%type;
    b_codpos            tpostn.codpos%type;
  begin
    if p_codform is not null then
      begin
        select codform
          into v_codform
          from tintview
         where codform = p_codform;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tintview');
        return;
      end;
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
    if v_codcomp is null then
      v_codcomp := p_codcomp;
    end if;
  end check_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_flg               varchar2(10 char);
    v_check_flg         boolean := false;
    v_codcomp           tintvewp.codcomp%type;
    v_codpos            tintvewp.codpos%type;
    v_codposOld         tintvewp.codpos%type;
    v_scorfull          tintvewp.scorfull%type;
    v_qtyscore          tintvewp.qtyscore%type;
  begin
    initial_value(json_str_input);
    for i in 0 .. json_params.get_size - 1 loop
      obj_data            := hcm_util.get_json_t(json_params, to_char(i));
      v_flg               := hcm_util.get_string_t(obj_data, 'flg');
      v_codcomp           := hcm_util.get_string_t(obj_data, 'codcomp');
      v_codpos            := hcm_util.get_string_t(obj_data, 'codpos');
      v_codposOld         := hcm_util.get_string_t(obj_data, 'codposOld');
      v_scorfull          := hcm_util.get_string_t(obj_data, 'scorfull');
      v_qtyscore          := hcm_util.get_string_t(obj_data, 'qtyscore');
      check_save(v_codpos, v_codcomp);
      if param_msg_error is null then
        if v_flg = 'delete' then
          begin
            delete from tintvewp
             where codcomp = v_codcomp
               and codpos  = nvl(v_codposOld, v_codpos)
               and codform = p_codform;
          exception when others then
            null;
          end;
        elsif v_flg = 'add' then
          v_check_flg := true;
          begin
            insert into tintvewp (codcomp, codpos, codform, scorfull, qtyscore, codcreate, dtecreate, coduser)
            values (v_codcomp, v_codpos, p_codform, v_scorfull, v_qtyscore, global_v_coduser, sysdate, global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
        else
          v_check_flg := true;
          begin
            update tintvewp
               set qtyscore   = v_qtyscore,
                   coduser    = global_v_coduser,
                   dteupd     = sysdate
             where codcomp    = v_codcomp
               and codpos     = v_codpos
               and codform    = p_codform;
          exception when others then
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

  procedure get_tintscor (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_tintscor(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tintscor;

  procedure gen_tintscor (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select grditem, grad, qtyscor, decode(global_v_lang, '101', descgrde
                                                         , '102', descgrdt
                                                         , '103', descgrd3
                                                         , '104', descgrd4
                                                         , '105', descgrd5, descgrde) descgrd
        from tintscor
       where codform = p_codform
       order by grditem;

  begin
    obj_rows            := json_object_t();

    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('grditem', i.grditem);
      obj_data.put('desc_grditem', i.descgrd);
      obj_data.put('grad', i.grad);
      obj_data.put('qtyscor', i.qtyscor);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_tintscor;

  procedure get_tintvews (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_tintvews(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tintvews;

  function get_qtyitem (v_codform tintvews.codform%type, v_numgrup tintvews.numgrup%type) return number is
    v_count             number := 0;
  begin
    begin
      select count(numitem)
        into v_count
        from tintvewd
       where codform = v_codform
         and numgrup = v_numgrup;
    exception when no_data_found then
      null;
    end;
    return v_count;
  end get_qtyitem;

  procedure gen_tintvews (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select numgrup, qtyfscor,
             decode(global_v_lang, '101', desgrupe
                                 , '102', desgrupt
                                 , '103', desgrup3
                                 , '104', desgrup4
                                 , '105', desgrup5, desgrupe) desgrup
        from tintvews
       where codform = p_codform
       order by numgrup;

  begin
    obj_rows            := json_object_t();

    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numgrup', i.numgrup);
      obj_data.put('desc_grditem', i.desgrup);
      obj_data.put('qtyitem', get_qtyitem(p_codform, i.numgrup));
      obj_data.put('qtyfscor', i.qtyfscor);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_tintvews;
end HRRC3FE;

/
