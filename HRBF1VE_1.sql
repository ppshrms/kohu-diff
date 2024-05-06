--------------------------------------------------------
--  DDL for Package Body HRBF1VE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1VE" AS
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

    p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_dteappr           := to_date(hcm_util.get_string_t(json_obj, 'p_dteappr'), 'DD/MM/YYYY');
    p_codappr           := hcm_util.get_string_t(json_obj, 'p_codappr');
    p_amtoutstd         := hcm_util.get_string_t(json_obj, 'p_amtoutstd');
    p_qtyrepaym         := hcm_util.get_string_t(json_obj, 'p_qtyrepaym');
    p_amtrepaym         := hcm_util.get_string_t(json_obj, 'p_amtrepaym');
    p_qtypaid           := hcm_util.get_string_t(json_obj, 'p_qtypaid');
    p_amttotpay         := hcm_util.get_string_t(json_obj, 'p_amttotpay');
    p_dtestrpmp         := to_number(hcm_util.get_number_t(json_obj, 'p_dtestrpmp'));
    p_dtestrpmm         := to_number(hcm_util.get_number_t(json_obj, 'p_dtestrpmm'));
    p_dtestrpmy         := to_number(hcm_util.get_number_t(json_obj, 'p_dtestrpmy'));
    p_dtelstpayp        := to_number(hcm_util.get_number_t(json_obj, 'p_dtelstpayp'));
    p_dtelstpaym        := to_number(hcm_util.get_number_t(json_obj, 'p_dtelstpaym'));
    p_dtelstpayy        := to_number(hcm_util.get_number_t(json_obj, 'p_dtelstpayy'));
    p_amtlstpay         := hcm_util.get_string_t(json_obj, 'p_amtlstpay');
    p_dteclose          := to_date(hcm_util.get_string_t(json_obj, 'p_dteclose'), 'DD/MM/YYYY');
    p_amtclose          := hcm_util.get_string_t(json_obj, 'p_amtclose');
    p_remark            := hcm_util.get_string_t(json_obj, 'p_remark');
    -- report
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_staemp    temploy1.staemp%type;
  begin
    if p_codempid_query is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid_query, 'staemp');
      if v_staemp is not null then
        if v_staemp = '9' then
          param_msg_error := get_error_msg_php('HR2101', global_v_lang);
          return;
        elsif v_staemp = '0' then
          param_msg_error := get_error_msg_php('HR2102', global_v_lang);
          return;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end if;
    end if;
  end check_index;


  function explode(p_delimiter varchar2, p_string long, p_limit number default 1000) return arr_1d as
    v_str1        varchar2(4000 char);
    v_comma_pos   number := 0;
    v_start_pos   number := 1;
    v_loop_count  number := 0;

    arr_result    arr_1d;

  begin
    arr_result(1) := null;
    loop
      v_loop_count := v_loop_count + 1;
      if v_loop_count-1 = p_limit then
        exit;
      end if;
      v_comma_pos := to_number(nvl(instr(p_string,p_delimiter,v_start_pos),0));
      v_str1 := substr(p_string,v_start_pos,(v_comma_pos - v_start_pos));
      arr_result(v_loop_count) := v_str1;

      if v_comma_pos = 0 then
        v_str1 := substr(p_string,v_start_pos);
        arr_result(v_loop_count) := v_str1;
        exit;
      end if;
      v_start_pos := v_comma_pos + length(p_delimiter);
    end loop;
    return arr_result;
  end explode;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_data            json_object_t;
    isFoundData         varchar2(1 char) := 'N';
    arr_result          arr_1d;

  begin
    begin
      select dteappraj, codappraj, amtoutstd, qtyrepaym, amtrepaym,
             qtypaid, amttotpay, dtestrpm, dtelstpay, amtlstpay,
             dteclose, amtclose, remark2, flgclose
        into p_dteappr, p_codappr, p_amtoutstd, p_qtyrepaym, p_amtrepaym,
             p_qtypaid, p_amttotpay, p_dtestrpm, p_dtelstpay, p_amtlstpay,
             p_dteclose, p_amtclose, p_remark, p_flgclose
        from trepay
       where codempid = p_codempid_query;
      isFoundData := 'Y';
    exception when no_data_found then
      null;
    end;
    if isFoundData = 'Y' then
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteappr', to_char(p_dteappr, 'DD/MM/YYYY'));
      obj_data.put('codappr', p_codappr);
      obj_data.put('amtoutstd', p_amtoutstd);
      obj_data.put('qtyrepaym', p_qtyrepaym);
      obj_data.put('amtrepaym', p_amtrepaym);
      obj_data.put('qtypaid', p_qtypaid);
      obj_data.put('amttotpay', p_amttotpay);
      obj_data.put('dtestrpm', p_dtestrpm);
