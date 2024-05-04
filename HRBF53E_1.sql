--------------------------------------------------------
--  DDL for Package Body HRBF53E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF53E" AS
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
    p_codlon            := hcm_util.get_string_t(json_obj, 'p_codlon');
    p_amtlon            := to_number(hcm_util.get_number_t(json_obj, 'p_amtlon'));
    p_amttlpay          := to_number(hcm_util.get_number_t(json_obj, 'p_amttlpay'));
    p_amtiflat          := to_number(hcm_util.get_number_t(json_obj, 'p_amtiflat'));
    p_rateilon          := to_number(hcm_util.get_number_t(json_obj, 'p_rateilon'));
    p_amtitotflat       := to_number(hcm_util.get_number_t(json_obj, 'p_amtitotflat'));
    p_qtyperiod         := to_number(hcm_util.get_number_t(json_obj, 'p_qtyperiod'));
    p_dtelonst          := to_date(hcm_util.get_string_t(json_obj, 'p_dtelonst'), 'DD/MM/YYYY');
    p_typintr           := hcm_util.get_string_t(json_obj, 'p_typintr');
    p_textCal           := hcm_util.get_string_t(json_obj, 'p_textCal');
    p_codempgar         := hcm_util.get_string_t(json_obj, 'p_codempgar');
    p_dteyrpay          := to_number(hcm_util.get_number_t(json_obj, 'p_dteyrpay'));
    p_mthpay            := to_number(hcm_util.get_number_t(json_obj, 'p_mthpay'));
    p_prdpay            := to_number(hcm_util.get_number_t(json_obj, 'p_prdpay'));
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');
    p_additional_year   := to_number(hcm_appsettings.get_additional_year);
    p_sendmail          := hcm_util.get_string_t(json_obj, 'p_sendmail');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index AS
    v_staemp            temploy1.staemp%type;
    v_numlvl            temploy1.numlvl%type;
  begin
    if p_codempid is not null then
      begin
        select staemp, codcomp, numlvl
          into v_staemp, p_codcomp, v_numlvl
          from temploy1
        where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      if v_staemp is not null then
        if v_staemp = '9' then
          param_msg_error := get_error_msg_php('HR2101', global_v_lang);
          return;
        elsif v_staemp = '0' then
          param_msg_error := get_error_msg_php('HR2102', global_v_lang);
          return;
        elsif not secur_main.secur1(p_codcomp, v_numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      end if;
    else
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
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

    cursor c1 is
      select numcont, codempid, codlon, amtlon, stalon, staappr, remarkap
        from tloaninf
       where codempid = p_codempid
       order by numcont;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', i.codempid);
      obj_data.put('numcont', i.numcont);
      obj_data.put('codlon', i.codlon);
      obj_data.put('desc_codlon', get_ttyplone_name(i.codlon, global_v_lang));
      obj_data.put('amtlon', i.amtlon);
      obj_data.put('stalon', i.stalon);
      obj_data.put('desc_stalon', get_tlistval_name('STALOAN', i.stalon, global_v_lang));
      obj_data.put('staappr', i.staappr);
      obj_data.put('desc_staappr', get_tlistval_name('ESSTAREQ', i.staappr, global_v_lang));
      obj_data.put('remarkap', i.remarkap);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_index;

  procedure check_detail AS
    v_codempid        tloaninf.codempid%type;
  begin
    begin
      select codempid
        into v_codempid
        from tloaninf
       where numcont = p_numcont;
    exception when no_data_found then
      null;
    end;
    if v_codempid <> p_codempid then
      param_msg_error := get_error_msg_php('BF0028', global_v_lang);
      return;
    end if;
  end check_detail;

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
    obj_tmp             json_object_t;
    v_found             boolean := false;
    v_amtmxlon          ttyploan.amtmxlon%type;
    v_ratelon           ttyploan.ratelon%type;
    v_nummxlon          ttyploan.nummxlon%type;
    v_qtygar            ttyploan.qtygar%type;
    v_condgar           ttyploan.condgar%type;
    v_amtasgar          ttyploan.amtasgar%type;
    v_codcomp           temploy1.codcomp%type;
    v_codempmt          temploy1.codempmt%type;
    v_codcompy          tcompny.codcompy%type;
    v_amtincom1         temploy3.amtincom1%type;
    v_amtincom2         temploy3.amtincom2%type;
    v_amtincom3         temploy3.amtincom3%type;
    v_amtincom4         temploy3.amtincom4%type;
    v_amtincom5         temploy3.amtincom5%type;
    v_amtincom6         temploy3.amtincom6%type;
    v_amtincom7         temploy3.amtincom7%type;
    v_amtincom8         temploy3.amtincom8%type;
    v_amtincom9         temploy3.amtincom9%type;
    v_amtincom10        temploy3.amtincom10%type;
    v_amtothr           number;
    v_amtday            number;
    v_amtmth            number;

    cursor c1 is
      select codempid, codcomp, numcont, codlon, typintr, rateilon, numlon, amtlon, formula,
             dtelonst, dtelonen, dteissue, dtestcal, typpayamt, dteyrpay, mthpay, prdpay,
             reaslon, typpay, amtiflat, amtitotflat, amttlpay, amtpaybo, qtyperiod, codreq, stalon,
             amtnpfin, dteaccls, dtelpay, desaccls, dteappr, codappr, staappr, qtyperip
        from tloaninf
       where codempid = p_codempid
         and numcont  = p_numcont;
  begin
    p_codcomp   := hcm_util.get_temploy_field(p_codempid, 'codcomp');
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid);
    obj_data.put('codcomp', p_codcomp);
    obj_data.put('numcont', p_numcont);
    obj_data.put('codlon', '');
    obj_data.put('typintr', '');
    obj_data.put('rateilon', '');
    obj_data.put('yrenumlon', '0');
    obj_data.put('mthnumlon', '0');
    obj_data.put('yrenummxlon', '0');
    obj_data.put('mthnummxlon', '0');
    obj_data.put('amtlon', '');
    obj_data.put('formula', '');
    obj_data.put('desc_formula', '');
    obj_data.put('dtelonst', to_char(sysdate, 'DD/MM/YYYY'));
    obj_data.put('dtelonen', to_char(sysdate, 'DD/MM/YYYY'));
    obj_data.put('dteissue', to_char(sysdate, 'DD/MM/YYYY'));
    obj_data.put('dtestcal', to_char(sysdate, 'DD/MM/YYYY'));
    obj_data.put('typpayamt', '1');
    obj_data.put('dteyrpay', to_char(sysdate, 'YYYY'));
    obj_data.put('mthpay', to_number(to_char(sysdate, 'MM')));
    obj_data.put('prdpay', '1');
    obj_data.put('reaslon', '');
    obj_data.put('typpay', '1');
    obj_data.put('amtiflat', 0);
    obj_data.put('amtitotflat', 0);
    obj_data.put('amttlpay', 0);
    obj_data.put('amtpaybo', '');
    obj_data.put('qtyperiod', 0);
    obj_data.put('codreq', global_v_codempid);
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
    obj_data.put('staappr', '');
    obj_data.put('qtyperip', 0);
    obj_data.put('amtmxlon', '');
    obj_data.put('reqgar', 'Y');
    obj_data.put('reqcol', 'Y');
    for i in c1 loop
      begin
        select amtmxlon, ratelon, nummxlon, qtygar, condgar, amtasgar
          into v_amtmxlon, v_ratelon, v_nummxlon, v_qtygar, v_condgar, v_amtasgar
          from ttyploan
         where codlon = i.codlon;
      exception when no_data_found then
        null;
      end;
      v_found     := true;
      obj_data.put('codempid', i.codempid);
      obj_data.put('codcomp', i.codcomp);
      obj_data.put('numcont', i.numcont);
      obj_data.put('codlon', i.codlon);
      obj_data.put('typintr', i.typintr);
      obj_data.put('rateilon', i.rateilon);
      obj_data.put('yrenumlon', floor(nvl(i.numlon, 0) / 12));
      obj_data.put('mthnumlon', mod(nvl(i.numlon, 0), 12));
      obj_data.put('yrenummxlon', floor(nvl(v_nummxlon, 0) / 12));
      obj_data.put('mthnummxlon', mod(nvl(v_nummxlon, 0), 12));
      obj_data.put('amtlon', i.amtlon);
      obj_data.put('formula', i.formula);
      obj_data.put('desc_formula', hcm_formula.get_description(i.formula, global_v_lang));
      obj_data.put('dtelonst', to_char(i.dtelonst, 'DD/MM/YYYY'));
      obj_data.put('dtelonen', to_char(i.dtelonen, 'DD/MM/YYYY'));
      obj_data.put('dteissue', to_char(i.dteissue, 'DD/MM/YYYY'));
      obj_data.put('dtestcal', to_char(i.dtestcal, 'DD/MM/YYYY'));
      obj_data.put('typpayamt', i.typpayamt);
      obj_data.put('dteyrpay', i.dteyrpay);
      obj_data.put('mthpay', i.mthpay);
      obj_data.put('prdpay', i.prdpay);
      obj_data.put('reaslon', i.reaslon);
      obj_data.put('typpay', i.typpay);
      obj_data.put('desc_typpay', get_tlistval_name('LOANPAYMT2', i.typpay, global_v_lang));
      obj_data.put('amtiflat', i.amtiflat);
      obj_data.put('amtitotflat', i.amtitotflat);
      obj_data.put('amttlpay', i.amttlpay);
      obj_data.put('amtpaybo', i.amtpaybo);
      obj_data.put('qtyperiod', i.qtyperiod);
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
      obj_data.put('staappr', i.staappr);
      obj_data.put('qtyperip', nvl(i.qtyperip, 0));
      if v_amtmxlon is null and v_ratelon is not null then
        begin
          select codcomp, codempmt,
                 stddec(c.amtincom1, a.codempid, v_chken) amtincom1,
                 stddec(c.amtincom2, a.codempid, v_chken) amtincom2,
                 stddec(c.amtincom3, a.codempid, v_chken) amtincom3,
                 stddec(c.amtincom4, a.codempid, v_chken) amtincom4,
                 stddec(c.amtincom5, a.codempid, v_chken) amtincom5,
                 stddec(c.amtincom6, a.codempid, v_chken) amtincom6,
                 stddec(c.amtincom7, a.codempid, v_chken) amtincom7,
                 stddec(c.amtincom8, a.codempid, v_chken) amtincom8,
                 stddec(c.amtincom9, a.codempid, v_chken) amtincom9,
                 stddec(c.amtincom10, a.codempid, v_chken) amtincom10
            into v_codcomp, v_codempmt,
                 v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                 v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10
            from temploy1 a, temploy3 c
          where a.codempid = i.codempid
            and a.codempid = c.codempid;
          v_codcompy        := hcm_util.get_codcomp_level(v_codcomp, 1);
          get_wage_income(v_codcomp, v_codempmt,
                              v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                              v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
                              v_amtothr, v_amtday, v_amtmth);
          if v_amtmth > 0 then
            v_amtmxlon          := nvl(v_amtmth, 0) * nvl(v_ratelon, 0);
          end if;
        exception when no_data_found then
          null;
        end;
      end if;
      obj_data.put('amtmxlon', v_amtmxlon);
      if nvl(v_qtygar, 0) > 0 or v_condgar is not null then
        obj_data.put('reqgar', 'Y');
      else
        obj_data.put('reqgar', 'N');
      end if;
      if nvl(v_amtasgar, 0) > 0 then
        obj_data.put('reqcol', 'Y');
      else
        obj_data.put('reqcol', 'N');
      end if;
      if i.staappr in ('A', 'Y', 'N') then
        obj_tmp     := json_object_t(get_response_message(null, get_error_msg_php('HR8014', global_v_lang), global_v_lang));
        obj_data.put('response', hcm_util.get_string_t(obj_tmp, 'response'));
      end if;
    end loop;
    json_str_output := obj_data.to_clob;
  end gen_detail;

  procedure get_tloancol (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
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
      obj_data.put('numcont', i.numcont);
      obj_data.put('codcolla', i.codcolla);
      obj_data.put('desc_codcolla', get_tcodec_name('TCODCOLA', i.codcolla, global_v_lang));
      obj_data.put('amtcolla', i.amtcolla);
      obj_data.put('numrefer', i.numrefer);
      obj_data.put('descolla', i.descolla);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_tloancol;

  procedure get_tloangar (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
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
    v_year              number := 0;
    v_month             number := 0;
    v_day               number := 0;

    cursor c1 is
      select b.codempgar, a.codcomp, a.codpos, a.dteempmt, b.amtgar
        from tloangar b, temploy1 a
       where b.numcont   = p_numcont
         and b.codempgar = a.codempid
       order by b.codempgar;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      get_service_year(i.dteempmt, sysdate, 'Y', v_year, v_month, v_day);
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', get_emp_img(i.codempgar));
      obj_data.put('codempgar', i.codempgar);
      obj_data.put('desc_codempgar', get_temploy_name(i.codempgar, global_v_lang));
      obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
      obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
      obj_data.put('qtywork', v_year || '(' || v_month || ')');
      obj_data.put('amount', i.amtgar);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_tloangar;

  procedure get_tloangar_info (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tloangar_info(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tloangar_info;

  procedure gen_tloangar_info (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select a.numcont, codempid, amtlon, amtgar, dtelonst, dtelonen, stalon
        from tloangar a, tloaninf b
       where a.codempgar = p_codempgar
         and a.numcont   = b.numcont
       order by numcont;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', get_emp_img(i.codempid));
      obj_data.put('codempid', i.codempid);
      obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
      obj_data.put('numcont', i.numcont);
      obj_data.put('amtlon', i.amtlon);
      obj_data.put('amtgar', i.amtgar);
      obj_data.put('dtelonst', to_char(i.dtelonst, 'DD/MM/YYYY'));
      obj_data.put('dtelonen', to_char(i.dtelonen, 'DD/MM/YYYY'));
      obj_data.put('stalon', i.stalon);
      obj_data.put('desc_stalon', get_tlistval_name('STALOAN', i.stalon, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_tloangar_info;

  procedure check_codempgar (v_codempgar tloangar.codempgar%type) as
    v_staemp            temploy1.staemp%type;
    v_codcomp           temploy1.codcomp%type;
    v_typpayroll        temploy1.typpayroll%type;
    v_dteempmt          temploy1.dteempmt%type;
    v_numlvl            temploy1.numlvl%type;
    v_codpos            temploy1.codpos%type;
    v_jobgrade          temploy1.jobgrade%type;
    v_year              number;
    v_month             number;
    v_day               number;
    v_flgfound          boolean := false;
    v_statment          ttyploan.condgar%type;
    b_codempgar         tloangar.codempgar%type;
  begin
    begin
      select codcomp, typpayroll, dteempmt, numlvl, codpos, jobgrade
        into v_codcomp, v_typpayroll, v_dteempmt, v_numlvl, v_codpos, v_jobgrade
        from temploy1
       where codempid = v_codempgar;
      get_service_year(v_dteempmt, sysdate, 'Y', v_year, v_month, v_day);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
      return;
    end;
    if v_codempgar = p_codempid then
      param_msg_error := get_error_msg_php('BF0013', global_v_lang);
      return;
    end if;
    if v_staemp is not null then
      if v_staemp = '9' then
        param_msg_error := get_error_msg_php('HR2101', global_v_lang);
        return;
      elsif v_staemp = '0' then
        param_msg_error := get_error_msg_php('HR2102', global_v_lang);
        return;
      end if;
    end if;
    if param_msg_error is null then
      if p_codlon is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      end if;
    end if;
    if param_msg_error is null then
      begin
        select condgar
          into p_condgar
          from ttyploan
         where codlon = p_codlon;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'ttyploan');
        return;
      end;
      if p_condgar is not null then
        v_statment := p_condgar;
        v_statment := replace(v_statment, 'V_HRPMA1.CODCOMP', '''' || v_codcomp || '''');
        v_statment := replace(v_statment, 'V_HRPMA1.CODPOS', '''' || v_codpos || '''');
        v_statment := replace(v_statment, 'V_HRPMA1.NUMLVL', v_numlvl);
        v_statment := replace(v_statment, 'V_HRPMA1.JOBGRADE', '''' || v_jobgrade || '''');
        v_statment := replace(v_statment, 'V_HRPMA1.AGE', ((v_year * 12) + v_month));
        v_statment := 'select count(*) from dual where ' || v_statment;
        v_flgfound := execute_stmt(v_statment);
        if not v_flgfound then
          param_msg_error := get_error_msg_php('BF0007', global_v_lang);
          return;
        end if;
      end if;
    end if;
    begin
      select codempgar
        into b_codempgar
        from tloangar
       where numcont   = p_numcont
         and codempgar = p_codempgar;
      param_msg_error := get_error_msg_php('HR2005', global_v_lang);
      return;
    exception when no_data_found then
      null;
    end;
  end check_codempgar;

  procedure get_codempgar (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_codempgar(p_codempgar);
    if param_msg_error is null then
      gen_codempgar(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_codempgar;

  procedure gen_codempgar (json_str_output out clob) AS
    obj_data            json_object_t;
    v_year              number := 0;
    v_month             number := 0;
    v_day               number := 0;
    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    v_dteempmt          temploy1.dteempmt%type;

  begin
    begin
      select codcomp, codpos, dteempmt
        into v_codcomp, v_codpos, v_dteempmt
        from temploy1
       where codempid = p_codempgar;
    exception when no_data_found then
      null;
    end;
    get_service_year(v_dteempmt, sysdate, 'Y', v_year, v_month, v_day);
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempgar', p_codempgar);
    obj_data.put('desc_codempgar', get_temploy_name(p_codempgar, global_v_lang));
    obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
    obj_data.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
    obj_data.put('qtywork', v_year || '(' || v_month || ')');
    json_str_output := obj_data.to_clob;
  end gen_codempgar;

  procedure get_tintrteh (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tintrteh(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tintrteh;

  procedure gen_tintrteh (json_str_output out clob) AS
    obj_data            json_object_t;
    v_typintr           tintrteh.typintr%type;
    b_formula           tloaninf.formula%type;
    b_codlon            tloaninf.codlon%type;
    v_formula           tintrteh.formula%type;
    v_rateilon          tintrteh.rateilon%type;
    v_amtmxlon          ttyploan.amtmxlon%type;
    v_ratelon           ttyploan.ratelon%type;
    v_nummxlon          ttyploan.nummxlon%type;
    v_qtygar            ttyploan.qtygar%type;
    v_condgar           ttyploan.condgar%type;
    v_amtasgar          ttyploan.amtasgar%type;
    v_codcompy          tintrted.codcompy%type;
    v_amtlon            tloaninf.amtlon%type;
    v_codcomp           temploy1.codcomp%type;
    v_codempmt          temploy1.codempmt%type;
    v_amtincom1         temploy3.amtincom1%type;
    v_amtincom2         temploy3.amtincom2%type;
    v_amtincom3         temploy3.amtincom3%type;
    v_amtincom4         temploy3.amtincom4%type;
    v_amtincom5         temploy3.amtincom5%type;
    v_amtincom6         temploy3.amtincom6%type;
    v_amtincom7         temploy3.amtincom7%type;
    v_amtincom8         temploy3.amtincom8%type;
    v_amtincom9         temploy3.amtincom9%type;
    v_amtincom10        temploy3.amtincom10%type;
    v_amtothr           number;
    v_amtday            number;
    v_amtmth            number;

  begin
    v_codcompy          := hcm_util.get_codcomp_level(p_codcomp, '1');
    begin
      select formula, codlon
        into b_formula, b_codlon
        from tloaninf
       where numcont = p_numcont;
    exception when no_data_found then
      null;
    end;
    begin
      select typintr, formula, rateilon
        into v_typintr, v_formula, v_rateilon
        from tintrteh
       where codcompy = v_codcompy
         and codlon   = p_codlon
         and dteeffec = (select max(dteeffec)
                           from tintrteh
                          where codcompy = v_codcompy
                            and codlon   = p_codlon
                            and trunc(dteeffec) <= trunc(sysdate));
    exception when no_data_found then
      null;
    end;
    if v_typintr = '2' and b_formula is not null then
      v_formula := b_formula;
    end if;
    begin
      select amtmxlon, ratelon, nummxlon, qtygar, condgar, amtasgar
        into v_amtmxlon, v_ratelon, v_nummxlon, v_qtygar, v_condgar, v_amtasgar
        from ttyploan
       where codlon = p_codlon;
    exception when no_data_found then
      null;
    end;
    if v_amtmxlon is null and v_ratelon is not null then
      begin
        select codempmt,
               stddec(c.amtincom1, a.codempid, v_chken) amtincom1,
               stddec(c.amtincom2, a.codempid, v_chken) amtincom2,
               stddec(c.amtincom3, a.codempid, v_chken) amtincom3,
               stddec(c.amtincom4, a.codempid, v_chken) amtincom4,
               stddec(c.amtincom5, a.codempid, v_chken) amtincom5,
               stddec(c.amtincom6, a.codempid, v_chken) amtincom6,
               stddec(c.amtincom7, a.codempid, v_chken) amtincom7,
               stddec(c.amtincom8, a.codempid, v_chken) amtincom8,
               stddec(c.amtincom9, a.codempid, v_chken) amtincom9,
               stddec(c.amtincom10, a.codempid, v_chken) amtincom10
          into v_codempmt,
               v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
               v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10
          from temploy1 a, temploy3 c
        where a.codempid = p_codempid
          and a.codempid = c.codempid;
        get_wage_income(p_codcomp, v_codempmt,
                            v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                            v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
                            v_amtothr, v_amtday, v_amtmth);
        if v_amtmth > 0 then
          v_amtmxlon          := nvl(v_amtincom1, 0) * nvl(v_ratelon, 0);--User37 #3299 BF - PeoplePlus 06/04/2021 nvl(v_amtmth, 0) * nvl(v_ratelon, 0);
        end if;
      exception when no_data_found then
        null;
      end;
    end if;
    if b_codlon is null then
      if nvl(b_codlon, '@#$%') = p_codlon then
        v_amtlon            := 9999;--User37 #3299 BF - PeoplePlus 06/04/2021 p_amtlon;
      else
        v_amtlon            := v_amtmxlon;
      end if;
    else
      if b_codlon = p_codlon then
        v_amtlon            := 8888;--User37 #3299 BF - PeoplePlus 06/04/2021 p_amtlon;
      else
        v_amtlon            := v_amtmxlon;
      end if;
    end if;
    begin
      select rateilon
        into v_rateilon
        from tintrted a
       where codcompy = v_codcompy
         and codlon   = p_codlon
         and amtlon   = (select max(amtlon)
                           from tintrted
                          where codcompy = a.codcompy
                            and codlon   = a.codlon
                            and dteeffec = a.dteeffec
                            and v_amtlon >= amtlon)
         and dteeffec = (select max(dteeffec)
                           from tintrted
                          where codcompy = a.codcompy
                            and codlon   = a.codlon
                            and trunc(dteeffec) <= trunc(sysdate)
                            and a.amtlon >= amtlon);
    exception when no_data_found then
      null;
    end;
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('typintr', v_typintr);
    obj_data.put('yrenummxlon', floor(nvl(v_nummxlon, 0) / 12));
    obj_data.put('mthnummxlon', mod(nvl(v_nummxlon, 0), 12));
    obj_data.put('rateilon', v_rateilon);
    obj_data.put('amtmxlon', v_amtmxlon);
    obj_data.put('formula', v_formula);
    obj_data.put('desc_formula', hcm_formula.get_description(v_formula, global_v_lang));
    if nvl(v_qtygar, 0) > 0 or v_condgar is not null then
      obj_data.put('reqgar', 'Y');
    else
      obj_data.put('reqgar', 'N');
    end if;
    if nvl(v_amtasgar, 0) > 0 then
      obj_data.put('reqcol', 'Y');
    else
      obj_data.put('reqcol', 'N');
    end if;
    json_str_output := obj_data.to_clob;
  end gen_tintrteh;

  procedure save_tloaninf AS
  begin
    begin
      insert into tloaninf
                  (numcont, codempid, typpayroll, codcomp, codlon, typintr, rateilon,
                   dtelonst, dtelonen, dteissue, dtestcal, numlon, qtyperiod, dteeffec, stalon, staappr,
                   amttlpay, amtpaybo, amtiflat, amtpflat, amtitotflat, reaslon, typpay, amtlon, amtnpfin,
                   codreq, typpayamt, dteyrpay, mthpay, prdpay, formula, statementf, qtyperip, amtintovr,
                   dtecreate, codcreate, coduser)
            values (p_numcont, p_codempid, p_typpayroll, p_codcomp, p_codlon, p_typintr, p_rateilon,
                   p_dtelonst, p_dtelonen, p_dteissue, p_dtestcal, p_numlon, p_qtyperiod, p_dteeffec, 'N', 'P',
                   p_amttlpay, p_amtpaybo, p_amtiflat, 0, p_amtitotflat, p_reaslon, p_typpay, p_amtlon, p_amtlon,
                   p_codreq, p_typpayamt, p_dteyrpay, p_mthpay, p_prdpay, p_formula, p_statement, 0, 0,
                   sysdate, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      update  tloaninf
         set  typpayroll  = p_typpayroll,
              codcomp     = p_codcomp,
              codlon      = p_codlon,
              typintr     = p_typintr,
              rateilon    = p_rateilon,
              dtelonst    = p_dtelonst,
              dtelonen    = p_dtelonen,
              dteissue    = p_dteissue,
              dtestcal    = p_dtestcal,
              numlon      = p_numlon,
              qtyperiod   = p_qtyperiod,
              qtyperip    = 0,
              amtintovr   = 0,
              dteeffec    = p_dteeffec,
              stalon      = nvl(stalon, 'N'),
              staappr     = nvl(staappr, 'P'),
              amttlpay    = p_amttlpay,
              amtpaybo    = p_amtpaybo,
              amtiflat    = p_amtiflat,
              amtpflat    = 0,
              amtitotflat = p_amtitotflat,
              reaslon     = p_reaslon,
              typpay      = p_typpay,
              amtlon      = p_amtlon,
              amtnpfin    = p_amtlon,
              codreq      = p_codreq,
              typpayamt   = p_typpayamt,
              dteyrpay    = p_dteyrpay,
              mthpay      = p_mthpay,
              prdpay      = p_prdpay,
              formula     = p_formula,
              statementf  = p_statement,
              dteupd      = sysdate,
              coduser     = global_v_coduser
       where  numcont     = p_numcont
         and  codempid    = p_codempid;
    end;
  end save_tloaninf;

  procedure save_tloancol as
    obj_data            json_object_t;
    v_codcolla          tloancol.codcolla%type;
    v_amtcolla          tloancol.amtcolla%type;
    v_numrefer          tloancol.numrefer%type;
    v_descolla          tloancol.descolla%type;
    v_sum               number := 0;
    v_flg               varchar2(10 char);
  begin
    for i in 0 .. obj_tloancol.get_size - 1 loop
      obj_data        := hcm_util.get_json_t(obj_tloancol, to_char(i));
      v_flg           := hcm_util.get_string_t(obj_data, 'flg');
      v_codcolla      := hcm_util.get_string_t(obj_data, 'codcolla');
      v_amtcolla      := to_number(hcm_util.get_number_t(obj_data, 'amtcolla'));
      v_numrefer      := hcm_util.get_string_t(obj_data, 'numrefer');
      v_descolla      := hcm_util.get_string_t(obj_data, 'descolla');
      if v_flg = 'delete' then
        delete
          from tloancol
         where numcont  = p_numcont
           and codcolla = v_codcolla;
      else
        begin
          insert into tloancol (numcont, codcolla, amtcolla, numrefer, descolla, dtecreate, codcreate, coduser)
               values (p_numcont, v_codcolla, v_amtcolla, v_numrefer, v_descolla, sysdate, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          update tloancol
             set amtcolla = v_amtcolla,
                 numrefer = v_numrefer,
                 descolla = v_descolla,
                 dteupd   = sysdate,
                 coduser  = global_v_coduser
           where numcont  = p_numcont
             and codcolla = v_codcolla;
        end;
      end if;
    end loop;
    begin
      select sum(amtcolla)
        into v_sum
        from tloancol
       where numcont = p_numcont;
    exception when others then
      null;
    end;
    if p_amtasgar is not null then
      if v_sum < p_amtasgar then
        param_msg_error := get_error_msg_php('BF0043', global_v_lang);
        param_msg_error := replace(param_msg_error, '[P-AMTGAR]', to_char(p_amtasgar, 'fm99,999,990.90'));
        return;
      end if;
    end if;
  end save_tloancol;

  procedure save_tloangar as
    obj_data            json_object_t;
    v_codempgar         tloangar.codempgar%type;
    v_amount            tloangar.amtgar%type;
    v_flg               varchar2(10 char);
    v_count             number := 0;
    v_sum               number := 0;

  begin
    for i in 0 .. obj_tloangar.get_size - 1 loop
      obj_data        := hcm_util.get_json_t(obj_tloangar, to_char(i));
      v_flg           := hcm_util.get_string_t(obj_data, 'flg');
      v_codempgar     := hcm_util.get_string_t(obj_data, 'codempgar');
      v_amount        := to_number(hcm_util.get_number_t(obj_data, 'amount'));
      check_codempgar(v_codempgar);
      if param_msg_error is null then
        if v_flg = 'delete' then
          delete
            from tloangar
           where numcont   = p_numcont
             and codempgar = v_codempgar;
        else
          begin
            insert into tloangar (numcont, codempgar, amtgar, dtecreate, codcreate, coduser)
                 values (p_numcont, v_codempgar, v_amount, sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            update tloangar
               set amtgar    = v_amount,
                   dteupd    = sysdate,
                   coduser   = global_v_coduser
             where numcont   = p_numcont
               and codempgar = v_codempgar;
          end;
        end if;
      end if;
    end loop;
    begin
      select count(*), sum(amtgar)
        into v_count, v_sum
        from tloangar
       where numcont = p_numcont;
    exception when others then
      null;
    end;
    if p_qtygar is not null then
      if v_count < p_qtygar then
        param_msg_error := get_error_msg_php('BF0042', global_v_lang);
        param_msg_error := replace(param_msg_error, '[P-QTYGAR]', to_char(p_qtygar));
        return;
      end if;
    end if;
    if p_amtguarntr is not null then
      if v_sum < p_amtguarntr then
        param_msg_error := get_error_msg_php('BF0052', global_v_lang);
        param_msg_error := replace(param_msg_error, '[P-AMTGAR]', to_char(p_amtguarntr, 'fm99,999,990.90'));
        return;
      end if;
    end if;
  end save_tloangar;

  procedure check_save AS
    v_flgfound          boolean := false;
    v_dteempmt          temploy1.dteempmt%type;
    v_numlvl            temploy1.numlvl%type;
    v_codpos            temploy1.codpos%type;
    v_jobgrade          temploy1.jobgrade%type;
    v_condlon           ttyploan.condlon%type;
    v_statment          ttyploan.condlon%type;
    --<<User37 #3299 BF - PeoplePlus 06/04/2021
    v_ratelon           ttyploan.ratelon%type;
    v_nummxlon          ttyploan.nummxlon%type;
    v_maxsal            number;
    v_amtincom1         number;
    -->>User37 #3299 BF - PeoplePlus 06/04/2021
    v_year              number;
    v_month             number;
    v_day               number;
    v_dtepaymt          tdtepay.dtepaymt%type;
    v_codcompy          tcompny.codcompy%type;
  begin
    if p_codempid is not null then
      begin
        select codcomp, typpayroll, dteempmt, numlvl, codpos, jobgrade
          into p_codcomp, p_typpayroll, v_dteempmt, v_numlvl, v_codpos, v_jobgrade
          from temploy1
        where codempid = p_codempid;
        get_service_year(v_dteempmt, sysdate, 'Y', v_year, v_month, v_day);
        begin
          select condlon, amtasgar, qtygar, amtguarntr, condgar,
                 ratelon, nummxlon--User37 #3299 BF - PeoplePlus 06/04/2021
            into v_condlon, p_amtasgar, p_qtygar, p_amtguarntr, p_condgar,
                 v_ratelon, v_nummxlon--User37 #3299 BF - PeoplePlus 06/04/2021
            from ttyploan
           where codlon = p_codlon;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'ttyploan');
          return;
        end;
        --<<User37 #3299 BF - PeoplePlus 06/04/2021
        if v_ratelon is not null then
            begin
                select stddec(amtincom1, codempid, v_chken) amtincom1
                  into v_amtincom1
                  from temploy3
                 where codempid = p_codempid;
            exception when no_data_found then
                v_amtincom1 := 0;
            end;
            v_maxsal := v_amtincom1 * v_ratelon;
            if p_amtlon > v_maxsal then
                param_msg_error := get_error_msg_php('BF0069', global_v_lang);
                return;
            end if;
        end if;
        if ((nvl(p_yrenumlon,0)*12) + nvl(p_mthnumlon,0)) > v_nummxlon then
                param_msg_error := get_error_msg_php('BF0070', global_v_lang);
                return;
        end if;
        -->>User37 #3299 BF - PeoplePlus 06/04/2021
        if v_condlon is not null then
          v_statment := v_condlon;
          v_statment := replace(v_statment, 'V_HRPMA1.CODCOMP', '''' || p_codcomp || '''');
          v_statment := replace(v_statment, 'V_HRPMA1.CODPOS', '''' || v_codpos || '''');
          v_statment := replace(v_statment, 'V_HRPMA1.NUMLVL', v_numlvl);
          v_statment := replace(v_statment, 'V_HRPMA1.JOBGRADE', '''' || v_jobgrade || '''');
          v_statment := replace(v_statment, 'V_HRPMA1.AGE', ((v_year * 12) + v_month));
          v_statment := 'select count(*) from dual where ' || v_statment;
          v_flgfound := execute_stmt(v_statment);
          if not v_flgfound then
            param_msg_error := get_error_msg_php('BF0008', global_v_lang);
            return;
          end if;
        end if;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
    end if;
    if p_amtpaybo > 0 then
      if p_amtpaybo < p_amttlpay then
        param_msg_error := get_error_msg_php('BF0050', global_v_lang);
        return;
      end if;
    end if;
    v_codcompy        := hcm_util.get_codcomp_level(p_codcomp, '1');
    begin
      select dteeffec
        into p_dteeffec
        from tintrteh
       where codcompy = v_codcompy
         and codlon   = p_codlon
         and dteeffec = (select max(dteeffec)
                           from tintrteh
                          where codcompy = v_codcompy
                            and codlon   = p_codlon);
    exception when no_data_found then
      null;
    end;
    if p_typpay = '1' then
      begin
        select dtepaymt
          into v_dtepaymt
          from tdtepay
         where codcompy   = v_codcompy
           and typpayroll = p_typpayroll
           and dteyrepay  = p_dteyrpay
           and dtemthpay  = p_mthpay
           and numperiod  = p_prdpay;
      exception when no_data_found then
        null;
      end;
      if p_dtelonst > v_dtepaymt then
        param_msg_error := get_error_msg_php('BF0067', global_v_lang);
        return;
      end if;
      if p_dtestcal > v_dtepaymt then
        param_msg_error := get_error_msg_php('BF0068', global_v_lang);
        return;
      end if;
    end if;
  end check_save;

  procedure initial_save (obj_input in json_object_t) as
    obj_data            json_object_t;
  begin
    obj_data            := hcm_util.get_json_t(obj_input, 'tab1');
    obj_tloancol        := hcm_util.get_json_t(obj_input, 'tloancol');
    obj_tloangar        := hcm_util.get_json_t(obj_input, 'tloangar');
    p_numcont           := hcm_util.get_string_t(obj_data, 'numcont');
    p_codlon            := hcm_util.get_string_t(obj_data, 'codlon');
    p_typintr           := to_char(hcm_util.get_number_t(obj_data, 'typintr'));
    p_rateilon          := to_number(hcm_util.get_number_t(obj_data, 'rateilon'));
    p_yrenumlon         := to_number(hcm_util.get_number_t(obj_data, 'yrenumlon'));
    p_mthnumlon         := to_number(hcm_util.get_number_t(obj_data, 'mthnumlon'));
    p_numlon            := (p_yrenumlon * 12) + p_mthnumlon;
    p_amtlon            := to_number(hcm_util.get_number_t(obj_data, 'amtlon'));
    obj_formula         := hcm_util.get_json_t(obj_data, 'formula');
    p_formula           := hcm_util.get_string_t(obj_formula, 'code');
    p_statement         := hcm_util.get_string_t(obj_formula, 'description');
    p_dtelonst          := to_date(hcm_util.get_string_t(obj_data, 'dtelonst'), 'DD/MM/YYYY');
    p_dtelonen          := to_date(hcm_util.get_string_t(obj_data, 'dtelonen'), 'DD/MM/YYYY');
    p_dteissue          := to_date(hcm_util.get_string_t(obj_data, 'dteissue'), 'DD/MM/YYYY');
    p_dtestcal          := to_date(hcm_util.get_string_t(obj_data, 'dtestcal'), 'DD/MM/YYYY');
    p_typpayamt         := to_char(hcm_util.get_number_t(obj_data, 'typpayamt'));
    p_dteyrpay          := to_number(hcm_util.get_number_t(obj_data, 'dteyrpay'));
    p_mthpay            := to_number(hcm_util.get_number_t(obj_data, 'mthpay'));
    p_prdpay            := to_number(hcm_util.get_number_t(obj_data, 'prdpay'));
    p_reaslon           := hcm_util.get_string_t(obj_data, 'reaslon');
    p_typpay            := to_number(hcm_util.get_number_t(obj_data, 'typpay'));
    p_amtiflat          := to_number(hcm_util.get_number_t(obj_data, 'amtiflat'));
    p_amttlpay          := to_number(hcm_util.get_number_t(obj_data, 'amttlpay'));
    p_amtitotflat       := to_number(hcm_util.get_number_t(obj_data, 'amtitotflat'));
    p_amtpaybo          := to_number(hcm_util.get_string_t(obj_data, 'amtpaybo'));
    p_qtyperiod         := to_number(hcm_util.get_number_t(obj_data, 'qtyperiod'));
    p_codreq            := hcm_util.get_string_t(obj_data, 'codreq');
  end initial_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_codform           tfwmailh.codform %type;
    v_msg_to            clob;
    v_template_to       clob;
    v_func_appr         tfwmailh.codappap%type;
    v_rowid             rowid;
    v_error             terrorm.errorno%type;
  begin
    initial_value(json_str_input);
    initial_save(json_params);
    if param_msg_error is null then
      check_save;
      if param_msg_error is null then
        save_tloaninf;
      end if;
      if param_msg_error is null then
        save_tloancol;
      end if;
      if param_msg_error is null then
        save_tloangar;
      end if;
    end if;
    if param_msg_error is null then
      if p_sendmail = 'Y' then
        begin
          select rowid
            into v_rowid
            from tloaninf
           where numcont = p_numcont;
        exception when no_data_found then
          null;
        end;

        v_error := chk_flowmail.send_mail_for_approve('HRBF53E', p_codempid, global_v_codempid, global_v_coduser, null, 'HRBF56U', 170, 'E', 'P', 1, null, null,'TLOANINF',v_rowid, '1', null);
        commit;
        param_msg_error := get_error_msg_php('HR' || v_error, global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      else
        commit;
        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
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

  procedure save_index (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_flg               varchar2(10 char);
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      for i in 0 .. json_params.get_size - 1 loop
        obj_data        := hcm_util.get_json_t(json_params, to_char(i));
        v_flg           := hcm_util.get_string_t(obj_data, 'flg');
        p_numcont       := hcm_util.get_string_t(obj_data, 'numcont');
        if param_msg_error is null then
          begin
            delete
              from tloaninf
             where numcont  = p_numcont;
            if param_msg_error is null then
              begin
                delete
                  from tloancol
                 where numcont  = p_numcont;
              exception when others then
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
              end;
            end if;
            if param_msg_error is null then
              begin
                delete
                  from tloangar
                 where numcont  = p_numcont;
              exception when others then
                param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
              end;
            end if;
          exception when others then
            param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace || '@#$%400';
          end;
        end if;
      end loop;
    end if;
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2425', global_v_lang);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      rollback;
    end if;
    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end save_index;

  function cal_amtitotflat (v_textCal clob) return number is
    v_stmt              clob;
    v_amtcal            number := 0;
  begin
    v_stmt              := 'select ' || v_textCal || ' from dual';
    execute immediate v_stmt into v_amtcal;
    return v_amtcal;
  end cal_amtitotflat;

  procedure cal_loan (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
  begin
    initial_value(json_str_input);
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    if param_msg_error is null then
      obj_data.put('amtcal', cal_amtitotflat(p_textCal));
    end if;
    if param_msg_error is null then
      json_str_output     := obj_data.to_clob;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end cal_loan;

  procedure get_detail_descpay (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_descpay(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail_descpay;

  procedure gen_detail_descpay (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_mthpyre           varchar2(50 char);
    v_amtlonin          number := 0;
    v_amtlon            number := 0;
    v_intrst            number := 0;
    v_amount            number := 0;
    v_remain            number := 0;
    v_dtetmp            date;
    v_dayofmth          number := 0;

  begin
    obj_rows    := json_object_t();
    v_amtlonin  := p_amtlon;
    if p_amtlon > 0 then
      v_dtetmp    := to_date(p_dteyrpay || '/' || lpad(p_mthpay, 2, '0') || '/' || lpad(p_prdpay, 2, '0'), 'YYYY/MM/DD');
      for i in 1 .. p_qtyperiod loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        v_mthpyre   := to_char(v_dtetmp, 'MM') || '/' || (to_number(to_char(v_dtetmp, 'YYYY')) + p_additional_year);
        v_amount    := p_amttlpay;
        if p_typintr = '1' then
          v_dayofmth  := to_number(to_char(last_day(v_dtetmp), 'DD'));
          v_intrst    := round(((v_amtlonin * (p_rateilon / 100) * v_dayofmth) / 365),2);
          v_amtlon    := p_amttlpay - v_intrst;
          v_remain    := v_amtlonin - v_amtlon;
        elsif p_typintr = '2' then
          v_intrst    := nvl(cal_amtitotflat(p_textCal), 0);
          v_amtlon    := nvl(p_amttlpay, 0) - v_intrst;
          v_remain    := v_amtlonin - v_amtlon;
        else
          v_intrst    := nvl(p_amtiflat, 0);
          v_amtlon    := nvl(p_amttlpay, 0) - v_intrst;
          v_remain    := v_amtlonin - v_amtlon;
        end if;
        if v_remain < p_amttlpay and i = p_qtyperiod then
          v_amount    := v_amount + v_remain;
          v_remain    := 0;
          v_amtlon    := v_amount - v_intrst;
        end if;
        obj_data.put('coderror', '200');
        obj_data.put('period', to_char(i));
        obj_data.put('mthpyre', v_mthpyre);
        obj_data.put('amtlonin', v_amtlonin);
        obj_data.put('amtlon', v_amtlon);
        obj_data.put('intrst', v_intrst);
        obj_data.put('amount', v_amount);
        obj_data.put('remain', v_remain);
        v_amtlonin  := v_remain;

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
        v_dtetmp  := add_months(v_dtetmp, 1);
      end loop;
    end if;
    json_str_output := obj_rows.to_clob;
  end gen_detail_descpay;
end HRBF53E;

/
