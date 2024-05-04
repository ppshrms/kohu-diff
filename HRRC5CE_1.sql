--------------------------------------------------------
--  DDL for Package Body HRRC5CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC5CE" AS
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
    p_dtechg            := to_date(hcm_util.get_string_t(json_obj, 'p_dtechg'), 'DD/MM/YYYY');
    -- save detail
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');
    p_warning           := hcm_util.get_string_t(json_obj, 'p_warning');      --<<#7684
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcomp           temploy1.codcomp%type;
  begin
    if p_codempid is not null then
      begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = p_codempid
           and staemp   in ('1', '3', '9');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur3(v_codcomp, p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
  end check_index;

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
    obj_data            json_object_t;
    v_codempid          tcolltrl.codempid%type;
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
    v_status            tcolltrl.status%type;
    v_flgded            tcolltrl.flgded%type;
    v_qtyperiod         tcolltrl.qtyperiod%type;
    v_qtytranpy         tcolltrl.qtytranpy%type;
    v_amtdedcol         tcolltrl.amtdedcol%type;
    v_dtestrt           tcolltrl.dtestrt%type;
    v_dteend            tcolltrl.dteend%type;
    v_amtded            tcolltrl.amtded%type;
    v_staded            tcolltrl.staded%type;
    v_dtelstpay         tcolltrl.dtelstpay%type;
    v_remark            tcollchg.remark%type;
    v_dteappr           tcollchg.dteappr%type;
    v_codappr           tcollchg.codappr%type;

  begin
    begin
      select codempid, numcolla, numdocum, typcolla, stddec(amtcolla,codempid,v_chken), descoll, dtecolla,
             dtertdoc, dteeffec, filename, numrefdoc, dtechg, status, flgded,
             qtyperiod, qtytranpy, stddec(amtdedcol,codempid,v_chken), dtestrt, dteend, stddec(amtded,codempid,v_chken), staded, dtelstpay
        into v_codempid, v_numcolla, v_numdocum, v_typcolla, v_amtcolla, v_descoll, v_dtecolla,
             v_dtertdoc, v_dteeffec, v_filename, v_numrefdoc, v_dtechg, v_status, v_flgded,
             v_qtyperiod, v_qtytranpy, v_amtdedcol, v_dtestrt, v_dteend, v_amtded, v_staded, v_dtelstpay
        from tcolltrl
       where codempid = p_codempid
         and numcolla = p_numcolla;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tcolltrl');
      return;
    end;
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', v_codempid);
    obj_data.put('numcollao', v_numcolla);
    obj_data.put('numcolla', v_numcolla);
    obj_data.put('numdocumo', v_numdocum);
    obj_data.put('numdocum', v_numdocum);
    obj_data.put('typcollao', v_typcolla);
    obj_data.put('typcolla', v_typcolla);
    obj_data.put('amtcollao', v_amtcolla);
    obj_data.put('amtcolla', v_amtcolla);
    obj_data.put('descollo', v_descoll);
    obj_data.put('descoll', v_descoll);
    obj_data.put('dtecollao', to_char(v_dtecolla, 'DD/MM/YYYY'));
    obj_data.put('dtecolla', to_char(v_dtecolla, 'DD/MM/YYYY'));
    obj_data.put('dtertdoco', to_char(v_dtertdoc, 'DD/MM/YYYY'));
    obj_data.put('dtertdoc', to_char(v_dtertdoc, 'DD/MM/YYYY'));
    obj_data.put('dteeffeco', to_char(v_dteeffec, 'DD/MM/YYYY'));
    obj_data.put('dteeffec', to_char(v_dteeffec, 'DD/MM/YYYY'));
    obj_data.put('filenameo', v_filename);
    obj_data.put('filename', v_filename);
    obj_data.put('numrefdoco', v_numrefdoc);
    obj_data.put('numrefdoc', v_numrefdoc);
    obj_data.put('dtechgo', to_char(v_dtechg, 'DD/MM/YYYY'));
    obj_data.put('dtechg', to_char(v_dtechg, 'DD/MM/YYYY'));
    obj_data.put('statuso', v_status);
    obj_data.put('status', v_status);
    obj_data.put('flgdedo', v_flgded);
    obj_data.put('flgded', v_flgded);
    obj_data.put('qtyperiodo', v_qtyperiod);
    obj_data.put('qtyperiod', v_qtyperiod);
    obj_data.put('qtytranpyo', v_qtytranpy);
    obj_data.put('qtytranpy', v_qtytranpy);
    obj_data.put('amtdedcolo', v_amtdedcol);
    obj_data.put('amtdedcol', v_amtdedcol);
    obj_data.put('dtestrto', to_char(v_dtestrt, 'DD/MM/YYYY'));
    obj_data.put('dtestrt', to_char(v_dtestrt, 'DD/MM/YYYY'));
    obj_data.put('dteendo', to_char(v_dteend, 'DD/MM/YYYY'));
    obj_data.put('dteend', to_char(v_dteend, 'DD/MM/YYYY'));
    obj_data.put('amtdedo', v_amtded);
    obj_data.put('amtded', v_amtded);
    obj_data.put('stadedo', v_staded);
    obj_data.put('staded', v_staded);
--    obj_data.put('dtelstpayo', to_char(v_dtelstpay, 'DD/MM/YYYY'));
--    obj_data.put('dtelstpay', to_char(v_dtelstpay, 'DD/MM/YYYY'));
    obj_data.put('dtelstpayo', v_dtelstpay);
    obj_data.put('dtelstpay', v_dtelstpay);
    obj_data.put('remark', v_remark);
    obj_data.put('dteappr', to_char(nvl(v_dteappr, sysdate), 'DD/MM/YYYY'));
    obj_data.put('codappr', nvl(v_codappr, global_v_codempid));

    json_str_output := obj_data.to_clob;
  end gen_index;

  procedure check_save (v_codappr tcollchg.codappr%type, v_numcolla tcolltrl.numcolla%type,v_numcollao tcolltrl.numcolla%type,v_staded tcolltrl.staded%type) as   -- softberry || 13/02/2023 || #9091 ||   procedure check_save (v_codappr tcollchg.codappr%type, v_numcolla tcolltrl.numcolla%type,v_numcollao tcolltrl.numcolla%type,v_staded tcolltrl.staded%type) as  
    v_codcomp           temploy1.codcomp%type;
    b_numcolla          tcolltrl.numcolla%type;
    v_codjob            temploy1.codjob%type;
    b_amtcolla          number;
    v_amtcolla          number;
    n_amtcolla          number;
  begin
    if p_codempid is not null then
      begin
        select codcomp,codjob
          into v_codcomp,v_codjob
          from temploy1
         where codempid = v_codappr
           and staemp   in ('1', '3', '9');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur3(v_codcomp, v_codappr, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;

    if v_staded = 'Y' then
        begin
          select numcolla into b_numcolla
            from tcolltrl
           where codempid = p_codempid
             and numcolla <> v_numcolla
             and numcolla <> v_numcollao
             and flgded = 'Y'
             and status = 'A'
             and rownum   = 1;
          param_msg_error := replace(get_error_msg_php('RC0042', global_v_lang),'[P-NUMCOLLA]',b_numcolla);
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
      if b_amtcolla > v_amtcolla and (param_flgwarn != 'Y' or param_flgwarn is null) then  -- softberry || 13/02/2023 || #9091 || if b_amtcolla > v_amtcolla then   
        param_msg_error := replace(get_error_msg_php('RC0041', global_v_lang),'[P-AMTCOLLA]',to_char(b_amtcolla - v_amtcolla, 'fm9,999,990.90'));-- user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8766 || param_msg_error := replace(get_error_msg_php('RC0041', global_v_lang),'[P-AMTCOLLA]',to_char(v_amtcolla, 'fm9,999,990.90'));
        param_flgwarn := 'Y'; -- softberry || 13/02/2023 || #9091
        return;
      end if;
    end if; -- b_amtcolla is not null
  end check_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    v_numcolla          tcolltrl.numcolla%type;
    v_numcollao         tcolltrl.numcolla%type;
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
    v_amtdedcol         tcolltrl.amtdedcol%type;
    v_dtestrt           tcolltrl.dtestrt%type;
    v_dteend            tcolltrl.dteend%type;
    v_amtded            tcolltrl.amtded%type;
    v_staded            tcolltrl.staded%type;
    v_dtelstpay         tcolltrl.dtelstpay%type;
    v_remark            tcollchg.remark%type;
    v_dteappr           tcollchg.dteappr%type;
    v_codappr           tcollchg.codappr%type;
  begin
    initial_value(json_str_input);
    v_numcolla          := hcm_util.get_string_t(json_params, 'numcolla');
    v_numcollao         := hcm_util.get_string_t(json_params, 'numcollao');
    v_remark            := hcm_util.get_string_t(json_params, 'remark');
    v_dteappr           := to_date(hcm_util.get_string_t(json_params, 'dteappr'), 'DD/MM/YYYY');
    v_codappr           := hcm_util.get_string_t(json_params, 'codappr');
    v_flgded            := hcm_util.get_string_t(json_params, 'flgded');
    v_staded            := hcm_util.get_string_t(json_params, 'staded');
    param_flgwarn       := hcm_util.get_string_t(json_params,'flgwarning'); -- softberry || 13/02/2023 || #9091

--<< user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8766 ||     
    if v_staded <> 'Y' then
      v_flgded := 'N';
    end if;
-->> user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8766 || 
    check_save(v_codappr, v_numcolla,v_numcollao,v_staded);
    --<< softberry || 13/02/2023 || #9091
    if param_msg_error is not null then 
      json_str_output := get_response_message(null,param_msg_error,global_v_lang,param_flgwarn);
      return;
    end if;
    -->> softberry || 13/02/2023 || #9091

    if param_msg_error is null then
      begin
        select numdocum, typcolla, amtcolla, descoll, dtecolla,
               dtertdoc, dteeffec, filename, numrefdoc, dtechg, status, flgded,
               qtyperiod, qtytranpy, amtdedcol, dtestrt, dteend, amtded, staded, dtelstpay
          into v_numdocum, v_typcolla, v_amtcolla, v_descoll, v_dtecolla,
               v_dtertdoc, v_dteeffec, v_filename, v_numrefdoc, v_dtechg, v_status, v_flgded,
               v_qtyperiod, v_qtytranpy, v_amtdedcol, v_dtestrt, v_dteend, v_amtded, v_staded, v_dtelstpay
          from tcolltrl
         where codempid = p_codempid
           and numcolla = p_numcolla;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tcolltrl');
        return;
      end;

      begin
        insert into tcollchg
                    (codempid, numcollao, dtechg, numcollan, numdocum, typcolla, amtcolla, descolla,
                     filename, dtecolla, dtertdoc, dteeffec, remark, dteappr, codappr, dtecreate, codcreate, coduser)
             values (p_codempid, p_numcolla, nvl(v_dtechg, p_dtechg), v_numcolla, v_numdocum, v_typcolla, stddec(v_amtcolla,p_codempid,v_chken), v_descoll,
                     v_filename, v_dtecolla, v_dtertdoc, v_dteeffec, v_remark, v_dteappr, v_codappr, sysdate, global_v_coduser, global_v_coduser);

      exception when dup_val_on_index then
        update tcollchg
           set numcollan = v_numcolla,
               numdocum  = v_numdocum,
               typcolla  = v_typcolla,
--               amtcolla  = v_amtcolla,
               amtcolla  = stddec(v_amtcolla,codempid,v_chken),
               descolla  = v_descoll,
               filename  = v_filename,
               dtecolla  = v_dtecolla,
               dtertdoc  = v_dtertdoc,
               dteeffec  = v_dteeffec,
               remark    = v_remark,
               dteappr   = v_dteappr,
               codappr   = v_codappr,
               dteupd    = sysdate,
               coduser   = global_v_coduser
         where codempid  = p_codempid
           and numcollao = p_numcolla
           and dtechg    = nvl(v_dtechg, p_dtechg);
      end;

      v_numdocum          := hcm_util.get_string_t(json_params, 'numdocum');
      v_typcolla          := hcm_util.get_string_t(json_params, 'typcolla');
      v_amtcolla          := stdenc(hcm_util.get_string_t(json_params, 'amtcolla'),p_codempid,v_chken);
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
      v_amtdedcol         := stdenc(hcm_util.get_string_t(json_params, 'amtdedcol'),p_codempid,v_chken);
      v_dtestrt           := to_date(hcm_util.get_string_t(json_params, 'dtestrt'), 'DD/MM/YYYY');
      v_dteend            := to_date(hcm_util.get_string_t(json_params, 'dteend'), 'DD/MM/YYYY');
      v_amtded            := stdenc(hcm_util.get_string_t(json_params, 'amtded'),p_codempid,v_chken);
      v_staded            := hcm_util.get_string_t(json_params, 'staded');
--      v_dtelstpay         := to_date(hcm_util.get_string_t(json_params, 'dtelstpay'), 'DD/MM/YYYY');
      v_dtelstpay         := hcm_util.get_string_t(json_params, 'dtelstpay');
--<< user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8766 ||     
      if v_staded <> 'Y' then
        v_flgded := 'N';
      end if;
-->> user22 : 26/01/2023 : https://hrmsd.peopleplus.co.th:4448/redmine/issues/8766 || 
      if p_numcolla <> v_numcolla then
        begin
          insert into tcolltrl (
                 codempid, numcolla, numdocum, typcolla, amtcolla, descoll, dtecolla,
                 dtertdoc, dteeffec, filename, numrefdoc, dtechg, status, flgded,
                 qtyperiod, qtytranpy, amtdedcol, dtestrt, dteend, amtded, staded, dtelstpay,
                 dtecreate, codcreate, coduser
                )
          values (
                 p_codempid, v_numcolla, v_numdocum, v_typcolla, v_amtcolla, v_descoll, v_dtecolla,
                 v_dtertdoc, v_dteeffec, v_filename, v_numrefdoc, p_dtechg, v_status, v_flgded,
                 v_qtyperiod, v_qtytranpy, v_amtdedcol, v_dtestrt, v_dteend, v_amtded, v_staded, v_dtelstpay,
                 sysdate, global_v_coduser, global_v_coduser
                );
        exception when dup_val_on_index then
          param_msg_error := get_error_msg_php('HR2005', global_v_lang);
        end;

        begin
          update tcolltrl
             set status   = 'C',
                 coduser  = global_v_coduser,
                 dteupd   = sysdate
           where codempid = p_codempid
             and numcolla = p_numcolla;
        exception when others then
          null;
        end;
      else

        begin
          update tcolltrl
             set numdocum  = v_numdocum,
                 typcolla  = v_typcolla,
                 amtcolla  = v_amtcolla,
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
                 amtdedcol = v_amtdedcol,
                 dtestrt   = v_dtestrt,
                 dteend    = v_dteend,
                 amtded    = v_amtded,
                 staded    = v_staded,
                 dtelstpay = v_dtelstpay,
                 coduser   = global_v_coduser,
                 dteupd    = sysdate
           where codempid  = p_codempid
             and numcolla  = p_numcolla;

        exception when others then
          null;
        end;
      end if;
    end if;

    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_detail;
end HRRC5CE;

/
