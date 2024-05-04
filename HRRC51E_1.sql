--------------------------------------------------------
--  DDL for Package Body HRRC51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRRC51E" AS
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
    -- save detail
    json_params         := hcm_util.get_json_t(json_obj, 'json_params');
    p_warning           := hcm_util.get_string_t(json_obj, 'p_warning');      --<<#7684
    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_staemp            temploy1.staemp%type;
  begin
    if p_codempid is not null then
      begin
        select staemp, codcomp
          into v_staemp, p_codcomp
          from temploy1
         where codempid = p_codempid
           and staemp   in ('1', '3');
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
      select codempid, numseq, codempgrt, codtitle, dtegucon, amtguarntr,
             decode(global_v_lang, '101', namguare
                                 , '102', namguart
                                 , '103', namguar3
                                 , '104', namguar4
                                 , '105', namguar5, namguare) namguar
        from tguarntr
       where codempid = p_codempid
       order by numseq;

  begin
    obj_rows            := json_object_t();

    for i in c1 loop
      v_rcnt              := v_rcnt + 1;
      obj_data            := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', i.codempid);
      obj_data.put('numseq', i.numseq);
      obj_data.put('dtegucon', to_char(i.dtegucon, 'DD/MM/YYYY'));
      obj_data.put('amtguarntr', stddec(i.amtguarntr, p_codempid, v_chken));
      if i.codempgrt is null then
        obj_data.put('namguar', get_tlistval_name('CODTITLE', i.codtitle, global_v_lang) || i.namguar);
      else
        obj_data.put('namguar', get_temploy_name(i.codempgrt, global_v_lang));
      end if;

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
    v_numseq            tguarntr.numseq%type;
    v_dtegucon          tguarntr.dtegucon%type;
    v_amtguarntr        tguarntr.amtguarntr%type;
    v_desrelat          tguarntr.desrelat%type;
    v_codempgrt         tguarntr.codempgrt%type;
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
      select numseq, dtegucon, amtguarntr, desrelat, codempgrt,
             codtitle, namguare, namguart, namguar3, namguar4, namguar5,
             dteguabd, dteguret, adrcont, codpost, numtele, numfax, email,
             codident, numoffid, dteidexp, desnote, codoccup, despos,
             amtmthin, adroffi, codposto
        into v_numseq, v_dtegucon, v_amtguarntr, v_desrelat, v_codempgrt,
             v_codtitle, v_namguare, v_namguart, v_namguar3, v_namguar4, v_namguar5,
             v_dteguabd, v_dteguret, v_adrcont, v_codpost, v_numtele, v_numfax, v_email,
             v_codident, v_numoffid, v_dteidexp, v_desnote, v_codoccup, v_despos,
             v_amtmthin, v_adroffi, v_codposto
        from tguarntr
       where codempid = p_codempid
         and numseq   = p_numseq;
    exception when no_data_found then
      select nvl(max(numseq), 0) + 1
        into v_numseq
        from tguarntr
       where codempid = p_codempid;
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

    if  v_dtegucon is null then
      begin
        select dteempmt into v_dtegucon
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        v_dtegucon := '';
      end;
    end if;

    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', p_codempid);
    obj_data.put('numseq', v_numseq);
    obj_data.put('dtegucon', to_char(v_dtegucon, 'DD/MM/YYYY'));
    obj_data.put('amtguarntr', stddec(v_amtguarntr, p_codempid, v_chken));

    obj_data.put('desrelat', v_desrelat);

    obj_data.put('codempg', v_codempgrt);
    obj_data.put('codtitle', v_codtitle);
    obj_data.put('namguar', v_namguar);
    obj_data.put('namguare', v_namguare);
    obj_data.put('namguart', v_namguart);
    obj_data.put('namguar3', v_namguar3);
    obj_data.put('namguar4', v_namguar4);
    obj_data.put('namguar5', v_namguar5);
    obj_data.put('dteguabd', to_char(v_dteguabd, 'DD/MM/YYYY'));
    obj_data.put('dteguret', to_char(v_dteguret, 'DD/MM/YYYY'));
    obj_data.put('adrcont', v_adrcont);
    obj_data.put('codpost', v_codpost);
    obj_data.put('numtele', v_numtele);
    obj_data.put('numfax', v_numfax);
    obj_data.put('email', v_email);
    obj_data.put('codident', v_codident);
    obj_data.put('numoffid', v_numoffid);
    obj_data.put('dteidexp', to_char(v_dteidexp, 'DD/MM/YYYY'));
    obj_data.put('desnote', v_desnote);
    obj_data.put('codoccup', v_codoccup);
    obj_data.put('despos', v_despos);
    obj_data.put('amtmthin', stddec(v_amtmthin, p_codempid, v_chken));
    obj_data.put('adroffi', v_adroffi);
    obj_data.put('codposto', v_codposto);

    json_str_output := obj_data.to_clob;
  end gen_detail;

  procedure get_detail_codempid (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_codempid(json_str_output);
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_detail_codempid;

  procedure gen_detail_codempid (json_str_output out clob) AS
    obj_data            json_object_t;
    v_dtegucon          tguarntr.dtegucon%type;
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
    v_email             tguarntr.email%type;
    v_codoccup          tguarntr.codoccup%type;
    v_despos            tguarntr.despos%type;
    v_adroffi           tguarntr.adroffi%type;
    v_codposto          tguarntr.codposto%type;
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

  begin
    begin
      select dteempmt, codtitle, namempe, namempt, namemp3, namemp4, namemp5,
             dteempdb, dteretire, adrcontt, codpostc, nummobile, email,
             get_tpostn_name(codpos, global_v_lang), codcomp, codempmt,
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
        into v_dtegucon, v_codtitle, v_namguare, v_namguart, v_namguar3, v_namguar4, v_namguar5,
             v_dteguabd, v_dteguret, v_adrcont, v_codpost, v_numtele, v_email,
             v_despos, v_codcomp, v_codempmt,
             v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
             v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10
        from temploy1 a, temploy2 b, temploy3 c
       where a.codempid = p_codempid
         and a.codempid = b.codempid
         and a.codempid = c.codempid;
      v_codoccup        := '0006';
      v_codcompy        := hcm_util.get_codcomp_level(v_codcomp, 1);
      get_wage_income(v_codcompy, v_codempmt,
                          v_amtincom1, v_amtincom2, v_amtincom3, v_amtincom4, v_amtincom5,
                          v_amtincom6, v_amtincom7, v_amtincom8, v_amtincom9, v_amtincom10,
                          v_amtothr, v_amtday, v_amtmth);
    exception when no_data_found then
      null;
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
    obj_data.put('codempid', p_codempid);
    obj_data.put('dtegucon', to_char(v_dtegucon, 'DD/MM/YYYY'));
    obj_data.put('codtitle', v_codtitle);
    obj_data.put('namguar', v_namguar);
    obj_data.put('namguare', v_namguare);
    obj_data.put('namguart', v_namguart);
    obj_data.put('namguar3', v_namguar3);
    obj_data.put('namguar4', v_namguar4);
    obj_data.put('namguar5', v_namguar5);
    obj_data.put('dteguabd', to_char(v_dteguabd, 'DD/MM/YYYY'));
    obj_data.put('dteguret', to_char(v_dteguret, 'DD/MM/YYYY'));
    obj_data.put('adrcont', v_adrcont);
    obj_data.put('codpost', v_codpost);
    obj_data.put('numtele', v_numtele);
    obj_data.put('email', v_email);
    obj_data.put('codoccup', v_codoccup);
    obj_data.put('despos', v_despos);
    obj_data.put('amtmthin', v_amtmth);
    obj_data.put('adroffi', get_tcompny_name(v_codcompy, global_v_lang));
    obj_data.put('codposto', v_codposto);

    json_str_output := obj_data.to_clob;
  end gen_detail_codempid;

  procedure save_index (json_str_input in clob, json_str_output out clob) AS
    obj_data            json_object_t;
    v_flg               varchar2(10 char);
    v_codempid          tguarntr.codempid%type;
    v_numseq            tguarntr.numseq%type;
    v_count             number := 0;
    v_sum               number := 0;
  begin
    initial_value(json_str_input);
    for i in 0 .. json_params.get_size - 1 loop
      obj_data            := hcm_util.get_json_t(json_params, to_char(i));
      v_flg               := hcm_util.get_string_t(obj_data, 'flg');
      v_codempid          := hcm_util.get_string_t(obj_data, 'codempid');
      v_numseq            := hcm_util.get_string_t(obj_data, 'numseq');
      if param_msg_error is null then
        if v_flg = 'delete' then
          begin
            delete from tguarntr
             where codempid = v_codempid
               and numseq   = v_numseq;
            begin
              select count(numseq), sum(stddec(amtguarntr, v_codempid, v_chken))
                into v_count, v_sum
                from tguarntr
               where codempid = v_codempid;
            exception when no_data_found then
              v_count     := 0;
              v_sum       := 0;
            end;
            update ttotguar
               set qtyquar    = v_count,
                   amtbudguar = stdenc(v_sum, v_codempid, v_chken),
                   dteupd     = sysdate,
                   coduser    = global_v_coduser
             where codempid   = v_codempid;
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
    b_amtguarntr        number;
    v_amtguarntr        number;
    n_amtguarntr        number;
  begin
    if p_codempid is not null then
      begin
        select staemp, codcomp, codpos, codjob
          into v_staemp, p_codcomp, p_codpos, p_codjob
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end;
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    --
    begin
      select amtguarntr
        into b_amtguarntr
        from tjobcode
       where codjob = p_codjob;
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
      if b_amtguarntr > v_amtguarntr and (param_flgwarn != 'Y' or param_flgwarn is null)  then -- softberry || 24/02/2023 || #8764 || if b_amtguarntr > v_amtguarntr  then
--      if b_amtguarntr > v_amtguarntr  then 
        param_msg_error := replace(get_error_msg_php('RC0043', global_v_lang),'[P-AMTCOLLA]',to_char(b_amtguarntr - v_amtguarntr, 'fm9,999,990.90'));
      end if;
    end if; -- b_amtguarntr is not null
  end check_save;

  procedure save_detail (json_str_input in clob, json_str_output out clob) AS
    obj_tmp             json_object_t;
    v_numseq            tguarntr.numseq%type;
    v_dtegucon          tguarntr.dtegucon%type;
    v_amtguarntr        tguarntr.amtguarntr%type;
    b_amtguarntr        tjobcode.amtguarntr%type;
--    v_desrelat          tguarntr.desrelat%type;  -- #7200 || USER39 || 08/12/2021
    v_desrelat          varchar2(1000 char); -- #7200 || USER39 || 08/12/2021
    v_codempgrt         tguarntr.codempgrt%type;
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
    --v_desnote           tguarntr.desnote%type; -- #7200 || USER39 || 08/12/2021
    v_desnote           varchar2(30000 char); -- #7200 || USER39 || 08/12/2021
    v_codoccup          tguarntr.codoccup%type;
    v_despos            tguarntr.despos%type;
    v_amtmthin          tguarntr.amtmthin%type;
    v_adroffi           tguarntr.adroffi%type;
    v_codposto          tguarntr.codposto%type;
    v_count             number := 0;
    v_sum               number := 0;
    v_amt               tjobcode.amtcolla%type;--<<#7684
  begin
    initial_value(json_str_input);
    param_flgwarn       := hcm_util.get_string_t(json_params,'flgwarning'); -- softberry || 24/02/2023 || #8764
    check_save;
    --<< softberry || 14/02/2023 || #9091
    if param_msg_error is not null and  (param_flgwarn != 'Y' or param_flgwarn is null)  then 
      json_str_output := get_response_message(null,param_msg_error,global_v_lang,'Y');
      return;
    end if;
    -->> softberry || 14/02/2023 || #9091        
    
    if param_msg_error is null then
      v_dtegucon          := to_date(hcm_util.get_string_t(json_params, 'dtegucon'), 'DD/MM/YYYY');
      v_amtguarntr        := hcm_util.get_string_t(json_params, 'amtguarntr');
      v_desrelat          := hcm_util.get_string_t(json_params, 'desrelat');
      v_desrelat          := substr(v_desrelat,1,40);  -- #7200 || USER39 || 08/12/2021
      v_codempgrt         := hcm_util.get_string_t(json_params, 'codempg');
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
      v_desnote           := substr(v_desnote,1,500);  -- #7200 || USER39 || 08/12/2021
      v_codoccup          := hcm_util.get_string_t(json_params, 'codoccup');
      v_despos            := hcm_util.get_string_t(json_params, 'despos');
      v_amtmthin          := hcm_util.get_string_t(json_params, 'amtmthin');
      v_adroffi           := hcm_util.get_string_t(json_params, 'adroffi');
      v_codposto          := hcm_util.get_string_t(json_params, 'codposto');

      if param_msg_error is null then
        begin
          insert into tguarntr
                 (codempid, numseq, dtegucon, amtguarntr, desrelat, codempgrt,
                  codtitle, namguare, namguart, namguar3, namguar4, namguar5,
                  dteguabd, dteguret, adrcont, codpost, numtele, numfax, email,
                  codident, numoffid, dteidexp, desnote, codoccup, despos,
                  amtmthin, adroffi, codposto, codcreate, dtecreate, coduser)
          values (p_codempid, p_numseq, v_dtegucon, stdenc(v_amtguarntr, p_codempid, v_chken), v_desrelat, v_codempgrt,
                  v_codtitle, v_namguare, v_namguart, v_namguar3, v_namguar4, v_namguar5,
                  v_dteguabd, v_dteguret, v_adrcont, v_codpost, v_numtele, v_numfax, v_email,
                  v_codident, v_numoffid, v_dteidexp, v_desnote, v_codoccup, v_despos,
                  stdenc(v_amtmthin, p_codempid, v_chken), v_adroffi, v_codposto, global_v_coduser, sysdate, global_v_coduser);
        exception when dup_val_on_index then
          update tguarntr
             set dtegucon   = v_dtegucon,
                 amtguarntr = stdenc(v_amtguarntr, p_codempid, v_chken),
                 desrelat   = v_desrelat,
                 codempgrt  = v_codempgrt,
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
                 amtmthin   = stdenc(v_amtmthin, p_codempid, v_chken),
                 adroffi    = v_adroffi,
                 codposto   = v_codposto,
                 coduser    = global_v_coduser,
                 dteupd     = sysdate
           where codempid   = p_codempid
             and numseq     = p_numseq;
        end;
      end if;
    end if;

    if param_msg_error is null then
      begin
        insert into ttotguar (codempid, codcomp, codpos, qtyquar, amtbudguar, dtecreate, codcreate, coduser)
        values (p_codempid, p_codcomp, p_codpos, 1, stdenc(v_amtguarntr, p_codempid, v_chken), sysdate, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        begin
          select count(numseq), sum(stddec(amtguarntr, p_codempid, v_chken))
            into v_count, v_sum
            from tguarntr
           where codempid = p_codempid;
        exception when no_data_found then
          v_count     := 1;
          v_sum       := v_amtguarntr;
        end;
        update ttotguar
           set qtyquar    = v_count,
               amtbudguar = stdenc(v_sum, p_codempid, v_chken),
               dteupd     = sysdate,
               coduser    = global_v_coduser
         where codempid   = p_codempid;
      end;
    end if;

    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang); -- softberry || 27/02/2023 || #8764
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
end HRRC51E;

/
