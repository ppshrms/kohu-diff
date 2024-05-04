--------------------------------------------------------
--  DDL for Package Body HRRC58X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC58X" AS
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
    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_numseq            := hcm_util.get_string_t(json_obj, 'p_numseq');
    p_numcolla          := hcm_util.get_string_t(json_obj, 'p_numcolla');
    p_additional_year   := to_number(hcm_appsettings.get_additional_year);

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy          tcenter.codcompy%type;
    v_codpos            temploy1.codpos%type;
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
    v_dtepaymt          tdtepay.dtepaymt%type;
--<< #7195 || USER39 || 19/11/2021
    v2_codempid  varchar2(200 char);
    v2_dteyrepay number;
    v2_dtemthpay number ;
    v2_numprdded number;
    v2_numperiod number;
    v2_dtepaymt  date;
    v2_con       varchar2(200 char);
-->> #7195 || USER39 || 19/11/2021

    cursor c1 is
      select a.codempid, a.codcomp, a.codpos, a.dteefpos, b.qtyguar qtyguar_job, b.amtcolla amtcolla_job, c.qtyquar, stddec(c.amtcolla,c.codempid,v_chken) amtcolla, a.TYPPAYROLL
        from temploy1 a ,tjobcode b, ttotguar c
       where a.codempid = c.codempid
         and a.codjob   = b.codjob
         and a.codcomp  like p_codcomp || '%'
         and a.codpos   = nvl(p_codpos, a.codpos)
         and (b.qtyguar > 0 or b.amtcolla > 0)
       order by a.codcomp, a.codpos, a.codempid;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_found             := true;

--<< #7195 || USER39 || 19/11/2021
         v2_con := 'N';
         begin
             select codempid, dteyrepay, dtemthpay, numperiod, numprdded
              into v2_codempid, v2_dteyrepay, v2_dtemthpay, v2_numperiod, v2_numprdded
              from tguardet t1
             where codempid = i.codempid
               and numprdded = (select min(numprdded) from tguardet
                             where codempid = t1.codempid);
              v2_con := 'Y';
         exception when no_data_found then
              v2_con := 'N';
         end;

         if v2_con = 'Y' then
             begin
                  select dtepaymt
                    into v2_dtepaymt
                    from tdtepay
                    where codcompy = substr(i.codcomp,1,4)
                    --and typpayroll = i.TYPPAYROLL
                    and dteyrepay = v2_dteyrepay
                    and dtemthpay = v2_dtemthpay
                    and numperiod = v2_numperiod
                    and rownum = 1;
             exception when no_data_found then
                    v2_dtepaymt := null;
             end;
         end if;
