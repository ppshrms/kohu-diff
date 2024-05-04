--------------------------------------------------------
--  DDL for Package Body HRES77E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES77E" as
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
    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj, 'p_numseq');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');

    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
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
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');
    p_additional_year   := to_number(hcm_appsettings.get_additional_year);
    p_sendmail          := hcm_util.get_string_t(json_obj, 'p_sendmail');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index AS
    v_staemp            temploy1.staemp%type;
    v_numlvl            temploy1.numlvl%type;
  begin
    if p_dtestrt is not null and p_dteend is not null then
      if p_dtestrt > p_dteend then
         param_msg_error := get_error_msg_php('HR2021', global_v_lang);
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

    cursor c1 is
      select *
      from tloanreq
      where codempid = p_codempid
      and dtereq between nvl(p_dtestrt,dtereq) and nvl(p_dteend,dtereq)
      order by dtereq desc;

  begin
    obj_rows    := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('codempid' , r1.codempid );
      obj_data.put('numseq' , r1.numseq );
      obj_data.put('dtereq' , to_char(r1.dtereq,'dd/mm/yyyy') );
      obj_data.put('numcont' , r1.numcont );
      obj_data.put('desc_codlon' , get_ttyplone_name(r1.codlon, global_v_lang) );
      obj_data.put('amtlon' , r1.amtlon );
      obj_data.put('numlon' , r1.numlon );
      obj_data.put('status' , get_tlistval_name('ESSTAREQ',trim(r1.staappr),global_v_lang) );
      obj_data.put('staappr' , r1.staappr );
      obj_data.put('remarkap' , r1.remarkap );
      obj_data.put('desc_codappr' , r1.codappr || ' ' ||get_temploy_name(r1.codappr,global_v_lang) );
      obj_data.put('desc_codempap' , chk_workflow.get_next_approve('HRES77E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.approvno),'0'),global_v_lang) );
      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_rows.to_clob;
  end gen_index;

  procedure check_detail AS
    v_codempid        tloaninf.codempid%type;
  begin
    if p_codempid is null or p_dtereq is null then
       param_msg_error := get_error_msg_php('HR2045', global_v_lang);
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
    v_tloanreq          tloanreq%rowtype;
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
    v_flag              varchar2(10 char);

    cursor c1 is
      select codempid, codcomp, numcont, codlon, typintr, rateilon, numlon, amtlon, formula,
             dtelonst, dtelonen, dteissue, dtestcal, typpayamt, dteyrpay, mthpay, prdpay,
             reaslon, typpay, amtiflat, amtitotflat, amttlpay, amtpaybo, qtyperiod, codreq, stalon,
             amtnpfin, dteaccls, dtelpay, desaccls, dteappr, codappr, staappr, qtyperip
        from tloaninf
       where codempid = p_codempid
         and numcont  = p_numcont;
  begin
   -- check numseq
    if p_numseq is null then
      begin
        select nvl(max(numseq),0) + 1 into p_numseq
          from tloanreq
         where codempid = p_codempid
           and dtereq = p_dtereq;
      exception when no_data_found then
        p_numseq := 1;
      end;
    end if;
    --  get data from tloanreq
    begin
      select * into v_tloanreq
        from tloanreq
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq;
      v_flag := 'edit';
    exception when no_data_found then
      v_tloanreq := null;
      v_flag    := 'add';
    end;
    p_codcomp   := hcm_util.get_temploy_field(p_codempid, 'codcomp');
    if v_flag = 'add' then
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid);
      obj_data.put('numseq', p_numseq);
      obj_data.put('dtereq', to_char(sysdate, 'DD/MM/YYYY'));
      obj_data.put('codcomp', p_codcomp );
      obj_data.put('staappr', '' );
      obj_data.put('amtiflat', '' );
      obj_data.put('amtitotflat',  '' );
      obj_data.put('amtlon',  '' );
      obj_data.put('amtmxlon', '' );
      obj_data.put('amtpaybo', '' );
      obj_data.put('amttlpay','0.00' );
      obj_data.put('codappr', '' );
      obj_data.put('codlon','');
      obj_data.put('codreq', p_codempid );
      obj_data.put('desc_codappr', '' );
      obj_data.put('dteappr', '' );
      obj_data.put('dteissue', to_char(sysdate, 'DD/MM/YYYY') );
      obj_data.put('dtelonst', '' );
      obj_data.put('dteyrpay', to_char(sysdate, 'YYYY') );
      obj_data.put('formula', '' );
      obj_data.put('desc_formula', '');
      obj_data.put('mthnumlon', '');
      obj_data.put('mthnummxlon','');
      obj_data.put('mthpay',to_number(to_char(sysdate, 'MM')));
      obj_data.put('numcont', '' );
      obj_data.put('prdpay','1' );
      obj_data.put('qtyperiod', '');
      obj_data.put('rateilon','' );
      obj_data.put('reaslon', '');
      obj_data.put('typintr','' );
      obj_data.put('typpay', '1' );
      obj_data.put('typpayamt','1' );
      obj_data.put('yrenumlon', '' );--
      obj_data.put('yrenummxlon', '' );--
    --
    elsif v_flag = 'edit' then
      begin
        select amtmxlon, ratelon, nummxlon, qtygar, condgar, amtasgar
          into v_amtmxlon, v_ratelon, v_nummxlon, v_qtygar, v_condgar, v_amtasgar
          from ttyploan
         where codlon = v_tloanreq.codlon;
      exception when no_data_found then
        null;
      end;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid);
      obj_data.put('numseq', p_numseq );
      obj_data.put('dtereq' , to_char(p_dtereq,'dd/mm/yyyy') );
      obj_data.put('staappr', v_tloanreq.staappr );
      obj_data.put('codcomp', v_tloanreq.codcomp );
      obj_data.put('amtiflat', v_tloanreq.amtiflat );
      obj_data.put('amtitotflat', v_tloanreq.amtitotflat );
      obj_data.put('amtlon', v_tloanreq.amtlon );
      obj_data.put('amtmxlon', v_amtmxlon );
      obj_data.put('amtpaybo', v_tloanreq.amtpaybo );
      obj_data.put('amttlpay', v_tloanreq.amttlpay );
      obj_data.put('codappr', v_tloanreq.codappr );
      obj_data.put('codlon', v_tloanreq.codlon );
      obj_data.put('codreq', p_codempid );
      obj_data.put('desc_codappr', v_tloanreq.codappr || ' - ' || get_temploy_name(v_tloanreq.codappr, global_v_lang) );
      obj_data.put('dteappr', v_tloanreq.dteappr );
      obj_data.put('dteissue', to_char(v_tloanreq.dtelonst,'dd/mm/yyyy') );
      obj_data.put('dtelonst', to_char(v_tloanreq.dtelonst,'dd/mm/yyyy') );
      obj_data.put('dteyrpay', v_tloanreq.dteyrpay );
      obj_data.put('formula', v_tloanreq.formula );
      obj_data.put('desc_formula', hcm_formula.get_description(v_tloanreq.formula , global_v_lang));
      obj_data.put('mthnumlon', mod(nvl(v_tloanreq.numlon, 0), 12) );
      obj_data.put('mthnummxlon', mod(nvl(v_nummxlon, 0), 12) );
      obj_data.put('mthpay', v_tloanreq.mthpay );
      obj_data.put('numcont', v_tloanreq.numcont );
      obj_data.put('prdpay', v_tloanreq.prdpay );
      obj_data.put('qtyperiod', v_tloanreq.qtyperiod );
      obj_data.put('rateilon', v_tloanreq.rateilon );
      obj_data.put('reaslon', v_tloanreq.reaslon );
      obj_data.put('typintr', v_tloanreq.typintr );
      obj_data.put('typpay', v_tloanreq.typpay );
      obj_data.put('typpayamt', v_tloanreq.typpayamt );
      obj_data.put('qtyperip', '' );
      obj_data.put('yrenumlon', floor(nvl(v_tloanreq.numlon, 0) / 12) );--
      obj_data.put('yrenummxlon', floor(nvl(v_nummxlon, 0) / 12));--
    end if;
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
      select *
        from tloanreq2
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq
       order by codcolla;
       --TLOANREQ2
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
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
    v_codcomp           temploy1.codcomp%type;
    v_codpos      temploy1.codpos%type;
    v_dteempmt    temploy1.dteempmt%type;
    cursor c1 is
      select *
        from tloanreq3
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq
       order by codempgar;
