--------------------------------------------------------
--  DDL for Package Body HRRC52E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC52E" AS
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

    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_numcolla          := hcm_util.get_string_t(json_obj, 'p_numcolla');
    -- save detail
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');
    p_warning           := hcm_util.get_string_t(json_obj, 'p_warning');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_staemp            temploy1.staemp%type;
  begin
    if p_codempid is not null then
      begin
        select staemp
          into v_staemp
          from temploy1
         where codempid = p_codempid
           and staemp   in ('1', '3', '9');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
  end check_index;

  function check_delete (v_numcolla tcolltrl.numcolla%type) return varchar2 is
    v_count               number := 0;
  begin
    begin
      select count(*)
        into v_count
        from tcolltrl
       where codempid = p_codempid
         and numcolla = v_numcolla
         and status   = 'A'
         and staded   = 'Y'
         and trunc(dtestrt) < trunc(sysdate)
         and trunc(dteend)  > trunc(sysdate);
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
      select numcolla, typcolla, amtcolla, numdocum
        from tcolltrl
       where codempid = p_codempid
       order by numcolla;

  begin
    obj_rows            := json_object_t();

    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numcolla', i.numcolla);
      obj_data.put('typcolla', i.typcolla);
      obj_data.put('desc_typcolla', get_tcodec_name('TCODCOLA', i.typcolla, global_v_lang));
      obj_data.put('amtcolla', stddec(i.amtcolla, p_codempid, v_chken));
      obj_data.put('numdocum', i.numdocum);
      obj_data.put('isDelete', check_delete(i.numcolla));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
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
    v_numcolla          tcolltrl.numcolla%type;
    v_numdocum          tcolltrl.numdocum%type;
    v_typcolla          tcolltrl.typcolla%type;
    v_amtcolla          tcolltrl.amtcolla%type;
    v_descoll           tcolltrl.descoll%type;
    v_dtecolla          tcolltrl.dtecolla%type;
    v_dtertdoc          tcolltrl.dtertdoc%type;
    v_dteeffec          tcolltrl.dteeffec%type;
    v_filename          tcolltrl.filename%type;
    v_numrefdoc         tcolltrl.numrefdoc%type;
    v_dtechg            tcolltrl.dtechg%type;
    v_status            tcolltrl.status%type := 'A';
    v_flgded            tcolltrl.flgded%type;
    v_qtyperiod         tcolltrl.qtyperiod%type;
    v_qtytranpy         tcolltrl.qtytranpy%type;
    v_amtdedcol         tcolltrl.amtdedcol%type;
    v_dtestrt           tcolltrl.dtestrt%type;
    v_dteend            tcolltrl.dteend%type;
    v_amtded            tcolltrl.amtded%type;
    v_staded            tcolltrl.staded%type;
    v_dtelstpay         tcolltrl.dtelstpay%type;
    v_codcreate         tcolltrl.codcreate%type;
    v_dtecreate         tcolltrl.dtecreate%type;
    v_dteupd            tcolltrl.dteupd%type;
    v_coduser           tcolltrl.coduser%type;
    v_codpos            temploy1.codpos%type;
    v_dteempmt          temploy1.dteempmt%type;

  begin
    begin
      select numdocum, typcolla, amtcolla, descoll, dtecolla, dtertdoc, dteeffec,
             filename, numrefdoc, dtechg, status, flgded, qtyperiod, qtytranpy,
             amtdedcol, dtestrt, dteend, amtded, staded, dtecreate, codcreate, dteupd, coduser
        into v_numdocum, v_typcolla, v_amtcolla, v_descoll, v_dtecolla, v_dtertdoc, v_dteeffec,
             v_filename, v_numrefdoc, v_dtechg, v_status, v_flgded, v_qtyperiod, v_qtytranpy,
             v_amtdedcol, v_dtestrt, v_dteend, v_amtded, v_staded, v_dtecreate, v_codcreate, v_dteupd, v_coduser
        from tcolltrl
       where codempid = p_codempid
         and numcolla = p_numcolla;
    exception when no_data_found then
      null;
    end;
    begin
      select dteempmt, codpos
        into v_dteempmt, v_codpos
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      null;
    end;
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid);
    obj_data.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
    obj_data.put('numcolla', p_numcolla);
    obj_data.put('numdocum', v_numdocum);
    obj_data.put('typcolla', v_typcolla);
    obj_data.put('amtcolla', stddec(v_amtcolla, p_codempid, v_chken));
    obj_data.put('descoll', v_descoll);
    obj_data.put('dtecolla', to_char(v_dtecolla, 'DD/MM/YYYY'));
    obj_data.put('dtertdoc', to_char(v_dtertdoc, 'DD/MM/YYYY'));
    obj_data.put('dteeffec', to_char(v_dteeffec, 'DD/MM/YYYY'));
    obj_data.put('filename', v_filename);
    obj_data.put('numrefdoc', v_numrefdoc);
    obj_data.put('dtechg', to_char(v_dtechg, 'DD/MM/YYYY'));
    obj_data.put('status', v_status);
    obj_data.put('flgded', v_flgded);
    obj_data.put('qtyperiod', v_qtyperiod);
    obj_data.put('qtytranpy', v_qtytranpy);
    obj_data.put('amtdedcol', stddec(v_amtdedcol, p_codempid, v_chken));
    obj_data.put('dteempmt', to_char(v_dteempmt, 'DD/MM/YYYY'));
    obj_data.put('dtestrt', to_char(v_dtestrt, 'DD/MM/YYYY'));
    obj_data.put('dteend', to_char(v_dteend, 'DD/MM/YYYY'));
    obj_data.put('amtded', stddec(v_amtded, p_codempid, v_chken));
    obj_data.put('staded', v_staded);
    obj_data.put('dtelstpay', v_dtelstpay);
    obj_data.put('dteupd', to_char(nvl(v_dteupd, v_dtecreate), 'DD/MM/YYYY'));
    obj_data.put('coduser', get_codempid(nvl(v_coduser, v_codcreate)));

    json_str_output := obj_data.to_clob;
  end gen_detail;

  procedure save_index (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_flg               varchar2(10 char);
    v_count             number := 0;
    v_sum               number := 0;
  begin
    initial_value(json_str_input);
    for i in 0 .. json_params.get_size - 1 loop
      obj_data            := hcm_util.get_json_t(json_params, to_char(i));
      v_flg               := hcm_util.get_string_t(obj_data, 'flg');
      p_numcolla          := hcm_util.get_string_t(obj_data, 'numcolla');
      if param_msg_error is null then
        if v_flg = 'delete' then
          begin
            delete from tcolltrl
             where codempid = p_codempid
               and numcolla = p_numcolla;
            begin
              select count(numcolla), sum(stddec(amtcolla, p_codempid, v_chken))
                into v_count, v_sum
                from tcolltrl
               where codempid = p_codempid;
            exception when no_data_found then
              v_count     := 0;
              v_sum       := 0;
            end;
            update ttotguar
               set qtycolla = v_count,
                   amtcolla = stdenc(v_sum, p_codempid, v_chken),
                   dteupd   = sysdate,
                   coduser  = global_v_coduser
             where codempid = p_codempid;
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

  procedure check_save is
    v_staemp            temploy1.staemp%type;
    v_numcolla          tcolltrl.numcolla%type;
    v_codjob            temploy1.codjob%type;
    b_amtcolla          number;
    v_amtcolla          number;
    n_amtcolla          number;
  begin
    if p_codempid is not null then
      begin
        select staemp, codcomp, codpos, codjob
          into v_staemp, p_codcomp, p_codpos,v_codjob
          from temploy1
         where codempid = p_codempid
           and staemp   in ('1', '3', '9');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;

    if p_staded = 'Y' then -- user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8766 || 
      begin
        select numcolla
          into v_numcolla
          from tcolltrl
         where codempid = p_codempid
           and numcolla <> p_numcolla
           and staded   = 'Y'
           and status   = 'A'
           and rownum   = 1;
        param_msg_error := replace(get_error_msg_php('RC0042', global_v_lang),'[P-NUMCOLLA]',v_numcolla);
        return;
      exception when no_data_found then null;
      end;
    end if;
    --
    begin
      select amtcolla
        into b_amtcolla
        from tjobcode
       where codjob = v_codjob;
    exception when no_data_found then
      b_amtcolla  := 0;
    end;
    --
    if b_amtcolla is not null then
      begin
        select sum(stddec(amtcolla, p_codempid, v_chken))
          into v_amtcolla
          from tcolltrl
         where codempid    = p_codempid
           and numcolla   <> p_numcolla;
      end;
      n_amtcolla := to_number(hcm_util.get_string_t(json_params, 'amtcolla'));
      v_amtcolla := nvl(v_amtcolla,0) + nvl(n_amtcolla,0);
      --
      if b_amtcolla > v_amtcolla and (param_flgwarn != 'Y' or param_flgwarn is null) then -- softberry || 14/02/2023 || #9091 || if b_amtcolla > v_amtcolla then   
        param_msg_error := replace(get_error_msg_php('RC0041', global_v_lang),'[P-AMTCOLLA]',to_char(b_amtcolla - v_amtcolla, 'fm9,999,990.90'));-- user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8766 || param_msg_error := replace(get_error_msg_php('RC0041', global_v_lang),'[P-AMTCOLLA]',to_char(v_amtcolla, 'fm9,999,990.90'));
        param_flgwarn := 'Y'; -- softberry || 14/02/2023 || #9091
        return; -- softberry || 7/03/2023 || #9091
      end if;
    end if; -- b_amtcolla is not null
  end check_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_tmp             json_object_t;
    v_numdocum          tcolltrl.numdocum%type;
    v_typcolla          tcolltrl.typcolla%type;
    v_amtcolla          tcolltrl.amtcolla%type;
    v_descoll           tcolltrl.descoll%type;
    v_dtecolla          tcolltrl.dtecolla%type;
    v_dtertdoc          tcolltrl.dtertdoc%type;
    v_dteeffec          tcolltrl.dteeffec%type;
    v_filename          tcolltrl.filename%type;
    v_numrefdoc         tcolltrl.numrefdoc%type;
    v_dtechg            tcolltrl.dtechg%type;
    v_status            tcolltrl.status%type;
    v_flgded            tcolltrl.flgded%type;
    v_qtyperiod         tcolltrl.qtyperiod%type;
    v_qtytranpy         tcolltrl.qtytranpy%type;
    v_dtestrt           tcolltrl.dtestrt%type;
    v_dteend            tcolltrl.dteend%type;
    v_amtded            tcolltrl.amtded%type;
    v_staded            tcolltrl.staded%type;
    v_dtelstpay         tcolltrl.dtelstpay%type;
    v_amtdedcol         tcolltrl.amtdedcol%type;
    v_count             number := 0;
    v_sum               number := 0;
    v_amt               tjobcode.amtcolla%type;
  begin
    initial_value(json_str_input);
    p_numcolla          := hcm_util.get_string_t(json_params, 'numcolla');
    v_numdocum          := hcm_util.get_string_t(json_params, 'numdocum');
    v_typcolla          := hcm_util.get_string_t(json_params, 'typcolla');
    v_amtcolla          := to_number(hcm_util.get_string_t(json_params, 'amtcolla'));
    v_descoll           := hcm_util.get_string_t(json_params, 'descoll');
    v_dtecolla          := to_date(hcm_util.get_string_t(json_params, 'dtecolla'), 'DD/MM/YYYY');
    v_dtertdoc          := to_date(hcm_util.get_string_t(json_params, 'dtertdoc'), 'DD/MM/YYYY');
    v_dteeffec          := to_date(hcm_util.get_string_t(json_params, 'dteeffec'), 'DD/MM/YYYY');
    v_filename          := hcm_util.get_string_t(json_params, 'filename');
    v_numrefdoc         := hcm_util.get_string_t(json_params, 'numrefdoc');
    v_dtechg            := to_date(hcm_util.get_string_t(json_params, 'dtechg'), 'DD/MM/YYYY');
    v_status            := hcm_util.get_string_t(json_params, 'status');
    v_flgded            := hcm_util.get_string_t(json_params, 'flgded');
    v_qtyperiod         := hcm_util.get_string_t(json_params, 'qtyperiod');
    v_qtytranpy         := hcm_util.get_string_t(json_params, 'qtytranpy');
    v_dtestrt           := to_date(hcm_util.get_string_t(json_params, 'dtestrt'), 'DD/MM/YYYY');
    v_dteend            := to_date(hcm_util.get_string_t(json_params, 'dteend'), 'DD/MM/YYYY');
--    v_amtded            := to_number(hcm_util.get_string_t(json_params, 'amtded')); --#7829
--    v_amtdedcol         := to_number(hcm_util.get_string_t(json_params, 'amtdedcol'));--#7829
    v_amtded            := hcm_util.get_string_t(json_params, 'amtded');
    v_amtdedcol         := hcm_util.get_string_t(json_params, 'amtdedcol');
    v_staded            := hcm_util.get_string_t(json_params, 'staded');--User37 #4383 2. RC Module 04/01/2022  v_staded            := hcm_util.get_string_t(json_params, 'staded');
    --
    param_flgwarn       := hcm_util.get_string_t(json_params,'flgwarning'); -- softberry || 14/02/2023 || #9091
--<< user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8766 ||     
    p_staded := v_staded;
    if v_staded <> 'Y' then
      v_flgded := 'N';
    end if;
-->> user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8766 || 
    check_save;
    --<< softberry || 14/02/2023 || #9091
    if param_msg_error is not null  then 
      json_str_output := get_response_message(null,param_msg_error,global_v_lang,param_flgwarn);
      return;
    end if;
    -->> softberry || 14/02/2023 || #9091    
    --
    if param_msg_error is null then
      begin
        insert into tcolltrl
               (codempid, numcolla, numdocum, typcolla, amtcolla, descoll,
                dtecolla, dtertdoc, dteeffec, filename, numrefdoc, dtechg,
                status, flgded, qtyperiod, qtytranpy, dtestrt, dteend,
                amtded, amtdedcol, staded, dtecreate, codcreate, coduser)
        values (p_codempid, p_numcolla, v_numdocum, v_typcolla, stdenc(v_amtcolla, p_codempid, v_chken), v_descoll,
                v_dtecolla, v_dtertdoc, v_dteeffec, v_filename, v_numrefdoc, v_dtechg,
                v_status, v_flgded, v_qtyperiod, v_qtytranpy, v_dtestrt, v_dteend,
                stdenc(v_amtded, p_codempid, v_chken), stdenc(v_amtdedcol, p_codempid, v_chken), v_staded, sysdate, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        update tcolltrl
           set numdocum  = v_numdocum,
               typcolla  = v_typcolla,
               amtcolla  = stdenc(v_amtcolla, p_codempid, v_chken),
               descoll   = v_descoll,
               dtecolla  = v_dtecolla,
               dtertdoc  = v_dtertdoc,
               dteeffec  = v_dteeffec,
               filename  = v_filename,
               numrefdoc = v_numrefdoc,
               dtechg    = v_dtechg,
               status    = v_status,
               flgded    = v_flgded,
               qtyperiod = v_qtyperiod,
               qtytranpy = v_qtytranpy,
               dtestrt   = v_dtestrt,
               dteend    = v_dteend,
               amtded    = stdenc(v_amtded, p_codempid, v_chken),
               amtdedcol = stdenc(v_amtdedcol, p_codempid, v_chken),
               staded    = v_staded,
--               dtelstpay = v_dtelstpay,
               dteupd    = sysdate,
               coduser   = global_v_coduser
         where codempid  = p_codempid
           and numcolla  = p_numcolla;
      end;
    end if;
    if param_msg_error is null then
      begin
        insert into ttotguar (codempid, codcomp, codpos, qtycolla, amtcolla, dtecreate, codcreate, coduser)
        values (p_codempid, p_codcomp, p_codpos, 1, stdenc(v_amtcolla, p_codempid, v_chken), sysdate, global_v_coduser, global_v_coduser);
        v_sum         := v_amtcolla;
      exception when dup_val_on_index then
        begin
          select count(numcolla), sum(stddec(amtcolla, p_codempid, v_chken))
            into v_count, v_sum
            from tcolltrl
           where codempid = p_codempid
             and status = 'A';
        exception when no_data_found then
          v_count     := 1;
          v_sum       := v_amtcolla;
        end;
        update ttotguar
           set qtycolla = v_count,
               amtcolla = stdenc(v_sum, p_codempid, v_chken),
               dteupd   = sysdate,
               coduser  = global_v_coduser
         where codempid = p_codempid;
      end;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      if p_warning = 'W' then
        rollback;
        obj_tmp         := json_object_t(get_response_message('200', param_msg_error, global_v_lang));
        obj_tmp.put('warning', p_warning);
        json_str_output := obj_tmp.to_clob;
      else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    end if;
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;
end HRRC52E;

/
