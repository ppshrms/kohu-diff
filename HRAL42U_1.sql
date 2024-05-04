--------------------------------------------------------
--  DDL for Package Body HRAL42U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL42U" is
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
    -- index param
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_timstrt           := replace(hcm_util.get_string_t(json_obj,'p_timstrt'),':','');
    p_timend            := replace(hcm_util.get_string_t(json_obj,'p_timend'),':','');
    begin
      p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'), 'dd/mm/yyyy');
      p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'), 'dd/mm/yyyy');
    exception when others then
      param_msg_error := get_error_msg_php('HR2025',global_v_lang);
    end;
    p_dtework           := to_date(hcm_util.get_string_t(json_obj,'p_dtework'), 'dd/mm/yyyy');
    p_typot             := hcm_util.get_string_t(json_obj,'p_typot');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure initial_value_detail (json_obj in json_object_t) is
  begin
    p_amtmealn          := hcm_util.get_string_t(json_obj,'p_amtmealn');
    p_amtmealo          := hcm_util.get_string_t(json_obj,'p_amtmealo');
    p_qtyleaven         := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_qtyleaven'));
    p_qtyleaveo         := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_qtyleaveo'));
    p_codcompn          := hcm_util.get_string_t(json_obj,'p_codcompn');
    p_codcompo          := hcm_util.get_string_t(json_obj,'p_codcompo');
    p_codcostn          := hcm_util.get_string_t(json_obj,'p_codcostn');
    p_codrem            := hcm_util.get_string_t(json_obj,'p_codrem');
    p_remark            := hcm_util.get_string_t(json_obj,'p_remark');
    p_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
    p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'dd/mm/yyyy');
  end;

  procedure check_index is
    v_dteeffec              date;
    v_numlvl                number;
    v_check                 boolean := false;
    v_count                 number  := 0;
  begin
    if p_codempid is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codempid');
    else
      begin
        select codempid, codcomp
          into p_codempid, p_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --

      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    --
    if not secur_main.secur7(p_codcomp, global_v_coduser) then
      param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      return;
    end if;
    --
    begin
      select dteeffec, condot, condextr
        into param_dteeffec, param_condot, param_condextr
        from tcontrot
       where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
         and dteeffec = (
                         select max(dteeffec)
                           from tcontrot
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                            and dteeffec <= sysdate
                        )
         and rownum <= 1;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tcontrot');
      return;
    end;
  end;

  procedure check_save is
    v_count number := 0;
    v_staemp  temploy1.staemp%type;
  begin
    begin
      select codempid, staemp
        into p_codappr, v_staemp
        from temploy1
       where codempid = upper(p_codappr);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'codappr');
      return;
    end;
    --
    if v_staemp = 0 then
      param_msg_error := get_error_msg_php('HR2102', global_v_lang, 'codappr');
      return;
    elsif v_staemp = 9 then
      param_msg_error := get_error_msg_php('HR2101', global_v_lang, 'codappr');
      return;
    end if;
    --
    param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompn);
    if param_msg_error is not null then
      return;
    end if;
    begin
      select codcodec into p_codrem
        from tcodotrq
       where codcodec = p_codrem;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'codrem');
      return;
    end;
  end;

  procedure check_detail is
    v_count     number := 0;
    v_dteeffex  date;
  begin
    if p_codshift is not null then
      begin
        select codshift into p_codshift
          from tshiftcd
         where codshift = p_codshift;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'codshift');
        return;
      end;
    end if;

