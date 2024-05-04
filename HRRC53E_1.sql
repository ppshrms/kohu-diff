--------------------------------------------------------
--  DDL for Package Body HRRC53E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC53E" AS
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
    p_numseq            := hcm_util.get_string_t(json_obj, 'p_numseq');
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
    v_desappr           thisguarn.desappr%type;
    v_dteappr           thisguarn.dteappr%type;
    v_codappr           thisguarn.codappr%type;

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
    obj_data.put('numseqo', v_numseq);
    obj_data.put('numseq', v_numseq);
    obj_data.put('dtegucono', to_char(v_dtegucon, 'DD/MM/YYYY'));
    obj_data.put('dtegucon', to_char(v_dtegucon, 'DD/MM/YYYY'));
    v_amtguarntr := stddec(v_amtguarntr,v_codempid,hcm_secur.get_v_chken); --#5824 || USER39 || 08/10/2021
    obj_data.put('amtguarntro', v_amtguarntr);
    obj_data.put('amtguarntr', v_amtguarntr);
    obj_data.put('desrelato', v_desrelat);
    obj_data.put('desrelat', v_desrelat);
    obj_data.put('codempgo', v_codempg);
    obj_data.put('codempg', v_codempg);
    obj_data.put('codtitleo', v_codtitle);
    obj_data.put('codtitle', v_codtitle);
    obj_data.put('namguaro', v_namguar);
    obj_data.put('namguaroe', v_namguare);
    obj_data.put('namguarot', v_namguart);
    obj_data.put('namguaro3', v_namguar3);
    obj_data.put('namguaro4', v_namguar4);
    obj_data.put('namguaro5', v_namguar5);
    obj_data.put('namguar', v_namguar);
    obj_data.put('namguare', v_namguare);
    obj_data.put('namguart', v_namguart);
    obj_data.put('namguar3', v_namguar3);
    obj_data.put('namguar4', v_namguar4);
    obj_data.put('namguar5', v_namguar5);
    obj_data.put('dteguabdo', to_char(v_dteguabd, 'DD/MM/YYYY'));
    obj_data.put('dteguabd', to_char(v_dteguabd, 'DD/MM/YYYY'));
    obj_data.put('dtegureto', to_char(v_dteguret, 'DD/MM/YYYY'));
    obj_data.put('dteguret', to_char(v_dteguret, 'DD/MM/YYYY'));
    obj_data.put('adrconto', v_adrcont);
    obj_data.put('adrcont', v_adrcont);
    obj_data.put('codpostow', v_codpost);
    obj_data.put('codpost', v_codpost);
    obj_data.put('numteleo', v_numtele);
    obj_data.put('numtele', v_numtele);
    obj_data.put('numfaxo', v_numfax);
    obj_data.put('numfax', v_numfax);
    obj_data.put('emailo', v_email);
    obj_data.put('email', v_email);
    obj_data.put('codidento', v_codident);
    obj_data.put('codident', v_codident);
    obj_data.put('numoffido', v_numoffid);
    obj_data.put('numoffid', v_numoffid);
    obj_data.put('dteidexpo', to_char(v_dteidexp, 'DD/MM/YYYY'));
    obj_data.put('dteidexp', to_char(v_dteidexp, 'DD/MM/YYYY'));
    obj_data.put('desnoteo', v_desnote);
    obj_data.put('desnote', v_desnote);
    obj_data.put('codoccupo', v_codoccup);
    obj_data.put('codoccup', v_codoccup);
    obj_data.put('desposo', v_despos);
    obj_data.put('despos', v_despos);
    v_amtmthin := stddec(v_amtmthin,v_codempid,hcm_secur.get_v_chken); --#5824 || USER39 || 08/10/2021
    obj_data.put('amtmthino', v_amtmthin);
    obj_data.put('amtmthin', v_amtmthin);
    obj_data.put('adroffio', v_adroffi);
    obj_data.put('adroffi', v_adroffi);
    obj_data.put('codpostoo', v_codposto);
    obj_data.put('codposto', v_codposto);
    obj_data.put('desappr', v_desappr);
    obj_data.put('dteappr', to_char(nvl(v_dteappr, sysdate), 'DD/MM/YYYY'));
    obj_data.put('codappr', nvl(v_codappr, global_v_codempid));

    json_str_output := obj_data.to_clob;
  end gen_index;

  procedure check_save (v_codappr thisguarn.codappr%type) as
    v_codcomp           temploy1.codcomp%type;
    v_codjob            temploy1.codjob%type;
    b_amtguarntr        number;
    v_amtguarntr        number;
    n_amtguarntr        number;
  begin