--      arr_result := explode('/', p_dtestrpm, 3);

      if p_dtestrpm is not null then
          obj_data.put('dtestrpmpo', substr(p_dtestrpm,7,1));
          obj_data.put('dtestrpmp', substr(p_dtestrpm,7,1));
          obj_data.put('dtestrpmmo', to_number(substr(p_dtestrpm,5,2)));
          obj_data.put('dtestrpmm', to_number(substr(p_dtestrpm,5,2)));
          obj_data.put('dtestrpmyo', substr(p_dtestrpm,1,4));
          obj_data.put('dtestrpmy', substr(p_dtestrpm,1,4));
      end if;
      obj_data.put('dtelstpay', p_dtelstpay);
--      arr_result := explode('/', p_dtelstpay, 3);
      if p_dtelstpay is not null then
          obj_data.put('dtelstpaypo', substr(p_dtelstpay,7,1));
          obj_data.put('dtelstpayp', substr(p_dtelstpay,7,1));
          obj_data.put('dtelstpaymo', to_number(substr(p_dtelstpay,5,2)));
          obj_data.put('dtelstpaym', to_number(substr(p_dtelstpay,5,2)));
          obj_data.put('dtelstpayyo', substr(p_dtelstpay,1,4));
          obj_data.put('dtelstpayy', substr(p_dtelstpay,1,4));
      end if;
      obj_data.put('amtlstpay', p_amtlstpay);
      obj_data.put('dteclose', to_char(p_dteclose, 'DD/MM/YYYY'));
      obj_data.put('amtclose', p_amtclose);
      obj_data.put('remark', p_remark);
      obj_data.put('flgclose', p_flgclose);

      if isInsertReport then
        insert_ttemprpt(
          p_dteappr,
          p_codappr,
          p_amtoutstd,
          p_qtyrepaym,
          p_amtrepaym,
          p_qtypaid,
          p_amttotpay,
          p_dtestrpm,
          p_dtelstpay,
          p_amtlstpay,
          p_dteclose,
          p_amtclose,
          p_remark,
          p_flgclose,
          (p_amtoutstd - p_amttotpay)
        );
      end if;

      if param_msg_error is null then
        json_str_output := obj_data.to_clob;
      else
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'trepay');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;

  procedure initial_save_value AS
  begin
    if p_dteclose is not null and p_amtclose is not null then
      p_flgclose := 'Y';
    else
      p_flgclose := 'N';
    end if;
--    p_dtestrpm  := to_char(p_dtestrpmy) ||'/'|| lpad(to_char(p_dtestrpmm), 2, '0') ||'/'|| to_char(p_dtestrpmp);
    p_dtestrpm  := to_char(p_dtestrpmy) || lpad(to_char(p_dtestrpmm), 2, '0') || to_char(p_dtestrpmp);