--    begin
--      select codempid
--        into p_codempid
--        from temploy1
--       where codempid = upper(p_codempid)
--         and staemp <> '9';
--    exception when no_data_found then
--      param_msg_error := get_error_msg_php('HR2101', global_v_lang, 'codempid');
--      return;
--    end;
    begin
      select min(dteeffec) into v_dteeffex
      from  ttexempt a, temploy1 b
      where a.codempid = p_codempid
      and   a.codempid = b.codempid
      and   a.dteeffec >= b.dteempmt
      and   a.staupd   in ('C','U');

      if p_dtework >= v_dteeffex and v_dteeffex is not null then
        param_msg_error := get_error_msg_php('HR2101', global_v_lang, 'codempid');
        return;
      end if;
    end;

    begin
      select count(*)
        into v_count
        from tattence
       where codempid = upper(p_codempid)
         and dtework = p_dtework ;
    end;
    --
    if v_count = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang,'tattence');
      return;
    end if;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) as
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

  procedure gen_index (json_str_output out clob) as
    obj_row               json_object_t;
    obj_data              json_object_t;
    v_dtework             date;
    v_acttimein           varchar2(100 char);
    v_acttimeout          varchar2(100 char);
    v_timin               varchar2(100 char);
    v_timout              varchar2(100 char);
    v_timstrt             varchar2(100 char);
    v_timend              varchar2(100 char);
    --
    v_rcnt                number  := 0;
    v_secur               boolean := false;
    v_permis              boolean := false;
    v_exist               boolean := false;

    cursor c_tovrtime is
      select dtework, typot, codshift,
             timstrt, timend, codempid,
             qtyminot, numotreq, flgotcal
        from tovrtime
       where codempid = upper(p_codempid)
         and dtework between p_dtestrt and p_dteend
      order by dtework, typot;
  begin
    obj_row               := json_object_t();
    for c1 in c_tovrtime loop
      v_exist := true;
      v_secur := secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur then
        v_permis              := true;
        obj_data              := json_object_t();
        v_rcnt                := v_rcnt + 1;
        v_dtework             := c1.dtework;
        if c1.timstrt is not null then
          v_timstrt := substr(c1.timstrt, 1, 2) || ':' || substr(c1.timstrt, 3, 2);
        else
          v_timstrt := null;
        end if;
        --
        if c1.timend is not null then
          v_timend := substr(c1.timend, 1, 2) || ':' || substr(c1.timend, 3, 2);
        else
          v_timend := null;
        end if;
        --
        obj_data.put('coderror', '200');
        obj_data.put('dtework', to_char(c1.dtework, 'dd/mm/yyyy'));
        obj_data.put('typot', c1.typot);
        obj_data.put('codshift', c1.codshift);
        obj_data.put('ot_timstr', v_timstrt);
        obj_data.put('ot_timend', v_timend);
        obj_data.put('ot_hour', hcm_util.convert_minute_to_hour(c1.qtyminot));
        obj_data.put('numotreq', c1.numotreq);
        --
        v_acttimein           := '';
        v_acttimeout          := '';
        v_timin               := null;
        v_timout              := null;
        --
        begin
          select timin, timout
            into v_timin, v_timout
            from tattence
           where codempid = upper(p_codempid)
             and dtework = v_dtework;
        exception when no_data_found then
          v_timin               := null;
          v_timout              := null;
        end;
        --
        if v_timin is not null and v_timout is not null then
          v_acttimein  := substr(v_timin, 1, 2) || ':' || substr(v_timin, 3, 2);
          v_acttimeout := substr(v_timout, 1, 2) || ':' || substr(v_timout, 3, 2);
        end if;
        obj_data.put('timstr', v_acttimein);
        obj_data.put('timend', v_acttimeout);
        obj_data.put('flgotcal', c1.flgotcal);
        --
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;
    --
    if not v_permis and v_exist then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('403',param_msg_error,global_v_lang);
        return;
    end if;
    --
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_query_detail (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value (json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_query_detail (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_query_detail;

  procedure gen_query_detail (json_str_output out clob) as
    obj_row     json_object_t;
    v_timin			varchar2(1000 char);
    v_timout		varchar2(1000 char);
    v_dtestrtw	date;
    v_dteendw		date;
    v_flgotcal_chk  tovrtime.flgotcal%type;
    v_errorno   varchar2(100 char) := 'HR1510';
  begin

    begin
      select timin,timout,codshift,typwork
        into v_timin,v_timout,p_codshift,p_typwork
        from tattence
       where codempid = p_codempid
         and dtework  = p_dtework;
    exception when no_data_found then
      v_timin 	 := null;
      v_timout	 := null;
      p_codshift := null;
    end;
    --
    begin
      select flgotcal into v_flgotcal_chk
        from tovrtime
       where codempid = p_codempid
         and dtework  = p_dtework;
    exception when others then null;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror','200');
    obj_row.put('codempid',p_codempid);
    obj_row.put('dtework',to_char(p_dtework,'dd/mm/yyyy'));
    obj_row.put('typot',p_typot);
    obj_row.put('codshift',p_codshift);
    obj_row.put('flgotcal',v_flgotcal_chk);

    --
    if v_flgotcal_chk = 'Y' then
      obj_row.put('response', v_errorno||' '||get_errorm_name(v_errorno,global_v_lang));
    end if;
    --
    if v_timin is not null then
      obj_row.put('timin',substr(v_timin,1,2)||':'||substr(v_timin,3,2));
    end if;
    if v_timout is not null then
      obj_row.put('timout',substr(v_timout,1,2)||':'||substr(v_timout,3,2));
    end if;

    json_str_output := obj_row.to_clob;
  end gen_query_detail;

  procedure get_tovrtime_table(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_tovrtime_table (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tovrtime_table;

  procedure gen_tovrtime_table (json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_rcnt        number := 0;
    v_timstrt     varchar2(100 char);
    v_timend      varchar2(100 char);
    v_timstrto    varchar2(100 char);
    v_timendo     varchar2(100 char);
    v_qtydedbrk     varchar2(100 char);
    rec_tlogot    tlogot%rowtype;
    cursor c_tovrtime is
      select *
        from tovrtime
       where codempid = p_codempid
         and dtework  = p_dtework
         and typot    = p_typot;
  begin
    obj_row         := json_object_t();
    obj_data        := json_object_t();
    obj_data.put('coderror', 200);
    for r_tovrtime in c_tovrtime loop
      v_rcnt       := v_rcnt + 1;
      if r_tovrtime.timstrt is not null then
        v_timstrt := substr(r_tovrtime.timstrt,1,2)||':'||substr(r_tovrtime.timstrt,3,2);
      else
        v_timstrt := null;
      end if;
      --
      if r_tovrtime.timend is not null then
        v_timend := substr(r_tovrtime.timend,1,2)||':'||substr(r_tovrtime.timend,3,2);
      else
        v_timend := null;
      end if;
--      begin
--        select * into rec_tlogot
--        from tlogot
--        where codempid = p_codempid
--        and dtework  = p_dtework
--        and dtetimupd = (select max(dtetimupd)
--                            from tlogot
--                            where codempid = p_codempid
--                            and dtework  = p_dtework
--                            and dtetimupd <= sysdate)
--        and rownum = 1;
--      exception when no_data_found then
--        rec_tlogot := null;
--      end;
--      if rec_tlogot.timstoto is not null then
--        v_timstrto := substr(rec_tlogot.timstoto,1,2)||':'||substr(rec_tlogot.timstoto,3,2);
--        v_qtydedbrk :=  hcm_util.convert_minute_to_hour(r_tovrtime.qtydedbrk);
--      else
--        v_timstrto := null;
--        v_qtydedbrk := '';
--      end if;
--      --
--      if rec_tlogot.timenoto is not null then
--        v_timendo := substr(rec_tlogot.timenoto,1,2)||':'||substr(rec_tlogot.timenoto,3,2);
--      else
--        v_timendo := null;
--      end if;
      obj_data.put('dtestrto', to_char(r_tovrtime.dtestrt,'dd/mm/yyyy'));
      obj_data.put('timstrto', v_timstrt);
      obj_data.put('dteendo', to_char(r_tovrtime.dteend,'dd/mm/yyyy'));
      obj_data.put('timendo', v_timend);
      obj_data.put('qtydedbrko', hcm_util.convert_minute_to_hour(r_tovrtime.qtydedbrk));
--      obj_data.put('qtydedbrko', v_qtydedbrk);
      obj_data.put('dtestrtn', to_char(r_tovrtime.dtestrt,'dd/mm/yyyy'));
      obj_data.put('timstrtn', v_timstrt);
      obj_data.put('dteendn', to_char(r_tovrtime.dteend,'dd/mm/yyyy'));
      obj_data.put('timendn', v_timend);
      obj_data.put('qtydedbrkn', hcm_util.convert_minute_to_hour(r_tovrtime.qtydedbrk));
      obj_data.put('qtyminot', hcm_util.convert_minute_to_hour(r_tovrtime.qtyminot));
      obj_data.put('flgotcal', r_tovrtime.flgotcal);

    end loop;
    obj_row.put(to_char(0), obj_data);

    json_str_output := obj_row.to_clob;
  end gen_tovrtime_table;

  procedure get_cal_overtime (json_str_input in clob, json_str_output out clob) as
    obj_row     json_object_t;
  	r_tovrtime    tovrtime%rowtype;
    a_qtyminot    hral85b_batch.a_qtyminot;
    a_rteotpay    hral85b_batch.a_rteotpay;
    v_qtymin			number;
    v_qtyminoto	  number;
    v_chkTime	    boolean;

    p_otcalflg    varchar2(4000 char) := null;
  begin

    initial_value(json_str_input);
    check_index;

    if p_dtestrt is not null and p_dteend is not null and
       p_timstrt is not null and p_timend is not null then
       if length(p_timstrt) < 4 then
        p_timstrt := '0'||p_timstrt;
       end if;
       if length(p_timend) < 4 then
        p_timend := '0'||p_timend;
       end if;

       v_chkTime := hcm_validate.check_time(p_timstrt);
       if not v_chkTime then
          param_msg_error := get_error_msg_php('HR2015',global_v_lang);
          json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
          return;
       end if;
       v_chkTime := hcm_validate.check_time(p_timend);
       if v_chkTime then
         hral85b_batch.cal_time_ot (hcm_util.get_codcomp_level(p_codcomp,1), param_dteeffec, param_condot, param_condextr,
                                   null, p_codempid, p_dtework, p_typot,
                                   null, p_dtestrt, p_timstrt, p_dteend, p_timend,
                                   null, null, null, null, null,
                                   null, null, null, global_v_coduser,'N',
                                   r_tovrtime,a_rteotpay,a_qtyminot);
       else
          param_msg_error := get_error_msg_php('HR2015',global_v_lang);
          json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
          return;
       end if;
      if a_rteotpay(1) > 0 or r_tovrtime.qtyminot > 0 then
        obj_row := json_object_t();
        obj_row.put('coderror','200');
        obj_row.put('typwork',r_tovrtime.typwork);
        obj_row.put('timstrt',r_tovrtime.timstrt);
        obj_row.put('timend',r_tovrtime.timend);
        obj_row.put('qtyminot',hcm_util.convert_minute_to_hour(nvl(r_tovrtime.qtyminot, 0)));
        obj_row.put('amtmeal',stddec(r_tovrtime.amtmeal,p_codempid,v_chken));
        obj_row.put('qtydedbrk',hcm_util.convert_minute_to_hour(nvl(r_tovrtime.qtydedbrk, 0)));
      else
        obj_row := json_object_t();
        obj_row.put('coderror','200');
        obj_row.put('typwork','');
        obj_row.put('timstrt','');
        obj_row.put('timend','');
        obj_row.put('qtyminot','');
        obj_row.put('amtmeal','');
        obj_row.put('qtydedbrk','');
      end if;
    end if;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_cal_overtime;

  procedure get_cal_pay_overtime (json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    r_tovrtime    tovrtime%rowtype;
    a_qtyminot    hral85b_batch.a_qtyminot;
    a_rteotpay    hral85b_batch.a_rteotpay;
    v_qtymin			number;
    v_qtyminoto	  number;

    p_otcalflg    varchar2(4000 char) := null;
    v_rcnt        number := 0;
    v_chkTime     boolean;
  begin
    initial_value(json_str_input);
    check_index;
    if p_dtestrt is not null and p_dteend is not null and
       p_timstrt is not null and p_timend is not null then
       if length(p_timstrt) < 4 then
        p_timstrt := '0'||p_timstrt;
       end if;
       if length(p_timend) < 4 then
        p_timend := '0'||p_timend;
       end if;
       v_chkTime := hcm_validate.check_time(p_timstrt);
      if not v_chkTime then
          param_msg_error := get_error_msg_php('HR2015',global_v_lang);
          json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
          return;
       end if;
       v_chkTime := hcm_validate.check_time(p_timend);
       if v_chkTime then
          hral85b_batch.cal_time_ot (hcm_util.get_codcomp_level(p_codcomp,1), param_dteeffec, param_condot, param_condextr,
                                   null, p_codempid, p_dtework, p_typot,
                                   null, p_dtestrt, p_timstrt, p_dteend, p_timend,
                                   null, null, null, null, null,
                                   null, null, null, global_v_coduser,'N',
                                   r_tovrtime,a_rteotpay,a_qtyminot);
       else
        param_msg_error := get_error_msg_php('HR2015',global_v_lang);
        json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
        return;
       end if;
      v_qtymin := 0;
      obj_row      := json_object_t();
      if a_rteotpay(1) > 0 or r_tovrtime.qtyminot > 0 then
        if a_rteotpay(1) > 0 then
          for i in 1..20 loop
            if a_qtyminot(i) > 0 then
              begin
                select qtyminot into v_qtyminoto
                from   totpaydt
                where  codempid = p_codempid
                and    dtework  = p_dtework
                and    typot    = p_typot
                and    rteotpay = a_rteotpay(i);
              exception when no_data_found then null;
              end;

              obj_data     := json_object_t();
              v_rcnt       := v_rcnt + 1;

              obj_data.put('coderror','200');
              obj_data.put('rteotpay', a_rteotpay(i));
              obj_data.put('qtyminotn', hcm_util.convert_minute_to_hour(a_qtyminot(i)));
              obj_data.put('qtyminoto', hcm_util.convert_minute_to_hour(v_qtyminoto));
              obj_row.put(to_char(v_rcnt - 1), obj_data);
            end if;
          end loop;
        end if;
      else
        obj_data     := json_object_t();

        obj_data.put('coderror','200');
        obj_data.put('rteotpay', '');
        obj_data.put('qtyminotn','');
        obj_data.put('qtyminoto', '');
        obj_row.put(to_char(0), obj_data);
      end if;
    end if;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_totpaydt_table (json_str_input in clob, json_str_output out clob) as
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_totpaydt_table (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_totpaydt_table;

  procedure gen_totpaydt_table (json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_qtymin	    number := 0;
    v_rcnt        number := 0;
    v_qtyminoto        number := 0;
    cursor c_totpaydt is
    select rteotpay, qtyminot
      from totpaydt
     where codempid = p_codempid
       and dtework  = p_dtework
       and typot		= p_typot
    order by rteotpay;

  begin
    obj_row        := json_object_t();
    for r_totpaydt in c_totpaydt loop
      obj_data     := json_object_t();
      v_rcnt       := v_rcnt + 1;
      obj_data.put('coderror','200');
      obj_data.put('rteotpay', r_totpaydt.rteotpay);
      obj_data.put('qtyminotn', hcm_util.convert_minute_to_hour(r_totpaydt.qtyminot));
--      begin
--      select qtyminoto into v_qtyminoto
--        from tlogot2
--       where codempid = p_codempid
--         and dtework  = p_dtework
--         and typot	 = p_typot
--         and dtetimupd = (select max(dtetimupd)
--                            from tlogot2
--                           where codempid = p_codempid
--                             and dtework  = p_dtework
--                             and typot	 = p_typot);
--      exception when no_data_found then
--        v_qtyminoto := 0;
--      end;
      obj_data.put('qtyminoto', hcm_util.convert_minute_to_hour(r_totpaydt.qtyminot));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    json_str_output := obj_row.to_clob;
  end gen_totpaydt_table;


  procedure get_tovrtime_detail(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      gen_tovrtime_detail (json_str_output);
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tovrtime_detail;

  procedure gen_tovrtime_detail (json_str_output out clob) as
    obj_row             json_object_t;
    v_amtmeal           varchar2(4000 char);
--    v_amtmealn          varchar2(4000 char);
--    v_amtmealo          varchar2(4000 char);
    v_qtyleave          number;
    v_codcompw          varchar2(4000 char);
    v_cost_center_w     varchar2(4000 char);
    v_cost_center_o     varchar2(4000 char);
    v_codrem            varchar2(4000 char);
    v_remark            varchar2(4000 char);
    v_codappr           varchar2(4000 char);
    v_dteappr           date;
    v_dteupd            date;
    v_coduser           varchar2(4000 char);
    v_codcompo          TCENTER.CODCOMP%TYPE;
    v_flgdata           varchar2(10 char) := 'Y';
    v_countpaydt        number;

--    rec_tlogot    tlogot%rowtype;
  begin
    begin
      select amtmeal, qtyleave, codcompw, codrem,
             remark, codappr, dteappr, dteupd, coduser
        into v_amtmeal, v_qtyleave, v_codcompw, v_codrem,
             v_remark, v_codappr, v_dteappr, v_dteupd, v_coduser
        from tovrtime
       where codempid = p_codempid
         and dtework  = p_dtework
         and typot    = p_typot;
    exception when no_data_found then
      v_amtmeal   := null;
      v_qtyleave  := null;
      v_codcompw  := null;
      v_codrem    := null;
      v_remark    := null;
      v_codappr   := GET_CODEMPID(global_v_coduser);
      v_dteappr   := sysdate;
      v_dteupd    := null;
      v_coduser   := null;
      v_flgdata   := 'N';
    end;
    --
    begin
        select count(codempid)
          into v_countpaydt
          from totpaydt
         where codempid = p_codempid
           and dtework  = p_dtework
           and typot	= p_typot;
    exception when no_data_found then
        v_countpaydt := 0;
    end;

    --
    if v_flgdata = 'N' then
      begin
        select codcompw into v_codcompw
        from v_tattence_cc
        where codempid = p_codempid
        and dtework = p_dtework;
--        select codcomp
--          into v_codcompw
--          from twkchhr
--         where p_dtework between dtestrt and dteend
--           and codempid = p_codempid
--           and codcomp is not null;
      exception when no_data_found then
        null;
      end;
    end if;
    begin
      select costcent into v_cost_center_w
        from tcenter
       where codcomp  = get_compful(v_codcompw);
    exception when no_data_found then
      v_cost_center_w := null;
    end;
--    begin
--      select * into rec_tlogot
--      from tlogot
--      where codempid = p_codempid
--      and dtework  = p_dtework
--      and dtetimupd = (select max(dtetimupd)
--                          from tlogot
--                          where codempid = p_codempid
--                          and dtework  = p_dtework
--                          and dtetimupd <= sysdate)
--      and rownum = 1;
--    exception when no_data_found then
--      rec_tlogot := null;
--    end;
--    begin
--      select costcent into v_cost_center_o
--        from tcenter
--       where codcomp  = get_compful(rec_tlogot.codcompwo);
--    exception when no_data_found then
--      v_cost_center_o := null;
--    end;
--    if v_amtmeal is not null then
--      v_amtmealn := stddec(v_amtmeal,p_codempid,v_chken);
--    else
--      v_amtmealn := '';
--    end if;
--    if rec_tlogot.amtmealo is not null then
--      v_amtmealo := stddec(rec_tlogot.amtmealo,p_codempid,v_chken);
--    else
--      v_amtmealo := '';
--    end if;
    --
    obj_row := json_object_t();
    obj_row.put('coderror','200');
    obj_row.put('amtmealo',stddec(v_amtmeal,p_codempid,v_chken));
    obj_row.put('amtmealn',stddec(v_amtmeal,p_codempid,v_chken));
    obj_row.put('qtyleaveo',hcm_util.convert_minute_to_hour(v_qtyleave));
    obj_row.put('qtyleaven',hcm_util.convert_minute_to_hour(v_qtyleave));
    obj_row.put('codcompo',get_compful(v_codcompw));
    obj_row.put('codcosto',v_cost_center_w);
    obj_row.put('codcompn',get_compful(v_codcompw));
    obj_row.put('codcostn',v_cost_center_w);
    obj_row.put('codrem',v_codrem);
    obj_row.put('remark',v_remark);
    obj_row.put('codappr',v_codappr);
    obj_row.put('dteappr',to_char(v_dteappr,'dd/mm/yyyy'));
    obj_row.put('dteupd',to_char(v_dteupd,'dd/mm/yyyy'));
    obj_row.put('coduser', get_codempid(v_coduser));
    if (v_countpaydt > 0 or stddec(v_amtmeal,p_codempid,v_chken) > 0 ) or v_flgdata = 'N' then
        obj_row.put('flgtypot', 'Y');
    else
        obj_row.put('flgtypot', 'N');
    end if;
    obj_row.put('desc_coduser', v_coduser || ' - ' || get_temploy_name(get_codempid(v_coduser), global_v_lang));

    json_str_output := obj_row.to_clob;
  end gen_tovrtime_detail;

  procedure save_delete (json_str_input in clob, json_str_output out clob) as
    json_obj          json_object_t;
    json_obj_data     json_object_t;
    json_obj_row      json_object_t;
    v_codempid        varchar2(1000 char);
    v_dtework         date;
    v_typot           varchar2(100 char);

    v_codcomp         varchar2(4000 char);
    v_codcompw        varchar2(4000 char);
    v_dtestot         date;
    v_timstot         varchar2(4000 char);
    v_dteenot         date;
    v_timenot         varchar2(4000 char);
    v_amtmeal         varchar2(4000 char);
    v_qtyleave        number;
    v_dtetimupd       date;
    v_check           varchar2(1) := 'N';
    v_date			      date := sysdate;

    cursor c_dellog is
      select	dtework,typot,rteotpay,qtyminot
        from	totpaydt
       where	codempid	=	v_codempid
         and	dtework		=	v_dtework
         and	typot			=	v_typot
      order by typot,rteotpay;
  begin
    initial_value (json_str_input);
    json_obj          := json_object_t(json_str_input);
    json_obj_data     := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    for i in 0 .. json_obj_data.get_size - 1 loop
      json_obj_row        := hcm_util.get_json_t(json_obj_data,to_char(i));
      v_codempid          := hcm_util.get_string_t(json_obj_row, 'codempid');
      v_dtework           := to_date(hcm_util.get_string_t(json_obj_row, 'dtework'), 'dd/mm/yyyy');
      v_typot             := hcm_util.get_string_t(json_obj_row, 'typot');

      begin
        select codcomp, dtestrt, timstrt, dteend, timend , amtmeal, qtyleave, codcompw
          into v_codcomp, v_dtestot, v_timstot, v_dteenot, v_timenot , v_amtmeal, v_qtyleave, v_codcompw
          from tovrtime
         where codempid = upper(v_codempid)
           and dtework  = v_dtework
           and typot    = v_typot
           and flgotcal = 'N';

          begin
            select 'Y' into v_check
              from tlogot
             where codempid  = upper(v_codempid)
               and dtetimupd = v_date;
          exception when no_data_found then
            v_check := 'N';
          end;
          begin
            if v_check = 'N' then
              insert into tlogot
                          (codempid,dtetimupd,dteupd,dtework,typot,codcomp,
                           dtestoto,timstoto,dteenoto,timenoto,
                           amtmealo,
                           qtyleaveo,codcompwo,coduser)
                   values
                          (v_codempid,v_date,v_date,v_dtework,v_typot,v_codcomp,
                           v_dtestot,v_timstot,v_dteenot,v_timenot,
                           (v_amtmeal),
                           v_qtyleave,v_codcompw,global_v_coduser);
            end if;
          end;
          for i in c_dellog loop
            insert into	tlogot2
              (codempid,dtetimupd,dteupd,dtework,typot,
               rteotpay,qtyminoto,qtyminotn,
               coduser,codcreate)
            values
              (v_codempid,v_date,v_date,i.dtework,i.typot,
               i.rteotpay,i.qtyminot,null,
               global_v_coduser, global_v_coduser);
          end loop;
          begin
            delete from tovrtime
                  where codempid = upper(v_codempid)
                    and dtework  = v_dtework
                    and typot    = v_typot
                    and flgotcal = 'N';
            delete from totpaydt
                  where codempid = upper(v_codempid)
                    and dtework  = v_dtework
                    and typot    = v_typot;
           end;
      exception when no_data_found then
        if param_msg_error is null then
          param_msg_error     := get_error_msg_php('HR1510', global_v_lang);
        end if;
      end;
    end loop;
    if param_msg_error is null then
      commit;
      param_msg_error     := get_error_msg_php('HR2425', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end save_delete;

  procedure post_detail (json_str_input in clob, json_str_output out clob) as
    json_obj_data       json_object_t;
    json_detail_data    json_object_t;
    json_table1_data    json_object_t;
    json_table2_data    json_object_t;
    v_qtyminot          tovrtime.qtyminot%type;
    v_qtyleave          tovrtime.qtyleave%type;
    v_qtyminot_pay      totpaydt.qtyminot%type;
    v_flgotcal_chk      tovrtime.flgotcal%type;
  begin
    initial_value (json_str_input);

    json_obj_data     := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    json_detail_data  := hcm_util.get_json_t(json_obj_data,to_char('detail2'));
    json_table1_data  := hcm_util.get_json_t(json_obj_data,to_char('table1'));
    json_table2_data  := hcm_util.get_json_t(json_obj_data,to_char('table2'));
    p_flgtypot        := hcm_util.get_string_t(json_detail_data,'p_flgtypot');
    p_flgadj          := 'Y';

    begin
      select flgotcal into v_flgotcal_chk
        from tovrtime
       where codempid = p_codempid
         and dtework  = p_dtework;
    exception when others then
        v_flgotcal_chk := 'N';
    end;

    if v_flgotcal_chk = 'Y' then
        param_msg_error     := get_error_msg_php('HR1510', global_v_lang);
        json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;

    -- set datetime logs
    v_date := sysdate;
    -- upd_detail
    upd_tovrtime(json_detail_data,json_table1_data);
    upd_totpaydt(json_obj_data);


    if param_msg_error is null then
      begin
        select nvl(qtyminot,0), nvl(qtyleave,0)
          into v_qtyminot, v_qtyleave
          from tovrtime
         where codempid = p_codempid
           and dtework  = p_dtework
           and typot    = p_typot;
      exception when no_data_found then
        v_qtyminot  := 0;
        v_qtyleave  := 0;
      end;

      begin
        select nvl(sum(nvl(qtyminot,0)),0)
          into v_qtyminot_pay
          from totpaydt
         where codempid = p_codempid
           and dtework  = p_dtework
           and typot	= p_typot;
      exception when no_data_found then
        v_qtyminot  := 0;
        v_qtyleave  := 0;
      end;
      if p_flgtypot = 'Y' then
        if p_amtmealn is null or p_amtmealn = 0 then
          if v_qtyminot <> v_qtyminot_pay then
              rollback;
              param_msg_error     := get_error_msg_php('AL0072', global_v_lang);
              json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
              return;
          end if;
        end if;
      else
        if v_qtyminot < v_qtyleave then
            rollback;
            param_msg_error     := get_error_msg_php('AL0073', global_v_lang);
            json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
      end if;

      commit;
      param_msg_error     := get_error_msg_php('HR2401', global_v_lang);
    else
      rollback;
    end if;
    json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure upd_totpaydt(json_str_input in json_object_t) is
    param_json      json_object_t;
    json_obj_row    json_object_t;
    v_qtyminotn	    totpaydt.qtyminot%type;
    v_qtyminoto	    totpaydt.qtyminot%type;
    v_qtyminotn_tmp totpaydt.qtyminot%type;
    v_rteotpay 	    totpaydt.rteotpay%type;
    v_rteotpay_tmp  totpaydt.rteotpay%type;
    v_flg           varchar2(100 char);
    v_flg_del       boolean := false;

  begin
    param_json := hcm_util.get_json_t(json_str_input,to_char('table2'));
    -- delete data --
    begin
      delete totpaydt where codempid = p_codempid
                        and dtework  = p_dtework
                        and typot	 = p_typot;
    exception when others then null;
    end;
    -- insert data and upd. logs --
    if param_json.get_size > 0 then
        for i in 0..param_json.get_size-1 loop --1 2
          json_obj_row        := hcm_util.get_json_t(param_json,to_char(i));
          v_qtyminotn         := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj_row, 'qtyminotn'));
          v_qtyminoto         := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj_row, 'qtyminoto'));
          v_qtyminotn_tmp     := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj_row, 'qtyminotnOld'));
          v_rteotpay          := hcm_util.get_string_t(json_obj_row, 'rteotpay');
          v_rteotpay_tmp      := hcm_util.get_string_t(json_obj_row, 'rteotpayOld');
          v_flg               := hcm_util.get_string_t(json_obj_row, 'flg');
          --
          if p_flgtypot = 'Y' then
              if v_flg = 'add' then
                if nvl(v_rteotpay,0) > 0 and nvl(v_qtyminotn,0) > 0  then
                  insert into totpaydt(codempid,dtework,typot,rteotpay,qtyminot,coduser, codcreate)
                       values (p_codempid,p_dtework,p_typot,
                              v_rteotpay,v_qtyminotn,global_v_coduser, global_v_coduser);
                  --
                  if nvl(v_qtyminoto,0) <> nvl(v_qtyminotn,0) then
                    insert into	tlogot2(codempid,dtetimupd,dteupd,dtework,typot,
                                        rteotpay,qtyminoto,qtyminotn,coduser,codcreate)
                         values (p_codempid,v_date,v_date,p_dtework,p_typot,
                                 v_rteotpay,v_qtyminoto,v_qtyminotn,global_v_coduser,global_v_coduser);
                  end if;
                end if;
              elsif v_flg = 'delete' then
                insert into	tlogot2(codempid,dtetimupd,dteupd,dtework,typot,
                            rteotpay,qtyminoto,qtyminotn,coduser,codcreate)
                     values (p_codempid,v_date,v_date,p_dtework,p_typot,
                             v_rteotpay,v_qtyminoto,null,global_v_coduser,global_v_coduser);
              end if;
          else

            insert into	tlogot2(codempid,dtetimupd,dteupd,dtework,typot,
                        rteotpay,qtyminoto,qtyminotn,coduser,codcreate)
                 values (p_codempid,v_date,v_date,p_dtework,p_typot,
                         v_rteotpay,v_qtyminoto,null,global_v_coduser,global_v_coduser);
          end if;
        end loop;
    end if;
  end;

  procedure upd_tovrtime(json_str_input_detail in json_object_t,
                         json_str_input_table1 in json_object_t) as
    param_json_row    json_object_t;
    v_dtestrtn        tovrtime.dtestrt%type;
    v_timstrtn        tovrtime.timstrt%type;
    v_dteendn         tovrtime.dteend%type;
    v_timendn         tovrtime.timend%type;
    v_qtydedbrkn      tovrtime.qtydedbrk%type;
    v_qtyminot        tovrtime.qtyminot%type;
    --
    v_dtestrto        tovrtime.dtestrt%type;
    v_timstrto        tovrtime.timstrt%type;
    v_dteendo         tovrtime.dteend%type;
    v_timendo         tovrtime.timend%type;
    --
    v_typpayroll      tovrtime.typpayroll%type;
    v_codcalen        tovrtime.codcalen%type;
    v_codcomp         tovrtime.codcomp%type;
    v_codshift        tovrtime.codshift%type;
    v_typwork         tovrtime.typwork%type;
    v_amtmealn        varchar2(100 char);
    v_amtmealo        varchar2(100 char);
    v_cost_center_w   varchar2(100 char);
    --
    v_numrec          number := 0;
    v_error           varchar2(4000 char);
    v_err_table       varchar2(4000 char);
    v_cnt             number := 0;
    v_flg             varchar2(100 char);
--    v_flg             boolean;
  begin
    initial_value_detail(json_str_input_detail);
    check_save;
    if param_msg_error is null then
      for i in 0..json_str_input_table1.get_size-1 loop
        param_json_row    := hcm_util.get_json_t(json_str_input_table1,to_char(i));
        v_dtestrtn        := to_date(hcm_util.get_string_t(param_json_row, 'dtestrtn'),'dd/mm/yyyy');
        v_timstrtn        := replace(hcm_util.get_string_t(param_json_row, 'timstrtn'),':','');
        v_dteendn         := to_date(hcm_util.get_string_t(param_json_row, 'dteendn'),'dd/mm/yyyy');
        v_timendn         := replace(hcm_util.get_string_t(param_json_row, 'timendn'),':','');
        v_qtydedbrkn      := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json_row, 'qtydedbrkn'));
        v_qtyminot        := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json_row, 'qtyminot'));
        v_flg             := hcm_util.get_string_t(param_json_row, 'flg');
--        v_flg             := hcm_util.get_boolean_t(param_json_row, 'flgEdit');
        --

--        if v_flg then
--          v_dtestrto        := to_date(hcm_util.get_string_t(param_json_row, 'dtestrtnOld'),'dd/mm/yyyy');
--          v_timstrto        := replace(hcm_util.get_string_t(param_json_row, 'timstrtnOld'),':','');
--          v_dteendo         := to_date(hcm_util.get_string_t(param_json_row, 'dteendnOld'),'dd/mm/yyyy');
--          v_timendo         := replace(hcm_util.get_string_t(param_json_row, 'timendnOld'),':','');
--        else
          v_dtestrto        := to_date(hcm_util.get_string_t(param_json_row, 'dtestrto'),'dd/mm/yyyy');
          v_timstrto        := replace(hcm_util.get_string_t(param_json_row, 'timstrto'),':','');
          v_dteendo         := to_date(hcm_util.get_string_t(param_json_row, 'dteendo'),'dd/mm/yyyy');
          v_timendo         := replace(hcm_util.get_string_t(param_json_row, 'timendo'),':','');
--        end if;

      end loop;
      --
      begin
        select typpayroll,codcalen,codcomp
          into v_typpayroll,v_codcalen,v_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
      end;
      --
      begin
        select codshift,typwork
          into v_codshift,v_typwork
          from tattence
         where codempid = p_codempid
           and dtework  = p_dtework;
      exception when no_data_found then null;
      end;
      --
      begin
        select count(*) into v_cnt
          from tovrtime
         where codempid = p_codempid
           and dtework  = p_dtework
           and typot    = p_typot;
      exception when no_data_found then null;
      end;

      if p_flgtypot = 'Y' then
        p_qtyleaven := null;
      end if;
      if p_amtmealn is not null then
        v_amtmealn  :=  stdenc(p_amtmealn,p_codempid,v_chken);
      else
        v_amtmealn := '';
      end if;
      if p_amtmealo is not null then
        v_amtmealo  :=  stdenc(p_amtmealo,p_codempid,v_chken);
      else
        v_amtmealo := '';
      end if;
      if p_amtmealn is not null and p_amtmealn > 0 then
        p_flgmeal := 'Y';
      else
        p_flgmeal := 'N';
      end if;

      if v_cnt = 0 then
        insert into tovrtime(codempid,dtework,typot,dtestrt,timstrt,dteend,timend,
                             qtydedbrk,qtyminot,coduser, codcreate,
                             amtmeal,qtyleave,codcompw,codrem,remark,codappr,dteappr,
                             typpayroll,codcalen,codcomp,codshift,typwork,flgadj,flgmeal)
             values(p_codempid,p_dtework,p_typot,v_dtestrtn,v_timstrtn,v_dteendn,v_timendn,
                    v_qtydedbrkn,v_qtyminot,global_v_coduser, global_v_coduser,
                    stdenc(p_amtmealn,p_codempid,v_chken),p_qtyleaven,p_codcompn,p_codrem,p_remark,p_codappr,p_dteappr,
                    v_typpayroll,v_codcalen,v_codcomp,v_codshift,v_typwork,p_flgadj,p_flgmeal);
        -- insert logs
        insert into tlogot(dteupd, codempid, dtetimupd, codcomp, dtework, typot,
                    dtestoto,timstoto,dteenoto,timenoto,amtmealo,qtyleaveo,codcompwo,
                    dtestotn, timstotn, dteenotn, timenotn, amtmealn, qtyleaven, codcompwn,
                    coduser,codcreate)
             values(v_date, p_codempid, v_date, v_codcomp, p_dtework, p_typot,
                    null, null, null, null, null, null, null,
                    v_dtestrtn,v_timstrtn,v_dteendn, v_timendn,stdenc(p_amtmealn,p_codempid,v_chken),p_qtyleaven,p_codcompn,
                    global_v_coduser, global_v_coduser);
      else
                    if v_flg is not null then
            --        if v_flg then
                      update tovrtime set dtestrt  = v_dtestrtn,
                                          timstrt  = v_timstrtn,
                                          dteend   = v_dteendn,
                                          timend   = v_timendn,
                                          qtydedbrk = v_qtydedbrkn,
                                          qtyminot = v_qtyminot,
                                          coduser  = global_v_coduser,
                                          codcreate  = global_v_coduser,
                                          --
                                          amtmeal  = stdenc(p_amtmealn,p_codempid,v_chken),
                                          qtyleave = p_qtyleaven,
                                          codcompw = p_codcompn,
                                          codrem   = p_codrem,
                                          remark   = p_remark,
                                          codappr  = p_codappr,
                                          dteappr  = p_dteappr,
                                          flgadj   = p_flgadj,
                                          flgmeal  = p_flgmeal,
                                          --
                                          typpayroll = v_typpayroll,
                                          codcalen = v_codcalen,
                                          codcomp  = v_codcomp,
                                          codshift = v_codshift,
                                          typwork  = v_typwork
                                    where codempid = p_codempid
                                      and dtework  = p_dtework
                                      and typot		 = p_typot;
                    else
                      update tovrtime set amtmeal  = stdenc(p_amtmealn,p_codempid,v_chken),
                                          qtyleave = p_qtyleaven,
                                          codcompw = p_codcompn,
                                          codrem   = p_codrem,
                                          remark   = p_remark,
                                          codappr  = p_codappr,
                                          dteappr  = p_dteappr,
                                          flgadj   = p_flgadj,
                                          flgmeal  = p_flgmeal,
                                          --
                                          typpayroll = v_typpayroll,
                                          codcalen = v_codcalen,
                                          codcomp  = v_codcomp,
                                          codshift = v_codshift,
                                          typwork  = v_typwork,
                                          coduser  = global_v_coduser
                                    where codempid = p_codempid
                                      and dtework  = p_dtework
                                      and typot		 = p_typot;
                    end if;
            --        if json_str_input_table1.get_size > 0 then --<<user25 Date : 12/10/2021 2.AL Module #6197
            --            -- insert logs
                            insert into tlogot(dteupd,codempid,dtetimupd,codcomp,dtework,typot,dtestoto,timstoto,
                                        dteenoto,timenoto,amtmealo,qtyleaveo,codcompwo,dtestotn,timstotn,dteenotn,
                                        timenotn,amtmealn,qtyleaven,codcompwn,coduser, codcreate)
                                 values(v_date,p_codempid,v_date,v_codcomp,p_dtework,p_typot,v_dtestrto,v_timstrto,
                                        v_dteendo,v_timendo,stdenc(p_amtmealo,p_codempid,v_chken),p_qtyleaveo,p_codcompo,v_dtestrtn,v_timstrtn,v_dteendn,
                                        v_timendn,stdenc(p_amtmealn,p_codempid,v_chken),p_qtyleaven,p_codcompn,global_v_coduser, global_v_coduser);
            --        end if;--<<user25 Date : 12/10/2021 2.AL Module #6197
      end if;

      -- check edit qtyleave
      if json_str_input_table1.get_size <> 0 then
        if nvl(p_qtyleaven,0) <> nvl(p_qtyleaveo,0) then
          hral85b_batch.gen_compensate(p_codempid, v_codcomp, v_codcalen, v_typpayroll,
                                       v_dtestrtn,
                                       global_v_coduser, v_numrec, v_error, v_err_table);
        end if;
      end if;
--      rollback;
    end if;
  end;

  procedure get_codcenter(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    json_obj      json_object_t := json_object_t(json_str_input);
    v_codcenter   varchar2(1000 char);
    v_codcomp     varchar2 (1000 char);
    v_total       number := 0;
  begin
    v_codcomp := hcm_util.get_string_t(json_obj,'p_codcomp');
    begin
      select costcent into v_codcenter
        from tcenter
       where codcomp = v_codcomp;
    exception when no_data_found then
      v_codcenter := null;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('codcenter', v_codcenter);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
end HRAL42U;

/
