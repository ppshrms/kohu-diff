--------------------------------------------------------
--  DDL for Package Body HRPY2OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY2OE" is
-- last update: 24/08/2018 16:15
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := upper(hcm_util.get_string_t(json_obj, 'p_codempid'));
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');

    -- index
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'), 'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'), 'dd/mm/yyyy');
    p_dteresignstrt     := to_date(hcm_util.get_string_t(json_obj,'p_dteresignstrt'), 'dd/mm/yyyy');
    p_dteresignend      := to_date(hcm_util.get_string_t(json_obj,'p_dteresignend'), 'dd/mm/yyyy');
    p_codcomp           := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
    p_codempid          := upper(hcm_util.get_string_t(json_obj, 'p_codempid_query'));
    p_typretmt          := upper(hcm_util.get_string_t(json_obj, 'p_typretmt'));
    -- detail
    p_dtevcher          := to_date(hcm_util.get_string_t(json_obj,'p_dtevcher'), 'dd/mm/yyyy');
    -- tdeducto
    p_qtysrvyr          := to_number(hcm_util.get_string_t(json_obj, 'p_qtysrvyr'));
    p_qtyday            := to_number(hcm_util.get_string_t(json_obj, 'p_qtyday'));
    p_qtymthsal         := to_number(hcm_util.get_string_t(json_obj, 'p_qtymthsal'));
    p_pctplus           := to_number(hcm_util.get_string_t(json_obj, 'p_pctplus'));
    p_amtratec1         := to_number(hcm_util.get_string_t(json_obj, 'p_amtratec1'));
    p_amtratec2         := to_number(hcm_util.get_string_t(json_obj, 'p_amtratec2'));
    p_pctexprt          := to_number(hcm_util.get_string_t(json_obj, 'p_pctexprt'));
    p_amtmaxtax         := to_number(hcm_util.get_string_t(json_obj, 'p_amtmaxtax'));
    p_amtmaxday         := to_number(hcm_util.get_string_t(json_obj, 'p_amtmaxday'));
    -- cal_amttax
    p_amtnet            := to_number(hcm_util.get_string_t(json_obj, 'p_amtnet'));
    p_flgtax            := hcm_util.get_string_t(json_obj, 'p_flgtax');
    -- tcompstn
    p_tcompstn_amtprovf  := to_number(hcm_util.get_string_t(json_obj, 'amtprovf'));
    p_tcompstn_amtsvr    := to_number(hcm_util.get_string_t(json_obj, 'amtsvr'));
    p_tcompstn_amtexctax := to_number(hcm_util.get_string_t(json_obj, 'amtexctax'));
    p_tcompstn_amtothcps := to_number(hcm_util.get_string_t(json_obj, 'amtothcps'));
    p_tcompstn_amtexpnse := to_number(hcm_util.get_string_t(json_obj, 'amtexpnse'));
    p_tcompstn_amttaxcps := to_number(hcm_util.get_string_t(json_obj, 'amttaxcps'));
    p_tcompstn_amtavgsal := to_number(hcm_util.get_string_t(json_obj, 'amtavgsal'));
    p_tcompstn_stavcher  := hcm_util.get_string_t(json_obj, 'stavcher');
    p_tcompstn_wrkyr     := hcm_util.get_string_t(json_obj, 'wrkyr');
    p_tcompstn_flgavgsal := hcm_util.get_string_t(json_obj, 'flgavgsal');
    p_tcompstn_flgexpnse := hcm_util.get_string_t(json_obj, 'flgexpnse');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codempid is not null then
      v_flgsecur := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_zupdsal = 'N' then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;

    if p_typretmt is not null then
      param_msg_error := check_tcodec('TCODRETM', p_typretmt, global_v_lang);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codcomp is null and p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'codcomp');
      return;
    end if;
  end;

  procedure check_detail is
    v_staemp              varchar2(1 char);
    v_codempid            varchar2(100 char);
    v_qtysrvyr            tdeducto.qtysrvyr%type := 0;
    v_count_tdeducto      number := 0;
  begin
    if p_codempid is not null then
        begin
          select staemp into v_staemp
            from temploy1
          where codempid like p_codempid;
          if v_staemp = '0' then
            param_msg_error := get_error_msg_php('HR2102', global_v_lang);
            return;
          end if;
        exception when no_data_found then
          null;
        end;
      if param_msg_error is null then
        param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, p_codempid, false);
        if param_msg_error is not null then
          return;
        else
          v_flgsecur := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
          if v_zupdsal = 'N' then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang);
            return;
          end if;
        end if;
      end if;

      if param_msg_error is null then
        begin
          select codempid into v_codempid
            from ttpminf
          where codempid = p_codempid
            and rownum = 1;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttpminf');
          return;
        end;
      end if;

      if param_msg_error is null then
        begin
          select qtysrvyr into v_qtysrvyr
            from tdeducto
          where rownum = 1;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tdeducto');
          return;
        end;
      end if;

      if param_msg_error is null then
        begin
          select a.codempid into v_codempid
            from temploy1 a
            where a.codempid = p_codempid
              and add_months(a.dteempmt, (12 * v_qtysrvyr)) <= trunc(sysdate);
        exception when no_data_found then
          param_msg_error := get_error_msg_php('PY0011', global_v_lang);
          param_msg_error := replace(param_msg_error, '#1', v_qtysrvyr);
          return;
        end;
      end if;
    end if;

    if p_typretmt is not null then
      param_msg_error := check_tcodec('TCODRETM', p_typretmt, global_v_lang);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if param_msg_error is null then
      begin
        select codincom1,codincom2,codincom3,codincom4,codincom5,
                codincom6,codincom7,codincom8,codincom9,codincom10
          into p_tcontpms_codincom1,p_tcontpms_codincom2,p_tcontpms_codincom3,p_tcontpms_codincom4,p_tcontpms_codincom5,
                p_tcontpms_codincom6,p_tcontpms_codincom7,p_tcontpms_codincom8,p_tcontpms_codincom9,p_tcontpms_codincom10
          from tcontpms
          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
          and dteeffec = (select max(dteeffec)
                              from tcontpms
                            where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteeffec <= trunc(sysdate));
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tcontpms');
        return;
      end;
    end if;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_codcomp           varchar2(100 char);
    v_secur             boolean := false;
    v_flgdata           boolean := false;

    cursor c_tinitregh is
      select codempid, codcomp, dtevcher, typretmt, stavcher
        from tcompstn
       where codcomp   like nvl(v_codcomp, codcomp)
         and typretmt  = nvl(p_typretmt, typretmt)
         and (dtevcher between nvl(p_dtestrt, dtevcher) and nvl(p_dteend, dtevcher))
         and codempid  = nvl(p_codempid, codempid)
      order by codempid;

  begin
    obj_row            := json_object_t();
    if p_codcomp is not null then
      v_codcomp := p_codcomp || '%';
    end if;
    for r1 in c_tinitregh loop
      v_flgdata := true;
      v_flgsecur := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

      if v_flgsecur and v_zupdsal ='Y' then
        v_secur            := true;
        v_rcnt             := v_rcnt + 1;
        obj_data           := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('dtevcher', to_char(r1.dtevcher, 'dd/mm/yyyy'));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('typretmt', r1.typretmt);
        obj_data.put('desc_typretmt', get_tcodec_name('TCODRETM', r1.typretmt, global_v_lang));
        obj_data.put('stavcher', r1.stavcher);

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if v_flgdata and  not v_secur then
      param_msg_error   := get_error_msg_php('HR3007', global_v_lang);
      json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  end gen_index;

  procedure get_scrlabel (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_scrlabel (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_scrlabel;

  procedure gen_scrlabel (json_str_output out clob) is
    obj_data            json_object_t;
    v_flgexst           boolean := false;
    cursor c1_tdeducto is
      select qtymthsal, pctplus, amtratec1, amtratec2, pctexprt, amtmaxtax, amtmaxday
        from tdeducto;

    cursor c1_tcompstn is
      select qtymthsal, pctplus, amtratec1, amtratec2, pctexprt, amtmaxtax, amtmaxday
        from tcompstn
       where codempid = p_codempid;

  begin
    for r1 in c1_tcompstn loop
      v_flgexst := true;
      exit;
    end loop;
    obj_data           := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('qtymthsal', '');
    obj_data.put('pctplus', '');
    obj_data.put('amtratec1', '0');
    obj_data.put('amtratec2', '0');
    obj_data.put('pctexprt', '');
    obj_data.put('amtmaxtax', '0');
    obj_data.put('amtmaxday', '');
    if p_codempid is null then
      for r1 in c1_tdeducto loop
        obj_data.put('qtymthsal', r1.qtymthsal);
        obj_data.put('pctplus', r1.pctplus);
        obj_data.put('amtratec1', to_char(nvl(r1.amtratec1, 0), 'fm99,999,990'));
        obj_data.put('amtratec2', to_char(nvl(r1.amtratec2, 0), 'fm99,999,990'));
        obj_data.put('pctexprt', r1.pctexprt);
        obj_data.put('amtmaxtax', to_char(nvl(r1.amtmaxtax, 0), 'fm99,999,990'));
        obj_data.put('amtmaxday', r1.amtmaxday);
      end loop;
    else
      if v_flgexst then
        for r1 in c1_tcompstn loop
          obj_data.put('qtymthsal', r1.qtymthsal);
          obj_data.put('pctplus', r1.pctplus);
          obj_data.put('amtratec1', to_char(nvl(r1.amtratec1, 0), 'fm99,999,990'));
          obj_data.put('amtratec2', to_char(nvl(r1.amtratec2, 0), 'fm99,999,990'));
          obj_data.put('pctexprt', r1.pctexprt);
          obj_data.put('amtmaxtax', to_char(nvl(r1.amtmaxtax, 0), 'fm99,999,990'));
          obj_data.put('amtmaxday', r1.amtmaxday);
        end loop;
      else
       for r1 in c1_tdeducto loop
          obj_data.put('qtymthsal', r1.qtymthsal);
          obj_data.put('pctplus', r1.pctplus);
          obj_data.put('amtratec1', to_char(nvl(r1.amtratec1, 0), 'fm99,999,990'));
          obj_data.put('amtratec2', to_char(nvl(r1.amtratec2, 0), 'fm99,999,990'));
          obj_data.put('pctexprt', r1.pctexprt);
          obj_data.put('amtmaxtax', to_char(nvl(r1.amtmaxtax, 0), 'fm99,999,990'));
          obj_data.put('amtmaxday', r1.amtmaxday);
        end loop;
      end if;
    end if;

    json_str_output := obj_data.to_clob;
  end gen_scrlabel;

  procedure get_tdeducto (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_tdeducto (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tdeducto;

  procedure gen_tdeducto (json_str_output out clob) is
    obj_data            json_object_t;

    cursor c1_tdeducto is
      select qtysrvyr, qtyday, qtymthsal, pctplus, amtratec1, amtratec2, pctexprt, amtmaxtax, amtmaxday
        from tdeducto;

  begin
    obj_data           := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('qtysrvyr', '');
    obj_data.put('qtyday', '');
    obj_data.put('qtymthsal', '');
    obj_data.put('pctplus', '');
    obj_data.put('amtratec1', '0');
    obj_data.put('amtratec2', '0');
    obj_data.put('pctexprt', '');
    obj_data.put('amtmaxtax', '0');
    obj_data.put('amtmaxday', '');
    for r1 in c1_tdeducto loop
      obj_data.put('qtysrvyr', r1.qtysrvyr);
      obj_data.put('qtyday', r1.qtyday);
      obj_data.put('qtymthsal', r1.qtymthsal);
      obj_data.put('pctplus', r1.pctplus);
      obj_data.put('amtratec1', nvl(r1.amtratec1, 0));
      obj_data.put('amtratec2', nvl(r1.amtratec2, 0));
      obj_data.put('pctexprt', r1.pctexprt);
      obj_data.put('amtmaxtax', nvl(r1.amtmaxtax, 0));
      obj_data.put('amtmaxday', r1.amtmaxday);
    end loop;

    json_str_output := obj_data.to_clob;
  end gen_tdeducto;

  procedure save_tdeducto (json_str_input in clob, json_str_output out clob) is
    v_exists            varchar2(1 char);
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      begin
        select 'Y'
          into v_exists
          from tdeducto
         where rownum = 1;
      exception when no_data_found then
          null;
      end;
      if v_exists = 'Y' then
        update tdeducto
           set qtysrvyr = p_qtysrvyr,
               qtyday = p_qtyday,
               qtymthsal = p_qtymthsal,
               pctplus = p_pctplus,
               amtratec1 = p_amtratec1,
               amtratec2 = p_amtratec2,
               pctexprt = p_pctexprt,
               amtmaxtax = p_amtmaxtax,
               amtmaxday = p_amtmaxday,
               coduser = global_v_coduser;
      else
        insert into tdeducto
        (qtysrvyr, qtyday, qtymthsal, pctplus, amtratec1, amtratec2, pctexprt, amtmaxtax, amtmaxday, codcreate)
        values
        (p_qtysrvyr, p_qtyday, p_qtymthsal, p_pctplus, p_amtratec1, p_amtratec2, p_pctexprt, p_amtmaxtax, p_amtmaxday, global_v_coduser);
      end if;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_tdeducto;

  procedure initial_detail is
    v_year         number := 0;
    v_month        number := 0;
    v_date         number := 0;
    v_day          number := 0;
    v_qtyday       number := 0;
    v_dteempmt     temploy1.dteempmt%type;
    v_dteeffex     temploy1.dteeffex%type;
  begin
    p_cal := 'Y';
    begin
      select qtymthsal, pctplus,
              qtysrvyr, qtyday,
              amtratec1, amtratec2,
              pctexprt, amtmaxday,
              amtmaxtax
        into p_qtymthsal, p_pctplus,
             p_qtysrvyr, v_qtyday,
             p_amtratec1, p_amtratec2,
             p_pctexprt, p_amtmaxday,
             p_amtmaxtax
        from tdeducto
       where rownum <= 1;
    exception when no_data_found then
      null;
    end;

    begin
      select qtyday
        into p_qtyday
        from tcompstn
       where codempid = p_codempid;
    exception when no_data_found then
      p_qtyday := v_qtyday;
    end;

    begin
      select dteempmt, dteeffex, codcomp, typpayroll
        into v_dteempmt, v_dteeffex, p_codcomp, p_typpayroll
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      null;
    end;

    begin
      select codcurr, amtincom1
        into p_codcurr, p_amtsalary
        from temploy3
       where codempid = p_codempid;
    exception when no_data_found then
      null;
    end;

    --<<user14 29/05/2012 SNT-550016
    if v_dteeffex is null then
        begin
            select max(dteeffec)
              into v_dteeffex
              from ttexempt
            where codempid = p_codempid
              and staupd = 'C';
        exception when no_data_found then
            v_dteeffex   := null;
        end;
    end if;
    -->>user14 29/05/2012 SNT-550016

    get_service_year(v_dteempmt, v_dteeffex, 'Y', v_year, v_month, v_date);
    v_day := (v_month * 30) + v_date;
    if v_day >= p_qtyday then
      v_year := v_year + 1;
    end if;
    p_wrkyr := v_year;
  end;

  procedure get_tcompstn (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    initial_detail;
    check_detail;
    if param_msg_error is null then
      begin
        delete ttemprpt where codempid = global_v_codempid
                          and codapp   = 'HRPY2OE';
      end;
      gen_tcompstn (json_str_output);
      temp_report;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tcompstn;

  procedure gen_tcompstn (json_str_output out clob) is
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_codcomp           varchar2(100 char);
    v_flgretire         varchar2(10 char);

    cursor c_tcompstn is
      select codempid, codcomp, dtevcher, typretmt,
              amtprovf, amtexpnse, amtsvr, amtexctax,
              amtothcps, amttaxcps, stavcher, wrkyr,
              flgavgsal, flgexpnse, amtavgsal
        from tcompstn
       where codempid = p_codempid
         and typretmt = p_typretmt
         and dtevcher = p_dtevcher
      order by codempid;

  begin
    obj_data           := json_object_t();
    obj_data.put('coderror', '200');

    --<< user4 || 23/11/2022
    begin
     select nvl(flgretire,'N')
      into v_flgretire
      from tretirmt
     where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
       and typretmt = p_typretmt
       and dteeffec = (select max(dteeffec)
                        from tretirmt
                       where typretmt = p_typretmt
                         and codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                         and dteeffec <= sysdate)
       and rownum = 1;
    exception when no_data_found then
      v_flgretire := 'N';
    end;
    -->> user4 || 23/11/2022

    for r1 in c_tcompstn loop
      v_rcnt             := v_rcnt + 1;
      obj_data.put('codempid', r1.codempid);
      obj_data.put('dtevcher', to_char(r1.dtevcher, 'dd/mm/yyyy'));
      obj_data.put('codcomp', nvl(r1.codcomp, p_codcomp));
      obj_data.put('typretmt', r1.typretmt);
      obj_data.put('amtprovf', nvl(stddec(r1.amtprovf, r1.codempid, v_chken), 0));
      obj_data.put('amtexpnse', nvl(stddec(r1.amtexpnse, r1.codempid, v_chken), 0));
      --<< user4 || 23/11/2022
      --obj_data.put('amtsvr', nvl(stddec(r1.amtsvr, r1.codempid, v_chken), 0));
      if v_flgretire = 'Y' then
        obj_data.put('amtsvr', '');
      else
        obj_data.put('amtsvr', nvl(stddec(r1.amtsvr, r1.codempid, v_chken), 0));
      end if;
      -->> user4 || 23/11/2022
      obj_data.put('amtexctax', nvl(stddec(r1.amtexctax, r1.codempid, v_chken), 0));
      --<< user4 || 23/11/2022
      --obj_data.put('amtothcps', nvl(stddec(r1.amtothcps, r1.codempid, v_chken), 0));
      if v_flgretire = 'Y' then
        obj_data.put('amtothcps', nvl(stddec(r1.amtothcps, r1.codempid, v_chken), 0));
      else
        obj_data.put('amtothcps', '');
      end if;
      -->> user4 || 23/11/2022
      obj_data.put('amttaxcps', nvl(stddec(r1.amttaxcps, r1.codempid, v_chken), 0));
      obj_data.put('stavcher', r1.stavcher);
      if nvl(r1.stavcher,'') = 'P' then
        obj_data.put('flgreadonly', false);
        obj_data.put('flgreadonly', false);
      else
        obj_data.put('flgreadonly', true);
        --<<User37 #5934 10/06/2021
        obj_data.put('errormsg', replace(get_error_msg_php('PY0058', global_v_lang),'@#$%400'));
        --obj_data.put('errormsg', get_error_msg_php('PY0058', global_v_lang));
        -->>User37 #5934 10/06/2021
      end if;
      obj_data.put('wrkyr', r1.wrkyr);
      obj_data.put('flgavgsal', r1.flgavgsal);
      obj_data.put('flgexpnse', r1.flgexpnse);
      obj_data.put('amtavgsal', nvl(stddec(r1.amtavgsal, r1.codempid, v_chken), 0));
      p_flgavgsal_tmp := r1.flgavgsal;
      p_flgexpnse_tmp := r1.flgexpnse;
      p_tcompstn_amtprovf  := nvl(stddec(r1.amtprovf, r1.codempid, v_chken), 0);
      p_tcompstn_amtsvr    := nvl(stddec(r1.amtsvr, r1.codempid, v_chken), 0);
      p_tcompstn_amtexctax := nvl(stddec(r1.amtexctax, r1.codempid, v_chken), 0);
      p_tcompstn_amtothcps := nvl(stddec(r1.amtothcps, r1.codempid, v_chken), 0);
      p_tcompstn_amtavgsal := nvl(stddec(r1.amtavgsal, r1.codempid, v_chken), 0);
      p_tcompstn_total_amt := p_tcompstn_amtprovf + p_tcompstn_amtsvr - p_tcompstn_amtexctax + p_tcompstn_amtothcps;
    end loop;
    if v_rcnt = 0 then
      obj_data.put('codempid', p_codempid);
      obj_data.put('dtevcher', to_char(p_dtevcher, 'dd/mm/yyyy'));
      obj_data.put('codcomp', p_codcomp);
      obj_data.put('typretmt', p_typretmt);
      obj_data.put('amtprovf', 0);
      obj_data.put('amtexpnse', 0);
      --<< user4 || 23/11/2022
      --obj_data.put('amtsvr', get_amtsvr(nvl(p_cal, 'N')));
      if v_flgretire = 'Y' then
        obj_data.put('amtsvr', '');
      else
        obj_data.put('amtsvr', get_amtsvr(nvl(p_cal, 'N')));
      end if;
      -->> user4 || 23/11/2022
      obj_data.put('amtexctax', get_amtexctax(nvl(p_cal, 'N')));

      --<< user4 || 23/11/2022
      --obj_data.put('amtothcps', 0);
      if v_flgretire = 'Y' then
        obj_data.put('amtothcps', 0);
      else
        obj_data.put('amtothcps', '');
      end if;
      -->> user4 || 23/11/2022
      obj_data.put('amttaxcps', 0);
      obj_data.put('stavcher', 'P');
      obj_data.put('flgreadonly', false);
      obj_data.put('wrkyr', p_wrkyr);
      obj_data.put('flgavgsal', '1');
      obj_data.put('flgexpnse', '1');
      obj_data.put('amtavgsal', 0);
      p_tcompstn_amtprovf  := 0;
      p_tcompstn_amtsvr    := get_amtsvr(nvl(p_cal, 'N'));
      p_tcompstn_amtexctax := get_amtexctax(nvl(p_cal, 'N'));
      p_tcompstn_amtothcps := 0;
      p_tcompstn_amtavgsal := 0;
      p_tcompstn_total_amt := p_tcompstn_amtprovf + p_tcompstn_amtsvr - p_tcompstn_amtexctax + p_tcompstn_amtothcps;
    end if;
    p_flgavgsal := '1';
    obj_data.put('flgavgsal1', get_avgsal(nvl(p_cal, 'N')));
    p_flgavgsal := '2';
    obj_data.put('flgavgsal2', get_avgsal(nvl(p_cal, 'N')));
    p_flgexpnse := '1';
    obj_data.put('amtratec1', p_amtratec1);
    p_flgexpnse := '2';
    obj_data.put('amtratec2', p_amtratec2);
    obj_data.put('tax_cal', get_tax_cal);
    obj_data.put('flgretire', v_flgretire); -- user4 || 23/11/2022
    json_str_output := obj_data.to_clob;
  end gen_tcompstn;

  procedure get_amttax (json_str_input in clob, json_str_output out clob) is
    obj_data          json_object_t;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      obj_data          := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response', cal_amttax(p_amtnet, p_flgtax));

      json_str_output :=obj_data.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_amttax;

  procedure save_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      begin
        delete
          from tcompstn
         where instr(',' || p_codempid || ',', ','||codempid||',') > 0
           and (stavcher <> 'F' OR stavcher IS NULL);
      end;
      param_msg_error := get_error_msg_php('HR2425', global_v_lang);
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure save_detail (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    initial_detail;
    if param_msg_error is null then
      begin
        insert into tcompstn
        (codempid, codcomp, typpayroll, dtevcher, typretmt,
         amtsvr, amtothcps,
         amtexctax, amtprovf,
         amtexpnse, amttaxcps,
         stavcher, amtavgsal,
         flgcps, codcurr, amtsalary, flgavgsal, flgexpnse,
         wrkyr, qtysrvyr, qtyday, qtymthsal, pctplus, amtratec1, amtratec2,
         pctexprt, amtmaxtax, amtmaxday, codcreate, coduser)
        values
        (p_codempid, p_codcomp, p_typpayroll, p_dtevcher,p_typretmt,
         stdenc(p_tcompstn_amtsvr, p_codempid, v_chken), stdenc(p_tcompstn_amtothcps, p_codempid, v_chken),
         stdenc(p_tcompstn_amtexctax, p_codempid, v_chken), stdenc(p_tcompstn_amtprovf, p_codempid, v_chken),
         stdenc(p_tcompstn_amtexpnse, p_codempid, v_chken), stdenc(p_tcompstn_amttaxcps, p_codempid, v_chken),
         p_tcompstn_stavcher, stdenc(p_tcompstn_amtavgsal, p_codempid, v_chken),
         'Y', p_codcurr, p_amtsalary, p_tcompstn_flgavgsal, p_tcompstn_flgexpnse,
         p_tcompstn_wrkyr, p_qtysrvyr, p_qtyday, p_qtymthsal, p_pctplus, p_amtratec1, p_amtratec2,
         p_pctexprt, p_amtmaxtax, p_amtmaxday, global_v_coduser, global_v_coduser);
      exception when dup_val_on_index then
        update tcompstn
           set codcomp   = p_codcomp,
               amtprovf  = stdenc(p_tcompstn_amtprovf, p_codempid, v_chken),
               amtsvr    = stdenc(p_tcompstn_amtsvr, p_codempid, v_chken),
               amtexctax = stdenc(p_tcompstn_amtexctax, p_codempid, v_chken),
               amtothcps = stdenc(p_tcompstn_amtothcps, p_codempid, v_chken),
               amtexpnse = stdenc(p_tcompstn_amtexpnse, p_codempid, v_chken),
               amttaxcps = stdenc(p_tcompstn_amttaxcps, p_codempid, v_chken),
               amtavgsal = stdenc(p_tcompstn_amtavgsal, p_codempid, v_chken),
               wrkyr     = p_tcompstn_wrkyr,
               flgavgsal = p_tcompstn_flgavgsal,
               flgexpnse = p_tcompstn_flgexpnse,
               typpayroll = p_typpayroll,
               codcurr   = p_codcurr,
               amtsalary = p_amtsalary,
               qtysrvyr  = p_qtysrvyr,
               qtyday    = p_qtyday,
               qtymthsal = p_qtymthsal,
               pctplus   = p_pctplus,
               amtratec1 = p_amtratec1,
               amtratec2 = p_amtratec2,
               pctexprt  = p_pctexprt,
               amtmaxtax = p_amtmaxtax,
               amtmaxday = p_amtmaxday,
               stavcher  = p_tcompstn_stavcher,--User37 #5934 10/06/2021
               coduser   = global_v_coduser
         where codempid  = p_codempid
           and dtevcher  = p_dtevcher
           and typretmt  = p_typretmt;
      end;
      param_msg_error := get_error_msg_php('HR2401', global_v_lang);
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;

  function get_amtsvr (p_type varchar2) return number is
    v_codcomp        temploy1.codcomp%type;
    v_codempmt       temploy1.codempmt%type;
    v_dteempmt       date;
    v_dteeffex       date;
    v_amtincom1      number := 0;
    v_amtsvr         number := 0;
    v_qtyday         number := 0;
    v_amthr          number := 0;
    v_amtday         number := 0;
    v_amtmth         number := 0;

  begin
    if nvl(p_type, 'N') = 'Y' then
        begin
          select a.codcomp, a.codempmt, stddec(b.amtincom1, a.codempid, v_chken) amtincom1,
                 a.dteempmt, a.dteeffex
            into v_codcomp, v_codempmt, v_amtincom1,
                 v_dteempmt, v_dteeffex
            from temploy1 a, temploy3 b
           where a.codempid = b.codempid
             and a.codempid = p_codempid;
        exception when no_data_found then
            v_codcomp   := null;
            v_codempmt  := null;
            v_amtincom1 := 0;
            v_dteempmt  := null;
            v_dteeffex  := null;
        end;

        --<<user14 29/05/2012 snt-550016
        if v_dteeffex is null then
            begin
                select max(dteeffec)
                  into v_dteeffex
                  from ttexempt
                 where codempid = p_codempid
                   and staupd in ('C','U');
            exception when no_data_found then
                  v_dteeffex   := null;
            end;
        end if;
        v_qtyday := v_dteeffex - v_dteempmt;
        -->>user14 29/05/2012 snt-550016
        get_wage_income(hcm_util.get_codcomp_level(v_codcomp, 1), v_codempmt, v_amtincom1,
                        0, 0, 0, 0, 0, 0, 0, 0, 0, v_amthr, v_amtday, v_amtmth);
        begin
--        select nvl(ratepay, 0) * v_amtmth
        select nvl(ratepay, 0) * v_amtday
          into v_amtsvr
          from tretirmt
         where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
           and typretmt = p_typretmt
           and v_qtyday between (nvl(qtyyrest, 0) * 365) + (nvl(qtymthst, 0) * 30) + nvl(qtydayst, 0)
                            and (nvl(qtyyreen, 0) * 365) + (nvl(qtymthen, 0) * 30) + nvl(qtydayen, 0)
           and dteeffec = (select max(dteeffec)
                             from tretirmt
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
                              and typretmt = p_typretmt
                              and dteeffec <= trunc(sysdate));
        exception when no_data_found then
          v_amtsvr := 0;
        end;
      end if;
    return v_amtsvr;
  end get_amtsvr;

  function get_retrospect(p_codcompy tdtepay.codcompy%type,
                          p_codempmt temploy1.codempmt%type,
                          p_dteeffex temploy1.dteeffex%type,
                          p_day      number) return number is

    v_dtestr             date := p_dteeffex - p_day;
    v_chk                varchar2(1 char) := 'N';
    v_typpayroll         tsincexp.typpayroll%type;
    v_period             number := 0;
    v_lstperiod          number := 0;
    v_minperiod          number := 0;
    v_maxperiod          number := 0;
    v_amtpay             number := 0;
    v_sumpay             number := 0;
    v_wrkdy              number := 0;
    v_day                number := 0;
    v_amthr              number := 0;
    v_amtday             number := 0;
    v_amtmth             number := 0;

    cursor c_tsincexp1 is
        select sum(stddec(amtpay, codempid, v_chken)) sum_pay
          from tsincexp
         where codempid = p_codempid
           and dteyrepay || lpad(dtemthpay, 2, '0') || lpad(numperiod, 2, '0') between v_minperiod and v_maxperiod
           and codpay = p_tcontpms_codincom1
           and flgslip =	'1'
      order by dteyrepay || lpad(dtemthpay, 2, '0') || lpad(numperiod, 2, '0') desc;

    cursor c_tsincexp2 is
        select sum(stddec(amtpay, codempid, v_chken)) sum_pay
          from tsincexp
        where codempid = p_codempid
          and dteyrepay || lpad(dtemthpay, 2, '0') || lpad(numperiod, 2, '0') = v_period
          and codpay = p_tcontpms_codincom1
          and flgslip =	'1'
      order by dteyrepay || lpad(dtemthpay, 2, '0') || lpad(numperiod, 2, '0') desc;

    cursor c_tdtepay is
        select dteyrepay || lpad(dtemthpay, 2, '0') || lpad(numperiod, 2, '0') period,
               dtestrt, dteend
          from tdtepay
        where codcompy = p_codcompy
          and typpayroll = v_typpayroll
          and dteyrepay  = to_number(to_char(v_dtestr, 'yyyy'))
      order by dteyrepay || lpad(dtemthpay, 2, '0') || lpad(numperiod, 2, '0') desc;

  begin

      begin
        select min(dteyrepay || lpad(dtemthpay, 2, '0') || lpad(numperiod, 2, '0')),
               max(dteyrepay || lpad(dtemthpay, 2, '0') || lpad(numperiod, 2, '0'))
          into v_minperiod, v_maxperiod
          from tsincexp
         where codempid = p_codempid
           and flgslip =	'1';
      exception when no_data_found then
          v_minperiod := null;
          v_maxperiod := null;
      end;
      begin
        select distinct typpayroll
          into v_typpayroll
          from tsincexp
         where codempid = p_codempid
           and dteyrepay = to_number(to_char(v_dtestr, 'yyyy'))
           and dtemthpay = to_number(to_char(v_dtestr, 'mm'))
           and flgslip = '1'
           and rownum = 1;
      exception when no_data_found then
          v_typpayroll  := null;
      end;
      if v_typpayroll is not null then
        for i in c_tdtepay loop
          if v_dtestr between i.dtestrt and i.dteend then
            v_period := i.period;
            v_day    := (i.dteend - v_dtestr) + 1;
            v_wrkdy  := (i.dteend - i.dtestrt)+ 1;
            exit;
          end if;
          v_lstperiod := i.period;
        end loop;
        v_minperiod   := v_lstperiod;
      end if;


      for i in c_tsincexp1 loop
          v_amtpay  := i.sum_pay;
      end loop;
      for i in c_tsincexp2 loop
          v_sumpay  := i.sum_pay;
      end loop;

      if v_wrkdy <> 0 then
        v_sumpay  := (v_day / v_wrkdy) * nvl(v_sumpay, 0);
      end if;

      v_amtpay  :=  v_amtpay + round(nvl(v_sumpay, 0), 2);

      get_wage_income(p_codcompy, p_codempmt, v_amtpay,
                      0, 0, 0, 0, 0, 0, 0, 0, 0, v_amthr, v_amtday, v_amtmth);

      v_amtpay := v_amtmth;
  return v_amtpay;
  end get_retrospect;

  function get_amtexctax (p_type varchar2) return number is
    v_unitcal1         tcontpmd.unitcal1%type;
    v_codcomp          temploy1.codcomp%type;
    v_dteeffex         temploy1.dteeffex%type;
    v_codempmt         temploy1.codempmt%type;
    v_amtincom1        number := 0;
    v_amtexctax        number := 0;

  begin
    if nvl(p_type,'N') = 'Y' then
      begin
        select a.codcomp, a.dteeffex, a.codempmt,
               stddec(b.amtincom1, a.codempid, v_chken) amtincom1
          into v_codcomp, v_dteeffex, v_codempmt, v_amtincom1
          from temploy1 a, temploy3 b
         where a.codempid = b.codempid
           and a.codempid = p_codempid;
      exception when no_data_found then
        v_codcomp   := null;
        v_dteeffex  := null;
        v_amtincom1 := null;
      end;
      --<<user14 29/05/2012 snt-550016
      if v_dteeffex is null then
        begin
          select max(dteeffec)
            into v_dteeffex
            from ttexempt
           where codempid = p_codempid
             and staupd in ('C','U');
        exception when no_data_found then
          v_dteeffex   := null;
        end;
      end if;
      -->>user14 29/05/2012 snt-550016

      v_amtexctax := get_retrospect(hcm_util.get_codcomp_level(v_codcomp, 1), v_codempmt, v_dteeffex, p_amtmaxday);
      v_amtexctax := least(nvl(v_amtexctax, 0), p_amtmaxtax);
    end if;
    return v_amtexctax;
  end get_amtexctax;

  function cal_amttax (p_amtnet number,
                       p_flgtax varchar2) return number is
    -- p_flgtax 1 ??A ??A???A<??A ??A???A???A ??A???A? ??A ??A???a???? ??A ??A???a??a????A ??A???A???A ??A???a? ??A ??A???a? ??A ??A???a? ??A ??A???A???A ??A???A?, 2 ??A ??A???A!.??A ??A???A-??A ??A???A-??A ??A???A???A ??A???a????A ??A???A<??A ??A???a??A?
    v_dteyreff number;
    v_amtcal   number;
    v_numseq   number;
    v_amt      number;
    tmp_amttax number := 0;

      cursor c_ttaxinf is
        select numseq, amtsalst, amtsalen, pcttax, nvl(amtacccal, 0) amtacccal
          from ttaxinf
        where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
          and typincom = '2'
          and dteyreff = (select max(dteyreff)
                            from ttaxinf
                           where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                             and typincom = '2'
                             and dteyreff <= to_number(to_char(sysdate, 'yyyy')))
          and p_amtnet between amtsalst and amtsalen;

      cursor c_ttaxinf2 is
        select numseq, amtsalst, pcttax, nvl(amtacccal, 0) amtacccal
          from ttaxinf
         where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
           and typincom = '2'
           and dteyreff = (select max(dteyreff)
                             from ttaxinf
                            where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                              and typincom = '2'
                              and dteyreff <= to_number(to_char(sysdate, 'yyyy')))
           and v_amt between amtsalst and amtsalen;

  begin
    if p_amtnet > 0 then
      for r1 in c_ttaxinf loop
        v_numseq := r1.numseq;
        v_amtcal :=	p_amtnet - r1.amtsalst + 1;
        if p_flgtax = '1' then
          tmp_amttax :=	round(v_amtcal * r1.pcttax / 100, 2) + r1.amtacccal;
        else
          tmp_amttax :=	(round(v_amtcal * r1.pcttax / 100, 2) + r1.amtacccal) /
                      (1 - (r1.pcttax / 100));
          v_amt := p_amtnet + tmp_amttax;
          if v_amt not between r1.amtsalst and r1.amtsalen then
            for r2 in c_ttaxinf2 loop
              v_amtcal :=	p_amtnet - r2.amtsalst + 1;
              tmp_amttax :=	(round(v_amtcal * r2.pcttax / 100, 2) + r2.amtacccal) /
                          (1 - (r2.pcttax / 100));
            end loop;
          end if;
        end if;
      end loop;
    end if;
    -- p_amttax := p_amttax + nvl(:parameter.taxadd, 0); -- ??A ??A???A!??A ??A???A???A ??A???A???A ??A???a?sA???A ??A???A???A ??A???A'??A ??A???a? ??A ??A???A!??A ??A???A???A ??A???a? ??A ??A???A???A ??A???a?zA???A ??A???a??A???A ??A???a? ??A ??A???A???A ??A???a??A!??A ??A???a???!??A ??A???A-??A ??A???a??A!??A ??A???a?sA???A ??A???a??A!??A ??A???A'??A ??A???a?zA???A ??A???a??????A ??A???a??A???A ??A???a??A???A ??A???A???A ??A???A???A ??A???a??a????A ??A???????A ??A???A'??A ??A???a??a????A ??A???A???A ??A???a? ??A ??A???a?sA???A ??A???A???A ??A???A???A ??A???a? ??A ??A???A???A ??A???A???A ??A???A???A ??A???A???A ??A???A!??A ??A???a?sA???A ??A???a??A!??A ??A???A???A ??A???a? ??A ??A???A-??A ??A???a?zA???A ??A???a??????A ??A???a???!??A ??A???A???A ??A???A???A ??A???A#??A ??A???a??A???A ??A???A???A ??A???a??A???A ??A???a?sA???A ??A???A???A ??A???A? --
    return tmp_amttax;
  end cal_amttax;

  function get_avgsal (p_type varchar2) return number is
    v_amtincom1  temploy3.amtincom1%type;
    v_qtymthsal  number := 0;
    v_year       number := 0;
    v_month      number := 0;
    v_date       date;
    v_codcurr    temploy3.codcurr%type;
    v_ratechg    number := 0;
    v_amthr      number := 0;
    v_amtday     number := 0;
    v_amtmth     number := 0;
    v_codcomp    temploy1.codcomp%type;
    v_codempmt   temploy1.codempmt%type;
    v_typpayroll temploy1.typpayroll%type;
    v_total      number := 0;
    v_count      number := 0;
    v_amtavgsal  number := 0;
    v_sal        number := 0;
    v_avgsal     number := 0;

    cursor c1 is
      select sum(stddec(a.amtpay, a.codempid, v_chken)) amtpay
        from tsincexp a
       where a.codempid = p_codempid
         and codpay = p_tcontpms_codincom1
         and flgslip =	'1'
          and exists(select codcompy
                       from tdtepay
                      where codcompy   = hcm_util.get_codcomp_level(v_codcomp, 1)
                        and typpayroll = v_typpayroll
                        and dteyrepay  = a.dteyrepay
                        and dtemthpay  = a.dtemthpay
                        and numperiod  = a.numperiod)
        group by a.dteyrepay, a.dtemthpay
        order by a.dteyrepay desc, a.dtemthpay desc;

  begin
    -- find fix income code
    begin
      select codincom1, codincom2, codincom3, codincom4, codincom5,
             codincom6, codincom7, codincom8, codincom9, codincom10
        into p_tcontpms_codincom1, p_tcontpms_codincom2, p_tcontpms_codincom3, p_tcontpms_codincom4, p_tcontpms_codincom5,
             p_tcontpms_codincom6, p_tcontpms_codincom7, p_tcontpms_codincom8, p_tcontpms_codincom9, p_tcontpms_codincom10
        from tcontpms
       where dteeffec = (select max(dteeffec)
                           from tcontpms
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteeffec <= trunc(sysdate))
         and codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
    exception when no_data_found then
      null;
    end;
    -- find fix income code
      if nvl(p_type, 'N') = 'Y' then
          begin
          select codcomp, codempmt, typpayroll
            into v_codcomp, v_codempmt, v_typpayroll
            from temploy1
          where codempid = p_codempid;
          exception when no_data_found then
            null;
          end;

          begin
            select amtincom1
              into v_amtincom1
              from temploy3
             where codempid = p_codempid;
          exception when no_data_found then
            null;
          end;
          v_amtavgsal := stddec(v_amtincom1, p_codempid, v_chken);
          get_wage_income(hcm_util.get_codcomp_level(v_codcomp,  1), v_codempmt, v_amtavgsal,
                          0, 0, 0, 0, 0, 0, 0, 0, 0, v_amthr, v_amtday, v_amtmth);
          v_amtavgsal := v_amtmth;

          if p_flgavgsal = '1' then
            v_avgsal := v_amtavgsal;
          else
            for i in c1 loop
              v_total := v_total + i.amtpay;
              v_count := v_count + 1;
              if v_count = nvl(p_qtymthsal, 0) then
                exit;
              end if;
            end loop;
            if v_count = 0 then
              v_sal := v_amtavgsal;
            else
              v_sal := v_total / v_count;
            end if;
            v_avgsal := v_sal * (1 + (p_pctplus / 100));
          end if;

        end if;
    return v_avgsal;
  end get_avgsal;

  function get_tax_cal return number is
    v_income number := 0;
  begin
    if nvl(p_tcompstn_amtothcps, 0) <> 0 then
      if (nvl(p_tcompstn_amtprovf, 0) + nvl(p_tcompstn_amtsvr, 0)) - nvl(p_tcompstn_amtexctax, 0) <> 0 then
        if nvl(p_tcompstn_amtothcps, 0) > (nvl(p_wrkyr, 0) * nvl(p_tcompstn_amtavgsal, 0)) then
          v_income := (nvl(p_tcompstn_amtprovf, 0) + nvl(p_tcompstn_amtsvr, 0) - nvl(p_tcompstn_amtexctax, 0)) + (nvl(p_wrkyr, 0) * nvl(p_tcompstn_amtavgsal, 0));
        else
          v_income := nvl(p_tcompstn_total_amt, 0);
        end if;
      else
        if nvl(p_tcompstn_amtothcps, 0) > (nvl(p_wrkyr, 0) * nvl(p_tcompstn_amtavgsal, 0)) then
          v_income := (nvl(p_wrkyr, 0) * nvl(p_tcompstn_amtavgsal, 0));
        else
          v_income := nvl(p_tcompstn_amtothcps, 0);
        end if;
      end if;
    else
      v_income := (nvl(p_tcompstn_amtsvr, 0) - nvl(p_tcompstn_amtexctax, 0)) + nvl(p_tcompstn_amtprovf, 0);
    end if;

    if v_income < 0 then
      v_income := 0;
    end if;
    return v_income;
  end get_tax_cal;

  function get_fst_pay return number is
    v_pay number := 0;
  begin
      if p_flgexpnse = '1' then
        v_pay := nvl(p_wrkyr, 0) * nvl(p_amtratec1, 0);
      else
        v_pay := nvl(p_wrkyr, 0) * nvl(p_amtratec2, 0);
      end if;
      if v_pay < 0 then
        v_pay := 0;
      end if;
      return v_pay;
  end get_fst_pay;

  procedure temp_report is

    f_labdate1          varchar2(4000 char);
    f_labdate2          varchar2(4000 char);
    f_repname           varchar2(4000 char);
    v_namcompny         varchar2(4000 char);
    v_numoffid1         varchar2(4000 char);
    v_numcotax          varchar2(4000 char);
    v_num               number := 1;
    v_namerpt           varchar2(4000 char);
    v_codcompy          varchar2(4000 char);

    type add_array is table of varchar2(1) index by binary_integer;
    v_numoffid          add_array;
    v_numtaxid	        add_array;

    v_codtitle          temploy1.codtitle%type;
    v_namfirste         temploy1.namfirste%type;
    v_namfirstt         temploy1.namfirstt%type;
    v_namfirst3         temploy1.namfirst3%type;
    v_namfirst4         temploy1.namfirst4%type;
    v_namfirst5         temploy1.namfirst5%type;
    v_namlaste          temploy1.namlaste%type;
    v_namlastt          temploy1.namlastt%type;
    v_namlast3          temploy1.namlast3%type;
    v_namlast4          temploy1.namlast4%type;
    v_namlast5          temploy1.namlast5%type;
    v_first_name        varchar2(4000 char);
    v_last_name         varchar2(4000 char);
    tmp_numoffid		    temploy2.numoffid%type;
    tmp_numtaxid		    temploy3.numtaxid%type;
    v_t2_address        varchar2(4000 char);
    v_report            varchar2(4000 char);
    global_v_appl       varchar2(4000 char):= 'HRPY2OE';
    v_tmp_amtsvr        number := 0;
    v_tmp_amtexctax     number := 0;
    v_tmp_amtprovf      number := 0;
    v_tmp_amtothcps     number := 0;
    v_tmp_amtexpnse     number := 0;
    v_tmp_amttaxcps     number := 0;
    v_tmp_amtavgsal     number := 0;
    v_net_amount        number := 0;
    v_total_exp         number := 0;
    v_total_amt         number := 0;
    v_amount            number := 0;
    v_expense           number := 0;
    v_cal               varchar2(4000 char);
    v_fst_pay           number := 0;
    v_sec_pay           number := 0;
    v_outstanding       number := 0;
    v_tax_cal           number := 0;
    v_total_outstanding number := 0;
    v_numseq            number;

    cursor c_tcompstn is
      select *
        from tcompstn
       where codempid = p_codempid
         and typretmt = p_typretmt
         and dtevcher = p_dtevcher
      order by codempid;

  begin
--      begin
--        delete ttemprpt where codempid = global_v_codempid
--                          and codapp   = global_v_appl;
--      end;
      --
        begin
          select nvl(max(numseq), 0)
            into v_numseq
            from ttemprpt
           where codempid = global_v_codempid
             and codapp   = global_v_appl;
        exception when no_data_found then
          null;
        end;
        v_numseq    := v_numseq + 1;


      begin
        select numoffid
          into tmp_numoffid
          from temploy2
         where codempid = p_codempid;
      exception when no_data_found then
          tmp_numoffid := null;
      end;

      begin
        select numtaxid
          into tmp_numtaxid
          from temploy3
         where codempid = p_codempid;
      exception when no_data_found then
        tmp_numtaxid := null;
      end;

      if tmp_numoffid is not null then
        for i in 1..13 loop
          v_numoffid(i) := ' ';
          v_numoffid(i) := substr(tmp_numoffid,i,1);
        end loop;
      end if;

      v_numoffid1 := v_numoffid(1)||v_numoffid(2)||v_numoffid(3)||v_numoffid(4)||v_numoffid(5)||
                     v_numoffid(6)||v_numoffid(7)||v_numoffid(8)||v_numoffid(9)||v_numoffid(10)||
                     v_numoffid(11)||v_numoffid(12)||v_numoffid(13);

      if tmp_numtaxid is not null and v_numoffid1 is null then
          for i in 1..10 loop
            v_numtaxid(i) := ' ';
            v_numtaxid(i) := substr(tmp_numtaxid,i,1);
          end loop;
      else
          for i in 1..10 loop
            v_numtaxid(i) := ' ';
          end loop;
      end if;

      begin
        select a.codtitle,
               a.namfirste, a.namfirstt, a.namfirst3, a.namfirst4, a.namfirst5,
               a.namlaste, a.namlastt, a.namlast3, a.namlast4, a.namlast5
        into   v_codtitle,
               v_namfirste, v_namfirstt, v_namfirst3, v_namfirst4, v_namfirst5,
               v_namlaste, v_namlastt, v_namlast3, v_namlast4, v_namlast5
        from temploy1 a, temploy2 b
        where a.codempid = b.codempid
          and a.codempid = p_codempid;
      exception when no_data_found then
        v_namfirste := null; v_namfirstt := null; v_namfirst3 := null;
        v_namfirst4 := null; v_namfirst5 := null; v_namlaste  := null;
        v_namlastt  := null; v_namlast3  := null; v_namlast4  := null;
        v_namlast5  := null;
      end;

      if global_v_lang = '101' then
        v_first_name := get_tlistval_name('CODTITLE',v_codtitle,global_v_lang)||v_namfirste;
        v_last_name  := v_namlaste;
      elsif global_v_lang = '102' then
        v_first_name := get_tlistval_name('CODTITLE',v_codtitle,global_v_lang)||v_namfirstt;
        v_last_name  := v_namlastt;
      elsif global_v_lang = '103' then
        v_first_name := get_tlistval_name('CODTITLE',v_codtitle,global_v_lang)||v_namfirst3;
        v_last_name  := v_namlast3;
      elsif global_v_lang = '104' then
        v_first_name := get_tlistval_name('CODTITLE',v_codtitle,global_v_lang)||v_namfirst4;
        v_last_name  := v_namlast4;
      elsif global_v_lang = '105' then
        v_first_name := get_tlistval_name('CODTITLE',v_codtitle,global_v_lang)||v_namfirst5;
        v_last_name  := v_namlast5;
      end if;
      for r1 in c_tcompstn loop
        v_cal           := 'Y';
        p_flgavgsal     := r1.flgavgsal;
        p_flgexpnse     := r1.flgexpnse;
        p_amtratec1     := r1.amtratec1;
        p_amtratec2     := r1.amtratec2;
        p_wrkyr         := r1.wrkyr;

        v_fst_pay       := get_fst_pay;
        -- stddec --

        v_tmp_amtsvr            := stddec(r1.amtsvr,r1.codempid,v_chken);
        v_tmp_amtexctax         := stddec(r1.amtexctax,r1.codempid,v_chken);
        v_tmp_amtprovf          := stddec(r1.amtprovf,r1.codempid,v_chken);
        v_tmp_amtothcps         := stddec(r1.amtothcps,r1.codempid,v_chken);
        v_tmp_amtexpnse         := stddec(r1.amtexpnse,r1.codempid,v_chken);
        v_tmp_amtavgsal         := get_avgsal(nvl(v_cal,'N'));
        p_tcompstn_amtothcps    := v_tmp_amtothcps;
        p_tcompstn_amtprovf     := v_tmp_amtprovf;
        p_tcompstn_amtsvr       := v_tmp_amtsvr;
        p_tcompstn_amtexctax    := v_tmp_amtexctax;
        p_tcompstn_amtavgsal    := v_tmp_amtavgsal;
        p_tcompstn_total_amt    := p_tcompstn_amtprovf + p_tcompstn_amtsvr - p_tcompstn_amtexctax + p_tcompstn_amtothcps;

         -- stddec --
        v_tax_cal           := get_tax_cal;
        v_outstanding       := greatest(nvl(v_tax_cal,0) - nvl(v_fst_pay,0),0);
        v_sec_pay           := (r1.pctexprt/100)*nvl(v_outstanding,0);
        v_total_amt         := greatest(nvl(v_tmp_amtprovf,0) + nvl(v_tmp_amtsvr,0) -
                                        nvl(v_tmp_amtexctax,0) + nvl(v_tmp_amtothcps,0),0);
        v_total_exp         := nvl(v_fst_pay,0) + nvl(v_sec_pay,0);
        v_amount            := greatest(nvl(v_total_amt,0) - nvl(v_tmp_amtexpnse,0),0);
        v_expense           := nvl(v_total_exp,0);
        v_net_amount        := greatest(nvl(v_amount,0) - nvl(v_expense,0),0);
        v_tmp_amttaxcps     := cal_amttax(v_net_amount,'1');
        v_total_outstanding := greatest(nvl(v_tmp_amtprovf,0) + nvl(v_tmp_amtsvr,0) +
                                        nvl(v_tmp_amtothcps,0) - nvl(v_tmp_amttaxcps,0) ,0);
        --
        insert into ttemprpt
                    (codempid,codapp,numseq,temp100,
                     item1,item2,item3,--1-27
                     item4,item5,item6,
                     item7,item8,item9,
                     item10,item11,item12,
                     item13,item14,item15,
                     item16,item17,item18,
                     item19,item20,item21,
                     item22,item23,item24,
                     item25,item26,item27,
                     temp31,temp32,temp33,--31-65
                     temp34,temp35,
                     temp36,temp37,
                     temp38,temp39,
                     temp40,temp41,
                     temp42,temp43,
                     temp44,temp45,
                     temp46,temp47,
                     temp48,temp49,
                     temp50,temp51,
                     temp52,temp53,
                     temp54,temp55,
                     temp56,temp57,
                     temp58,temp59,
                     temp60,temp61,
                     temp62,temp63,
                     temp64,temp65,
                     -- label detail
                     item28,item29,
                     item30,item31,
                     item32,item33,
                     item34,
                     item35,item36)
             values (global_v_codempid,global_v_appl,v_numseq,p_codempid,
                     v_numoffid(1), v_numoffid(2),v_numoffid(3),
                     v_numoffid(4), v_numoffid(5),v_numoffid(6),
                     v_numoffid(7), v_numoffid(8),v_numoffid(9),
                     v_numoffid(10),v_numoffid(11),v_numoffid(12),
                     v_numoffid(13),v_numtaxid(1),v_numtaxid(2),
                     v_numtaxid(3), v_numtaxid(4),v_numtaxid(5),
                     v_numtaxid(6), v_numtaxid(7),v_numtaxid(8),
                     v_numtaxid(9), v_numtaxid(10),v_first_name,   --item24
                     v_last_name,r1.flgavgsal,r1.flgexpnse,  ----item27
                     r1.wrkyr,trunc(v_tmp_amtavgsal),(v_tmp_amtavgsal - trunc(v_tmp_amtavgsal)) * 100,   --temp31 -33
                     trunc(v_tax_cal),trunc(mod(v_tax_cal,1)*100),
                     trunc(v_fst_pay),trunc(mod(v_fst_pay,1)*100),
                     trunc(v_outstanding),trunc(mod(v_outstanding,1)*100),
                     trunc(v_sec_pay),trunc(mod(v_sec_pay,1)*100),
                     trunc(v_total_exp),trunc(mod(v_total_exp,1)*100),
                     trunc(v_tmp_amtprovf),trunc(mod(v_tmp_amtprovf,1)*100),
                     trunc(v_tmp_amtsvr),trunc(mod(v_tmp_amtsvr,1)*100),
                     trunc(v_tmp_amtexctax),trunc(mod(v_tmp_amtexctax,1)*100),
                     trunc(v_tmp_amtothcps),trunc(mod(v_tmp_amtothcps,1)*100),
                     trunc(v_total_amt),trunc(mod(v_total_amt,1)*100),
                     trunc(v_tmp_amtexpnse),trunc(mod(v_tmp_amtexpnse,1)*100),
                     trunc(v_amount),trunc(mod(v_amount,1)*100),
                     trunc(v_expense),trunc(mod(v_expense,1)*100),
                     trunc(v_net_amount),trunc(mod(v_net_amount,1)*100),
                     trunc(v_tmp_amttaxcps),trunc(mod(v_tmp_amttaxcps,1)*100),
                     trunc(v_total_outstanding),trunc(mod(v_total_outstanding,1)*100),
                     -- label detail  label28 - label34
                     to_char(nvl(r1.amtmaxday,0),'fm990'),to_char(nvl(r1.amtmaxtax,0),'fm99,999,990'),
                     to_char(nvl(r1.qtymthsal,0),'fm990'),to_char(nvl(r1.pctplus,0),'fm990'),
                     to_char(nvl(r1.amtratec1,0),'fm99,999,990'),to_char(nvl(r1.amtratec2,0),'fm99,999,990'),
                     to_char(nvl(r1.pctexprt,0),'fm990'),
                     nvl(p_flgavgsal_tmp,1),nvl(p_flgexpnse_tmp,1));
      end loop;
      --
      commit;
  end;

  ----- start Specific Report ------
  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    json_index_rows     := hcm_util.get_json_t(json_obj, 'p_index_rows');
  end initial_report;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
    p_index_rows      json_object_t;

  begin
    initial_report(json_str_input);
--    isInsertReport := true;


    if param_msg_error is null then
        begin
          delete
            from ttemprpt
           where codempid = global_v_codempid
             and codapp like p_codapp || '%';
        exception when others then
          null;
        end;

        for i in 0..json_index_rows.get_size-1 loop
          p_index_rows  := hcm_util.get_json_t(json_index_rows, to_char(i));
          p_codempid    := upper(hcm_util.get_string_t(p_index_rows, 'codempid'));
          p_typretmt    := upper(hcm_util.get_string_t(p_index_rows, 'typretmt'));
          p_dtevcher    := to_date(hcm_util.get_string_t(p_index_rows, 'dtevcher'),'dd/mm/yyyy');
          p_codcomp     := upper(hcm_util.get_string_t(p_index_rows, 'codcomp'));
          temp_report;
        end loop;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

end HRPY2OE;

/