--      select b.codempgar, a.codcomp, a.codpos, a.dteempmt, b.amtgar
--        from tloangar b, temploy1 a
--       where b.numcont   = p_numcont
--         and b.codempgar = a.codempid
--       order by b.codempgar;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      begin
        select codcomp, codpos, dteempmt into v_codcomp, v_codpos, v_dteempmt
        from temploy1
        where codempid = i.codempid;
      exception when no_data_found then
        null;
      end;
      get_service_year(v_dteempmt, sysdate, 'Y', v_year, v_month, v_day);
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('image', get_emp_img(i.codempgar));
      obj_data.put('codempgar', i.codempgar);
      obj_data.put('desc_codempgar', get_temploy_name(i.codempgar, global_v_lang));
      obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang));
      obj_data.put('desc_codpos', get_tpostn_name(v_codpos, global_v_lang));
      obj_data.put('qtywork', v_year || '(' || v_month || ')');
      obj_data.put('amount', i.amtgar);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_tloangar;
  procedure get_tloaninf (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_tloaninf(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tloaninf;

  procedure gen_tloaninf (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_year              number := 0;
    v_month             number := 0;
    v_day               number := 0;

    cursor c1 is
      select *
        from tloaninf
       where codempid = p_codempid
       order by numcont;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
--      begin
--        select codcomp, codpos, dteempmt into v_codcomp, v_codpos, v_dteempmt
--        from temploy1
--        where codempid = i.codempid;
--      exception when no_data_found then
--        null;
--      end;
      v_rcnt      := v_rcnt + 1;
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numcont', i.numcont);
      obj_data.put('desc_codlon', get_ttyplone_name(i.codlon, global_v_lang));
      obj_data.put('amtlon', i.amtlon);
      obj_data.put('amt_remaining', i.amtlon - i.amttotpay);
      obj_data.put('amttlpay', i.amttlpay);
      obj_data.put('desc_stalon', get_tlistval_name('STALOAN', i.stalon, global_v_lang));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_tloaninf;
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
    v_dteempdb          temploy1.dteempdb%type;
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
      select codcomp, typpayroll, dteempdb, numlvl, codpos, jobgrade
        into v_codcomp, v_typpayroll, v_dteempdb, v_numlvl, v_codpos, v_jobgrade
        from temploy1
       where codempid = v_codempgar;
      get_service_year(v_dteempdb, sysdate, 'Y', v_year, v_month, v_day);
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
--      begin
--        select condgar
--          into p_condgar
--          from ttyploan
--         where codlon = p_codlon;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'ttyploan');
--        return;
--      end;
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
--    begin
--      select codempgar
--        into b_codempgar
--        from tloangar
--       where numcont   = p_numcont
--         and codempgar = p_codempgar;
--      param_msg_error := get_error_msg_php('HR2005', global_v_lang);
--      return;
--    exception when no_data_found then
--      null;
--    end;
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
--    begin
--      select formula
--        into b_formula
--        from tloaninf
--       where numcont = p_numcont;
--    exception when no_data_found then
--      null;
--    end;
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
--    if v_typintr = '2' and b_formula is not null then
--      v_formula := b_formula;
--    end if;
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
        get_wage_income(v_codcompy, v_codempmt,
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
    if p_amtlon is null then
      v_amtlon            := v_amtmxlon;
    else
      v_amtlon            := p_amtlon;
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
                            and amtlon   >= v_amtlon)
         and dteeffec = (select max(dteeffec)
                           from tintrted
                          where codcompy = a.codcompy
                            and codlon   = a.codlon
                            and trunc(dteeffec) <= trunc(sysdate)
                            );
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
--    if nvl(v_qtygar, 0) > 0 or v_condgar is not null then
--      obj_data.put('reqgar', 'Y');
--    else
--      obj_data.put('reqgar', 'N');
--    end if;
--    if nvl(v_amtasgar, 0) > 0 then
--      obj_data.put('reqcol', 'Y');
--    else
--      obj_data.put('reqcol', 'N');
--    end if;
    json_str_output := obj_data.to_clob;
  end gen_tintrteh;

  procedure save_tloanreq AS    
    v_codcompy          tcompny.codcompy%type;
    v_codempmt          temploy1.codempmt%type;
    v_ratelon           number := 0;
    v_amtmxlon          number := 0;
    v_amtothr           number;
    v_amtday            number;
    v_amtmth            number;
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
  begin
    begin
      select ratelon
        into v_ratelon
        from ttyploan 
        where codlon = p_codlon;
    exception when others then
      null;
    end;
    if v_ratelon is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, '1');
      begin
        select codempmt into v_codempmt
        from   temploy1
        where  codempid = p_codempid;
      exception when others then 
        v_codempmt := null;
      end;
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
      get_wage_income(v_codcompy, v_codempmt,
                      v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                      v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
                      v_amtothr, v_amtday, v_amtmth);
      v_amtmxlon := nvl(v_amtmth, 0) * v_ratelon;    
      if v_amtmxlon < p_amtlon then
        param_msg_error := get_error_msg_php('BF0069', global_v_lang);      
        return;
      end if;
    end if;
--    begin
--      select count(*) into v_count
--        from tloanreq
--       where codempid = p_codempid
--         and dtereq = p_dtereq
--         and numseq = p_numseq;
--    end;
    begin
      insert into tloanreq (codempid, dtereq, numseq, codcomp, codlon,
                            typintr, rateilon, dtelonst, numlon, qtyperiod,
                            amttlpay, amtpaybo, reaslon, typpay, amtlon, amtiflat, amtitotflat,
                            typpayamt, dteyrpay, mthpay, prdpay, dteeffec,
                            formula, statementf,
                            approvno, remarkap, staappr, routeno,
                            dteinput, dtesnd, dteapph,
                            dtecreate, codcreate, coduser)
            values (p_codempid, p_dtereq, p_numseq, p_codcomp, p_codlon,
                    p_typintr, p_rateilon, p_dteissue, p_numlon, p_qtyperiod,
                    p_amttlpay, p_amtpaybo, p_reaslon, p_typpay, p_amtlon, p_amtiflat, p_amtitotflat,
                    p_typpayamt, p_dteyrpay, p_mthpay, p_prdpay, p_dteeffec,
                    p_formula, p_statement,
                    tloanreq_approvno, tloanreq_remarkap, tloanreq_staappr, tloanreq_routeno,
                    trunc(sysdate), null, trunc(sysdate),
                    trunc(sysdate), global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      begin
        update tloanreq
          set codcomp	=	p_codcomp,
              codlon	=	p_codlon,
              typintr	=	p_typintr,
              rateilon	=	p_rateilon,
              dtelonst	=	p_dteissue,
              numlon	=	p_numlon,
              qtyperiod	=	p_qtyperiod,
              amttlpay	=	p_amttlpay,
              amtpaybo	=	p_amtpaybo,
              reaslon	=	p_reaslon,
              typpay	=	p_typpay,
              amtlon	=	p_amtlon,
              amtiflat	=	p_amtiflat,
              amtitotflat	=	p_amtitotflat,
              typpayamt	=	p_typpayamt,
              dteyrpay	=	p_dteyrpay,
              mthpay	=	p_mthpay,
              prdpay	=	p_prdpay,
              dteeffec	=	p_dteeffec,
              formula	=	p_formula,
              statementf	=	p_statement,
              approvno	=	tloanreq_approvno,
              remarkap	=	tloanreq_remarkap,
              staappr	=	tloanreq_staappr,
              routeno	=	tloanreq_routeno,
              dteupd  = sysdate,
              coduser = global_v_coduser
        where codempid = p_codempid
          and dtereq = p_dtereq
          and numseq = p_numseq;
      end;
    end;
  end save_tloanreq;

  procedure save_tloanreq2 as
    obj_data            json_object_t;
    v_codcolla          tloancol.codcolla%type;
    v_amtcolla          tloancol.amtcolla%type;
    v_numrefer          tloancol.numrefer%type;
    v_descolla          tloancol.descolla%type;
    v_sum               number := 0;
    v_flg               varchar2(10 char);
  begin
    for i in 0..obj_tloancol.get_size - 1 loop
      obj_data        := hcm_util.get_json_t(obj_tloancol, to_char(i));
      v_flg           := hcm_util.get_string_t(obj_data, 'flg');
      v_codcolla      := hcm_util.get_string_t(obj_data, 'codcolla');
      v_amtcolla      := to_number(hcm_util.get_number_t(obj_data, 'amtcolla'));
      v_numrefer      := hcm_util.get_string_t(obj_data, 'numrefer');
      v_descolla      := hcm_util.get_string_t(obj_data, 'descolla');
      if v_flg = 'delete' then
        delete
          from tloanreq2
         where codempid = p_codempid
           and dtereq   = p_dtereq
           and numseq   = p_numseq
           and codcolla = v_codcolla;
      else
        begin
          insert into tloanreq2 (codempid, dtereq, numseq, codcolla, amtcolla, numrefer, descolla, dtecreate, codcreate, coduser)
               values (p_codempid, p_dtereq, p_numseq, v_codcolla, v_amtcolla, v_numrefer, v_descolla, sysdate, global_v_coduser, global_v_coduser);
        exception when dup_val_on_index then
          update tloanreq2
             set amtcolla = v_amtcolla,
                 numrefer = v_numrefer,
                 descolla = v_descolla,
                 dteupd   = sysdate,
                 coduser  = global_v_coduser
           where codempid = p_codempid
             and dtereq   = p_dtereq
             and numseq   = p_numseq
             and codcolla = v_codcolla;
        end;
      end if;
    end loop;
    begin
      select nvl(sum(nvl(amtcolla,0)),0)
        into v_sum
        from tloanreq2 
        where codempid = p_codempid
          and dtereq = p_dtereq
          and numseq = p_numseq;
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
  end save_tloanreq2;

  procedure save_tloanreq3 as
    obj_data            json_object_t;
    v_codempgar         tloangar.codempgar%type;
    v_amount            tloangar.amtgar%type;
    v_flg               varchar2(10 char);
    v_count             number := 0;
    v_sum               number := 0;

  begin
    for i in 0..obj_tloangar.get_size - 1 loop
      obj_data        := hcm_util.get_json_t(obj_tloangar, to_char(i));
      v_flg           := hcm_util.get_string_t(obj_data, 'flg');
      v_codempgar     := hcm_util.get_string_t(obj_data, 'codempgar');
      v_amount        := to_number(hcm_util.get_number_t(obj_data, 'amount'));
      check_codempgar(v_codempgar);
      if param_msg_error is null then
        if v_flg = 'delete' then
          delete
            from tloanreq3
           where codempid  = p_codempid
             and dtereq    = p_dtereq
             and numseq    = p_numseq
             and codempgar = v_codempgar;
        else
          begin
            insert into tloanreq3 (codempid, dtereq, numseq, codempgar, amtgar, dtecreate, codcreate, coduser)
                 values (p_codempid, p_dtereq, p_numseq, v_codempgar, v_amount, sysdate, global_v_coduser, global_v_coduser);
          exception when dup_val_on_index then
            update tloanreq3
               set amtgar    = v_amount,
                   dteupd    = sysdate,
                   coduser   = global_v_coduser
             where codempid  = p_codempid
               and dtereq    = p_dtereq
               and numseq    = p_numseq
               and codempgar = v_codempgar;
          end;
        end if;
      else
        exit;
      end if;
    end loop;
    begin
      select count(*), nvl(sum(nvl(amtgar,0)),0)
        into v_count, v_sum
        from tloanreq3
       where codempid = p_codempid
         and dtereq   = p_dtereq
         and numseq   = p_numseq;
    exception when others then
      null;
    end;
    if param_msg_error is not null then
      return;
    end if;
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
        param_msg_error := replace(param_msg_error, '[P-AMTGAR]', to_char(p_amtguarntr, 'fm99,999,990.90')||', req='||to_char(v_sum, 'fm99,999,990.90'));
        return;
      end if;
    end if;
  end save_tloanreq3;

  procedure check_save AS
    v_flgfound          boolean := false;
    v_dteempdb          temploy1.dteempdb%type;
    v_numlvl            temploy1.numlvl%type;
    v_codpos            temploy1.codpos%type;
    v_jobgrade          temploy1.jobgrade%type;
    v_condlon           ttyploan.condlon%type;
    v_statment          ttyploan.condlon%type;
    v_year              number;
    v_month             number;
    v_day               number;
  begin
    if p_codlon is null or p_amtlon is null or p_yrenumlon is null or p_mthnumlon is null or
       p_dteissue is null or p_prdpay is null or p_mthpay is null or p_dteyrpay is null or p_dteissue is null or
       p_reaslon is null
      then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_codempid is not null then
      begin
        select codcomp, typpayroll, dteempdb, numlvl, codpos, jobgrade
          into p_codcomp, p_typpayroll, v_dteempdb, v_numlvl, v_codpos, v_jobgrade
          from temploy1
        where codempid = p_codempid;
        get_service_year(v_dteempdb, sysdate, 'Y', v_year, v_month, v_day);
        begin
          select condlon, amtasgar, qtygar, amtguarntr, condgar
            into v_condlon, p_amtasgar, p_qtygar, p_amtguarntr, p_condgar
            from ttyploan
           where codlon = p_codlon;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'ttyploan');
          return;
        end;
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
    begin
      select dteeffec
        into p_dteeffec
        from tintrteh
       where codcompy = hcm_util.get_codcomp_level(p_codcomp, '1')
         and codlon   = p_codlon
         and dteeffec = (select max(dteeffec)
                           from tintrteh
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp, '1')
                            and codlon   = p_codlon);
    exception when no_data_found then
      null;
    end;