--<< #7195 || USER39 || 19/11/2021


      if secur_main.secur3(i.codcomp, i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        v_rcnt              := v_rcnt + 1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('codcomp', i.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(i.codcomp, global_v_lang));
        obj_data.put('codpos', i.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
        obj_data.put('dteefpos', to_char(i.dteefpos, 'DD/MM/YYYY'));
        obj_data.put('qtyguar_job', nvl(i.qtyguar_job, 0));
        obj_data.put('amtcolla_job', nvl(i.amtcolla_job, 0));
        obj_data.put('qtyquar', nvl(i.qtyquar, 0));
        obj_data.put('amtcolla', nvl(i.amtcolla, 0));
        obj_data.put('dtepaymt', to_char(v2_dtepaymt, 'DD/MM/YYYY')); --<< #7195 || USER39 || 19/11/2021
        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if v_rcnt = 0 then
      if v_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttotguar');
      end if;
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_index;

  procedure get_tguarntr (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tguarntr(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tguarntr;

  procedure gen_tguarntr (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select a.codempid, a.numseq, a.codempgrt, a.codtitle,
             decode(global_v_lang, '101', a.namguare
                                 , '102', a.namguart
                                 , '103', a.namguar3
                                 , '104', a.namguar4
                                 , '105', a.namguar5
                                 , a.namguare) namguar,
             a.dtegucon, a.dteidexp, a.amtguarntr, a.desrelat, b.staemp, a.desnote
        from tguarntr a, temploy1 b
       where a.codempid  = p_codempid
         and a.codempgrt = b.codempid(+)
       order by a.numseq;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', i.codempid);
      obj_data.put('numseq', i.numseq);
      obj_data.put('codempg', i.codempgrt);
      if i.codempgrt is null then
        obj_data.put('desc_codempg', get_tlistval_name('CODTITLE', i.codtitle, global_v_lang) || i.namguar);
      else
        obj_data.put('desc_codempg', get_temploy_name(i.codempgrt, global_v_lang));
      end if;
      obj_data.put('dtegucon', to_char(i.dtegucon, 'DD/MM/YYYY'));
      obj_data.put('dteidexp', to_char(i.dteidexp, 'DD/MM/YYYY'));
      obj_data.put('amtguarntr', nvl(stddec(i.amtguarntr, i.codempid, v_chken), 0));
      obj_data.put('desrelat', i.desrelat);
      obj_data.put('status', i.staemp);
      obj_data.put('desc_status', get_tlistval_name('FSTAEMP', i.staemp, global_v_lang));
      obj_data.put('desnote', i.desnote);

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tguarntr');
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_tguarntr;

  procedure get_tcolltrl (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tcolltrl(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tcolltrl;

  procedure gen_tcolltrl (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select codempid, numcolla, typcolla, descoll, amtcolla, status, numdocum, dtecolla, amtdedcol
        from tcolltrl
       where codempid = p_codempid
       order by numcolla;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', i.codempid);
      obj_data.put('numcolla', i.numcolla);
      obj_data.put('typcolla', i.typcolla);
      obj_data.put('desc_typcolla', get_tcodec_name('TCODCOLA', i.typcolla, global_v_lang));
      obj_data.put('descoll', i.descoll);
      obj_data.put('amtcolla', nvl(stddec(i.amtcolla, i.codempid, v_chken), 0));
      obj_data.put('numdocum', i.numdocum);
      obj_data.put('dtecolla', to_char(i.dtecolla, 'DD/MM/YYYY'));
      obj_data.put('status', i.status);
      obj_data.put('desc_status', get_tlistval_name('STACOLTRL', i.status, global_v_lang));
      obj_data.put('amtdedcol', stddec(i.amtdedcol, i.codempid, v_chken));

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tcolltrl');
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_tcolltrl;

  procedure get_tguardet (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tguardet(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tguardet;

  procedure gen_tguardet (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;

    cursor c1 is
      select codempid, dteyrepay, dtemthpay, numperiod, numprdded, amtded
        from tguardet
       where codempid = p_codempid
       order by numprdded;

  begin
    obj_rows            := json_object_t();
    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', i.codempid);
      obj_data.put('numprdded', i.numprdded);
      obj_data.put('period', i.numperiod || ' ' || get_tlistval_name('MONTH', i.dtemthpay, global_v_lang) || ' ' || to_char(i.dteyrepay + p_additional_year));
      obj_data.put('amtded', nvl(i.amtded, 0));
      obj_data.put('desnote', '');

      obj_rows.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tguardet');
    else
      json_str_output := obj_rows.to_clob;
    end if;
  end gen_tguardet;

  procedure get_tguarntr_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tguarntr_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tguarntr_detail;

  procedure gen_tguarntr_detail (json_str_output out clob) AS
    obj_data            json_object_t;
    v_codempid          tguarntr.codempid%type;
    v_numseq            tguarntr.numseq%type;
    v_dtegucon          tguarntr.dtegucon%type;
    v_amtguarntr        tguarntr.amtguarntr%type;
    v_desrelat          tguarntr.desrelat%type;
    v_codempg           tguarntr.codempgrt%type;
    v_codtitle          tguarntr.codtitle%type;
    v_namguar           tguarntr.namguare%type;
    v_namguare          tguarntr.namguare%type;
    v_namguart          tguarntr.namguart%type;
    v_namguar3          tguarntr.namguar3%type;
    v_namguar4          tguarntr.namguar4%type;
    v_namguar5          tguarntr.namguar5%type;
    v_dteguabd          tguarntr.dteguabd%type;
    v_dteguret          tguarntr.dteguret%type;
    v_adrcont           tguarntr.adrcont%type;
    v_codpost           tguarntr.codpost%type;
    v_numtele           tguarntr.numtele%type;
    v_numfax            tguarntr.numfax%type;
    v_email             tguarntr.email%type;
    v_codident          tguarntr.codident%type;
    v_numoffid          tguarntr.numoffid%type;
    v_dteidexp          tguarntr.dteidexp%type;
    v_desnote           tguarntr.desnote%type;
    v_codoccup          tguarntr.codoccup%type;
    v_despos            tguarntr.despos%type;
    v_amtmthin          tguarntr.amtmthin%type;
    v_adroffi           tguarntr.adroffi%type;
    v_codposto          tguarntr.codposto%type;

  begin
    begin
      select codempid, numseq, dtegucon, amtguarntr, desrelat, codempgrt,
             codtitle, namguare, namguart, namguar3, namguar4, namguar5,
             dteguabd, dteguret, adrcont, codpost, numtele, numfax, email,
             codident, numoffid, dteidexp, desnote, codoccup, despos,
             amtmthin, adroffi, codposto
        into v_codempid, v_numseq, v_dtegucon, v_amtguarntr, v_desrelat, v_codempg,
             v_codtitle, v_namguare, v_namguart, v_namguar3, v_namguar4, v_namguar5,
             v_dteguabd, v_dteguret, v_adrcont, v_codpost, v_numtele, v_numfax, v_email,
             v_codident, v_numoffid, v_dteidexp, v_desnote, v_codoccup, v_despos,
             v_amtmthin, v_adroffi, v_codposto
        from tguarntr
       where codempid = p_codempid
         and numseq   = p_numseq;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tguarntr');
      return;
    end;
    if global_v_lang = '101' then
      v_namguar           := v_namguare;
    elsif global_v_lang = '102' then
      v_namguar           := v_namguart;
    elsif global_v_lang = '103' then
      v_namguar           := v_namguar3;
    elsif global_v_lang = '104' then
      v_namguar           := v_namguar4;
    elsif global_v_lang = '105' then
      v_namguar           := v_namguar5;
    end if;

    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', v_codempid);
    obj_data.put('numseq', v_numseq);
    obj_data.put('dtegucon', to_char(v_dtegucon, 'DD/MM/YYYY'));
    obj_data.put('amtguarntr', stddec(v_amtguarntr, v_codempid, v_chken));
    obj_data.put('desrelat', v_desrelat);
    obj_data.put('codempg', v_codempg);
    if v_codempg is null then
      obj_data.put('desc_codempg', get_tlistval_name('CODTITLE', v_codtitle, global_v_lang) || v_namguar);
    else
      obj_data.put('desc_codempg', get_temploy_name(v_codempg, global_v_lang));
    end if;
    obj_data.put('dteguabd', to_char(v_dteguabd, 'DD/MM/YYYY'));
    obj_data.put('dteguret', to_char(v_dteguret, 'DD/MM/YYYY'));
    obj_data.put('adrcont', v_adrcont);
    obj_data.put('codpost', v_codpost);
    obj_data.put('numtele', v_numtele);
    obj_data.put('numfax', v_numfax);
    obj_data.put('email', v_email);
    obj_data.put('codident', v_codident);
    obj_data.put('desc_codident', get_tlistval_name('CODIDENT', v_codident, global_v_lang));
    obj_data.put('numoffid', v_numoffid);
    obj_data.put('dteidexp', to_char(v_dteidexp, 'DD/MM/YYYY'));
    obj_data.put('desnote', v_desnote);
    obj_data.put('codoccup', v_codoccup);
    obj_data.put('desc_codoccup', get_tcodec_name('TCODOCCU', v_codoccup, global_v_lang));
    obj_data.put('despos', v_despos);
    obj_data.put('amtmthin', stddec(v_amtmthin, v_codempid, v_chken));
    obj_data.put('adroffi', v_adroffi);
    obj_data.put('codposto', v_codposto);

    json_str_output := obj_data.to_clob;
  end gen_tguarntr_detail;

  procedure get_tcolltrl_detail (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_tcolltrl_detail(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_tcolltrl_detail;

  procedure gen_tcolltrl_detail (json_str_output out clob) AS
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

  begin
    begin
      select codempid, numcolla, numdocum, typcolla, amtcolla, descoll, dtecolla,
             dtertdoc, dteeffec, filename, numrefdoc, dtechg, status, flgded,
             qtyperiod, qtytranpy, amtdedcol, dtestrt, dteend, amtded, staded, dtelstpay
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
    obj_data.put('numcolla', v_numcolla);
    obj_data.put('numdocum', v_numdocum);
    obj_data.put('typcolla', v_typcolla);
    obj_data.put('desc_typcolla', get_tcodec_name('TCODCOLA', v_typcolla, global_v_lang));
    obj_data.put('amtcolla', stddec(v_amtcolla, v_codempid, v_chken));
    obj_data.put('descoll', v_descoll);
    obj_data.put('dtecolla', to_char(v_dtecolla, 'DD/MM/YYYY'));
    obj_data.put('dtertdoc', to_char(v_dtertdoc, 'DD/MM/YYYY'));
    obj_data.put('dteeffec', to_char(v_dteeffec, 'DD/MM/YYYY'));
    obj_data.put('filename', v_filename);
    obj_data.put('path_filename', get_tsetup_value('PATHWORKPHP') || get_tfolderd('HRRC52E') || '/' || v_filename);
    obj_data.put('numrefdoc', v_numrefdoc);
    obj_data.put('dtechg', to_char(v_dtechg, 'DD/MM/YYYY'));
    obj_data.put('status', v_status);
    obj_data.put('desc_status', get_tlistval_name('STACOLTRL', v_status, global_v_lang));
    obj_data.put('flgded', v_flgded);
    if v_flgded = 'Y' then
      obj_data.put('desc_flgded', get_label_name('HRRC5CE', global_v_lang, 280));
    else
      obj_data.put('desc_flgded', get_label_name('HRRC5CE', global_v_lang, 290));
    end if;
    obj_data.put('qtyperiod', v_qtyperiod);
    obj_data.put('qtytranpy', v_qtytranpy);
    obj_data.put('amtdedcol', stddec(v_amtdedcol, v_codempid, v_chken));
    obj_data.put('dtestrt', to_char(v_dtestrt, 'DD/MM/YYYY'));
    obj_data.put('dteend', to_char(v_dteend, 'DD/MM/YYYY'));
    obj_data.put('amtded', stddec(v_amtded, v_codempid, v_chken));
    obj_data.put('staded', v_staded);
    if v_staded = 'Y' then
      obj_data.put('desc_staded', get_label_name('HRRC5CE', global_v_lang, 280));
    else
      obj_data.put('desc_staded', get_label_name('HRRC5CE', global_v_lang, 290));
    end if;
    obj_data.put('dtelstpay', to_char(v_dtelstpay, 'DD/MM/YYYY'));

    json_str_output := obj_data.to_clob;
  end gen_tcolltrl_detail;
end HRRC58X;

/