--    p_dtelstpay := to_char(p_dtelstpayy) ||'/'|| lpad(to_char(p_dtelstpaym), 2, '0') ||'/'|| to_char(p_dtelstpayp);
    p_dtelstpay := to_char(p_dtelstpayy) || lpad(to_char(p_dtelstpaym), 2, '0') || to_char(p_dtelstpayp);
  end initial_save_value;

  function chk_tdtepay(v_dteyear number, v_dtemonth number, v_period number) return varchar2 is
    v_check         varchar2(1 char);
  begin
    begin
      select 'Y'
        into v_check
        from tdtepay
       where codcompy   = hcm_util.get_codcomp_level(p_codcomp, 1)
         and typpayroll = p_typpayroll
         and dteyrepay  = v_dteyear
         and dtemthpay  = v_dtemonth
         and numperiod  = v_period;
    exception when no_data_found then
      null;
    end;
    if v_check is null then
      return get_error_msg_php('HR2055', global_v_lang, 'tdtepay');
    end if;
    return null;
  end chk_tdtepay;

  procedure check_save AS
    v_staemp            temploy1.staemp%type;
    v_zupdsal           varchar2(100 char);
    v_check             varchar2(500 char);
    v_approvno          number := 1;
    v_codpos            temploy1.codpos%type;
    v_chkapprov         boolean := false;
  begin
    if p_codempid_query is not null then
      begin
        select codcomp, typpayroll, codpos
          into p_codcomp, p_typpayroll, v_codpos
          from temploy1
         where codempid = p_codempid_query;
      exception when no_data_found then
        null;
      end;
      if p_codcomp is not null then
        if not secur_main.secur2(p_codempid_query, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;
    param_msg_error := chk_tdtepay(p_dtestrpmy, p_dtestrpmm, p_dtestrpmp);
    if param_msg_error is not null then
      return;
    end if;
    param_msg_error := chk_tdtepay(p_dtelstpayy, p_dtelstpaym, p_dtelstpayp);
    if param_msg_error is not null then
      return;
    end if;
    if p_codappr is not null then
      v_staemp := hcm_util.get_temploy_field(p_codappr, 'staemp');
      if v_staemp is not null then
        if v_staemp = '9' then
          param_msg_error := get_error_msg_php('HR2101', global_v_lang);
          return;
        elsif v_staemp = '0' then
          param_msg_error := get_error_msg_php('HR2102', global_v_lang);
          return;
        else
          v_chkapprov := chk_flowmail.check_approve('HRBF1VE', p_codempid_query, v_approvno, p_codappr, null, null, v_check);
          if not v_chkapprov then
            if v_check = 'HR2010' then
              param_msg_error := get_error_msg_php(v_check, global_v_lang, 'tfwmailc');
              return;
            else
              param_msg_error := get_error_msg_php('HR3008', global_v_lang);
              return;
            end if;
          end if;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end if;
    end if;
  end;

  procedure save_trepaylog (v_fldedit varchar2, v_desold varchar2, v_desnew varchar2) AS
  begin
    begin
      insert into trepaylog
             (codempid, dteedit, fldedit, desold, desnew, codcomp, dteupd, coduser, codcreate)
      values (p_codempid_query, sysdate, v_fldedit, v_desold, v_desnew, p_codcomp, sysdate, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      update trepaylog
         set desold   = v_desold,
             desnew   = v_desnew,
             codcomp  = p_codcomp,
             dteupd   = sysdate,
             coduser  = global_v_coduser
       where codempid = p_codempid_query
         and dteedit  = sysdate
         and fldedit  = v_fldedit;
    end;
  end save_trepaylog;

  procedure check_save_log AS
    v_dteappr           trepay.dteappr%type;
    v_codappr           trepay.codappr%type;
    v_amtoutstd         trepay.amtoutstd%type;
    v_qtyrepaym         trepay.qtyrepaym%type;
    v_amtrepaym         trepay.amtrepaym%type;
    v_qtypaid           trepay.qtypaid%type;
    v_amttotpay         trepay.amttotpay%type;
    v_dtestrpm          trepay.dtestrpm%type;
    v_dtelstpay         trepay.dtelstpay%type;
    v_amtlstpay         trepay.amtlstpay%type;
    v_dteclose          trepay.dteclose%type;
    v_amtclose          trepay.amtclose%type;
    v_remark            trepay.remark%type;
    v_flgclose          trepay.flgclose%type;
  begin
    begin
      select dteappraj, codappraj, amtoutstd, qtyrepaym, amtrepaym,
             qtypaid, amttotpay, dtestrpm, dtelstpay, amtlstpay,
             dteclose, amtclose, remark2, flgclose
        into v_dteappr, v_codappr, v_amtoutstd, v_qtyrepaym, v_amtrepaym,
             v_qtypaid, v_amttotpay, v_dtestrpm, v_dtelstpay, v_amtlstpay,
             v_dteclose, v_amtclose, v_remark, v_flgclose
        from trepay
       where codempid = p_codempid_query;
    exception when no_data_found then
      null;
    end;
    if nvl(to_char(v_dteappr, 'DD/MM/YYYY'), '@#$%') <> nvl(to_char(p_dteappr, 'DD/MM/YYYY'), '@#$%') then
      save_trepaylog('DTEAPPRAJ', to_char(v_dteappr, 'DD/MM/YYYY'), to_char(p_dteappr, 'DD/MM/YYYY'));
    end if;
    if nvl(v_codappr, '@#$%') <> nvl(p_codappr, '@#$%') then
      save_trepaylog('CODAPPRAJ', v_codappr, p_codappr);
    end if;
    if nvl(v_amtoutstd, 0) <> nvl(p_amtoutstd, 0) then
      save_trepaylog('AMTOUTSTD', v_amtoutstd, p_amtoutstd);
    end if;
    if nvl(v_qtyrepaym, 0) <> nvl(p_qtyrepaym, 0) then
      save_trepaylog('QTYREPAYM', v_qtyrepaym, p_qtyrepaym);
    end if;
    if nvl(v_amtrepaym, 0) <> nvl(p_amtrepaym, 0) then
      save_trepaylog('AMTREPAYM', v_amtrepaym, p_amtrepaym);
    end if;
    if nvl(v_qtypaid, 0) <> nvl(p_qtypaid, 0) then
      save_trepaylog('QTYPAID', v_qtypaid, p_qtypaid);
    end if;
    if nvl(v_amttotpay, 0) <> nvl(p_amttotpay, 0) then
      save_trepaylog('AMTTOTPAY', v_amttotpay, p_amttotpay);
    end if;
    if nvl(v_dtestrpm, '@#$%') <> nvl(p_dtestrpm, '@#$%') then
      save_trepaylog('DTESTRPM', v_dtestrpm, p_dtestrpm);
    end if;
    if nvl(v_dtelstpay, '@#$%') <> nvl(p_dtelstpay, '@#$%') then
      save_trepaylog('DTELSTPAY', v_dtelstpay, p_dtelstpay);
    end if;
    if nvl(v_amtlstpay, 0) <> nvl(p_amtlstpay, 0) then
      save_trepaylog('AMTLSTPAY', v_amtlstpay, p_amtlstpay);
    end if;
    if nvl(to_char(v_dteclose, 'DD/MM/YYYY'), '@#$%') <> nvl(to_char(p_dteclose, 'DD/MM/YYYY'), '@#$%') then
      save_trepaylog('DTECLOSE', to_char(v_dteclose, 'DD/MM/YYYY'), to_char(p_dteclose, 'DD/MM/YYYY'));
    end if;
    if nvl(v_amtclose, 0) <> nvl(p_amtclose, 0) then
      save_trepaylog('AMTCLOSE', v_amtclose, p_amtclose);
    end if;
    if nvl(v_remark, '@#$%') <> nvl(p_remark, '@#$%') then
      save_trepaylog('REMARK2', v_remark, p_remark);
    end if;
    if nvl(v_flgclose, '@#$%') <> nvl(p_flgclose, '@#$%') then
      save_trepaylog('FLGCLOSE', v_flgclose, p_flgclose);
    end if;
  end check_save_log;

  procedure save_trepay AS
  begin
    check_save_log;
    if param_msg_error is null then
      begin
        update trepay
           set dteappraj   = p_dteappr,
               codappraj   = p_codappr,
               amtoutstd   = p_amtoutstd,
               qtyrepaym   = p_qtyrepaym,
               amtrepaym   = p_amtrepaym,
               qtypaid     = p_qtypaid,
               amttotpay   = p_amttotpay,
               dtestrpm    = p_dtestrpm,
               dtelstpay   = p_dtelstpay,
               amtlstpay   = p_amtlstpay,
               dteclose    = p_dteclose,
               amtclose    = p_amtclose,
               remark2     = p_remark,
               flgclose    = p_flgclose,
               dteupd      = sysdate,
               coduser     = global_v_coduser
         where codempid    = p_codempid_query;
      exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
      end;
    end if;
  end save_trepay;

  procedure save_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    initial_save_value;
    check_save;
    if param_msg_error is null then
      save_trepay;
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
  end save_index;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  function get_ttemprpt_numseq (v_codapp varchar2) return number is
    v_numseq            number := 1;
  begin
    begin
      select nvl(max(numseq), 0) + 1
        into v_numseq
        from ttemprpt
       where codempid = global_v_codempid
         and codapp   = v_codapp;
    exception when no_data_found then
      null;
    end;
    return v_numseq;
  end;

  procedure insert_ttemprpt(
    v_dteappr             date,
    v_codappr             varchar2,
    v_amtoutstd           varchar2,
    v_qtyrepaym           varchar2,
    v_amtrepaym           varchar2,
    v_qtypaid             varchar2,
    v_amttotpay           varchar2,
    v_dtestrpm            varchar2,
    v_dtelstpay           varchar2,
    v_amtlstpay           varchar2,
    v_dteclose            date,
    v_amtclose            varchar2,
    v_remark              varchar2,
    v_flgclose            varchar2,
    v_amount              number
  ) is
    v_numseq              number := 1;
    b_dteappr             varchar2(100 char);
    b_dteclose            varchar2(100 char);
    b_amtclose            varchar2(100 char);
  begin
    v_numseq            := get_ttemprpt_numseq(p_codapp);
    if v_dteappr is null then
      b_dteappr          := ' ';
    else
      b_dteappr          := to_char(v_dteappr, 'dd/mm/') || (to_number(to_char(v_dteappr, 'yyyy')) + v_additional_year);
    end if;
    if v_dteclose is null then
      b_dteclose          := ' ';
    else
      b_dteclose          := to_char(v_dteclose, 'dd/mm/') || (to_number(to_char(v_dteclose, 'yyyy')) + v_additional_year);
    end if;
    if v_amtclose is null then
      b_amtclose          := ' ';
    else
      b_amtclose          := to_char(v_amtclose, 'fm99,999,990.90');
    end if;
    begin
      insert
        into ttemprpt
           (
             codempid, codapp, numseq,
             item1, item2, item3, item4, item5,
             item6, item7, item8, item9, item10,
             item11, item12, item13, item14, item15,
             item16, item17, item18
           )
      values
           (
             global_v_codempid, p_codapp, v_numseq,
             get_emp_img(p_codempid_query), -- item1
             p_codempid_query, -- item2
             get_temploy_name(p_codempid_query, global_v_lang), -- item3
             b_dteappr, -- item4
             v_codappr || ' - ' || get_temploy_name(v_codappr, global_v_lang), -- item5
             to_char(v_amtoutstd, 'fm99,999,990.90'), -- item6
             v_qtyrepaym, -- item7
             to_char(v_amtrepaym, 'fm99,999,990.90'), -- item8
             v_qtypaid, -- item9
             to_char(v_amttotpay, 'fm99,999,990.90'), -- item10
             substr(v_dtestrpm, 7, 2) || ' ' || get_tlistval_name('MONTH', to_number(substr(v_dtestrpm, 5, 2)), global_v_lang) || ' ' || to_char(to_number(substr(v_dtestrpm, 0, 4)) + v_additional_year), -- item11
             substr(v_dtelstpay, 7, 2) || ' ' || get_tlistval_name('MONTH', to_number(substr(v_dtelstpay, 5, 2)), global_v_lang) || ' ' || to_char(to_number(substr(v_dtelstpay, 0, 4)) + v_additional_year), -- item12
             to_char(v_amtlstpay, 'fm99,999,990.90'), -- item13
             b_dteclose, -- item14
             b_amtclose, -- item15
             nvl(v_remark, ' '), -- item16
             v_flgclose, -- item17
             to_char(v_amount, 'fm99,999,990.90') -- item18
           );
    exception when others then
      param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
    end;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt;

  procedure gen_report(json_str_input in clob, json_str_output out clob) is
    json_output       clob;
  begin
    initial_value(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
    end if;
    if param_msg_error is null then
      gen_index(json_output);
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end gen_report;
end HRBF1VE;

/