--    if param_msg_error is null then
--      begin
--        select a.condgar
--          into p_condgar
--          from ttyploan a, tloaninf b
--         where a.codlon  = b.codlon
--           and b.numcont = p_numcont;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'ttyploan');
--        return;
--      end;
--    end if;
  end check_save;

  procedure insert_next_step is
    v_codapp     varchar2(10) := 'HRES77E';
    v_count      number := 0;
    v_approvno   number := 0;
    v_codempid_next  temploy1.codempid%type;
    v_codempap   temploy1.codempid%type;
    v_codcompap  tcenter.codcomp%type;
    v_codposap   varchar2(4 char);
    v_remark     varchar2(200 char) := substr(get_label_name('HRESZXEC1',global_v_lang,99),1,200);
    v_routeno    varchar2(100 char);

    v_ok        boolean;

    v_flgfwbwlim  varchar2(1);
    v_qtyminle    number;
    v_qtydlefw    number;
    v_qtydlebw    number;

    v_dtefw       date;
    v_dteaw       date;
    v_typleave	  varchar2(4 char);
    v_table			  varchar2(50 char);
    v_error			  varchar2(50 char);
  begin
    v_approvno       := 0;
    v_codempap       := p_codempid;
    tloanreq_staappr  := 'P';
    chk_workflow.find_next_approve(v_codapp,v_routeno,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,p_codempid,'');

    if v_routeno is null then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflph');
      return;
    end if;
    --
    chk_workflow.find_approval(v_codapp,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,v_table,v_error);
    if v_error is not null then
      param_msg_error := get_error_msg_php(v_error,global_v_lang,v_table);
      return;
    end if;
     --Loop Check Next step
    loop
      v_codempid_next := chk_workflow.check_next_step(v_codapp,v_routeno,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,p_codempid);
      if  v_codempid_next is not null then
        v_approvno         := v_approvno + 1;
        tloanreq_codappr    := v_codempid_next;
        tloanreq_staappr    := 'A';
        tloanreq_dteappr    := trunc(sysdate);
        tloanreq_remarkap   := v_remark;
        tloanreq_approvno   := v_approvno;
        begin
            select  count(*) into v_count
             from   taploanrq
             where  codempid = p_codempid
             and    dtereq   = p_dtereq
             and    numseq   = p_numseq
             and    approvno = v_approvno;
        exception when no_data_found then  v_count := 0;
        end;

        if v_count = 0 then
          insert into taploanrq (codempid, dtereq, numseq, approvno,
--                                 amtalw, typpay,
                                 codappr, dteappr, staappr, remark, dteapph,
                                 dtecreate, codcreate, coduser)
              values (p_codempid, p_dtereq, p_numseq, v_approvno,
--                      p_amtalw, p_typpay,
                      v_codempid_next, trunc(sysdate), 'A', v_remark, sysdate,
                      sysdate, global_v_coduser, global_v_coduser);
        else
          update taploanrq
             set codappr = v_codempid_next,
                 dteappr   = trunc(sysdate),
                 staappr   = 'A',
                 remark    = v_remark ,
                 coduser   = global_v_coduser,
                 dteapph   = sysdate
           where codempid = p_codempid
             and dtereq   = p_dtereq
             and numseq   = p_numseq
             and approvno = v_approvno;
        end if;
        chk_workflow.find_next_approve(v_codapp,v_routeno,p_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,p_codempid,'');--user22 : 02/08/2016 : HRMS590307 || chk_workflow.find_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_seqno,v_approvno,b_index_codempid);
      else
        exit;
      end if;
    end loop;

    tloanreq_approvno     := v_approvno;
    tloanreq_routeno      := v_routeno;
  end;
  --
  procedure initial_save (json_str in clob) as
    obj_data            json_object_t;
    obj_input           json_object_t;
  begin
    obj_input           := json_object_t(json_str);
    obj_data            := hcm_util.get_json_t(obj_input, 'tab1');
    obj_tloancol        := hcm_util.get_json_t(obj_input, 'tloancol');
    obj_tloangar        := hcm_util.get_json_t(obj_input, 'tloangar');
    p_codempid          := hcm_util.get_string_t(obj_data, 'codempid');
    p_dtereq            := to_date(hcm_util.get_string_t(obj_data, 'dtereq'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(obj_data, 'numseq');
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
--    p_dtelonst          := to_date(hcm_util.get_string_t(obj_data, 'dteissue'), 'DD/MM/YYYY');
    p_dtelonen          := to_date(hcm_util.get_string_t(obj_data, 'dtelonen'), 'DD/MM/YYYY');
    p_dteissue          := to_date(hcm_util.get_string_t(obj_data, 'dteissue'), 'DD/MM/YYYY');
    p_dtestcal          := to_date(hcm_util.get_string_t(obj_data, 'dtestcal'), 'DD/MM/YYYY');
    p_typpayamt         := to_char(hcm_util.get_number_t(obj_data, 'typpayamt'));
    p_dteyrpay          := to_number(hcm_util.get_number_t(obj_data, 'dteyrpay'));
    p_mthpay            := to_number(hcm_util.get_number_t(obj_data, 'mthpay'));
    p_prdpay            := to_number(hcm_util.get_number_t(obj_data, 'prdpay'));
    p_reaslon           := hcm_util.get_string_t(obj_data, 'reaslon');
    p_typpay            := to_char(hcm_util.get_number_t(obj_data, 'typpay'));--to_number(hcm_util.get_number_t(obj_data, 'typpay'));

    p_amtiflat          := to_number(hcm_util.get_string_t(obj_data, 'amtiflat'));
    p_amttlpay          := to_number(hcm_util.get_number_t(obj_data, 'amttlpay'));
    p_amtitotflat       := to_number(hcm_util.get_string_t(obj_data, 'amtitotflat'));
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
    initial_save(json_str_input);
    if param_msg_error is null then
      check_save;
      insert_next_step;
      if param_msg_error is null then
        save_tloanreq;
      end if;
      if param_msg_error is null then
        save_tloanreq2;
      end if;
      if param_msg_error is null then
        save_tloanreq3;
      end if;
    end if;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
--      obj_data := json_object_t();
--      obj_data.put('coderror', '200');
--      obj_data.put('response', hcm_util.get_string_t(json_object_t(v_response),'response'));
--      obj_data.put('numvcher', p_numvcher);
--
--      json_str_output := obj_data.to_clob;
      commit;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      rollback;
    end if;
--    if param_msg_error is null then
--      if p_sendmail = 'Y' then
--        begin
--          select rowid
--            into v_rowid
--            from tloaninf
--           where numcont = p_numcont;
--        exception when no_data_found then
--          null;
--        end;
--        begin
--          select codform
--            into v_codform
--            from tfwmailh
--           where codapp = 'HRBF53E';
--        exception when no_data_found then
--          v_codform := null;
--        end;
--        chk_flowmail.get_message('HRBF53E', global_v_lang, v_msg_to, v_template_to, v_func_appr);
--        chk_flowmail.replace_text_frmmail(v_template_to, 'TLOANINF', v_rowid, get_label_name('HRBF53E', global_v_lang, 90), v_codform, '1', v_func_appr, global_v_coduser, global_v_lang, v_msg_to);
--        v_error := chk_flowmail.send_mail_to_approve('HRBF53E', p_codempid, p_numcont, v_msg_to, null, get_label_name('HRBF53E', global_v_lang, 90), 'E', 'P', global_v_lang, 1, null, null);
--        commit;
--        param_msg_error := get_error_msg_php('HR' || v_error, global_v_lang);
--        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--      else
--        commit;
--        param_msg_error := get_error_msg_php('HR2401', global_v_lang);
--        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
--      end if;
--    else
--      rollback;
--    end if;
--    json_str_output := get_response_message(null, param_msg_error, global_v_lang);
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
    p_codempid          := hcm_util.get_string_t(json_params, 'codempid');
    p_dtereq            := to_date(hcm_util.get_string_t(json_params,'dtereq'),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_params, 'numseq');
    begin
      update tloanreq
         set staappr = 'C',
             dtecancel = trunc(sysdate),
             coduser = global_v_coduser
       where codempid = p_codempid
         and dtereq = p_dtereq
         and numseq = p_numseq;
    exception when no_data_found then
      null;
    end;
    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      commit;
    else
      json_str_output := param_msg_error;
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
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
      for i in 1..p_qtyperiod loop
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        v_dtetmp    := add_months(p_dtelonst, i);
        v_mthpyre   := to_char(v_dtetmp, 'MM') || '/' || (to_number(to_char(v_dtetmp, 'YYYY')) + p_additional_year);
        v_amount    := p_amttlpay;
        if p_typintr = '1' then
          v_dayofmth  := to_number(to_char(last_day(v_dtetmp), 'DD'));
          v_intrst    := (v_amtlonin * (p_rateilon / 100) * v_dayofmth) / 365;
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
      end loop;
    end if;
    json_str_output := obj_rows.to_clob;
  end gen_detail_descpay;

  procedure gen_loan_condition(json_str_output out clob) as
    obj_data        json_object_t;
    obj_data2       json_object_t;
    v_ttyploan      ttyploan%rowtype;
    v_flag          varchar(50 char) := 'Edit';
    v_deslon        ttyploan.deslone%type;
  begin
    begin
      select * into v_ttyploan
        from ttyploan
       where codlon = p_codlon;
    exception when no_data_found then
      v_ttyploan := null;
      v_flag     := 'Add';
    end;
    begin
      select decode(global_v_lang,'101',deslone
                                 ,'102',deslont
                                 ,'103',deslon3
                                 ,'104',deslon4
                                 ,'105',deslon5) as deslon
      into v_deslon
      from ttyploan
      where codlon = p_codlon;
    exception when no_data_found then
      v_deslon := null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror',200);
    obj_data.put('codlon',p_codlon);
    obj_data.put('deslon',v_deslon);
    obj_data.put('deslone',v_ttyploan.deslone);
    obj_data.put('deslont',v_ttyploan.deslont);
    obj_data.put('deslon3',v_ttyploan.deslon3);
    obj_data.put('deslon4',v_ttyploan.deslon4);
    obj_data.put('deslon5',v_ttyploan.deslon5);
    obj_data.put('amtmxlon',v_ttyploan.amtmxlon);
    obj_data.put('ratelon',v_ttyploan.ratelon);
    obj_data.put('nummxlony',floor(nvl(v_ttyploan.nummxlon, 0) / 12));
    obj_data.put('nummxlonm',mod(nvl(v_ttyploan.nummxlon, 0), 12));
--  add logical statement
    obj_data.put('statement_condlon',get_logical_desc(v_ttyploan.statementl));
    obj_data.put('amtasgar',v_ttyploan.amtasgar);
    obj_data.put('qtygar',v_ttyploan.qtygar);
    obj_data.put('amtguarntr',v_ttyploan.amtguarntr);
--  add logical statement
    obj_data.put('statement_condgar',get_logical_desc(v_ttyploan.statementg));

    json_str_output := obj_data.to_clob;

  end gen_loan_condition;

  procedure get_loan_condition(json_str_input in clob,json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    gen_loan_condition(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_loan_condition;
end hres77e;

/
