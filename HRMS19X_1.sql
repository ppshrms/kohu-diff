--------------------------------------------------------
--  DDL for Package Body HRMS19X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS19X" is

  procedure initial_value(json_str_input in clob) as
    json_obj      json_object_t;
  begin
    json_obj              := json_object_t(json_str_input);

    --global
    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');

    --value
    b_index_codempid      := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_codcomp       := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_codcalen      := hcm_util.get_string_t(json_obj,'p_codcalen');
    b_index_dtestr        := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'dd/mm/yyyy');
    b_index_dteend        := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_codcomp             := upper(hcm_util.get_string_t(json_obj, 'p_codcomp'));
    v_text_key            := 'otrate';

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end;
  --
  function cal_hour_unlimited (p_min number, p_null boolean := false) return varchar2 is
    v_hou_display     varchar2(10 char) := '0';
    v_min_display     varchar2(10 char) := '00';
  begin
    if nvl(p_min, 0) > 0 then
      v_hou_display        := trunc(p_min / 60);
      v_min_display        := lpad(mod(p_min, 60), 2, '0');
      return v_hou_display || ':' || v_min_display;
    else
      if p_null then
        return null;
      else
        return v_hou_display || ':' || v_min_display;
      end if;
    end if;
  exception when others then
    return p_min;
  end;
  --
  procedure check_index is
    v_staemp    varchar2(1 char);
    v_secur			boolean;
    v_zupdsal   varchar2(4 char);

  begin

    ------------------------------------------------------
    if b_index_dtestr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    elsif b_index_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if b_index_dtestr > b_index_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang);
      return;
    end if;

    ------------------------------------------------------
    if b_index_codempid is  null and b_index_codcalen is null and replace(b_index_codcomp,'%',null) is null  then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if b_index_codempid is not null then
      b_index_codcalen  := null;
      b_index_codcomp   := null;
        begin
          select staemp into v_staemp
            from temploy1
           where codempid = b_index_codempid;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
          return;
        end;

        v_secur := secur_main.secur2(b_index_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not v_secur then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
          return;
        end if;
    else
        if b_index_codcalen is not null then
            begin
              select codcodec into b_index_codcalen
                from tcodwork
               where codcodec = b_index_codcalen;
            exception when no_data_found then
              param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodwork');
              return;
            end;
        end if;
        if b_index_codcomp is not null then
          param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
          if param_msg_error is not null then return; end if;
        end if;
    end if;
  end;
  --
  procedure sum_tlateabs (p_dtework	in date,p_codempid in varchar2,p_flgwork varchar2)is
	v_late			number;
	v_early			number;
	v_absent		number;
  begin	-- abnormal
    ttemfilt_item07 := '';
    ttemfilt_item08 := '';
    ttemfilt_item09 := '';
    begin
      select sum(qtylate), sum(qtyearly), sum(qtyabsent)
        into v_late, v_early, v_absent
        from tlateabs
       where codempid = p_codempid
         and dtework  = p_dtework;
--user03 update 20190710
--         and flgwork  = p_flgwork;
          if nvl(v_late,0) > 0 then
              ttemfilt_item07 := trunc(v_late / 60,0)||':'||lpad(mod(v_late,60),2,'0');
          end if;
          if nvl(v_early,0) > 0 then
              ttemfilt_item08 := trunc(v_early / 60,0)||':'||lpad(mod(v_early,60),2,'0');
          end if;
          if nvl(v_absent,0) > 0 then
              ttemfilt_item09 := trunc(v_absent / 60,0)||':'||lpad(mod(v_absent,60),2,'0');
          end if;
          ttemfilt_temp01     := nvl(v_late,0);
          ttemfilt_temp02     := nvl(v_early,0);
          ttemfilt_temp03     := nvl(v_absent,0);
          parameter_qtylate   := parameter_qtylate   + nvl(v_late,0);
          parameter_qtyearly  := parameter_qtyearly  + nvl(v_early,0);
          parameter_qtyabsent := parameter_qtyabsent + nvl(v_absent,0);
    exception when no_data_found then null;
          ttemfilt_temp01     := 0;
          ttemfilt_temp02     := 0;
          ttemfilt_temp03     := 0;
    end;
  end;
  --
  PROCEDURE sum_tleavetr (p_dtework	in date,p_flgwork varchar2,p_codempid varchar2,p_codcomp varchar2,p_next out boolean) IS
	v_numseq     number;
	v_codapp     tempaprq.codapp%type :=  'HRMS19X';
	v_codleave   tleavecd.codleave%type;
	v_qtymin		 number;
  cursor c_tleavetr is
      select codleave,qtymin
        from tleavetr
       where codempid = p_codempid
         and dtework  = p_dtework
--user03 update 20190710
--         and flgwork  = p_flgwork
         and qtymin > 0;
  BEGIN
    p_next := true;
    ttemfilt_item10 := '';
    ttemfilt_item11 := '';
    ttemfilt_temp04 := 0;
    for l in c_tleavetr loop
        if ttemfilt_item10 is null then
            ttemfilt_item10 := get_tleavecd_name(l.codleave,global_v_lang);
        else
            ttemfilt_item10 := ttemfilt_item10||' / '||get_tleavecd_name(l.codleave,global_v_lang);
        end if;
        ttemfilt_item11     := trunc(l.qtymin / 60,0)||':'||lpad(mod(l.qtymin,60),2,'0');
        ttemfilt_temp04     := nvl(l.qtymin,0);
        parameter_qtyleave  := parameter_qtyleave + l.qtymin;
        ttemfilt_codcomp    := p_codcomp;
        p_next := false;
    end loop;
    if(p_next)then
      ttemfilt_temp04 := 0;
    end if;
  end;
  --
  PROCEDURE sum_tovrtime( p_dtework in tattence.dtework%type,p_codempid in varchar2) IS
	v_before		number;
	v_during		number;
	v_after 		number;
  BEGIN	-- OVRTIME
    begin
      select sum(qtyminot) into v_before
        from tovrtime
       where codempid = p_codempid
         and dtework  = p_dtework
         and typot    = 'B';
          if v_before > 0 then
              ttemfilt_item12 := trunc(v_before / 60,0)||':'||lpad(mod(trunc(v_before),60),2,'0');
              parameter_before := parameter_before + v_before;
          else
              ttemfilt_item12  := '';
          end if;
          ttemfilt_temp05 := nvl(v_before,0);
          exception when no_data_found then
            ttemfilt_temp05 := 0;
    end;
    begin
      select sum(qtyminot) into v_during
        from tovrtime
       where codempid = p_codempid
         and dtework  = p_dtework
         and typot    = 'D';
          if v_during > 0 then
            ttemfilt_item13  := trunc(v_during / 60,0)||':'||lpad(mod(trunc(v_during),60),2,'0');
            parameter_during := parameter_during + v_during;
          else
            ttemfilt_item13  := '';
          end if;
          ttemfilt_temp06 := nvl(v_during,0);
    exception when no_data_found then
          ttemfilt_temp06 := 0;
    end;
    begin
      select sum(qtyminot) into v_after
        from tovrtime
       where codempid = p_codempid
         and dtework  = p_dtework
         and typot    = 'A';
          if v_after > 0 then
            ttemfilt_item14 :=  trunc(v_after / 60,0)||':'||lpad(mod(trunc(v_after),60),2,'0');
            parameter_after := parameter_after + v_after;
          else
            ttemfilt_item14 := '';
          end if;
          ttemfilt_temp07 := nvl(v_after,0);
    exception when no_data_found then
        ttemfilt_temp07 := 0;
    end;
  end;
  --
  function get_ot_col (v_codcompy varchar2) return json_object_t is
    obj_ot_col         json_object_t;
    v_max_ot_col       number := 0;

    cursor max_ot_col is
      select distinct(rteotpay)
        from totratep2
       where codcompy = v_codcompy
--         and dteeffec = (select max(b.dteeffec)
--                           from totratep2 b
--                          where b.codcompy = v_codcompy
--                            and b.dteeffec <= sysdate)
    order by rteotpay;
  begin
    obj_ot_col := json_object_t();
    for row_ot in max_ot_col loop
      v_max_ot_col := v_max_ot_col + 1;
      obj_ot_col.put(to_char(v_max_ot_col), row_ot.rteotpay);
    end loop;
    return obj_ot_col;
  exception
  when others then
    return json_object_t();
  end;
  --
  procedure gen_data(json_str_output out clob) is
      flg_data    varchar2(1 char) := 'N';
      flg_secur   varchar2(1 char) := 'N';
      v_where     varchar2(100 char);
      v_flgpass   boolean;
      v_codapp		varchar2(100 char) := 'HRMS19X';
      v_codempid	varchar2(400 char);
      v_codcomp   varchar2(400 char);
      v_next      boolean;
      v_dtework   date;
      v_zupdsal   varchar2(100 char);

      v_rcnt          number;
      obj_row         json_object_t;
      obj_data        json_object_t;
      v_total         number;

      v_codcompy      varchar2(50 char);
      v_max_ot_col    number := 0;
      obj_ot_col      json_object_t;
      v_ot_min        number;
      v_rteotpay      number;
      v_rateot5       varchar2(100 char);
      v_rateot_min5   number;
      v_timinc        varchar2(100 char); --user4 || 25/07/2019
      v_timoutc       varchar2(100 char); --user4 || 25/07/2019
      v_data          varchar2(100 char);

   cursor c1 is
       select a.codempid,dtework,typwork,codshift,timstrtw,timendw,timin,timout,a.codcomp,codchng,codtitle,codpos,a.rowid
         from tattence a,temploy1 b
        where a.codempid = b.codempid
          and a.codempid = nvl(b_index_codempid,a.codempid)
          and b.codcomp  like  nvl(b_index_codcomp||'%','%')
          and b.codcalen = nvl(b_index_codcalen,b.codcalen)
          and dtework between b_index_dtestr and b_index_dteend
          order by a.codempid , dtework;
    cursor c2 is -- user4 || 25/07/2019
      select to_char(to_date(max(timtime),'hh24mi'),'hh24:mi') timout, to_char(to_date(min(timtime),'hh24mi'),'hh24:mi') timin
        from tatmfile
       where codempid = b_index_codempid
         and dtedate  = v_dtework
         and flginput = 2
         and dtetime between to_date(to_char(v_dtework,'dd/mm/yyyy')||ttemfilt_item05,'dd/mm/yyyyhh24:mi')
         and to_date(to_char(v_dtework,'dd/mm/yyyy')||ttemfilt_item06,'dd/mm/yyyyhh24:mi');
-- user03 update 20190710
--   cursor c2 is
--       select codempid,dtework,typwork,codshift,timstrtw,timendw,timin,timout,codcomp,codchng,rowid
--         from tattencr
--        where codempid = v_codempid
--          and dtework  = v_dtework;
  begin
    parameter_qtylate   := 0; parameter_qtyearly := 0;
    parameter_qtyabsent := 0; parameter_qtyleave := 0;
    parameter_before    := 0; parameter_during   := 0;
    parameter_after     := 0;

    v_rcnt := 0;
    obj_row := json_object_t();
    v_codcompy              := null;
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    elsif b_index_codempid is not null then
      begin
        select get_comp_split(codcomp, 1) codcompy
          into v_codcompy
          from temploy1
         where codempid = b_index_codempid;
      exception when no_data_found then
        null;
      end;
    end if;
    obj_ot_col        := get_ot_col(v_codcompy);

    -- loop data
    for i in c1 loop
        flg_data := 'Y' ;
        v_flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if v_flgpass then
            v_codempid := i.codempid;
            v_codcomp  := i.codcomp;
            v_dtework  := i.dtework;
            flg_secur  := 'Y';
            ttemfilt_item15  := i.codempid;
            ttemfilt_item16  := get_temploy_name(i.codempid,global_v_lang);
            ttemfilt_item17  := get_tpostn_name(i.codpos,global_v_lang);
            ttemfilt_item18  := get_tcenter_name(i.codcomp,global_v_lang);
            ttemfilt_date01	 := i.dtework;
            ttemfilt_date01d := i.dtework;
            ttemfilt_item01	 := i.typwork;
            ttemfilt_item02	 := i.codshift;
            ttemfilt_item03  := '';
            ttemfilt_item04  := '';
            ttemfilt_item05  := '';
            ttemfilt_item06  := '';
            ttemfilt_temp01  := 0;
            ttemfilt_temp02  := 0;
            ttemfilt_temp03  := 0;
            ttemfilt_temp04  := 0;
            ttemfilt_temp05  := 0;
            ttemfilt_temp06  := 0;
            ttemfilt_temp07  := 0;

            if i.timstrtw is not null then
               ttemfilt_item03	:= substr(i.timstrtw,1,2)||':'||substr(i.timstrtw,3,2);
            end if;

            if i.timendw is not null then
               ttemfilt_item04	:= substr(i.timendw,1,2)||':'||substr(i.timendw,3,2);
            end if;

            if i.timin is not null then
               ttemfilt_item05	:= substr(i.timin,1,2)||':'||substr(i.timin,3,2);
            end if;

            if i.timout is not null then
               ttemfilt_item06	:= substr(i.timout,1,2)||':'||substr(i.timout,3,2);
            end if;

            sum_tlateabs(i.dtework,v_codempid,'W');
            sum_tovrtime(i.dtework,v_codempid);
            ttemfilt_item10  := get_tcodec_name('TCODTIME',i.codchng,global_v_lang);
            ttemfilt_codcomp := i.codcomp;
            ttemfilt_item15	 := i.codempid;
            ttemfilt_item16	 := get_temploy_name(i.codempid,global_v_lang);

            sum_tleavetr(i.dtework,'W',v_codempid,v_codcomp,v_next);

            v_timinc  := null;
            v_timoutc := null;
            for r2 in c2 loop
              v_timinc  := r2.timin;
              v_timoutc := r2.timout;
            end loop;

        --user18 update 20191010
          select to_char(to_date(max(timtime),'hh24mi'),'hh24:mi') timout, to_char(to_date(min(timtime),'hh24mi'),'hh24:mi') timin
          into v_timoutc,v_timinc
            from tatmfile
           where codempid = ttemfilt_item15
             and flginput = 2
             and dtedate = ttemfilt_date01;


            v_rcnt := nvl(v_rcnt,0) + 1;
            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('desc_coderror','');
            obj_data.put('httpcode','');
            obj_data.put('flg','');
            obj_data.put('total',to_char(v_rcnt));
            obj_data.put('rcnt',to_char(v_rcnt));
            obj_data.put('codempid',ttemfilt_item15);
            obj_data.put('desc_codempid',ttemfilt_item16);
            obj_data.put('desc_codpos',ttemfilt_item17);
            obj_data.put('desc_codcomp',ttemfilt_item18);
            obj_data.put('dtework',to_char(ttemfilt_date01,'dd/mm/yyyy'));
            obj_data.put('typwork',ttemfilt_item01);
            obj_data.put('codshift',ttemfilt_item02);
            obj_data.put('timstrtw',ttemfilt_item03);
            obj_data.put('timendw',ttemfilt_item04);
            obj_data.put('timin',ttemfilt_item05);
            obj_data.put('timout',ttemfilt_item06);
            obj_data.put('timinc',v_timinc);   -- user4 || 25/07/2019
            obj_data.put('timoutc',v_timoutc); -- user4 || 25/07/2019
            obj_data.put('qtylate',ttemfilt_item07);
            obj_data.put('qtyearly',ttemfilt_item08);
            obj_data.put('qtyabsent',ttemfilt_item09);
            obj_data.put('desc_codchng',ttemfilt_item10);
            obj_data.put('qtyleave',ttemfilt_item11);
            obj_data.put('ot_before',ttemfilt_item12);
            obj_data.put('ot_during',ttemfilt_item13);
            obj_data.put('ot_after',ttemfilt_item14);

            obj_data.put('otkey', v_text_key);
            obj_data.put('otlen', v_rateot_length+1); --obj_ot_col.count
            v_rateot5 := null;
            v_rateot_min5 := 0;
            for i in 1..obj_ot_col.get_size loop
              v_data := hcm_util.get_string_t(obj_ot_col, to_char(i));
              begin
                select nvl(sum(qtyminot), 0)
                  into v_ot_min
                  from totpaydt
                 where codempid = v_codempid
                   and dtework  = v_dtework
                   and rteotpay = v_data;
              exception when no_data_found then
                v_ot_min      := 0;
              end;
             if i <= v_rateot_length then -- case < 5 rate
                obj_data.put(v_text_key||i, cal_hour_unlimited(v_ot_min, true));
                obj_data.put(v_text_key||'_min'||i, v_ot_min);
              else  -- case >= 5 rate
                v_rateot_min5 := v_rateot_min5 + nvl(v_ot_min, 0);
                v_rateot5 := cal_hour_unlimited(v_rateot_min5, true);
              end if;
            end loop;

            obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
            obj_data.put(v_text_key||'_min'||to_char(v_rateot_length+1), v_rateot_min5);


            obj_row.put(to_char(v_rcnt-1),obj_data);

            ----------------------------------------------
            -- tattencr
            v_dtework := i.dtework;
-- user03 update 20190710
--            for k in c2 loop
--                v_codcomp  := i.codcomp;
--                ttemfilt_temp01 := 0;
--                ttemfilt_temp02 := 0;
--                ttemfilt_temp03 := 0;
--                ttemfilt_temp04 := 0;
--                ttemfilt_temp05 := 0;
--                ttemfilt_temp06 := 0;
--                ttemfilt_temp07 := 0;
--                ttemfilt_date01	:= k.dtework;
--                ttemfilt_item01	:= k.typwork;
--                ttemfilt_item02	:= k.codshift;
--                ttemfilt_item03 := '';
--                ttemfilt_item04 := '';
--                ttemfilt_item05 := '';
--                ttemfilt_item06 := '';
--                if k.timstrtw is not null then
--                   ttemfilt_item03	:= substr(k.timstrtw,1,2)||':'||substr(k.timstrtw,3,2);
--                end if;
--                if k.timendw is not null then
--                   ttemfilt_item04	:= substr(k.timendw,1,2)||':'||substr(k.timendw,3,2);
--                end if;
--                if k.timin is not null then
--                   ttemfilt_item05	:= substr(k.timin,1,2)||':'||substr(k.timin,3,2);
--                end if;
--                if k.timout is not null then
--                   ttemfilt_item06	:= substr(k.timout,1,2)||':'||substr(k.timout,3,2);
--                end if;
--                sum_tlateabs(k.dtework,v_codempid,'R');
--                ttemfilt_item10  := get_tcodec_name('TCODTIME',k.codchng,global_v_lang);
--                ttemfilt_codcomp := k.codcomp;
--                ttemfilt_item15	:= i.codempid;
--                ttemfilt_item16	:= get_temploy_name(i.codempid,global_v_lang);
--                sum_tleavetr(i.dtework,'R',v_codempid,v_codcomp,v_next);
--
--                v_rcnt := nvl(v_rcnt,0) + 1;
--                obj_data := json_object_t();
--                obj_data.put('coderror','200');
--                obj_data.put('desc_coderror','');
--                obj_data.put('httpcode','');
--                obj_data.put('flg','');
--                obj_data.put('total',to_char(v_rcnt));
--                obj_data.put('rcnt',to_char(v_rcnt));
--                obj_data.put('codempid',ttemfilt_item15);
--                obj_data.put('desc_codempid',ttemfilt_item16);
--                obj_data.put('desc_codpos',ttemfilt_item17);
--                obj_data.put('desc_codcomp',ttemfilt_item18);
--                obj_data.put('dtework',ttemfilt_date01);
--                obj_data.put('typwork',ttemfilt_item01);
--                obj_data.put('codshift',ttemfilt_item02);
--                obj_data.put('timstrtw',ttemfilt_item03);
--                obj_data.put('timendw',ttemfilt_item04);
--                obj_data.put('timin',ttemfilt_item05);
--                obj_data.put('timout',ttemfilt_item06);
--                obj_data.put('qtylate',ttemfilt_item07);
--                obj_data.put('qtyearly',ttemfilt_item08);
--                obj_data.put('qtyabsent',ttemfilt_item09);
--                obj_data.put('desc_codchng',ttemfilt_item10);
--                obj_data.put('qtyleave',ttemfilt_item11);
--                obj_data.put('ot_before',ttemfilt_item12);
--                obj_data.put('ot_during',ttemfilt_item13);
--                obj_data.put('ot_after',ttemfilt_item14);
--                obj_row.put(to_char(v_rcnt-1),obj_data);
--            end loop;
        end if;
    end loop;
    if flg_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    elsif flg_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;

    if parameter_qtylate   > 0 or parameter_qtyearly > 0 or
        parameter_qtyabsent > 0 or parameter_qtyleave > 0 or
        parameter_before    > 0 or parameter_during   > 0 or
        parameter_after     > 0 then
        ttemfilt_item01  :=  'di_v300';--:ctrl_label.di_v300;
        ttemfilt_item07  := '';
        ttemfilt_item08  := '';
        ttemfilt_item09  := '';
        ttemfilt_item11  := '';
        ttemfilt_item12  := '';
        ttemfilt_item13  := '';
        ttemfilt_item14  := '';

        if parameter_qtylate > 0 then
            ttemfilt_item07  := trunc(parameter_qtylate / 60,0)||':'||lpad(mod(parameter_qtylate,60),2,'0');
        end if;
        if parameter_qtyearly > 0 then
            ttemfilt_item08  := trunc(parameter_qtyearly / 60,0)||':'||lpad(mod(parameter_qtyearly,60),2,'0');
        end if;
        if parameter_qtyabsent > 0 then
            ttemfilt_item09 := trunc(parameter_qtyabsent / 60,0)||':'||lpad(mod(parameter_qtyabsent,60),2,'0');
        end if;
        if parameter_qtyleave > 0 then
            ttemfilt_item11 := trunc(parameter_qtyleave / 60,0)||':'||lpad(mod(parameter_qtyleave,60),2,'0');
        end if;
        if parameter_before > 0 then
            ttemfilt_item12 := trunc(parameter_before / 60,0)||':'||lpad(mod(parameter_before,60),2,'0');
        end if;
        if parameter_during > 0 then
            ttemfilt_item13 := trunc(parameter_during / 60,0)||':'||lpad(mod(parameter_during,60),2,'0');
        end if;
        if parameter_after > 0 then
            ttemfilt_item14 := trunc(parameter_after / 60,0)||':'||lpad(mod(parameter_after,60),2,'0');
        end if;

        v_rcnt    := nvl(v_rcnt,0) + 1;
        obj_data  := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('desc_coderror','');
        obj_data.put('httpcode','');
        obj_data.put('flg','SUM');
        obj_data.put('total',to_char(v_rcnt));
        obj_data.put('rcnt',to_char(v_rcnt));
        obj_data.put('codempid','');
        obj_data.put('desc_codempid','รวม');
        obj_data.put('desc_codpos','');
        obj_data.put('desc_codcomp','');
        obj_data.put('dtework','');
        obj_data.put('typwork',get_label_name('HRMS19XC1', '102', 300));
        obj_data.put('codshift','');
        obj_data.put('timstrtw','');
        obj_data.put('timendw','');
        obj_data.put('timin','');
--        obj_data.put('timinc',v_timinc);   -- user4 || 25/07/2019
--        obj_data.put('timoutc',v_timoutc); -- user4 || 25/07/2019
        obj_data.put('timinc','');   -- user18 || 17/10/2019
        obj_data.put('timoutc',''); -- user18 || 17/10/2019
        obj_data.put('timout','');
        obj_data.put('qtylate',ttemfilt_item07);
        obj_data.put('qtyearly',ttemfilt_item08);
        obj_data.put('qtyabsent',ttemfilt_item09);
        obj_data.put('desc_codchng','');
        obj_data.put('qtyleave',ttemfilt_item11);
        obj_data.put('ot_before',ttemfilt_item12);
        obj_data.put('ot_during',ttemfilt_item13);
        obj_data.put('ot_after',ttemfilt_item14);
        obj_data.put('otkey', v_text_key);
        obj_data.put('otlen', v_rateot_length+1); --obj_ot_col.count
        v_rateot5 := null;
        v_rateot_min5 := 0;
        for i in 1..obj_ot_col.get_size loop
          v_data := hcm_util.get_string_t(obj_ot_col, to_char(i));
          begin
            select nvl(sum(qtyminot), 0)
              into v_ot_min
              from totpaydt
             where codempid = v_codempid
               --and dtework  = v_dtework
               and dtework  between b_index_dtestr and b_index_dteend
               and rteotpay = v_data;
          exception when no_data_found then
            v_ot_min      := 0;
          end;
         if i <= v_rateot_length then -- case < 5 rate
            obj_data.put(v_text_key||i, cal_hour_unlimited(v_ot_min, true));
            obj_data.put(v_text_key||'_min'||i, v_ot_min);
          else  -- case >= 5 rate
            v_rateot_min5 := v_rateot_min5 + nvl(v_ot_min, 0);
            v_rateot5 := cal_hour_unlimited(v_rateot_min5, true);
          end if;
        end loop;


        obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
        obj_data.put(v_text_key||'_min'||to_char(v_rateot_length+1), v_rateot_min5);

        obj_row.put(to_char(v_rcnt-1),obj_data);
    end if;
    json_str_output := obj_row.to_clob;
  end;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if; --param_msg_error
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure check_ot_head is
  begin
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if p_codempid is not null then
      begin
        select codempid
          into p_codempid
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;

  end check_ot_head;

  procedure get_ot_head (json_str_input in clob, json_str_output out clob) is
    v_codcompy          TCENTER.CODCOMPY%TYPE;
  begin
    initial_value(json_str_input);
    check_ot_head;
    if param_msg_error is null then
      gen_ot_head(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_ot_head;

  procedure gen_ot_head (json_str_output out clob) is
    obj_data           json_object_t;
    obj_row            json_object_t;
    v_codcomp          varchar2(50 char);
    v_codcompy         varchar2(50 char);
    v_max_ot_col       number := 0;
    obj_ot_col         json_object_t;
    v_count            number;
    v_other            varchar2(100 char);
    v_rateot5          varchar2(100 char);
    v_ot_col           varchar2(100 char);
  begin
    obj_data            := json_object_t();
    obj_row            := json_object_t();
    v_codcompy         := null;
    if p_codcomp is not null then
      v_codcompy := hcm_util.get_codcomp_level(p_codcomp, 1);
    elsif b_index_codempid is not null then
      begin
        select get_comp_split(codcomp, 1) codcompy
          into v_codcompy
          from temploy1
         where codempid = b_index_codempid;
      exception when no_data_found then
        null;
      end;
    end if;
    obj_ot_col         := get_ot_col(v_codcompy);
    obj_data.put('otkey', v_text_key);
    obj_data.put('otlen', v_rateot_length+1); --obj_ot_col.count
--    for i in 1..obj_ot_col.count loop
--      obj_data.put(v_text_key||i, hcm_util.get_string(obj_ot_col, to_char(i)));
--    end loop;
--    for i in 1..v_rateot_length loop
--      obj_data.put(v_text_key||i, hcm_util.get_string(obj_ot_col, to_char(i)));
--    end loop;
    for i in 1..v_rateot_length loop
      v_ot_col := hcm_util.get_string_t(obj_ot_col, to_char(i));
      if v_ot_col is not null then
        obj_data.put(v_text_key||i, hcm_util.get_string_t(obj_ot_col, to_char(i)));
      else
        obj_data.put(v_text_key||i, ' ');
      end if;
    end loop;

    v_count  := obj_ot_col.get_size;
    v_other  := get_label_name('HRAL61XC1', global_v_lang, '310');

--    v_rateot5 := null;
--    if v_count > v_rateot_length then
--      if v_count = v_rateot_length + 1 then
--        v_rateot5 := v_text_key;
--      else
--        v_rateot5 := v_other;
--      end if;
--    end if;
      v_rateot5 := null;
      if v_count > v_rateot_length then
        if v_count = v_rateot_length + 1 then
          v_rateot5 := hcm_util.get_string_t(obj_ot_col, to_char(v_rateot_length + 1));
        else
          v_rateot5 := v_other;
          end if;
      end if;
      obj_data.put(v_text_key||to_char(v_rateot_length+1), nvl(v_rateot5, v_other));

--    obj_data.put(v_text_key||to_char(v_rateot_length+1), v_rateot5);
    obj_row.put(0, obj_data);
    json_str_output := obj_row.to_clob;
  end gen_ot_head;

end;

/
