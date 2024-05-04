--------------------------------------------------------
--  DDL for Package Body HRBF5EE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF5EE" AS
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

    p_additional_year   := hcm_appsettings.get_additional_year;
    p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_numcont           := hcm_util.get_string_t(json_obj, 'p_numcont');
    p_typtran           := to_char(hcm_util.get_number_t(json_obj, 'p_typtran'));
    p_dteadjust         := to_date(hcm_util.get_string_t(json_obj, 'p_dteadjust'), 'DD/MM/YYYY');
    p_dteeffec          := to_date(hcm_util.get_string_t(json_obj, 'p_dteeffec'), 'DD/MM/YYYY');
    p_codappr           := hcm_util.get_string_t(json_obj, 'p_codappr');
    p_dteappr           := to_date(hcm_util.get_string_t(json_obj, 'p_dteappr'), 'DD/MM/YYYY');
    -- save
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  function cal_formula (v_formula clob) return number is
    v_stmt              clob;
    v_amtcal            number := 0;
  begin
    v_stmt              := v_formula;
    v_stmt              := replace(v_stmt, '{[A]}', nvl(p_amtlon, 0));
    v_stmt              := replace(v_stmt, '{[R]}', nvl(p_rateilon, 0));
    v_stmt              := replace(v_stmt, '{[T]}', nvl(p_qtyperiod, 0));
    v_stmt              := replace(v_stmt, '{[P]}', nvl(p_qtypayn, 0));
    execute immediate 'select ' || v_stmt || ' from dual' into v_amtcal;
    return v_amtcal;
  end cal_formula;

  procedure check_index AS
    v_staemp            temploy1.staemp%type;
    v_codcomp           temploy1.codcomp%type;
    v_numlvl            temploy1.numlvl%type;
  begin
    if p_codempid_query is not null then
      begin
        select staemp, codcomp, numlvl
          into v_staemp, v_codcomp, v_numlvl
          from temploy1
        where codempid = p_codempid_query;
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
        elsif not secur_main.secur1(v_codcomp, v_numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
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
    else
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
    v_dtestrt           varchar2(10 char);
    v_dteend            varchar2(10 char);
    v_amount            number;

    cursor c1 is
     select codempid, numcont, codlon, amtlon, amtnpfin, dtelpay
       from tloaninf
      where codempid = p_codempid_query
        and stalon   <> 'C'
        and staappr  = 'Y'
      order by numcont;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      if secur_main.secur2(i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', i.codempid);
        obj_data.put('numcont', i.numcont);
        obj_data.put('codlon', i.codlon);
        obj_data.put('desc_codlon', get_ttyplone_name(i.codlon, global_v_lang));
        obj_data.put('amtlon', i.amtlon);
        obj_data.put('amtnpfin', i.amtnpfin);
        obj_data.put('dtelpay', to_char(i.dtelpay, 'DD/MM/YYYY'));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_index;

  procedure check_detail is
    v_staemp            temploy1.staemp%type;
    v_codcomp           temploy1.codcomp%type;
    v_numlvl            temploy1.numlvl%type;
  begin
    if p_codappr is not null then
      begin
        select staemp, codcomp, numlvl
          into v_staemp, v_codcomp, v_numlvl
          from temploy1
        where codempid = p_codappr;
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
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end if;
    end if;
  end check_detail;

  procedure check_tab1 is
    v_dtelpay           tloaninf.dtelpay%type;
    v_typpay            tloaninf.typpay%type;
  begin
    check_detail;
    if param_msg_error is not null then
      return;
    end if;
    begin
      select dtelpay, typpay
        into v_dtelpay, v_typpay
        from tloaninf
       where numcont = p_numcont;
    exception when no_data_found then
      null;
    end;
    if v_dtelpay is null then
      param_msg_error := get_error_msg_php('BF0032', global_v_lang);
      return;
    end if;
    if v_typpay <> '1' then
      param_msg_error := get_error_msg_php('BF0033', global_v_lang);
      return;
    end if;
  end check_tab1;

  procedure get_tab1 (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if p_typtran = '1' then
      check_tab1;
    end if;
    if param_msg_error is null then
      gen_tab1(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tab1;

  function explode (p_delimiter varchar2, p_string long, p_limit number default 1000) return arr_1d as
    v_str1        varchar2(4000 char);
    v_comma_pos   number := 0;
    v_start_pos   number := 1;
    v_loop_count  number := 0;

    arr_result    arr_1d;

  begin
    for i in 1..p_limit loop
      arr_result(i) := null;
    end loop;
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

  procedure gen_tab1 (json_str_output out clob) AS
    obj_data            json_object_t;
    obj_tmp             json_object_t;
    v_dtelpay           tloaninf.dtelpay%type;
    v_amtrepmto         tloanpay.amtrepmt%type := 0;
    v_amtrepmt          tloanpay.amtrepmt%type := 0;
    v_amtpfino          tloanpay.amtpfin%type := 0;
    v_amtpfin           tloanpay.amtpfin%type := 0;
    v_amtpinto          tloanpay.amtpint%type := 0;
    v_amtpint           tloanpay.amtpint%type := 0;
    v_amtintst          tloanpay.amtintst%type := 0;
    v_amtinten          tloanpay.amtinten%type := 0;
    v_amtpfinst         tloanpay.amtpfinst%type := 0;
    v_amtpfinen         tloanpay.amtpfinen%type := 0;
    v_amtnpfin          tloaninf.amtnpfin%type := 0;
    v_prdlcal           tloaninf.prdlcal%type;
    v_mthlcal           tloaninf.mthlcal%type;
    v_yrelcal           tloaninf.yrelcal%type;
    v_periodpay         tloanadj.periodpay%type;
    v_remark            tloanadj.descadj%type;
    v_desc_periodpay    varchar2(1000 char);
    arr_result          arr_1d;
    index_array         number := 3;
    v_dterepmt          tloanpay.dterepmt%type;
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('dteeffec', to_char(p_dteeffec, 'DD/MM/YYYY'));
    if p_typtran = '1' then
      begin
        select periodpay, amtpayo, amtpayn, amtlono, amtlonn, amtpinto, amtpintn, descadj
          into v_periodpay, v_amtrepmto, v_amtrepmt, v_amtpfino, v_amtpfin, v_amtpinto, v_amtpint, v_remark
          from tloanadj
         where numcont   = p_numcont
           and dteadjust = p_dteadjust
           and dteeffec  = p_dteeffec
           and typtran   = p_typtran;

        begin
          select dtelpay
            into v_dtelpay
            from tloaninf
           where numcont = p_numcont;
        exception when no_data_found then
          null;
        end;
        for i in 1..index_array loop
          arr_result(i) := null;
        end loop;
        arr_result        := explode('/', v_periodpay, index_array);
        v_prdlcal         := to_number(arr_result(1));
        v_mthlcal         := to_number(arr_result(2));
        v_yrelcal         := to_number(arr_result(3));
        v_desc_periodpay  := v_prdlcal || ' ' || get_tlistval_name('MONTH', to_number(v_mthlcal), global_v_lang) || ' ' || to_char(to_number(v_yrelcal) + p_additional_year);
        obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR1505', global_v_lang), global_v_lang));
        obj_data.put('response', hcm_util.get_string_t(obj_tmp, 'response'));
      exception when no_data_found then
        begin
          select dtelpay, prdlcal, mthlcal, yrelcal, amtnpfin
            into v_dtelpay, v_prdlcal, v_mthlcal, v_yrelcal, v_amtnpfin
            from tloaninf
           where numcont = p_numcont;
           v_desc_periodpay  := v_prdlcal || ' ' || get_tlistval_name('MONTH', to_number(v_mthlcal), global_v_lang) || ' ' || to_char(to_number(v_yrelcal) + p_additional_year);
        exception when no_data_found then
          null;
        end;
        begin
          select amtrepmt, amtpfin, amtpint, amtinten, amtintst, amtpfinst, amtpfinen
            into v_amtrepmt, v_amtpfin, v_amtpint, v_amtinten, v_amtintst, v_amtpfinst, v_amtpfinen
            from tloanpay
           where numcont  = p_numcont
             and dterepmt = v_dtelpay
             and typtran  = '1';
        exception when no_data_found then
          null;
        end;
        v_amtrepmto     := v_amtrepmt;
        v_amtpfino      := v_amtpfin;
        v_amtpinto      := v_amtpint;
        v_periodpay     := v_prdlcal || '/' || v_mthlcal || '/' || v_yrelcal;
        begin
          select dterepmt
            into v_dterepmt
            from tloanpay
          where numcont  = p_numcont
            and dterepmt > v_dtelpay
            and typtran  = '2'
            and rownum   = 1
          order by dterepmt desc;
          obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR1501', global_v_lang), global_v_lang));
          obj_data.put('response', hcm_util.get_string_t(obj_tmp, 'response'));
          obj_data.put('dteeffec', to_char(v_dterepmt, 'DD/MM/YYYY'));
        exception when no_data_found then
          null;
        end;
      end;
    end if;
    obj_data.put('dtelpay', to_char(v_dtelpay, 'DD/MM/YYYY'));
    obj_data.put('periodpay', v_periodpay);
    obj_data.put('desc_periodpay', v_desc_periodpay);
    obj_data.put('amtrepmto', nvl(v_amtrepmto, 0));
    obj_data.put('amtrepmt', nvl(v_amtrepmt, 0));
    obj_data.put('amtpfino', nvl(v_amtpfino, 0));
    obj_data.put('amtpfin', nvl(v_amtpfin, 0));
    obj_data.put('amtpinto', nvl(v_amtpinto, 0));
    obj_data.put('amtpint', nvl(v_amtpint, 0));
    obj_data.put('amtintst', nvl(v_amtintst, 0));
    obj_data.put('amtinten', nvl(v_amtinten, 0));
    obj_data.put('amtpfinst', nvl(v_amtpfinst, 0));
    obj_data.put('amtpfinen', nvl(v_amtpfinen, 0));
    obj_data.put('amtnpfin', nvl(v_amtnpfin, 0));
    obj_data.put('remark', v_remark);
    json_str_output := obj_data.to_clob;
  end gen_tab1;

  procedure get_tab2 (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tab2(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tab2;

  procedure gen_tab2 (json_str_output out clob) AS
    obj_data            json_object_t;
    obj_tmp             json_object_t;
    v_qtyperip          tloaninf.qtyperip%type := 0;
    v_amtnpfin          tloaninf.amtnpfin%type := 0;
    v_amttlpay          tloaninf.amttlpay%type := 0;
    v_amtintovr         tloaninf.amtintovr%type := 0;
    v_amtiflat          tloaninf.amtiflat%type := 0;
    v_dtelpay           tloaninf.dtelpay%type;
    v_dtestcal          tloaninf.dtestcal%type;
    v_typintr           tloaninf.typintr%type;
    v_formula           tloaninf.formula%type;
    v_flgpay            tloanadj.flgpay%type := '1';
    v_amtpayc           tloanadj.amtpayc%type;
    v_amtpaycn          tloanadj.amtpayc%type;
    v_remark            tloanadj.descadj%type;
    v_amtrate           number := 0;
    v_dayofmth          number := 0;
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    if p_typtran = '2' then
      check_detail;
      if param_msg_error is not null then
        return;
      end if;
      begin
        select qtyperip, amtnpfin, amttlpay, amtintovr, dtestcal, dtelpay, typintr, rateilon, formula, qtyperiod, amtlon, amtiflat
          into v_qtyperip, v_amtnpfin, v_amttlpay, v_amtintovr, v_dtestcal, v_dtelpay, v_typintr, p_rateilon, v_formula, p_qtyperiod, p_amtlon, v_amtiflat
          from tloaninf
         where numcont = p_numcont;
        v_amtpayc       := v_amttlpay;
      exception when no_data_found then
        null;
      end;
      begin
        select numpay, flgpay, amtpayc, descadj
          into v_qtyperip, v_flgpay, v_amtpayc, v_remark
          from tloanadj
         where numcont   = p_numcont
           and dteadjust = p_dteadjust
           and dteeffec  = p_dteeffec
           and typtran   = p_typtran;
        obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR1505', global_v_lang), global_v_lang));
        obj_data.put('response', hcm_util.get_string_t(obj_tmp, 'response'));
      exception when no_data_found then
        if p_dteeffec <= v_dtelpay then
          param_msg_error := get_error_msg_php('BF0036', global_v_lang);
          return;
        end if;
        if v_typintr = '1' then
          v_amtrate         := round(((p_dteeffec - nvl(v_dtelpay, v_dtestcal)) / 365) * (p_rateilon / 100) *  v_amtnpfin, 2);
        elsif v_typintr = '2' then
          p_qtypayn         := p_qtyperiod - v_qtyperip;
          v_amtrate         := cal_formula(v_formula);
        elsif v_typintr = '3' then
          v_dayofmth        := to_number(to_char(last_day(p_dteeffec), 'DD'));
          v_amtrate         := (v_amtiflat / v_dayofmth) * to_number(to_char(p_dteeffec, 'DD'));
        end if;
        v_amtpaycn        := v_amtnpfin + v_amtintovr + v_amtrate;
        v_qtyperip        := v_qtyperip + 1;
      end;
    end if;
    obj_data.put('flgpay', v_flgpay);
    obj_data.put('qtyperip', nvl(v_qtyperip, 0));
    obj_data.put('amtnpfin', nvl(v_amtnpfin, 0));
    obj_data.put('amtpayc', nvl(v_amtpayc, 0));
    obj_data.put('amtpaycn', nvl(v_amtpaycn, 0));
    obj_data.put('amttlpay', nvl(v_amttlpay, 0));
    obj_data.put('amtintovr', nvl(v_amtintovr, 0));
    obj_data.put('remark', v_remark);
    json_str_output := obj_data.to_clob;
  end gen_tab2;

  procedure check_tab3 is
    v_dtelpay           tloaninf.dtelpay%type;
  begin
    check_detail;
    if param_msg_error is not null then
      return;
    end if;
    begin
      select dtelpay
        into v_dtelpay
        from tloaninf
       where numcont = p_numcont;
    exception when no_data_found then
      null;
    end;
    if p_dteeffec <= v_dtelpay then
      param_msg_error := get_error_msg_php('BF0036', global_v_lang);
      return;
    end if;
  end check_tab3;

  procedure get_tab3 (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if p_typtran = '3' then
      check_tab3;
    end if;
    if param_msg_error is null then
      gen_tab3(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tab3;

  procedure gen_tab3 (json_str_output out clob) AS
    obj_data            json_object_t;
    obj_tmp             json_object_t;
    v_amtnpfino         tloaninf.amtnpfin%type := 0;
    v_amtnpfin          tloaninf.amtnpfin%type := 0;
    v_amtintovro        tloaninf.amtintovr%type := 0;
    v_amtintovr         tloaninf.amtintovr%type := 0;
    v_amttlpayo         tloaninf.amttlpay%type := 0;
    v_amttlpay          tloaninf.amttlpay%type := 0;
    v_qtyperiod         tloaninf.qtyperiod%type := 0;
    v_qtyperip          tloaninf.qtyperip%type := 0;
    v_rateilono         tloaninf.rateilon%type := 0;
    v_rateilon          tloaninf.rateilon%type := 0;
    v_amtiflat          tloaninf.amtiflat%type := 0;
    v_qtypayo           tloanadj.qtypayo%type := 0;
    v_qtypayn           tloanadj.qtypayn%type := 0;
    v_remark            tloanadj.descadj%type;
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    if p_typtran = '3' then
      begin
        select amtnpfin, amtintovr, amttlpay, qtyperiod, qtyperip, rateilon, amtiflat
          into v_amtnpfin, v_amtintovr, v_amttlpay, v_qtyperiod, v_qtyperip, v_rateilon, v_amtiflat
          from tloaninf
          where numcont = p_numcont;
      exception when no_data_found then
        null;
      end;
      v_amtnpfino         := v_amtnpfin;
      v_amtintovro        := v_amtintovr;
      v_amttlpayo         := v_amttlpay;
      v_rateilono         := v_rateilon;
      v_qtypayo           := (nvl(v_qtyperiod, 0) - nvl(v_qtyperip, 0));
      v_qtypayn           := v_qtypayo;
      begin
        select amtpfino, amtpfinn, amtpinto2, amtpintn2,
               ratelono, ratelonn, descadj,
               amtrpmto, amtrpmtn, qtypayo, qtypayn
          into v_amtnpfino, v_amtnpfin, v_amtintovro, v_amtintovr,
               v_rateilono, v_rateilon, v_remark,
               v_amttlpayo, v_amttlpay, v_qtypayo, v_qtypayn
          from tloanadj
         where numcont   = p_numcont
           and dteadjust = p_dteadjust
           and dteeffec  = p_dteeffec
           and typtran   = p_typtran;
        obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR1505', global_v_lang), global_v_lang));
        obj_data.put('response', hcm_util.get_string_t(obj_tmp, 'response'));
      exception when no_data_found then
        null;
      end;
    end if;
    obj_data.put('amtnpfino', nvl(v_amtnpfino, 0));
    obj_data.put('amtnpfin', nvl(v_amtnpfin, 0));
    obj_data.put('amtintovro', nvl(v_amtintovro, 0));
    obj_data.put('amtintovr', nvl(v_amtintovr, 0));
    obj_data.put('amttlpayo', nvl(v_amttlpayo, 0));
    obj_data.put('amttlpay', nvl(v_amttlpay, 0));
    obj_data.put('rateilono', nvl(v_rateilono, 0));
    obj_data.put('rateilon', nvl(v_rateilon, 0));
    obj_data.put('qtypayo', nvl(v_qtypayo, 0));
    obj_data.put('qtypayn', nvl(v_qtypayn, 0));
    obj_data.put('amtiflat', nvl(v_amtiflat, 0));
    obj_data.put('remark', v_remark);
    json_str_output := obj_data.to_clob;
  end gen_tab3;

  procedure check_tab4 is
    v_codcompy          tcompny.codcompy%type;
    v_typpayroll        temploy1.typpayroll%type;
    v_yrelcal           tloaninf.yrelcal%type;
    v_mthlcal           tloaninf.mthlcal%type;
    v_prdlcal           tloaninf.prdlcal%type;
  begin
    check_detail;
    if param_msg_error is not null then
      return;
    end if;
    begin
      select hcm_util.get_codcomp_level(codcomp, 1), typpayroll, yrelcal, mthlcal, prdlcal
        into v_codcompy, v_typpayroll, v_yrelcal, v_mthlcal, v_prdlcal
        from tloaninf
       where numcont = p_numcont;
    exception when no_data_found then
      null;
    end;
    begin
      select dtestrt
        into p_dtestrt
        from tdtepay
       where codcompy   = v_codcompy
         and typpayroll = v_typpayroll
         and dteyrepay || lpad(dtemthpay, 2, 0) || lpad(numperiod, 2, 0) =
            (
              select min(dteyrepay || lpad(dtemthpay, 2, 0) || lpad(numperiod, 2, 0))
                from tdtepay
               where codcompy   = v_codcompy
                 and typpayroll = v_typpayroll
                 and dteyrepay || lpad(dtemthpay, 2, 0) || lpad(numperiod, 2, 0) > nvl(v_yrelcal, to_char(sysdate, 'YYYY')) || lpad(nvl(v_mthlcal, to_char(sysdate, 'MM')), 2, 0) || lpad(nvl(v_prdlcal, 1), 2, 0)
            );
    exception when no_data_found then
      null;
    end;
  end check_tab4;

  procedure get_tab4 (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if p_typtran = '4' then
      check_tab4;
    end if;
    if param_msg_error is null then
      gen_tab4(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tab4;

  procedure gen_tab4 (json_str_output out clob) AS
    obj_data            json_object_t;
    obj_tmp             json_object_t;
    v_rateilono         tloaninf.rateilon%type;
    v_rateilon          tloaninf.rateilon%type;
    v_formulao          tloaninf.formula%type;
    v_formula           tloaninf.formula%type;
    v_typintr           tloaninf.typintr%type;
    v_remark            tloanadj.descadj%type;
    v_disabled          varchar2(1 char) := 'N';
  begin
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    if p_typtran = '4' then
      begin
        select rateilon, formula, typintr
          into v_rateilon, v_formula, v_typintr
          from tloaninf
         where numcont = p_numcont;
      exception when no_data_found then
        null;
      end;
      v_rateilono         := v_rateilon;
      v_formulao          := v_formula;
      begin
        begin
          select typintr
            into v_typintr
            from tloaninf
           where numcont = p_numcont;
        exception when no_data_found then
          null;
        end;
        begin
          select ratelono, ratelonn, formulao, formulan, descadj
            into v_rateilono, v_rateilon, v_formulao, v_formula, v_remark
            from tloanadj
           where numcont   = p_numcont
             and dteadjust = p_dteadjust
             and dteeffec  = p_dteeffec
             and typtran   = p_typtran;
          obj_tmp           := json_object_t(get_response_message(null, get_error_msg_php('HR1505', global_v_lang), global_v_lang));
          obj_data.put('response', hcm_util.get_string_t(obj_tmp, 'response'));
          v_disabled        := 'Y';
        exception when no_data_found then
          if p_dteeffec <> nvl(p_dtestrt, to_date('01/01/1900', 'DD/MM/YYYY')) then
            obj_data.put('response', replace(get_error_msg_php('BF0066', global_v_lang), '@#$%400'));
          end if;
        end;
      exception when no_data_found then
        null;
      end;
    end if;
    obj_data.put('rateilono', v_rateilono);
    obj_data.put('rateilon', v_rateilon);
    obj_data.put('formulao', v_formulao);
    obj_data.put('formula', v_formula);
    obj_data.put('desc_formulao', hcm_formula.get_description(v_formulao, global_v_lang));
    obj_data.put('desc_formula', hcm_formula.get_description(v_formula, global_v_lang));
    obj_data.put('typintr', v_typintr);
    obj_data.put('remark', v_remark);
    obj_data.put('disabled', v_disabled);
    json_str_output := obj_data.to_clob;
  end gen_tab4;

  procedure check_save as
  begin
    begin
      select b.codcomp, a.codlon, a.typintr, a.amttotpay, a.amtnpfin, a.amtintovr, a.amtpflat, a.amtitotflat,
             a.amtlon, a.rateilon, a.qtyperiod, a.qtyperip, a.formula, a.dtelpay, a.dtestcal, a.typpayroll
        into p_codcomp, p_codlon, p_typintr, p_amttotpay, p_amtnpfin, p_amtintovr, p_amtpflat, p_amtitotflat,
             p_amtlon, p_rateilon, p_qtyperiod, p_qtyperip, p_formula, p_dtelpay, p_dtestcal, p_typpayroll
        from tloaninf a, temploy1 b
       where a.codempid = b.codempid
         and a.numcont  = p_numcont;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tloaninf');
      return;
    end;
  end check_save;

  procedure save_tab1 as
    v_periodpay         tloanadj.periodpay%type;
    v_descadj           tloanadj.descadj%type;
    v_amtpayo           tloanadj.amtpayo%type;
    v_amtpayn           tloanadj.amtpayn%type;
    v_amtlono           tloanadj.amtlono%type;
    v_amtlonn           tloanadj.amtlonn%type;
    v_amtpinto          tloanadj.amtpinto%type;
    v_amtpintn          tloanadj.amtpintn%type;
    v_amttotpay         tloaninf.amttotpay%type;
    v_amtnpfin          tloaninf.amtnpfin%type;
    v_amtintovr         tloaninf.amtintovr%type;
    v_amtpflat          tloaninf.amtpflat%type;
    v_amtpfinst         tloanpay.amtpfinst%type;
    v_stalon            tloaninf.stalon%type;
  begin
    v_periodpay         := hcm_util.get_string_t(json_params, 'periodpay');
    v_descadj           := hcm_util.get_string_t(json_params, 'remark');
    v_amtpayo           := to_number(hcm_util.get_number_t(json_params, 'amtrepmto'));
    v_amtpayn           := to_number(hcm_util.get_number_t(json_params, 'amtrepmt'));
    v_amtlono           := to_number(hcm_util.get_number_t(json_params, 'amtpfino'));
    v_amtlonn           := to_number(hcm_util.get_number_t(json_params, 'amtpfin'));
    v_amtpinto          := to_number(hcm_util.get_number_t(json_params, 'amtpinto'));
    v_amtpintn          := to_number(hcm_util.get_number_t(json_params, 'amtpint'));
    v_amtpfinst         := to_number(hcm_util.get_number_t(json_params, 'amtpfinst'));
    begin
      insert into tloanadj
             (numcont, dteadjust, typtran, dteeffec, codempid, codcomp, codlon,
              periodpay, amtpayo, amtpayn, amtlono, amtlonn, amtpinto, amtpintn, descadj,
              dtecreate, codcreate, coduser)
      values (p_numcont, trunc(sysdate), p_typtran, p_dteeffec, p_codempid_query, p_codcomp, p_codlon,
              v_periodpay, v_amtpayo, v_amtpayn, v_amtlono, v_amtlonn, v_amtpinto, v_amtpintn, v_descadj,
              sysdate, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      null;
    end;

    v_amttotpay         := null;
    v_amtnpfin          := null;
    v_amtintovr         := null;
    v_amtpflat          := null;
    if v_amtlonn > 0 then
      v_amtnpfin          := v_amtpfinst - v_amtlonn;
      if v_amtnpfin >= 0 then
        v_amtintovr         := 0;
      end if;
    else
      v_amtnpfin          := v_amtpfinst;
      v_amtintovr         := v_amtpinto - v_amtpintn;
    end if;
    if v_amtnpfin = 0 and v_amtintovr = 0 then
      v_stalon            := 'C';
    end if;
    begin
      update tloaninf
         set amttotpay = nvl(v_amttotpay, amttotpay),
             amtnpfin  = nvl(v_amtnpfin, amtnpfin),
             amtintovr = nvl(v_amtintovr, amtintovr),
             amtpflat  = nvl(v_amtpflat, amtpflat),
             stalon    = nvl(v_stalon, stalon)
       where numcont   = p_numcont;
    exception when others then
      null;
    end;
  end save_tab1;

  procedure save_tab2 as
    v_amtnpfin          tloaninf.amtnpfin%type;
    v_amtintovr         tloaninf.amtintovr%type;
    v_numpay            tloanadj.numpay%type;
    v_flgpay            tloanadj.flgpay%type;
    v_amtpayc           tloanadj.amtpayc%type;
    v_amtpaycn          tloanadj.amtpayc%type;
    v_descadj           tloanadj.descadj%type;
    v_dtestrt           ttrepayh.dtestrt%type;
    v_amtintrest        ttrepayh.amtintrest%type := 0;
    v_amtpfin           tloanpay.amtpfin%type := 0;
    v_amtpfinst         tloanpay.amtpfinst%type := 0;
    v_amtpfinen         tloanpay.amtpfinen%type := 0;
    v_amtintst          tloanpay.amtintst%type := 0;
    v_amtinten          tloanpay.amtinten%type := 0;
    v_stalon            tloaninf.stalon%type;
  begin
    v_descadj           := hcm_util.get_string_t(json_params, 'remark');
    v_numpay            := to_number(hcm_util.get_number_t(json_params, 'qtyperip'));
    v_numpay            := to_number(hcm_util.get_number_t(json_params, 'qtyperip'));
    v_flgpay            := hcm_util.get_number_t(json_params, 'flgpay');
    v_amtnpfin          := to_number(hcm_util.get_number_t(json_params, 'amtnpfin'));
    v_amtpayc           := to_number(hcm_util.get_number_t(json_params, 'amtpayc'));
    v_amtpaycn          := to_number(hcm_util.get_number_t(json_params, 'amtpaycn'));
    v_amtintovr         := to_number(hcm_util.get_number_t(json_params, 'amtintovr'));
    if p_dtelpay is null then
      v_dtestrt           := p_dtestcal;
    else
      v_dtestrt           := p_dtelpay + 1;
    end if;
    if v_flgpay = '2' then
      v_amtintrest        := v_amtpaycn - v_amtnpfin;
      v_amtpfin           := v_amtpayc - v_amtintrest;
      v_amtinten          := 0;
      v_amtpfinen         := 0;
      v_stalon            := 'C';
    else
      if v_amtpayc > v_amtpaycn then
        v_amtpayc           := v_amtpaycn;
      end if;
      v_amtintrest        := v_amtpaycn - v_amtnpfin;
      v_amtpfin           := greatest((v_amtpayc - v_amtintrest), 0);
      if v_amtpayc > v_amtintrest/*v_amtintovr*/ then
        v_amtinten          := 0;
        v_amtpfinen         := v_amtnpfin - v_amtpfin;
      else
        v_amtinten          := v_amtintrest/*v_amtintovr*/ - v_amtpayc;
        v_amtpfinen         := v_amtnpfin;
      end if;
      if v_amtinten = 0 and v_amtpfinen = 0 then
        v_flgpay            := '2';
        v_stalon            := 'C';
      end if;
    end if;
    v_amtpfinst         := v_amtnpfin;
    v_amtintst          := v_amtintovr;
    begin
      insert into ttrepayh
             (numcont, dtestrt, dteend, amtprinc, amtintrest, rateilon, dtecreate, codcreate, coduser)
      values (p_numcont, v_dtestrt, p_dteeffec, v_amtpayc, v_amtintrest, p_rateilon, sysdate, global_v_coduser, global_v_coduser);
    exception when no_data_found then
      null;
    end;
    begin
      insert into tloanpay
             (numcont, dterepmt, typtran, codempid, codcomp, typpayroll, typpay, amtpfin, amtpint, amtrepmt, amtpfinst, amtpfinen, amtintst, amtinten, dtecreate, codcreate, coduser)
      values (p_numcont, p_dteeffec, p_typtran, p_codempid_query, p_codcomp, p_typpayroll, '2', v_amtpfin, v_amtintrest, v_amtpayc, v_amtpfinst, v_amtpfinen, v_amtintst, v_amtinten, sysdate, global_v_coduser, global_v_coduser);
    exception when no_data_found then
      null;
    end;
    begin
      update tloaninf
         set dtelpay   = p_dteeffec,
             amttotpay = nvl(amttotpay, 0) + v_amtpayc,
             amtnpfin  = v_amtpfinen,
             amtintovr = v_amtinten,
             amtpflat  = nvl(amtpflat, 0) + v_amtintrest,
             qtyperip  = v_numpay,
             stalon    = nvl(v_stalon, stalon)
       where numcont   = p_numcont;
    exception when others then
      null;
    end;
    begin
      insert into tloanadj
             (numcont, dteadjust, typtran, dteeffec, codempid, codcomp, codlon,
              numpay, flgpay, amtpayc, descadj,
              dtecreate, codcreate, coduser)
      values (p_numcont, trunc(sysdate), p_typtran, p_dteeffec, p_codempid_query, p_codcomp, p_codlon,
              v_numpay, v_flgpay, v_amtpayc, v_descadj,
              sysdate, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      null;
    end;
  end save_tab2;

  procedure save_tab3 as
    v_amtpfino          tloanadj.amtpfino%type;
    v_amtpfinn          tloanadj.amtpfinn%type;
    v_amtpinto2         tloanadj.amtpinto2%type;
    v_amtpintn2         tloanadj.amtpintn2%type;
    v_ratelono          tloanadj.ratelono%type;
    v_ratelonn          tloanadj.ratelonn%type;
    v_amtrpmto          tloanadj.amtrpmto%type;
    v_amtrpmtn          tloanadj.amtrpmtn%type;
    v_qtypayo           tloanadj.qtypayo%type;
    v_qtypayn           tloanadj.qtypayn%type;
    v_descadj           tloanadj.descadj%type;
    v_amtiflat          tloaninf.amtiflat%type;
    v_qtyperiod         tloaninf.qtyperiod%type;
  begin
    v_descadj           := hcm_util.get_string_t(json_params, 'remark');
    v_amtpfino          := to_number(hcm_util.get_number_t(json_params, 'amtnpfino'));
    if hcm_util.get_string_t(json_params, 'amtnpfin') is not null then
      v_amtpfinn          := to_number(hcm_util.get_number_t(json_params, 'amtnpfin'));
    end if;
    v_amtpinto2         := to_number(hcm_util.get_number_t(json_params, 'amtintovro'));
    if hcm_util.get_string_t(json_params, 'amtintovr') is not null then
      v_amtpintn2         := to_number(hcm_util.get_number_t(json_params, 'amtintovr'));
    end if;
    v_ratelono          := to_number(hcm_util.get_number_t(json_params, 'rateilono'));
    v_ratelonn          := to_number(hcm_util.get_number_t(json_params, 'rateilon'));
    v_amtrpmto          := to_number(hcm_util.get_number_t(json_params, 'amttlpayo'));
    if hcm_util.get_string_t(json_params, 'amttlpay') is not null then
      v_amtrpmtn          := to_number(hcm_util.get_number_t(json_params, 'amttlpay'));
    end if;
    v_qtypayo           := to_number(hcm_util.get_number_t(json_params, 'qtypayo'));
    if hcm_util.get_string_t(json_params, 'qtypayn') is not null then
      v_qtypayn           := to_number(hcm_util.get_number_t(json_params, 'qtypayn'));
    end if;
    v_amtiflat          := to_number(hcm_util.get_number_t(json_params, 'amtiflat'));
    if v_qtypayn is not null and v_qtypayo <> v_qtypayn then
      v_qtyperiod         := (p_qtyperip + v_qtypayn);
    end if;
    if nvl(v_amtpfinn, v_amtpfino) = v_amtpfino and nvl(v_amtpintn2, v_amtpinto2) = v_amtpinto2 and nvl(v_amtrpmtn, v_amtrpmto) = v_amtrpmto and nvl(v_qtypayn, v_qtypayo) = v_qtypayo then
      param_msg_error := get_error_msg_php('HR2020', global_v_lang);
      return;
    end if;
    begin
      update tloaninf
         set amtnpfin  = nvl(v_amtpfinn, amtnpfin),
             amtintovr = nvl(v_amtpintn2, amtintovr),
             amtiflat  = nvl(v_amtiflat, amtiflat),
             amttlpay  = nvl(v_amtrpmtn, amttlpay),
             qtyperiod = nvl(v_qtyperiod, qtyperiod)
       where numcont   = p_numcont;
    exception when others then
      null;
    end;
    begin
      insert into tloanadj
             (numcont, dteadjust, typtran, dteeffec, codempid, codcomp, codlon,
              amtpfino, amtpfinn, amtpinto2, amtpintn2, ratelono, ratelonn, descadj,
              amtrpmto, amtrpmtn, qtypayo, qtypayn,
              dtecreate, codcreate, coduser)
      values (p_numcont, trunc(sysdate), p_typtran, p_dteeffec, p_codempid_query, p_codcomp, p_codlon,
              v_amtpfino, v_amtpfinn, v_amtpinto2, v_amtpintn2, v_ratelono, v_ratelonn, v_descadj,
              v_amtrpmto, v_amtrpmtn, v_qtypayo, v_qtypayn,
              sysdate, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      null;
    end;
  end save_tab3;

  procedure save_tab4 as
    v_descadj           tloanadj.descadj%type;
    v_ratelono          tloanadj.ratelono%type;
    v_ratelonn          tloanadj.ratelonn%type;
    v_formulao          tloanadj.formulao%type;
    v_statemento        tloanadj.statemento%type;
    v_formulan          tloanadj.formulan%type;
    v_statementn        tloanadj.statementn%type;
    obj_formula         json_object_t;
  begin
    v_descadj           := hcm_util.get_string_t(json_params, 'remark');
    v_ratelono          := to_number(hcm_util.get_number_t(json_params, 'rateilono'));
    v_ratelonn          := to_number(hcm_util.get_number_t(json_params, 'rateilon'));
    v_formulao          := hcm_util.get_string_t(json_params, 'formulao');
    obj_formula         := hcm_util.get_json_t(json_params, 'formula');
    v_formulan          := hcm_util.get_string_t(obj_formula, 'code');
    if v_formulao = v_formulan then
      param_msg_error := get_error_msg_php('HR2020', global_v_lang);
      return;
    end if;
    begin
      insert into tloanadj
             (numcont, dteadjust, typtran, dteeffec, codempid, codcomp, codlon,
              ratelono, ratelonn, formulao, statemento, formulan, statementn, descadj,
              dtecreate, codcreate, coduser)
      values (p_numcont, trunc(sysdate), p_typtran, p_dteeffec, p_codempid_query, p_codcomp, p_codlon,
              v_ratelono, v_ratelonn, v_formulao, v_statemento, v_formulan, v_statementn, v_descadj,
              sysdate, global_v_coduser, global_v_coduser);
    exception when dup_val_on_index then
      null;
    end;
  end save_tab4;

  procedure save_index (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is null then
      if p_typtran = '1' then
        save_tab1;
      elsif p_typtran = '2' then
        save_tab2;
      elsif p_typtran = '3' then
        save_tab3;
      elsif p_typtran = '4' then
        save_tab4;
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
  end save_index;

  procedure get_cal_tab3 (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    json_params         := json_object_t(json_str_input);
    check_save;
    if param_msg_error is null then
      gen_cal_tab3(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_cal_tab3;

  procedure gen_cal_tab3 (json_str_output out clob) AS
    obj_data            json_object_t;
    v_amtnpfino         tloaninf.amtnpfin%type;
    v_amtnpfin          tloaninf.amtnpfin%type;
    v_amtnpfinCal       tloaninf.amtnpfin%type;
    v_amtintovro        tloaninf.amtintovr%type;
    v_amtintovr         tloaninf.amtintovr%type;
    v_amtintovrCal      tloaninf.amtintovr%type;
    v_rateilono         tloaninf.rateilon%type;
    v_rateilon          tloaninf.rateilon%type;
    v_amttlpayo         tloaninf.amttlpay%type;
    v_amttlpay          tloaninf.amttlpay%type;
    v_amttlpayCal       tloaninf.amttlpay%type;
    v_amtiflat          tloaninf.amtiflat%type;
    v_qtypayo           tloanadj.qtypayn%type;
    v_qtypayn           tloanadj.qtypayn%type;
    v_type              varchar2(10 char) := '1';
  begin
    v_type              := to_char(hcm_util.get_number_t(json_params, 'p_type'));
    if hcm_util.get_string_t(json_params, 'amtnpfino') is not null then
      v_amtnpfino         := to_number(hcm_util.get_number_t(json_params, 'amtnpfino'));
    end if;
    if hcm_util.get_string_t(json_params, 'amtnpfin') is not null then
      v_amtnpfin          := to_number(hcm_util.get_number_t(json_params, 'amtnpfin'));
    end if;
    if hcm_util.get_string_t(json_params, 'amtintovro') is not null then
      v_amtintovro        := to_number(hcm_util.get_number_t(json_params, 'amtintovro'));
    end if;
    if hcm_util.get_string_t(json_params, 'amtintovr') is not null then
      v_amtintovr         := to_number(hcm_util.get_number_t(json_params, 'amtintovr'));
    end if;
    if hcm_util.get_string_t(json_params, 'rateilono') is not null then
      v_rateilono         := to_number(hcm_util.get_number_t(json_params, 'rateilono'));
    end if;
    if hcm_util.get_string_t(json_params, 'rateilon') is not null then
      v_rateilon          := to_number(hcm_util.get_number_t(json_params, 'rateilon'));
    end if;
    if hcm_util.get_string_t(json_params, 'amttlpayo') is not null then
      v_amttlpayo         := to_number(hcm_util.get_number_t(json_params, 'amttlpayo'));
    end if;
    if hcm_util.get_string_t(json_params, 'amttlpay') is not null then
      v_amttlpay          := to_number(hcm_util.get_number_t(json_params, 'amttlpay'));
    end if;
    if hcm_util.get_string_t(json_params, 'qtypayo') is not null then
      v_qtypayo           := to_number(hcm_util.get_number_t(json_params, 'qtypayo'));
    end if;
    if hcm_util.get_string_t(json_params, 'qtypayn') is not null then
      v_qtypayn           := to_number(hcm_util.get_number_t(json_params, 'qtypayn'));
    end if;
    if hcm_util.get_string_t(json_params, 'amtiflat') is not null then
      v_amtiflat          := to_number(hcm_util.get_number_t(json_params, 'amtiflat'));
    end if;
    p_qtypayn           := nvl(v_qtypayn, v_qtypayo);
    v_amttlpayCal       := nvl(v_amttlpay, v_amttlpayo);
    v_amtnpfinCal       := nvl(v_amtnpfin, v_amtnpfino);
    v_amtintovrCal      := nvl(v_amtintovr, v_amtintovro);

    if v_type = '1' and v_amttlpayCal = v_amttlpayo then
      v_qtypayn           := v_qtypayo;
    elsif v_type = '2' and p_qtypayn = v_qtypayo then
      v_amttlpay          := v_amttlpayo;
    else
      if p_typintr = '1' then
        if v_type = '1' then
          begin
            v_qtypayn           := ceil(log(1 + ((v_rateilono / 12) / 100), v_amttlpayCal / (v_amttlpayCal - (v_amtnpfinCal * ((v_rateilono / 12) / 100)))));
          exception when others then
            param_msg_error     := get_error_msg_php('HR2020', global_v_lang);
            return;
          end;
        else
          v_amttlpay          := ceil(v_amtnpfinCal / ((1 - (1 / power((1 + ((v_rateilon / 12)/100) ), p_qtypayn))) / ((v_rateilon / 12) / 100)));
        end if;
      elsif p_typintr = '2' then
        if p_qtyperip = 0 then
          p_amtitotflat       := cal_formula(p_formula) * p_qtypayn;
        end if;
        if v_type = '1' then
          v_qtypayn           := ceil((v_amtnpfinCal + (p_amtitotflat - p_amtpflat) + v_amtintovrCal) / v_amttlpayCal);
          v_amtiflat          := ((p_amtitotflat - p_amtpflat) + v_amtintovrCal) / p_qtypayn;
        else
          v_amttlpay          := (v_amtnpfinCal + (p_amtitotflat - p_amtpflat) + v_amtintovrCal) / p_qtypayn;
          v_amtiflat          := ((p_amtitotflat - p_amtpflat) + v_amtintovrCal) / p_qtypayn;
        end if;
      elsif p_typintr = '3' then
        if p_qtyperip = 0 then
          p_amtitotflat       := p_amtlon * ((p_rateilon / 12) / 100) * p_qtypayn;
        end if;
        if v_type = '1' then
          v_qtypayn           := ceil((v_amtnpfinCal + (p_amtitotflat - p_amtpflat) + v_amtintovrCal) / v_amttlpayCal);
          v_amtiflat          := ((p_amtitotflat - p_amtpflat) + v_amtintovrCal) / p_qtypayn;
        else
          v_amttlpay          := (v_amtnpfinCal + (p_amtitotflat - p_amtpflat) + v_amtintovrCal) / p_qtypayn;
          v_amtiflat          := ((p_amtitotflat - p_amtpflat) + v_amtintovrCal) / p_qtypayn;
        end if;
      end if;
    end if;
    
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('amtnpfin', v_amtnpfin);
    obj_data.put('amtintovr', v_amtintovr);
    obj_data.put('rateilon', v_rateilon);
    obj_data.put('amttlpay', v_amttlpay);
    obj_data.put('qtypayn', v_qtypayn);
    obj_data.put('amtiflat', v_amtiflat);
    json_str_output := obj_data.to_clob;
  end gen_cal_tab3;
end HRBF5EE;

/