--    if p_codempid is not null then
--      begin
--        select codcomp,codjob
--          into v_codcomp,v_codjob
--          from temploy1
--        where codempid = p_codempid;
--      exception when no_data_found then
--        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
--        return;
--      end;
--      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
--        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
--        return;
--      end if;
--    end if;
    --
    begin
      select amtguarntr
        into b_amtguarntr
        from tjobcode
       where codjob = v_codjob;
    exception when no_data_found then
      b_amtguarntr      := 0;
    end;
    --
    if b_amtguarntr is not null then
      begin
        select sum(stddec(amtguarntr, p_codempid, v_chken))
          into v_amtguarntr
          from tguarntr
         where codempid =  p_codempid
           and numseq   <> p_numseq;
      end;
      n_amtguarntr := hcm_util.get_string_t(json_params, 'amtguarntr');
      v_amtguarntr := nvl(v_amtguarntr,0) + nvl(n_amtguarntr,0);
      --
      if b_amtguarntr > v_amtguarntr and (param_flgwarn != 'Y' or param_flgwarn is null) then -- softberry || 20/03/2023 || #8764 || if b_amtguarntr > v_amtguarntr then
        param_msg_error := replace(get_error_msg_php('RC0043', global_v_lang),'[P-AMTCOLLA]',to_char(b_amtguarntr - v_amtguarntr, 'fm9,999,990.90'));
      end if;
    end if; -- b_amtguarntr is not null
  end check_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    v_numseq            tguarntr.numseq%type;
    v_dtegucon          tguarntr.dtegucon%type;
    v_amtguarntr        tguarntr.amtguarntr%type;
    v_desrelat          tguarntr.desrelat%type;
    v_codempg           tguarntr.codempgrt%type;
    v_codtitle          tguarntr.codtitle%type;
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
    v_desappr           thisguarn.desappr%type;
    v_dteappr           thisguarn.dteappr%type;
    v_codappr           thisguarn.codappr%type;
    v_codcomp           temploy1.codcomp%type;
    v_codpos            temploy1.codpos%type;
    n_amtguarntr        number := 0;
    --<<#7684
    v_count             number := 0;
    v_sum               number := 0;
    v_amt               tjobcode.amtcolla%type;
    -->>#7684
  begin
    initial_value(json_str_input);
    param_flgwarn       := hcm_util.get_string_t(json_params,'flgwarning'); -- softberry || 20/03/2023 || #8764
    v_desappr           := hcm_util.get_string_t(json_params, 'desappr');
    v_dteappr           := to_date(hcm_util.get_string_t(json_params, 'dteappr'), 'DD/MM/YYYY');
    v_codappr           := hcm_util.get_string_t(json_params, 'codappr');
    check_save(v_codappr);
    --<< softberry || 20/03/2023 || #8764
    if param_msg_error is not null and  (param_flgwarn != 'Y' or param_flgwarn is null)  then 
      json_str_output := get_response_message(null,param_msg_error,global_v_lang,'Y');
      return;
    end if;
    -->> softberry || 20/03/2023 || #8764       
    if param_msg_error is null then
      begin
        select dtegucon, amtguarntr, desrelat, codempgrt,
               codtitle, namguare, namguart, namguar3, namguar4, namguar5,
               dteguabd, dteguret, adrcont, codpost, numtele, numfax, email,
               codident, numoffid, dteidexp, desnote, codoccup, despos,
               amtmthin, adroffi, codposto
          into v_dtegucon, v_amtguarntr, v_desrelat, v_codempg,
               v_codtitle, v_namguare, v_namguart, v_namguar3, v_namguar4, v_namguar5,
               v_dteguabd, v_dteguret, v_adrcont, v_codpost, v_numtele, v_numfax, v_email,
               v_codident, v_numoffid, v_dteidexp, v_desnote, v_codoccup, v_despos,
               v_amtmthin, v_adroffi, v_codposto
          from tguarntr
         where codempid = p_codempid
           and numseq   = p_numseq;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tguarntr');
        -- return;  -- softberry || 20/03/2023 || #8764 || return;
      end;

      ----v_amtguarntr := stddec(v_amtguarntr,p_codempid,hcm_secur.get_v_chken); --#5824 || USER39 || 08/10/2021

      begin
        insert into thisguarn(codempid,numseq,dtechg,
                              amtbudguar,dtegucon,desrelat,codempg,
                              codtitle,namguare,namguart,namguar3,namguar4,namguar5,
                              dteguabd,dteguret,adrcont,codpost,numtele,numfax,email,
                              codident,numoffid,dteidexp,desnote,codoccup,despos,amtmthin,
                              adroffi,codposto,desappr,dteappr,codappr,dtecreate,codcreate,coduser)
                       values(p_codempid,p_numseq,p_dtechg,
                              v_amtguarntr,v_dtegucon,v_desrelat,v_codempg,
                              v_codtitle,v_namguare,v_namguart,v_namguar3,v_namguar4,v_namguar5,
                              v_dteguabd,v_dteguret,v_adrcont,v_codpost,v_numtele,v_numfax,v_email,
                              v_codident,v_numoffid,v_dteidexp,v_desnote,v_codoccup,v_despos,v_amtmthin,
                              v_adroffi,v_codposto,v_desappr,v_dteappr,v_codappr,sysdate,global_v_coduser,global_v_coduser);
      exception when dup_val_on_index then
        update thisguarn
           set amtbudguar  = v_amtguarntr,
               dtegucon    = v_dtegucon,
               desrelat    = v_desrelat,
               codempg     = v_codempg,
               codtitle    = v_codtitle,
               namguare    = v_namguare,
               namguart    = v_namguart,
               namguar3    = v_namguar3,
               namguar4    = v_namguar4,
               namguar5    = v_namguar5,
               dteguabd    = v_dteguabd,
               dteguret    = v_dteguret,
               adrcont     = v_adrcont,
               codpost     = v_codpost,
               numtele     = v_numtele,
               numfax      = v_numfax,
               email       = v_email,
               codident    = v_codident,
               numoffid    = v_numoffid,
               dteidexp    = v_dteidexp,
               desnote     = v_desnote,
               codoccup    = v_codoccup,
               despos      = v_despos,
               amtmthin    = v_amtmthin,
               adroffi     = v_adroffi,
               codposto    = v_codposto,
               desappr     = v_desappr,
               dteappr     = v_dteappr,
               codappr     = v_codappr,
               coduser     = global_v_coduser
         where codempid    = p_codempid
           and numseq      = p_numseq
           and dtechg      = p_dtechg;
        --param_msg_error := get_error_msg_php('HR2005', global_v_lang);
      end;
      ----
      begin
        select codcomp,codpos
          into v_codcomp, v_codpos
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tguarntr');
        -- return;  -- softberry || 20/03/2023 || #8764 || return;
      end;
      n_amtguarntr := hcm_util.get_string_t(json_params, 'amtguarntr');
      begin
        insert into ttotguar(codempid, codcomp, codpos, qtyquar, amtbudguar, dtecreate, codcreate, coduser)
                      values(p_codempid, v_codcomp, v_codpos, 1, stdenc(n_amtguarntr,p_codempid,hcm_secur.get_v_chken), sysdate, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        v_amtguarntr := stddec(v_amtguarntr,p_codempid,hcm_secur.get_v_chken); ----
        update ttotguar
           set ----amtbudguar = (amtbudguar - v_amtguarntr) + n_amtguarntr,
               amtbudguar = stdenc((stddec(amtbudguar,p_codempid,hcm_secur.get_v_chken) - v_amtguarntr) + n_amtguarntr
                                  ,p_codempid,hcm_secur.get_v_chken),
               dteupd     = sysdate,
               coduser    = global_v_coduser
         where codempid   = p_codempid;
      end;
      ----
      v_numseq            := hcm_util.get_string_t(json_params, 'numseq');
      v_dtegucon          := to_date(hcm_util.get_string_t(json_params, 'dtegucon'), 'DD/MM/YYYY');
      v_amtguarntr        := hcm_util.get_string_t(json_params, 'amtguarntr');
      v_amtguarntr        := stdenc(v_amtguarntr,p_codempid,hcm_secur.get_v_chken); --#5824 || USER39 || 08/10/2021
      v_desrelat          := hcm_util.get_string_t(json_params, 'desrelat');
      v_codempg           := hcm_util.get_string_t(json_params, 'codempg');
      v_codtitle          := hcm_util.get_string_t(json_params, 'codtitle');
      v_namguare          := hcm_util.get_string_t(json_params, 'namguare');
      v_namguart          := hcm_util.get_string_t(json_params, 'namguart');
      v_namguar3          := hcm_util.get_string_t(json_params, 'namguar3');
      v_namguar4          := hcm_util.get_string_t(json_params, 'namguar4');
      v_namguar5          := hcm_util.get_string_t(json_params, 'namguar5');
      v_dteguabd          := to_date(hcm_util.get_string_t(json_params, 'dteguabd'), 'DD/MM/YYYY');
      v_dteguret          := to_date(hcm_util.get_string_t(json_params, 'dteguret'), 'DD/MM/YYYY');
      v_adrcont           := hcm_util.get_string_t(json_params, 'adrcont');
      v_codpost           := hcm_util.get_string_t(json_params, 'codpost');
      v_numtele           := hcm_util.get_string_t(json_params, 'numtele');
      v_numfax            := hcm_util.get_string_t(json_params, 'numfax');
      v_email             := hcm_util.get_string_t(json_params, 'email');
      v_codident          := hcm_util.get_string_t(json_params, 'codident');
      v_numoffid          := hcm_util.get_string_t(json_params, 'numoffid');
      v_dteidexp          := to_date(hcm_util.get_string_t(json_params, 'dteidexp'), 'DD/MM/YYYY');
      v_desnote           := hcm_util.get_string_t(json_params, 'desnote');
      v_codoccup          := hcm_util.get_string_t(json_params, 'codoccup');
      v_despos            := hcm_util.get_string_t(json_params, 'despos');
      v_amtmthin          := hcm_util.get_string_t(json_params, 'amtmthin');
      v_amtmthin          := stdenc(v_amtmthin,p_codempid,hcm_secur.get_v_chken);  --#5824 || USER39 || 08/10/2021
      v_adroffi           := hcm_util.get_string_t(json_params, 'adroffi');
      v_codposto          := hcm_util.get_string_t(json_params, 'codposto');
      begin
        update tguarntr
           set dtegucon   = v_dtegucon,
               amtguarntr = v_amtguarntr,
               desrelat   = v_desrelat,
               codempgrt  = v_codempg,
               codtitle   = v_codtitle,
               namguare   = v_namguare,
               namguart   = v_namguart,
               namguar3   = v_namguar3,
               namguar4   = v_namguar4,
               namguar5   = v_namguar5,
               dteguabd   = v_dteguabd,
               dteguret   = v_dteguret,
               adrcont    = v_adrcont,
               codpost    = v_codpost,
               numtele    = v_numtele,
               numfax     = v_numfax,
               email      = v_email,
               codident   = v_codident,
               numoffid   = v_numoffid,
               dteidexp   = v_dteidexp,
               desnote    = v_desnote,
               codoccup   = v_codoccup,
               despos     = v_despos,
               amtmthin   = v_amtmthin,
               adroffi    = v_adroffi,
               codposto   = v_codposto,
               coduser    = global_v_coduser,
               dteupd     = sysdate
         where codempid   = p_codempid
           and numseq     = p_numseq;
      exception when others then
        null;
      end;
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

  procedure gen_data_employee(json_str_output out clob)as
    obj_data        json_object_t;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_jobgrade      temploy1.jobgrade%type;
    v_dteempmt      temploy1.dteempmt%type;
    v_dteempdb      temploy1.dteempdb%type;
    v_namemp        temploy1.namempt%type;
    v_adrcont       temploy2.adrcontt%type;
    v_year          number;
    v_month         number;
    v_day           number;
    rec_temploy1    temploy1%rowtype;
    rec_temploy2    temploy2%rowtype;
    rec_temploy3    temploy3%rowtype;
    v_tcompny       tcompny%rowtype;
    v_desc_codprov      varchar2(4000 char) := '';
    v_desc_codsubdist   varchar2(4000 char) := '';
    v_desc_coddist      varchar2(4000 char) := '';
    v_sumhur		        number := 0;
		v_sumday		        number := 0;
		v_summon		        number := 0;
  begin
    begin
      select *
        into rec_temploy1
        from temploy1
        where codempid = p_codempid;

    exception when no_data_found then
      rec_temploy1  := null;
    end;
    begin
      select *
        into rec_temploy2
        from temploy2
        where codempid = p_codempid;

    exception when no_data_found then
      rec_temploy2  := null;
    end;
    begin
      select *
        into rec_temploy3
        from temploy3
        where codempid = p_codempid;

    exception when no_data_found then
      rec_temploy3  := null;
    end;
    begin
      select decode(global_v_lang,'101',namempe
                                 ,'102',namempt
                                 ,'103',namemp3
                                 ,'104',namemp4
                                 ,'105',namemp5) as namemp
        into v_namemp
        from temploy1
        where codempid = p_codempid;

    exception when no_data_found then
      v_namemp  := null;
    end;
    begin
      select decode(global_v_lang,'101',adrconte
                                 ,'102',adrcontt
                                 ,'103',adrcont3
                                 ,'104',adrcont4
                                 ,'105',adrcont5) as adrcont
        into v_adrcont
        from temploy2
        where codempid = p_codempid;

    exception when no_data_found then
      v_adrcont  := null;
    end;

    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codtitle', rec_temploy1.codtitle );
    obj_data.put('namguar', v_namemp );
    obj_data.put('namguare', rec_temploy1.namempe );
    obj_data.put('namguart', rec_temploy1.namempt );
    obj_data.put('namguar3', rec_temploy1.namemp3 );
    obj_data.put('namguar4', rec_temploy1.namemp4 );
    obj_data.put('namguar5', rec_temploy1.namemp5 );
    obj_data.put('dteguabd', to_char(rec_temploy1.DTEEMPDB,'dd/mm/yyyy') );
    obj_data.put('desrelat', '' );
    obj_data.put('dteguret', to_char(rec_temploy1.DTERETIRE,'dd/mm/yyyy') );
    obj_data.put('adrcont', v_adrcont || ' ' || get_tsubdist_name(rec_temploy2.codsubdistc,global_v_lang) || ' ' || get_tcoddist_name(rec_temploy2.coddistc, global_v_lang) || ' ' || get_tcodec_name('TCODPROV', rec_temploy2.codprovc,global_v_lang) || ' ' || rec_temploy2.codpostc );
    obj_data.put('codpost', rec_temploy2.codpostc );
    obj_data.put('numtele', rec_temploy2.numtelec );
    obj_data.put('numfax', '' );
    obj_data.put('email', rec_temploy1.email );
    obj_data.put('codoccup', '' );
    obj_data.put('despos', get_tpostn_name(rec_temploy1.codpos, global_v_lang) );

    get_wage_income( hcm_util.get_codcomp_level(rec_temploy1.codcomp,1) ,rec_temploy1.codempmt,
                 to_number(stddec(rec_temploy3.amtincom1,p_codempid,v_chken)),
                 to_number(stddec(rec_temploy3.amtincom2,p_codempid,v_chken)),
                 to_number(stddec(rec_temploy3.amtincom3,p_codempid,v_chken)),
                 to_number(stddec(rec_temploy3.amtincom4,p_codempid,v_chken)),
                 to_number(stddec(rec_temploy3.amtincom5,p_codempid,v_chken)),
                 to_number(stddec(rec_temploy3.amtincom6,p_codempid,v_chken)),
                 to_number(stddec(rec_temploy3.amtincom7,p_codempid,v_chken)),
                 to_number(stddec(rec_temploy3.amtincom8,p_codempid,v_chken)),
                 to_number(stddec(rec_temploy3.amtincom9,p_codempid,v_chken)),
                 to_number(stddec(rec_temploy3.amtincom10,p_codempid,v_chken)),
                 v_sumhur ,v_sumday,v_summon);
    obj_data.put('amtmthin', v_summon );
    --
    begin
      select *
        into v_tcompny
        from tcompny
       where codcompy = hcm_util.get_codcomp_level(rec_temploy1.codcomp,1);
    exception when no_data_found then
      null;
    end;
    obj_data.put('adroffi', get_tcenter_name(rec_temploy1.codcomp,global_v_lang) );
    obj_data.put('codposto', v_tcompny.zipcode );
    obj_data.put('codident', '' );
    obj_data.put('numoffid', rec_temploy2.numoffid );
    obj_data.put('dteidexp', to_char(rec_temploy2.dteoffid,'dd/mm/yyyy') );

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_data_employee(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_data_employee(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HRRC53E;

/
