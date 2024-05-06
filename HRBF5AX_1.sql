--------------------------------------------------------
--  DDL for Package Body HRBF5AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF5AX" AS
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
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_numcont           := hcm_util.get_string_t(json_obj, 'p_numcont');
    -- report
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');
    p_codapp            := upper(hcm_util.get_string_t(json_obj, 'p_codapp'));
    p_additional_year   := to_number(hcm_appsettings.get_additional_year);

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  function get_date_output (v_dteinput varchar2) return varchar2 is
    v_dteout          date;
  begin
    v_dteout          := to_date(v_dteinput, 'DD/MM/YYYY');
    return to_char(v_dteout, 'DD/MM/') || (to_number(to_char(v_dteout, 'YYYY')) + p_additional_year);
  end get_date_output;

  procedure check_index AS
    v_codcomp           temploy1.codcomp%type;
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcomp
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
    v_found             boolean := false;

    cursor c1 is
      select a.dtelonst, a.numcont, a.codempid, a.codcomp, a.codlon,
             a.amtlon, a.stalon, a.staappr, a.dteappr, a.codappr,
             b.numlvl, a.qtyperiod, a.qtyperip, a.rowid
        from tloaninf a, temploy1 b
       where a.codcomp  like p_codcomp || '%'
         and a.codempid = b.codempid
         and a.dtelonst between p_dtestrt and p_dteend
       order by a.dtelonst;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      v_found     := true;
      if secur_main.secur1(i.codcomp, i.numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('dtelonst', to_char(i.dtelonst, 'DD/MM/YYYY'));
        obj_data.put('numcont', i.numcont);
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('codlon', i.codlon);
        obj_data.put('desc_codlon', get_ttyplone_name(i.codlon, global_v_lang));
        obj_data.put('amtlon', i.amtlon);
        obj_data.put('stalon', i.stalon);
        obj_data.put('desc_stalon', get_tlistval_name('STALOAN', i.stalon, global_v_lang));
        obj_data.put('qtyperiod', i.qtyperiod);
        obj_data.put('qtyperip', nvl(i.qtyperip, 0));
        obj_data.put('staappr', i.staappr);
        obj_data.put('desc_staappr', get_tlistval_name('ESSTAREQ', i.staappr, global_v_lang));
        obj_data.put('dteappr', to_char(i.dteappr, 'DD/MM/YYYY'));
        obj_data.put('codappr', i.codappr);
        obj_data.put('desc_codappr', get_temploy_name(i.codappr, global_v_lang));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;
    if v_found then
      if obj_rows.get_size > 0 then
        json_str_output := obj_rows.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tloaninf');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
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
    v_found             boolean := false;

    cursor c1 is
      select codempid, numcont, codlon, typintr, rateilon, numlon, amtlon, formula,
             dtelonst, dtelonen, dteissue, dtestcal, typpayamt, dteyrpay, mthpay, prdpay,
             reaslon, typpay, amtiflat, amttlpay, amtpaybo, qtyperiod, codreq, stalon,
             amtnpfin, dteaccls, dtelpay, desaccls, dteappr, codappr, qtyperip
        from tloaninf
       where codempid = p_codempid
         and numcont  = p_numcont;
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', '');
    obj_data.put('numcont', '');
    obj_data.put('codlon', '');
    obj_data.put('desc_codlon', '');
    obj_data.put('typintr', '');
    obj_data.put('desc_typintr', '');
    obj_data.put('rateilon', '');
    obj_data.put('yrenumlon', '');
    obj_data.put('mthnumlon', '');
    obj_data.put('amtlon', '');
    obj_data.put('desc_formula', '');
    obj_data.put('dtelonst', '');
    obj_data.put('dtelonen', '');
    obj_data.put('dteissue', '');
    obj_data.put('dtestcal', '');
    obj_data.put('typpayamt', '');
    obj_data.put('desc_typpayamt', '');
    obj_data.put('dteyrpay', '');
    obj_data.put('mthpay', '');
    obj_data.put('prdpay', '');
    obj_data.put('reaslon', '');
    obj_data.put('typpay', '');
    obj_data.put('desc_typpay', '');
    obj_data.put('amtiflat', '');
    obj_data.put('amttlpay', '');
    obj_data.put('amtpaybo', '');
    obj_data.put('qtyperiod', '');
    obj_data.put('qtyperip', '');
    obj_data.put('codreq', '');
    obj_data.put('stalon', '');
    obj_data.put('desc_stalon', '');
    obj_data.put('amtnpfin', '');
    obj_data.put('dteaccls', '');
    obj_data.put('dtelpay', '');
    obj_data.put('desaccls', '');
    obj_data.put('yrelaw', '');
    obj_data.put('dteappr', '');
    obj_data.put('codappr', '');
    obj_data.put('desc_codappr', '');
    for i in c1 loop
      v_found     := true;
      obj_data.put('codempid', i.codempid);
      obj_data.put('numcont', i.numcont);
      obj_data.put('codlon', i.codlon);
      obj_data.put('desc_codlon', get_ttyplone_name(i.codlon, global_v_lang));
      obj_data.put('typintr', i.typintr);
      obj_data.put('desc_typintr', get_tlistval_name('TYPINTREST', i.typintr, global_v_lang));
      obj_data.put('rateilon', i.rateilon);
      obj_data.put('yrenumlon', floor(i.numlon / 12));
      obj_data.put('mthnumlon', mod(i.numlon, 12));
      obj_data.put('amtlon', i.amtlon);
      obj_data.put('desc_formula', hcm_formula.get_description(i.formula, global_v_lang));
      obj_data.put('dtelonst', to_char(i.dtelonst, 'DD/MM/YYYY'));
      obj_data.put('dtelonen', to_char(i.dtelonen, 'DD/MM/YYYY'));
      obj_data.put('dteissue', to_char(i.dteissue, 'DD/MM/YYYY'));
      obj_data.put('dtestcal', to_char(i.dtestcal, 'DD/MM/YYYY'));
      obj_data.put('typpayamt', i.typpayamt);
      obj_data.put('desc_typpayamt', get_tlistval_name('LOANPAYMT', i.typpayamt, global_v_lang));
      obj_data.put('dteyrpay', i.dteyrpay);
      obj_data.put('mthpay', i.mthpay);
      obj_data.put('prdpay', i.prdpay);
      obj_data.put('reaslon', i.reaslon);
      obj_data.put('typpay', i.typpay);
      obj_data.put('desc_typpay', get_tlistval_name('LOANPAYMT2', i.typpay, global_v_lang));
      obj_data.put('amtiflat', i.amtiflat);
      obj_data.put('amttlpay', i.amttlpay);
      obj_data.put('amtpaybo', i.amtpaybo);
      obj_data.put('qtyperiod', i.qtyperiod);
      obj_data.put('qtyperip', i.qtyperip);
      obj_data.put('codreq', i.codreq);
      obj_data.put('stalon', i.stalon);
      obj_data.put('desc_stalon', get_tlistval_name('STALOAN', i.stalon, global_v_lang));
      obj_data.put('amtnpfin', i.amtnpfin);
      obj_data.put('dteaccls', to_char(i.dteaccls, 'DD/MM/YYYY'));
      obj_data.put('dtelpay', to_char(i.dtelpay, 'DD/MM/YYYY'));
      obj_data.put('desaccls', i.desaccls);
      obj_data.put('yrelaw', '0');
      obj_data.put('dteappr', to_char(i.dteappr, 'DD/MM/YYYY'));
      obj_data.put('codappr', i.codappr);
      obj_data.put('desc_codappr', i.codappr || ' - ' || get_temploy_name(i.codappr, global_v_lang));
    end loop;

    if isInsertReport then
      insert_ttemprpt('tloaninf', obj_data.to_clob);
    end if;
    if v_found then
      json_str_output := obj_data.to_clob;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tloaninf');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_detail;

  procedure get_tloancol (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tloancol(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tloancol;

  procedure gen_tloancol (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select numcont, codcolla, amtcolla, numrefer, descolla
        from tloancol
       where numcont  = p_numcont
       order by codcolla;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('numcont', i.numcont);
      obj_data.put('codcolla', i.codcolla);
      obj_data.put('desc_codcolla', get_tcodec_name('TCODCOLA', i.codcolla, global_v_lang));
      obj_data.put('amtcolla', i.amtcolla);
      obj_data.put('numrefer', i.numrefer);
      obj_data.put('descolla', i.descolla);

      if isInsertReport then
        insert_ttemprpt('tloancol', obj_data.to_clob);
      end if;

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_tloancol;

  procedure get_tloangar (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tloangar(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tloangar;

  procedure gen_tloangar (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    p_year              number := 0;
    p_month             number := 0;
    p_day               number := 0;

    cursor c1 is
      select codempgar, codcomp, codpos, dteempmt, amtgar
        from tloangar, temploy1
       where numcont   = p_numcont
         and codempgar = codempid;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      get_service_year(i.dteempmt, sysdate, 'Y', p_year, p_month, p_day);
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('image', get_emp_img(i.codempgar));
      obj_data.put('codempgar', i.codempgar);
      obj_data.put('desc_codempgar', get_temploy_name(i.codempgar, global_v_lang));
      obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
      obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
      obj_data.put('qtywork', p_year || '(' || p_month || ')');
      obj_data.put('amount', i.amtgar);

      if isInsertReport then
        insert_ttemprpt('tloangar', obj_data.to_clob);
      end if;

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_tloangar;

  procedure initial_report (json_obj json_object_t) AS
  begin
    p_codempid          := hcm_util.get_string_t(json_obj, 'codempid');
    p_numcont           := hcm_util.get_string_t(json_obj, 'numcont');
  end initial_report;

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
  end get_ttemprpt_numseq;

  procedure insert_ttemprpt(v_table varchar2, json_str_input clob) is
    obj_data              json_object_t;
    v_numseq              number := 1;
    v_desc_codlon         ttemprpt.item5%type;
    v_desc_typintr        ttemprpt.item6%type;
    v_rateilon            ttemprpt.item7%type;
    v_yrenumlon           ttemprpt.item8%type;
    v_mthnumlon           ttemprpt.item9%type;
    v_amtlon              ttemprpt.item10%type;
    v_desc_formula        ttemprpt.item11%type;
    v_dtelonst            ttemprpt.item12%type;
    v_dtelonen            ttemprpt.item13%type;
    v_dteissue            ttemprpt.item14%type;
    v_dtestcal            ttemprpt.item15%type;
    v_desc_typpayamt      ttemprpt.item16%type;
    v_period              ttemprpt.item17%type;
    v_desc_typpay         ttemprpt.item18%type;
    v_amtiflat            ttemprpt.item19%type;
    v_amttlpay            ttemprpt.item20%type;
    v_amtpaybo            ttemprpt.item21%type;
    v_qtyperiod           ttemprpt.item22%type;
    v_desc_stalon         ttemprpt.item23%type;
    v_amtnpfin            ttemprpt.item24%type;
    v_dteaccls            ttemprpt.item25%type;
    v_dtelpay             ttemprpt.item26%type;
    v_desaccls            ttemprpt.item27%type;
    v_yrelaw              ttemprpt.item28%type;
    v_dteappr             ttemprpt.item29%type;
    v_desc_codappr        ttemprpt.item30%type;
    v_desc_codreq         ttemprpt.item31%type;
    v_qtyperip            ttemprpt.item32%type;
    v_seqno               ttemprpt.item4%type;
    v_codcolla            ttemprpt.item5%type;
    v_desc_codcolla       ttemprpt.item6%type;
    v_amtcolla            ttemprpt.item7%type;
    v_numrefer            ttemprpt.item8%type;
    v_descolla            ttemprpt.item9%type;
    v_codempgar           ttemprpt.item5%type;
    v_desc_codempgar      ttemprpt.item6%type;
    v_desc_codpos         ttemprpt.item7%type;
    v_desc_codcomp        ttemprpt.item8%type;
    v_qtywork             ttemprpt.item9%type;
    v_amount              ttemprpt.item10%type;
  begin
    obj_data            := json_object_t(json_str_input);
    if v_table = 'tloaninf' then
      v_numseq            := get_ttemprpt_numseq(p_codapp);
      v_dtelonst          := get_date_output(hcm_util.get_string_t(obj_data, 'dtelonst'));
      v_dtelonen          := get_date_output(hcm_util.get_string_t(obj_data, 'dtelonen'));
      v_dteissue          := get_date_output(hcm_util.get_string_t(obj_data, 'dteissue'));
      v_dtestcal          := get_date_output(hcm_util.get_string_t(obj_data, 'dtestcal'));
      v_dteaccls          := get_date_output(hcm_util.get_string_t(obj_data, 'dteaccls'));
      v_dtelpay           := get_date_output(hcm_util.get_string_t(obj_data, 'dtelpay'));
      v_dteappr           := get_date_output(hcm_util.get_string_t(obj_data, 'dteappr'));
      v_desc_codlon       := hcm_util.get_string_t(obj_data, 'codlon') || ' - ' || hcm_util.get_string_t(obj_data, 'desc_codlon');
      v_desc_typintr      := hcm_util.get_string_t(obj_data, 'typintr') || ' - ' || hcm_util.get_string_t(obj_data, 'desc_typintr');
      v_rateilon          := to_char(hcm_util.get_string_t(obj_data, 'rateilon'), 'fm99,999,990.90');
      v_yrenumlon         := hcm_util.get_string_t(obj_data, 'yrenumlon');
      v_mthnumlon         := hcm_util.get_string_t(obj_data, 'mthnumlon');
      v_amtlon            := to_char(hcm_util.get_string_t(obj_data, 'amtlon'), 'fm99,999,990.90');
      v_desc_formula      := hcm_util.get_string_t(obj_data, 'desc_formula');
      v_desc_typpayamt    := hcm_util.get_string_t(obj_data, 'desc_typpayamt');
      v_period            := hcm_util.get_string_t(obj_data, 'prdpay') || ' ' || get_tlistval_name('MONTH', to_number(hcm_util.get_string_t(obj_data, 'mthpay')), global_v_lang) || ' ' || to_char(to_number(hcm_util.get_string_t(obj_data, 'dteyrpay')) + p_additional_year);
      v_desc_typpay       := hcm_util.get_string_t(obj_data, 'desc_typpay');
      v_desc_stalon       := hcm_util.get_string_t(obj_data, 'desc_stalon');
      v_amtiflat          := to_char(hcm_util.get_string_t(obj_data, 'amtiflat'), 'fm99,999,990.90');
      v_amttlpay          := to_char(hcm_util.get_string_t(obj_data, 'amttlpay'), 'fm99,999,990.90');
      v_amtpaybo          := to_char(hcm_util.get_string_t(obj_data, 'amtpaybo'), 'fm99,999,990.90');
      v_qtyperiod         := hcm_util.get_string_t(obj_data, 'qtyperiod');
      v_amtnpfin          := to_char(hcm_util.get_string_t(obj_data, 'amtnpfin'), 'fm99,999,990.90');
      v_desaccls          := hcm_util.get_string_t(obj_data, 'desaccls');
      v_yrelaw            := hcm_util.get_string_t(obj_data, 'yrelaw');
      v_desc_codappr      := hcm_util.get_string_t(obj_data, 'desc_codappr');
      v_desc_codreq       := hcm_util.get_string_t(obj_data, 'codreq');
      v_desc_codreq       := v_desc_codreq || ' - ' || get_temploy_name(v_desc_codreq, global_v_lang);
      v_qtyperip          := hcm_util.get_string_t(obj_data, 'qtyperip');
      begin
        insert
          into ttemprpt
            (
              codempid, codapp, numseq,
              item1, item2, item3, item4, item5,
              item6, item7, item8, item9, item10,
              item11, item12, item13, item14, item15,
              item16, item17, item18, item19, item20,
              item21, item22, item23, item24, item25,
              item26, item27, item28, item29, item30,
              item31, item32
            )
        values
            (
              global_v_codempid, p_codapp, v_numseq,
              get_emp_img(p_codempid), -- item1
              p_codempid, -- item2
              p_numcont, -- item3
              get_temploy_name(p_codempid, global_v_lang), -- item4
              v_desc_codlon, -- item5 as desc_codlon
              v_desc_typintr, -- item6 as desc_typintr
              v_rateilon, -- item7 as rateilon
              v_yrenumlon, -- item8 as yrenumlon
              v_mthnumlon, -- item9 as mthnumlon
              v_amtlon, -- item10 as amtlon
              v_desc_formula, -- item11 as desc_formula
              v_dtelonst, -- item12 as dtelonst
              v_dtelonen, -- item13 as dtelonen
              v_dteissue, -- item14 as dteissue
              v_dtestcal, -- item15 as dtestcal
              v_desc_typpayamt, -- item16 as desc_typpayamt
              v_period, -- item17 as period
              v_desc_typpay, -- item18 as desc_typpay
              v_amtiflat, -- item19 as amtiflat
              v_amttlpay, -- item20 as amttlpay
              v_amtpaybo, -- item21 as amtpaybo
              v_qtyperiod, -- item22 as qtyperiod
              v_desc_stalon, -- item23 as desc_stalon
              v_amtnpfin, -- item24 as amtnpfin
              v_dteaccls, -- item25 as dteaccls
              v_dtelpay, -- item26 as dtelpay
              v_desaccls, -- item27 as desaccls
              v_yrelaw, -- item28 as yrelaw
              v_dteappr, -- item29 as dteappr
              v_desc_codappr, -- item30 as desc_codappr
              v_desc_codreq, -- item31 as desc_codreq
              v_qtyperip -- item32 as qtyperip
            );
      exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
      end;
    elsif v_table = 'tloancol' then
      v_numseq              := get_ttemprpt_numseq(p_codapp || '1');
      v_seqno               := hcm_util.get_string_t(obj_data, 'rcnt');
      v_codcolla            := hcm_util.get_string_t(obj_data, 'codcolla');
      v_desc_codcolla       := hcm_util.get_string_t(obj_data, 'desc_codcolla');
      v_amtcolla            := to_char(hcm_util.get_string_t(obj_data, 'amtcolla'), 'fm99,999,990.90');
      v_numrefer            := hcm_util.get_string_t(obj_data, 'numrefer');
      v_descolla            := hcm_util.get_string_t(obj_data, 'descolla');
      begin
        insert
          into ttemprpt
            (
              codempid, codapp, numseq,
              item1, item2, item3, item4, item5,
              item6, item7, item8, item9
            )
        values
            (
              global_v_codempid, p_codapp || '1', v_numseq,
              get_emp_img(p_codempid), -- item1
              p_codempid, -- item2
              p_numcont, -- item3
              v_seqno, -- item4 as seqno
              v_codcolla, -- item5 as codcolla
              v_desc_codcolla, -- item6 as desc_codcolla
              v_amtcolla, -- item7 as amtcolla
              v_numrefer, -- item8 as numrefer
              v_descolla -- item9 as descolla
            );
      exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
      end;
    elsif v_table = 'tloangar' then
      v_numseq              := get_ttemprpt_numseq(p_codapp || '2');
      v_seqno               := hcm_util.get_string_t(obj_data, 'rcnt');
      v_codempgar           := hcm_util.get_string_t(obj_data, 'codempgar');
      v_desc_codempgar      := get_temploy_name(v_codempgar, global_v_lang);
      v_desc_codpos         := hcm_util.get_string_t(obj_data, 'desc_codpos');
      v_desc_codcomp        := hcm_util.get_string_t(obj_data, 'desc_codcomp');
      v_qtywork             := hcm_util.get_string_t(obj_data, 'qtywork');
      v_amount              := to_char(hcm_util.get_string_t(obj_data, 'amount'), 'fm99,999,990.90');
      begin
        insert
          into ttemprpt
            (
              codempid, codapp, numseq,
              item1, item2, item3, item4, item5,
              item6, item7, item8, item9, item10
            )
        values
            (
              global_v_codempid, p_codapp || '2', v_numseq,
              get_emp_img(p_codempid), -- item1
              p_codempid, -- item2
              p_numcont, -- item3
              v_seqno, -- item4 as seqno
              v_codempgar, -- item5 as codempgar
              v_desc_codempgar, -- item6 as desc_codempgar
              v_desc_codpos, -- item7 as desc_codpos
              v_desc_codcomp, -- item8 as desc_codcomp
              v_qtywork, -- item9 as qtywork
              v_amount -- item10 as amount
            );
      exception when others then
        param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
      end;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
  end insert_ttemprpt;

  procedure get_report (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_report(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_report;

  procedure gen_report (json_str_output out clob) AS
    json_output         clob;
  begin
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
      for i in 0..json_params.get_size - 1 loop
        if param_msg_error is not null then
          exit;
        end if;
        initial_report(hcm_util.get_json_t(json_params, to_char(i)));
        if param_msg_error is null then
          gen_detail(json_output);
        end if;
        if param_msg_error is null then
          gen_tloancol(json_output);
        end if;
        if param_msg_error is null then
          gen_tloangar(json_output);
        end if;
      end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715', global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  end gen_report;
end HRBF5AX;

/
