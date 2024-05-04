--------------------------------------------------------
--  DDL for Package Body HRAL51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL51E" as
  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
    p_numlereq          := hcm_util.get_string_t(json_obj,'p_numlereq');
    p_codleave          := hcm_util.get_string_t(json_obj,'p_codleave');
    p_dterecod          := to_date(hcm_util.get_string_t(json_obj,'p_dterecod'),'ddmmyyyy');
    p_dteleave          := to_date(hcm_util.get_string_t(json_obj,'p_dteleave'),'ddmmyyyy');
    -- paternity leave --
    p_dteprgntst        := to_date(hcm_util.get_string_t(json_obj,'p_dteprgntst'),'ddmmyyyy');
    p_timprgnt          := hcm_util.get_string_t(json_obj,'p_timprgnt');
    --
    p_timstr            := replace(hcm_util.get_string_t(json_obj,'p_timstr'),':','');
    p_timend            := replace(hcm_util.get_string_t(json_obj,'p_timend'),':','');
    p_flgleave          := hcm_util.get_string_t(json_obj,'p_flgleave');

    p_deslereq          := hcm_util.get_string_t(json_obj,'p_deslereq');
    -- pic
    p_stalereq          := hcm_util.get_string_t(json_obj,'p_stalereq');
    p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'ddmmyyyy');
    p_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
    p_dtecancl          := to_date(hcm_util.get_string_t(json_obj,'p_dtecancl'),'ddmmyyyy');
    p_numlereqg         := hcm_util.get_string_t(json_obj,'p_numlereqg');
    p_dtesave           := to_date(hcm_util.get_string_t(json_obj,'p_dtesave'),'ddmmyyyy');
    p_flgtyp            := hcm_util.get_string_t(json_obj,'p_flgtyp');
    p_filename          := hcm_util.get_string_t(json_obj,'p_filename');

    p_typleave          := hcm_util.get_string_t(json_obj,'p_typleave');

    if p_flgleave = 'A' then
      p_timstr := null;
      p_timend := null;
    end if;

    param_json          := hcm_util.get_json_t(json_obj,'param_json');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
    v_staemp  temploy1.staemp%type;
    v_secur   boolean;
  begin
    if p_dtestr is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_dteend is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_dtestr > p_dteend then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;
    if p_codempid is not null then
      begin
        select codempid, staemp
          into p_codempid, v_staemp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
      --
      if v_staemp like '0' then -- HR2102
        param_msg_error := get_error_msg_php('HR2102',global_v_lang);
        return;
      end if;
      --
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    end if;
    if p_codcomp is not null then
        v_secur := secur_main.secur7(p_codcomp, global_v_coduser);
        if not v_secur then
          param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;
    end if;
  end check_index;

  procedure check_detail as
    v_codleave tleavecd.codleave%type;
    v_typleave tleavcom.typleave%type;
    v_dtework  date;
    v_dayeupd  date;

  begin
    if p_codempid is not null then
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;

    begin
      select codleave into v_codleave
        from tleavecd
       where codleave = p_codleave;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang);
      return;
    end;

    begin
      select typleave
        into v_typleave
        from tleavcom t1,temploy1 t2
       where t2.codempid = p_codempid
         and t1.codcompy = hcm_util.get_codcomp_level(t2.codcomp,1)
         and typleave    = (select typleave from tleavecd where codleave = p_codleave);
    exception when no_data_found then
      param_msg_error := get_error_msg_php('AL0060', global_v_lang, 'tleavcom');
      return;
    end;
  end check_detail;

  procedure check_save as
    v_count     number;
    v_token     varchar2(100 char);
    v_dayeupd   date;
    v_dtecancl  date;
    v_descond   tleavecd.syncond%type;
    v_stmt      varchar2(4000 char);
    v_flgfound  boolean;
    v_numlvl    number;
    v_qtywkday  number;
    json_obj    json_object_t;
    v_codempid  temploy1.codempid%type;
    v_dtestr    date;
    v_dteend    date;
    v_numlereq  tlereqst.numlereq%type;
    v_codleave  tlereqst.codleave%type;
    v_dteprgntst  tlereqst.dteprgntst%type;
    v_dterecod  date;
    v_dteleave  date;
    v_timstr    tlereqst.timstrt%type;
    v_timend    tlereqst.timend%type;
    v_flgleave  tlereqst.flgleave%type;
    v_deslereq  tlereqst.deslereq%type;
    v_stalereq  tlereqst.stalereq%type;
    v_dteappr   date;
    v_codappr   tlereqst.codappr%type;
    v_dtecancl2  date;
    v_filename  tlereqst.filename%type;
    v_numlereqg tlereqst.numlereqg%type;
    v_qtyminle	number;
    v_qtyminrq	number;
    v_codcompy  TCENTER.CODCOMPY%TYPE;
    v_dteempmt  temploy1.dteempmt%type;
    v_dteeffex  temploy1.dteeffex%type;

    v_svyre     number;
    v_svmth     number;
    v_svday     number;
    v_dtestrle  date;
    v_qtyday    number;
    v_yrecycle  number;
    v_dtecycst  date;
    v_dtecycen  date;
    v_dayeupd_t  date;

    v_flgsecu       boolean;
    v_dtestrt       date;
  begin
    for i in 0..param_json.get_size-1 loop
      json_obj := hcm_util.get_json_t(param_json, to_char(i));
      v_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
      v_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
      v_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
      v_numlereq          := hcm_util.get_string_t(json_obj,'p_numlereq');
      v_codleave          := hcm_util.get_string_t(json_obj,'p_codleave');
      v_dterecod          := to_date(hcm_util.get_string_t(json_obj,'p_dterecod'),'ddmmyyyy');
      v_dteleave          := to_date(hcm_util.get_string_t(json_obj,'p_dteleave'),'ddmmyyyy');
      v_timstr            := replace(hcm_util.get_string_t(json_obj,'p_timstr'), ':');
      v_timend            := replace(hcm_util.get_string_t(json_obj,'p_timend'), ':');
      v_flgleave          := hcm_util.get_string_t(json_obj,'p_flgleave');
      v_deslereq          := hcm_util.get_string_t(json_obj,'p_deslereq');
      v_stalereq          := hcm_util.get_string_t(json_obj,'p_stalereq');
      v_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'ddmmyyyy');
      v_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
      v_dtecancl          := to_date(hcm_util.get_string_t(json_obj,'p_dtecancl'),'ddmmyyyy');
      v_filename          := hcm_util.get_string_t(json_obj,'p_filename');
      v_numlereqg         := hcm_util.get_string_t(json_obj,'p_numlereqg');
      v_dteprgntst        := to_date(hcm_util.get_string_t(json_obj,'p_dteprgntst'),'ddmmyyyy');
      v_dayeupd_t         := to_date(hcm_util.get_string_t(json_obj,'p_dayeupd'),'ddmmyyyy');
      if v_codleave is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      if v_codempid is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      if v_dterecod is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      if v_dteleave is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      if v_stalereq is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      if v_codappr is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      if v_dteappr is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      if v_flgleave is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
          return;
      end if;
      if v_flgleave is not null then
          if v_flgleave = 'A' then
              if v_dtestr is null or v_dteend is null then
                  param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                  return;
              end if;
          elsif v_flgleave = 'H' then
              if v_dtestr is null or v_dteend is null or v_timstr is null or v_timend is null then
                  param_msg_error := get_error_msg_php('HR2045',global_v_lang);
                  return;
              end if;
          end if;
      end if;
      if v_stalereq = 'C' then
          if v_dtecancl is null then
              param_msg_error := get_error_msg_php('HR2045',global_v_lang);
              return;
          end if;
          if not (v_dtecancl between v_dtestr and v_dteend) then
              param_msg_error := get_error_msg_php('AL0025',global_v_lang);
              return;
          end if;
          if v_dtecancl <= v_dayeupd_t then
              param_msg_error := get_error_msg_php('AL0026',global_v_lang);
              return;
          end if;
      else
          v_dtecancl := null;
      end if;
      if v_dtestr is not null and v_dteend is not null and
         v_timstr is not null and v_timend is not null and
         (v_dtestr = v_dteend and v_timstr = v_timend) then
        param_msg_error := get_error_msg_php('HR2020',global_v_lang);
        return;
      end if;
      if v_dtestr > v_dteend then
          param_msg_error := get_error_msg_php('HR2021',global_v_lang);
          return;
      end if;
      if v_codleave is not null then
          begin
              select  syncond
              into    v_descond
              from    tleavecd
              where   codleave = v_codleave;
          exception when no_data_found then null;
          end;
      end if;
      v_token := null;
      if v_flgleave = 'A' then
        v_timstr := null;
        v_timend  := null;
      end if;
      hral56b_batch.gen_entitlement(v_codempid  ,v_numlereq ,v_dayeupd  ,v_flgleave,
                      v_codleave  ,v_dteleave ,v_dtestr   ,v_timstr,
                      v_dteend    ,v_timend,
                      v_dteprgntst,
                      0          ,global_v_coduser,
                      v_token     ,v_count    ,v_count    ,v_count,
                      v_count     ,v_count    ,v_count    ,v_qtyminle,
                      v_qtyminrq  ,v_count);
      if v_token is not null then
          param_msg_error := get_error_msg_php(v_token,global_v_lang);
          return;
      end if;
    end loop;
  end check_save;
  --
  procedure check_warning is
    json_obj        json_object_t;
    param_row_file  json_object_t;
    att_param_json  json_object_t;
    att_param_rows  json_object_t;
    v_flgsecu       boolean;
    v_dtestrt       date;
    v_dteend        date;
    v_dterecod      date;
    v_dteleave      date;
    v_dteappr       date;
    v_dtecancl      date;
    v_qtydlefw      tleavecd.qtydlefw%type;
    v_qtydlebw      tleavecd.qtydlebw%type;
    v_dtefw         date;
    v_dteaw         date;
    v_timstr    tlereqst.timstrt%type;
    v_timend    tlereqst.timend%type;
    v_flgleave  tlereqst.flgleave%type;
    v_deslereq  tlereqst.deslereq%type;
    v_stalereq  tlereqst.stalereq%type;
    v_flgdlebw      varchar2(2 char);
    v_flgdlefw      varchar2(2 char);
    v_codleave      tleavecdatt.codleave%type;
    v_numseq        tleavecdatt.numseq%type;
    v_attachname    tlereqattch.filename%type;
    v_flgattach     tleavecdatt.flgattach%type;
    v_codempid      tlereqst.codempid%type;
    v_numlereq      varchar2(100 char);
    v_codappr       varchar2(100 char);
    v_filename      varchar2(100 char);
    v_numlereqg     varchar2(100 char);
  begin
    for i in 0..param_json.get_size-1 loop
      json_obj            := hcm_util.get_json_t(param_json, to_char(i));
      v_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
      v_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
      v_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
      v_numlereq          := hcm_util.get_string_t(json_obj,'p_numlereq');
      v_codleave          := hcm_util.get_string_t(json_obj,'p_codleave');
      v_dterecod          := to_date(hcm_util.get_string_t(json_obj,'p_dterecod'),'ddmmyyyy');
      v_dteleave          := to_date(hcm_util.get_string_t(json_obj,'p_dteleave'),'ddmmyyyy');
      v_timstr            := replace(hcm_util.get_string_t(json_obj,'p_timstr'), ':');
      v_timend            := replace(hcm_util.get_string_t(json_obj,'p_timend'), ':');
      v_flgleave          := hcm_util.get_string_t(json_obj,'p_flgleave');
      v_deslereq          := hcm_util.get_string_t(json_obj,'p_deslereq');
      v_stalereq          := hcm_util.get_string_t(json_obj,'p_stalereq');
      v_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'ddmmyyyy');
      v_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
      v_dtecancl          := to_date(hcm_util.get_string_t(json_obj,'p_dtecancl'),'ddmmyyyy');
      v_filename          := hcm_util.get_string_t(json_obj,'p_filename');
      v_numlereqg         := hcm_util.get_string_t(json_obj,'p_numlereqg');
      param_flgwarn       := hcm_util.get_string_t(json_obj,'p_flgwarning');
      att_param_json      := hcm_util.get_json_t(json_obj,'param_json');
      att_param_rows      := hcm_util.get_json_t(att_param_json,'rows');

      begin
        select qtydlefw,qtydlebw
          into v_qtydlefw,v_qtydlebw
          from tleavecd
         where codleave = v_codleave;
      exception when no_data_found then null;
      end;
      if v_dteleave >= v_dterecod and param_flgwarn = 'S' then
        if v_qtydlefw is not null then
          v_dtefw := v_dterecod + nvl(v_qtydlefw,0);
          if v_dteleave < v_dtefw then
            param_msg_error := get_error_msg_php('AL0047',global_v_lang);
            param_flgwarn := 'WARN1';
            return;
          end if;
        end if;
      elsif v_dteleave < v_dterecod and param_flgwarn = 'S' then
        if v_qtydlebw is not null then
          v_dteaw := v_dterecod - nvl(v_qtydlebw,0);
          v_flgdlebw := check_leave_after(v_codempid,v_dterecod,v_dteleave,nvl(v_qtydlebw,0));
          if v_flgdlebw = 'N' then
            param_msg_error := get_error_msg_php('AL0048',global_v_lang);
            param_flgwarn := 'WARN1';
            return;
          end if;
        end if;
      end if;
      if param_flgwarn = 'S' then
        param_flgwarn := 'WARN1';
      end if;
      if param_flgwarn = 'WARN1' then
        for i in 0..att_param_rows.get_size-1 loop
          param_row_file := json_object_t(att_param_rows.get(to_char(i)));
          v_codleave     := hcm_util.get_string_t(param_row_file,'codleave');
          v_numseq       := hcm_util.get_string_t(param_row_file,'numseq');
          v_attachname   := hcm_util.get_string_t(param_row_file,'attachname');
          v_flgattach    := hcm_util.get_string_t(param_row_file,'flgattach');

          if v_flgattach = 'Y' and v_attachname is null then
            param_msg_error := get_error_msg_php('HR2045',global_v_lang);
            param_flgwarn := 'WARN2';
          end if;
        end loop;
      end if;
    end loop;
  end;

  function check_leave_after(p_codempid varchar2,p_dtereq date,p_dteleave date,p_daydelay number) return varchar2 is
    v_flgworkth 	varchar2(10);
    v_date				date := p_dteleave + 1;
    v_codcompy  	tattence.codcomp%type;
    v_codcalen  	tattence.codcalen%type;
    v_typwork		  tattence.typwork%type;
    v_dtein				tattence.dtein%type;
    v_dteout			tattence.dteout%type;
    v_daydelay		number := 0;

  begin
    if p_dtereq is null or p_dteleave is null or p_daydelay is null then
      return 'Y';
    end if;
    if p_dtereq < v_date then
      return 'Y';
    end if;
    --
    loop
      begin
        select hcm_util.get_codcomp_level(a.codcomp,'1'),a.codcalen,a.typwork,a.dtein,a.dteout
          into v_codcompy,v_codcalen,v_typwork,v_dtein,v_dteout
          from tattence a
         where a.codempid = p_codempid
           and a.dtework  = v_date;
      exception when no_data_found then null;
      end;
      if p_dtereq < trunc(sysdate) then
        if (v_typwork = 'W') then
          v_daydelay := v_daydelay + 1;
        end if;
      else
        if (v_typwork = 'W') then
          v_daydelay := v_daydelay + 1;
        end if;
      end if;
      --
      if v_date >= p_dtereq or v_daydelay >= p_daydelay then
        exit;
      end if;
      v_date := v_date + 1;
    end loop;
    --
    if p_dtereq > v_date or v_daydelay > p_daydelay then
      return 'N';
    else
      return 'Y';
    end if;
  end;

  --
/*  function check_times (p_time in varchar2) return boolean is
    v_stmt			varchar2(500);
    v_time			varchar2(4);
  begin
    v_stmt := 'select to_char(to_date('''||p_time||
              ''',''hh24mi''),''hh24mi'') from dual';
    v_time := execute_desc(v_stmt);
    if v_time is null then
      return(false);
    else
      return(true);
    end if;
  end;

  function check_date (p_date in varchar2, p_zyear in number) return boolean is
    v_date		date;
    v_error		boolean := false;
  begin
    if p_date is not null then
      begin
        v_date := to_date(p_date,'dd/mm/yyyy');
      exception when others then
        v_error := true;
        return(v_error);
      end;
    end if;
    return(v_error);
  end;

  function check_dteyre (p_date in varchar2)
  return date is
    v_date		date;
    v_error		boolean := false;
    v_year    number;
    v_daymon	varchar2(30);
    v_text		varchar2(30);
    p_zyear		number;
    chkreg 		varchar2(30);
  begin
     begin
      select value into chkreg
      from v$nls_parameters where parameter = 'NLS_CALENDAR';
      if chkreg = 'Thai Buddha' then
        if to_number(substr(p_date,-4,4)) > 2500 then
          p_zyear := 0;
        else
          p_zyear := 543;
       end if;
      else
       if to_number(substr(p_date,-4,4)) > 2500 then
          p_zyear := -543;
       else
          p_zyear := 0;
       end if;
      end if;
    end;

    if p_date is not null then
      -- plus year --
      v_year			:= substr(p_date,-4,4);
      v_year			:= v_year + p_zyear;
      v_daymon		:= substr(p_date,1,length(p_date)-4);
      v_text			:= v_daymon||to_char(v_year);
      v_year      := null;
      v_daymon    := null;
      -- plus year --
      v_date := to_date(v_text,'dd/mm/yyyy');
    end if;

    return(v_date);
  end;
*/
  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);

      --2998
      if param_msg_error is not null then
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
            return;
      end if;
      --2998
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    json_obj json_object_t;
    json_row json_object_t;
    v_count  number := 0;
    v_found  number := 0;
    v_secur1    boolean;
    v_secur2    boolean;
    v_str_date  varchar2(100 char);
    cursor c1 is
        select  numlereq,codempid,codleave,dtestrt,timstrt,dteend,timend,stalereq,codcomp
        from    tlereqst
        where   codempid = nvl(p_codempid,codempid)
        and     codcomp like p_codcomp || '%'
        and    (dtestrt between p_dtestr and p_dteend
        or      dteend between p_dtestr and p_dteend
        or      p_dtestr between dtestrt and dteend
        or      p_dteend between dtestrt and dteend)
        order by numlereq;
  begin
    json_obj := json_object_t();
    for r1 in c1 loop
      v_found := 1;
      v_secur1 := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if v_secur1 then
        json_row := json_object_t();
        json_row.put('numlereq',r1.numlereq);
        json_row.put('image',get_emp_img (r1.codempid));
        json_row.put('codempid',r1.codempid);
        json_row.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        json_row.put('codleave',r1.codleave);
        json_row.put('desc_codleave',r1.codleave ||' - '||get_tleavecd_name(r1.codleave,global_v_lang));
        v_str_date := to_char(r1.dtestrt,'dd/mm/yyyy') || '  ' ||to_char(to_date(r1.timstrt,'hh24mi'),'hh24:mi');
        json_row.put('dtetimstr',v_str_date);
        v_str_date := to_char(r1.dteend ,'dd/mm/yyyy') || '  ' ||to_char(to_date(r1.timend ,'hh24mi'),'hh24:mi');
        json_row.put('dtetimend',v_str_date);
        json_row.put('stalereq',get_tlistval_name('NAMLSTAT',r1.stalereq,global_v_lang));
        json_row.put('coderror','200');

        json_obj.put(to_char(v_count),json_row);
        v_count := v_count + 1;
      end if;
    end loop;
    json_str_output := json_obj.to_clob;
    if v_found <> 0 and v_count = 0 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;
  --
  procedure get_detail(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail;
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure gen_detail(json_str_output out clob) as
    json_obj        json_object_t;
    json_row_att    json_object_t;
    json_obj_att    json_object_t;
    v_rcnt          number := 0;
    v_codempid      tlereqst.codempid%type;
    v_codcomp       tlereqst.codcomp%type;
    v_codleave      tlereqst.codleave%type;
    v_typleave      tleavecd.typleave%type;
    v_flgleave      tlereqst.flgleave%type;
    v_flgleave_cd   tlereqst.flgleave%type;
    v_numlereqg     tlereqst.numlereqg%type;
    v_codappr       tlereqst.codappr%type;
    v_dtestrt       date;
    v_timstrt       tlereqst.timstrt%type;
    v_dteend        date;
    v_timend        tlereqst.timend%type;
    v_stalereq      tlereqst.stalereq%type;
    v_dterecod      date;
    v_dayeupd       date;
    v_dteappr       date;
    v_dtecancl      date;
    v_deslereq      tlereqst.deslereq%type;
    v_dteleave      date;
    v_pathfile      varchar2(1000 char);
    v_namfile       tlereqst.filename%type;
    v_flg				    varchar2(10 char);
    v_folder        varchar2(100 char);
    v_host_folder   varchar2(200 char):= get_tsetup_value('PATHWORKPHP');

    v_codshift      tattence.codshift%type;
    v_timstrtw      tattence.timstrtw%type;
    v_timendw       tattence.timendw%type;
    --
    v_token         varchar2(100 char);
    v_flgstat       varchar2(10 char) := 'edit';

--    v_namleavcd     varchar2(4000 char);
    v_namleavty     tleavety.namleavtye%type;
    v_flgdlemx      tleavety.flgdlemx%type;

    v_coderr        varchar2(100 char);
    v_qtyday1       number;
    v_qtyday2       number;
    v_qtyday3       number;
    v_qtyday4       number;
    v_qtyday5       number;
    v_qtyday6       number;
    v_qtyavgwk      number;
    v_token1        number;
    v_token2        number;
    v_token3        number;
    v_qtyminrq	    number;
    v_qtyminle	    number;
    --
    v_dtecycen      date;
    v_dtecycst      date;
    v_yrecycle      number;
    v_qtytime       number;
    -- paternity leave --
    v_dteprgntst    date;
    v_timprgnt      varchar2(100 char);
    flg_chgleave    boolean := false;
    v_count_lvprgnt number  := 0;
    v_flgtype       varchar2(2 char);
    v_dtework       tlereqd.dtework%type;
    v_dayeupd_c     tlereqd.dayeupd%type;

    cursor c_leave_addnew is
      select filename, numseq, flgattach
        from tleavecdatt
       where codleave = v_codleave
      order by numseq;

    cursor c_leave_edit is
      select b.filename, nvl(b.numseq,c.numseq) numseq, c.filename filedesc,
              nvl(b.flgattach,c.flgattach) flgattach
        from tlereqattch b, tleavecdatt c
      where  c.numseq       = b.numseq(+)
        and  c.codleave     = b.codleave(+)
        and  c.codleave     = v_codleave
        and  b.numlereq(+)  = p_numlereq
      order by numseq;

  begin
    json_obj := json_object_t();
    begin
      select  codempid, codleave, dtestrt, timstrt, dteend, timend,
              stalereq, dterecod, dayeupd, deslereq, dteappr, dtecancl,
              filename, numlereqg, codappr, dteleave, flgleave, codcomp,dteprgntst
        into  v_codempid, v_codleave, v_dtestrt, v_timstrt, v_dteend, v_timend,
              v_stalereq, v_dterecod, v_dayeupd, v_deslereq, v_dteappr, v_dtecancl,
              v_namfile, v_numlereqg, v_codappr, v_dteleave, v_flgleave, v_codcomp,v_dteprgntst
        from  tlereqst
       where  numlereq = p_numlereq;

      /*if not secur_main.secur7(v_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      end if;*/

      -- check codleave change --
      if p_codleave != v_codleave then
        flg_chgleave := true;
      end if;
    exception when no_data_found then
      if p_numlereq is null then
        v_codempid := p_codempid;
        v_codleave := p_codleave;
        v_dterecod := p_dterecod;
        v_dteleave := sysdate;
        v_stalereq := 'A';
        v_dteappr  := sysdate;
        v_codappr  := global_v_codempid;
        v_flgstat  := 'add';
        v_dteend    := trunc(sysdate);
      else
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tlereqst');
      end if;
    end;

    v_dteleave := TO_DATE(TO_CHAR(v_dteleave, 'YYYY-MM-DD'), 'YYYY-MM-DD');
    --
    if param_msg_error is null then
      begin
        select typleave, flgleave
          into v_typleave, v_flgleave_cd
          from tleavecd
         where codleave = v_codleave;
      exception when no_data_found then
        v_typleave := null;
        v_flgleave := null;
      end;
      if v_flgstat = 'add' then
        v_flgleave := v_flgleave_cd;
      end if;

      begin
        select FLGTYPE
          into v_flgtype
          from TLEAVETY
         where TYPLEAVE  = v_typleave;
      exception when no_data_found then
        v_flgtype := null;
      end;
      -- paternity leave --
      if v_flgtype = 'M' then
        begin
          select dteprgntst into v_dteprgntst
            from temploy1
           where codempid = v_codempid
             and v_dteleave between add_months(dteprgntst, -9) and dteprgntst;
        exception when others then
          v_dteprgntst := null;
        end;
        json_obj.put('timprgnt' ,nvl(v_timprgnt,1));
        json_obj.put('flglvprgnt','Y');
      else
        json_obj.put('flglvprgnt','N');
        json_obj.put('timprgnt' ,v_timprgnt);
      end if;
      json_obj.put('dteprgntst' ,to_char(v_dteprgntst,'dd/mm/yyyy'));
      --

      json_obj.put('numlereq' ,p_numlereq);
      json_obj.put('codempid' ,v_codempid);
      json_obj.put('codleave' ,v_codleave);
      json_obj.put('dteleave' ,to_char(v_dteleave,'dd/mm/yyyy'));

      --
      json_obj.put('typleave' ,v_typleave);
      json_obj.put('flgleave' ,v_flgleave);
      json_obj.put('dtestrt'  ,to_char(v_dtestrt,'dd/mm/yyyy'));
      json_obj.put('dteend'   ,to_char(v_dteend ,'dd/mm/yyyy'));
      json_obj.put('dayeupd'  ,to_char(v_dayeupd,'dd/mm/yyyy'));
      json_obj.put('timstrt'  ,to_char(to_date(v_timstrt,'miss'),'mi:ss'));
      json_obj.put('timend'   ,to_char(to_date(v_timend ,'miss'),'mi:ss'));
      json_obj.put('stalereq' ,v_stalereq);
      json_obj.put('deslereq' ,v_deslereq);
      -- Path File --
      v_pathfile := v_host_folder || v_folder || '/' || v_namfile;
      if v_namfile is null then
          v_pathfile := null;
      end if;
      json_obj.put('pathfile' ,v_pathfile);
      json_obj.put('filename' ,v_namfile);
      ---------------
      json_obj.put('dteappr'  ,to_char(v_dteappr ,'dd/mm/yyyy'));
      json_obj.put('dtecancl' ,to_char(v_dtecancl,'dd/mm/yyyy'));
      json_obj.put('dterecod' ,to_char(v_dterecod,'dd/mm/yyyy'));
      json_obj.put('numlereqg',v_numlereqg);
      json_obj.put('codappr',v_codappr);
      json_obj.put('desc_codappr',get_temploy_name(v_codappr,global_v_lang));
      -- enabled flag leave edit --
      begin
        select flgleave into v_flg
          from tleavecd
         where codleave = nvl(v_codleave,p_codleave);
      exception when others then
          v_flg  := null;
      end;
      if v_flg = 'A' then
        json_obj.put('flgleave_r2','F');
        json_obj.put('flgleave_r3','F');
        json_obj.put('flgleave_r4','F');
        json_obj.put('flgleave_r1','T');
      elsif v_flg = 'F' then
        json_obj.put('flgleave_r4','F');
        json_obj.put('flgleave_r2','T');
        json_obj.put('flgleave_r3','T');
        json_obj.put('flgleave_r1','T');
      elsif v_flg = 'H' then
        json_obj.put('flgleave_r1','T');
        json_obj.put('flgleave_r2','T');
        json_obj.put('flgleave_r3','T');
        json_obj.put('flgleave_r4','T');
      else
        json_obj.put('flgleave_r1','T');
        json_obj.put('flgleave_r2','T');
        json_obj.put('flgleave_r3','T');
        json_obj.put('flgleave_r4','T');
      end if;

      if v_flgleave = 'A' then
        v_timstrt := null;
        v_timend  := null;
      end if;
      hral56b_batch.gen_entitlement(v_codempid  ,p_numlereq     ,v_dayeupd,   -- input
                                    v_flgleave  ,v_codleave     ,v_dteleave,
                                    v_dtestrt   ,v_timstrt      ,v_dteend,  v_timend    ,
                                    v_dteprgntst,
                                    0              ,global_v_coduser,
                                    v_coderr    ,v_qtyday1      ,v_qtyday2,         -- output
                                    v_qtyday3   ,v_qtyday4      ,v_qtyday5,
                                    v_qtyday6   ,v_qtyminle     ,v_qtyminrq    ,v_qtyavgwk);

      hcm_util.cal_dhm_hm(v_qtyday1,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
      json_obj.put('qtyday2dd',v_token1);
      json_obj.put('qtyday2hr',v_token2);
      json_obj.put('qtyday2mi',v_token3);
      hcm_util.cal_dhm_hm(v_qtyday2,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
      json_obj.put('qtyday3dd',v_token1);
      json_obj.put('qtyday3hr',v_token2);
      json_obj.put('qtyday3mi',v_token3);
      hcm_util.cal_dhm_hm(v_qtyday3,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
      json_obj.put('qtyday4dd',v_token1);
      json_obj.put('qtyday4hr',v_token2);
      json_obj.put('qtyday4mi',v_token3);
      hcm_util.cal_dhm_hm(v_qtyday4,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
      json_obj.put('qtyday5dd',v_token1);
      json_obj.put('qtyday5hr',v_token2);
      json_obj.put('qtyday5mi',v_token3);
      hcm_util.cal_dhm_hm(v_qtyday5,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
      json_obj.put('qtyday6dd_1',v_token1);
      json_obj.put('qtyday6hr_1',v_token2);
      json_obj.put('qtyday6mi_1',v_token3);
      hcm_util.cal_dhm_hm(v_qtyday6,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
      json_obj.put('qtyday6dd_2',v_token1);
      json_obj.put('qtyday6hr_2',v_token2);
      json_obj.put('qtyday6mi_2',v_token3);
      if v_flgstat = 'edit' then
        begin
          select  timstrtw,timendw,codshift
          into    v_timstrtw,v_timendw,v_codshift
          from    tattence
          where   codempid = v_codempid
          and     dtework  = v_dteleave;
          v_token := to_char(to_date(v_timstrtw,'miss'),'mi:ss') || ' - ' ||
                     to_char(to_date(v_timendw ,'miss'),'mi:ss');
          json_obj.put('timstrend',v_token);
          json_obj.put('codshift',v_codshift);
        exception when others then
          null;
        end;
      end if;
      --
      begin
        select  flgdlemx,
                decode(global_v_lang,'101',namleavtye,
                                     '102',namleavtyt,
                                     '103',namleavty3,
                                     '104',namleavty4,
                                     '105',namleavty5) namleavty
          into    v_flgdlemx,v_namleavty
          from    tleavety
          where   typleave = v_typleave;
      exception when no_data_found then
        v_flgdlemx  := null;
        v_namleavty := null;
      end;

      --
      json_obj.put('desc_typeleave',v_namleavty);
      json_obj.put('flgdlemx',v_flgdlemx);
      json_obj.put('desc_flgdlemx',get_tlistval_name('LVLIMIT',v_flgdlemx,global_v_lang));
      json_obj.put('flgstat', v_flgstat);
      --
      json_obj.put('qtytime',v_qtyminle);
      json_obj.put('qtyminrq',v_qtyminrq);

      --
      json_obj.put('coderror','200');

      -- get attachment document --
      json_row_att     := json_object_t();
      if v_flgstat = 'add' or flg_chgleave then
        for r1 in c_leave_addnew loop
          json_obj_att := json_object_t();
          json_obj_att.put('codleave',v_codleave);
          json_obj_att.put('numseq',r1.numseq);
          json_obj_att.put('filename',r1.filename);
          json_obj_att.put('attachname','');
          json_obj_att.put('flgattach',r1.flgattach);

          json_row_att.put(to_char(v_rcnt),json_obj_att);
          v_rcnt := v_rcnt + 1;
        end loop;
      elsif v_flgstat = 'edit' then
        for r1 in c_leave_edit loop
          json_obj_att := json_object_t();
          json_obj_att.put('codleave',v_codleave);
          json_obj_att.put('numseq',r1.numseq);
          json_obj_att.put('filename',r1.filedesc);
          json_obj_att.put('attachname',r1.filename);
          json_obj_att.put('flgattach',r1.flgattach);

          json_row_att.put(to_char(v_rcnt),json_obj_att);
          v_rcnt := v_rcnt + 1;
        end loop;
      end if;
      json_obj.put('document_att',json_row_att);
      if v_dayeupd is not null and (v_dayeupd >= nvl(v_dtecancl, v_dteend)) then
        json_obj.put('flgupd','N');
      end if;
      json_str_output := json_obj.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  procedure get_detail_numlereq(json_str_input in clob,json_str_output out clob) as
    json_obj        json_object_t;
    v_codempid      tlereqst.codempid%type;
    v_codleave      tlereqst.codleave%type;
    v_typleave      tleavety.typleave%type;
    v_flgleave      tlereqst.flgleave%type;
    v_numlereqg     tlereqst.numlereqg%type;
    v_codappr       tlereqst.codappr%type;
    v_dtestrt       date;
    v_timstrt       tlereqst.timstrt%type;
    v_dteend        date;
    v_timend        tlereqst.timend%type;
    v_stalereq      tlereqst.stalereq%type;
    v_dterecod      date;
    v_dayeupd       date;
    v_dteappr       date;
    v_dtecancl      date;
    v_deslereq      tlereqst.deslereq%type;
    v_dteleave      date;
    v_pathfile      varchar2(1000 char);
    v_namfile       tlereqst.filename%type;
    v_flg				    varchar2(10 char);
    v_folder        varchar2(100 char);
    v_host_folder   varchar2(200 char):= get_tsetup_value('PATHWORKPHP');

    v_codshift      tattence.codshift%type;
    v_timstrtw      tattence.timstrtw%type;
    v_timendw       tattence.timendw%type;
    --
    v_token         varchar2(100 char);
    v_flgstat       varchar2(10 char) := 'edit';

--    v_namleavcd     varchar2(4000 char);
    v_namleavty     tleavety.namleavtye%type;
    v_flgdlemx      tleavety.flgdlemx%type;
    v_flgtype      tleavety.flgtype%type;
    --
    v_coderr        varchar2(100 char);
    v_qtyday1       number;
    v_qtyday2       number;
    v_qtyday3       number;
    v_qtyday4       number;
    v_qtyday5       number;
    v_qtyday6       number;
    v_qtyavgwk      number;
    v_token1        number;
    v_token2        number;
    v_token3        number;
    v_qtytime       number;
    v_codcompy      tcenter.codcompy%type;
    v_dtecycen      date;
    v_dtecycst      date;
    v_qtyminrq	    number;
    v_qtyminle	    number;
    v_yrecycle      number;
    -- paternity leave --
    v_dteprgntst    date;
    v_timprgnt      varchar2(100 char);
  begin
    initial_value(json_str_input);
    json_obj := json_object_t();
    begin
      select  codempid, codleave, dtestrt, timstrt, dteend, timend,
              stalereq, dterecod, dayeupd, deslereq, dteappr, dtecancl,
              filename, numlereqg, codappr, dteleave, flgleave,dteprgntst
        into  v_codempid, v_codleave, v_dtestrt, v_timstrt, v_dteend, v_timend,
              v_stalereq, v_dterecod, v_dayeupd, v_deslereq, v_dteappr, v_dtecancl,
              v_namfile, v_numlereqg, v_codappr, v_dteleave, v_flgleave,v_dteprgntst
        from  tlereqst
       where  numlereq = p_numlereq;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
    end;
    if param_msg_error is null then
      begin
        select typleave
          into v_typleave
          from tleavecd
         where codleave = v_codleave;
        exception when no_data_found then
        v_typleave := null;
      end;
      --
      json_obj.put('numlereq' ,p_numlereq);
      json_obj.put('codempid' ,v_codempid);
      json_obj.put('codleave' ,v_codleave);
      json_obj.put('dteleave' ,to_char(v_dteleave,'dd/mm/yyyy'));
      json_obj.put('typleave' ,v_typleave);
      json_obj.put('flgleave' ,v_flgleave);
      json_obj.put('dtestrt'  ,to_char(v_dtestrt,'dd/mm/yyyy'));
      json_obj.put('dteend'   ,to_char(v_dteend ,'dd/mm/yyyy'));
      json_obj.put('dayeupd'  ,to_char(v_dayeupd,'dd/mm/yyyy'));
      json_obj.put('timstrt'  ,to_char(to_date(v_timstrt,'miss'),'mi:ss'));
      json_obj.put('timend'   ,to_char(to_date(v_timend ,'miss'),'mi:ss'));
      json_obj.put('stalereq' ,v_stalereq);
      json_obj.put('deslereq' ,v_deslereq);
      json_obj.put('flgstat', v_flgstat);
      -- paternity leave --
      json_obj.put('timprgnt' ,v_timprgnt);
      json_obj.put('dteprgntst' ,to_char(v_dteprgntst,'dd/mm/yyyy'));
      --
      -- Path File --
      v_pathfile := v_host_folder || v_folder || '/' || v_namfile;
      if v_namfile is null then
          v_pathfile := null;
      end if;
      json_obj.put('pathfile' ,v_pathfile);
      json_obj.put('filename' ,v_namfile);
      ---------------
      json_obj.put('dteappr'  ,to_char(v_dteappr ,'dd/mm/yyyy'));
      json_obj.put('dtecancl' ,to_char(v_dtecancl,'dd/mm/yyyy'));
      json_obj.put('dterecod' ,to_char(v_dterecod,'dd/mm/yyyy'));
      json_obj.put('numlereqg',v_numlereqg);
      json_obj.put('codappr',v_codappr);
      json_obj.put('desc_codappr',get_temploy_name(v_codappr,global_v_lang));
      -- enabled flag leave edit --
      begin
        select flgleave into v_flg
          from tleavecd
         where codleave = nvl(v_codleave,p_codleave);
      exception when others then
        v_flg  := null;
      end;
      if v_flg = 'A' then
        json_obj.put('flgleave_r2','F');
        json_obj.put('flgleave_r3','F');
        json_obj.put('flgleave_r4','F');
        json_obj.put('flgleave_r1','T');
      elsif v_flg = 'F' then
        json_obj.put('flgleave_r4','F');
        json_obj.put('flgleave_r2','T');
        json_obj.put('flgleave_r3','T');
        json_obj.put('flgleave_r1','T');
      elsif v_flg = 'H' then
        json_obj.put('flgleave_r1','T');
        json_obj.put('flgleave_r2','T');
        json_obj.put('flgleave_r3','T');
        json_obj.put('flgleave_r4','T');
      else
        json_obj.put('flgleave_r1','T');
        json_obj.put('flgleave_r2','T');
        json_obj.put('flgleave_r3','T');
        json_obj.put('flgleave_r4','T');
      end if;
      begin
        select  flgdlemx,flgtype,
                  decode(global_v_lang,'101',namleavtye,
                                       '102',namleavtyt,
                                       '103',namleavty3,
                                       '104',namleavty4,
                                       '105',namleavty5) namleavty
          into    v_flgdlemx,v_flgtype,v_namleavty
          from    tleavety
          where   typleave = v_typleave;
      exception when no_data_found then
        v_flgdlemx  := null;
        v_namleavty := null;
      end;
      json_obj.put('desc_typeleave',v_namleavty);
      json_obj.put('flgdlemx',v_flgdlemx);
      json_obj.put('desc_flgdlemx',get_tlistval_name('LVLIMIT',v_flgdlemx,global_v_lang));
      --
      if v_flgtype = 'M' then
        json_obj.put('flglvprgnt','Y');
      else
        json_obj.put('flglvprgnt','N');
      end if;
      --
      begin
        select  timstrtw,timendw,codshift
        into    v_timstrtw,v_timendw,v_codshift
        from    tattence
        where   codempid = v_codempid
        and     dtework  = v_dteleave;
        v_token := to_char(to_date(v_timstrtw,'miss'),'mi:ss') || ' - ' ||
                   to_char(to_date(v_timendw ,'miss'),'mi:ss');
        json_obj.put('timstrend',v_token);
        json_obj.put('codshift',v_codshift);
      exception when no_data_found then
          null;
      end;
      --
      begin
        select  flgleave
        into    v_flgleave
        from    tleavecd
        where   codleave = v_codleave;
      exception when no_data_found then
          v_flgleave  := null;
      end;
      if v_flgleave = 'A' then
        v_timstrt := null;
        v_timend  := null;
      end if;
      hral56b_batch.gen_entitlement(v_codempid  ,p_numlereq     ,v_dayeupd,   -- input
                                    v_flgleave  ,v_codleave     ,v_dteleave,
                                    v_dtestrt   ,v_timstrt     ,v_dteend,
                                    v_timend    ,v_dteprgntst,
                                    0           ,global_v_coduser,
                                    v_coderr    ,v_qtyday1      ,v_qtyday2,         -- output
                                    v_qtyday3   ,v_qtyday4      ,v_qtyday5,
                                    v_qtyday6   ,v_qtyminle     ,v_qtyminrq    ,v_qtyavgwk);

      hcm_util.cal_dhm_hm(v_qtyday1,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
      json_obj.put('qtyday2dd',v_token1);
      json_obj.put('qtyday2hr',v_token2);
      json_obj.put('qtyday2mi',v_token3);
      hcm_util.cal_dhm_hm(v_qtyday2,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
      json_obj.put('qtyday3dd',v_token1);
      json_obj.put('qtyday3hr',v_token2);
      json_obj.put('qtyday3mi',v_token3);
      hcm_util.cal_dhm_hm(v_qtyday3,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token); --08/03/2021 3 ?
      json_obj.put('qtyday4dd',v_token1);
      json_obj.put('qtyday4hr',v_token2);
      json_obj.put('qtyday4mi',v_token3);
      hcm_util.cal_dhm_hm(v_qtyday4,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token); --08/03/2021 4 ?
      json_obj.put('qtyday5dd',v_token1);
      json_obj.put('qtyday5hr',v_token2);
      json_obj.put('qtyday5mi',v_token3);
      hcm_util.cal_dhm_hm(v_qtyday5,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
      json_obj.put('qtyday6dd_1',v_token1);
      json_obj.put('qtyday6hr_1',v_token2);
      json_obj.put('qtyday6mi_1',v_token3);
      hcm_util.cal_dhm_hm(v_qtyday6,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
      json_obj.put('qtyday6dd_2',v_token1);
      json_obj.put('qtyday6hr_2',v_token2);
      json_obj.put('qtyday6mi_2',v_token3);
      v_qtytime := 0;
      begin
          select  t1.codcompy
          into    v_codcompy
          from    tcenter t1 , temploy1 t2
          where   t1.codcomp = t2.codcomp
          and     t2.codempid = v_codempid;
      exception when no_data_found then
          v_codcompy := null;
      end;
      json_obj.put('qtytime',v_qtyminle);
      json_obj.put('qtyminrq',v_qtyminrq);
      if v_dayeupd is not null and (v_dayeupd >= nvl(v_dtecancl, v_dteend)) then
        json_obj.put('flgupd','N');
      end if;
      --
      json_obj.put('coderror','200');

      json_str_output := json_obj.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_codshift_time(json_str_input in clob,json_str_output out clob) as
    json_obj        json_object_t;
    v_codshift      tattence.codshift%type;
    v_timstrtw      tattence.timstrtw%type;
    v_timendw       tattence.timendw%type;
    v_timstrtw_cd   tattence.timstrtw%type;
    v_timendw_cd    tattence.timendw%type;
    v_timstrtb_cd   tshiftcd.timstrtb%type;
    v_timendb_cd    tshiftcd.timendb%type;

    m_dtestrt       varchar2(100 char);
    m_dteend        varchar2(100 char);
    e_dtestrt       varchar2(100 char);
    e_dteend        varchar2(100 char);
    m_timstrt       varchar2(100 char);
    m_timend        varchar2(100 char);
    e_timstrt       varchar2(100 char);
    e_timend        varchar2(100 char);
    v_desshift      varchar2(100 char);
    v_m_dtestrt     date;
    v_m_dteend      date;
    v_e_dtestrt     date;
    v_e_dteend      date;
    v_m_timstrt     date;
    v_m_timend      date;
    v_e_timstrt     date;
    v_e_timend      date;

  begin
    initial_value(json_str_input);
    json_obj := json_object_t();

    begin
      select timstrtw, timendw, codshift
        into v_timstrtw, v_timendw, v_codshift
        from tattence
       where codempid = p_codempid
         and dtework = p_dteleave;

      v_desshift := to_char(to_date(v_timstrtw, 'miss'), 'mi:ss') || ' - ' || to_char(to_date(v_timendw, 'miss'), 'mi:ss');
      json_obj.put('desshift', v_desshift);
      json_obj.put('codshift', v_codshift);
    exception when no_data_found then
      null;
    end;

    begin
      select timstrtw, timendw, timstrtb, timendb
        into v_timstrtw_cd, v_timendw_cd, v_timstrtb_cd, v_timendb_cd
        from tshiftcd
       where codshift = v_codshift;
    exception when others then
      null;
    end;

    v_m_timstrt     := to_date(v_timstrtw_cd, 'hh24mi');
    v_m_timend      := to_date(v_timstrtb_cd, 'hh24mi');
    v_e_timstrt     := to_date(v_timendb_cd, 'hh24mi');
    v_e_timend      := to_date(v_timendw_cd, 'hh24mi');

    m_timstrt   := to_char(v_m_timstrt, 'hh24:mi');
    m_timend    := to_char(v_m_timend, 'hh24:mi');
    e_timstrt   := to_char(v_e_timstrt, 'hh24:mi');
    e_timend    := to_char(v_e_timend, 'hh24:mi');
    v_m_dtestrt := p_dteleave;
    v_m_dteend  := p_dteleave;
    v_e_dtestrt := p_dteleave;
    v_e_dteend  := p_dteleave;
    if v_m_timstrt > v_m_timend then
      v_m_dtestrt := p_dteleave;
      v_m_dteend  := p_dteleave + 1;
    end if;

    if v_m_timstrt > v_e_timstrt then
      v_e_dtestrt := p_dteleave + 1;
      v_e_dteend  := p_dteleave + 1;
    elsif v_m_timstrt > v_e_timend then
      v_e_dtestrt := p_dteleave;
      v_e_dteend  := p_dteleave + 1;
    end if;

    m_dtestrt     := to_char(v_m_dtestrt, 'dd/mm/yyyy');
    m_dteend      := to_char(v_m_dteend, 'dd/mm/yyyy');
    e_dtestrt     := to_char(v_e_dtestrt, 'dd/mm/yyyy');
    e_dteend      := to_char(v_e_dteend, 'dd/mm/yyyy');

    json_obj.put('m_timstrt', m_timstrt);
    json_obj.put('m_timend', m_timend);
    json_obj.put('e_timstrt', e_timstrt);
    json_obj.put('e_timend', e_timend);
    json_obj.put('m_dtestrt', m_dtestrt);
    json_obj.put('m_dteend', m_dteend);
    json_obj.put('e_dtestrt', e_dtestrt);
    json_obj.put('e_dteend', e_dteend);
    json_obj.put('coderror','200');
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_codshift_time;

  procedure get_entitled_flagleave(json_str_input in clob,json_str_output out clob) as
    json_obj    json_object_t;
    v_codempid  temploy1.codempid%type;
    v_qtyday1   number;
    v_qtyday2   number;
    v_qtyday3   number;
    v_qtyday4   number;
    v_qtyday5   number;
    v_qtyday6   number;
    v_dayeupd   date;
    v_qtyavgwk  number;
    v_token     varchar2(100 char);
    v_token1    number;
    v_token2    number;
    v_token3    number;
    v_dteleave  date;
    v_qtytime   number;
    v_codcompy  temploy1.codempid%type;
    v_dtecycen  date;
    v_dtecycst  date;
    v_qtyminrq	number;
    v_qtyminle	number;
    v_dtestrt   date;
    v_yrecycle  number;
    v_dteend    date;
    v_coderr    varchar2(100 char);
  begin
    initial_value(json_str_input);
    json_obj := json_object_t();
    begin
      select  dayeupd
      into    v_dayeupd
      from    tlereqst
      where   numlereq = p_numlereq;
    exception when no_data_found then
      v_dayeupd := null;
    end;

    hral56b_batch.gen_entitlement(p_codempid  ,p_numlereq     ,v_dayeupd,   -- input
                                  p_flgleave  ,p_codleave     ,p_dteleave,
                                  p_dtestr    ,p_timstr       ,p_dteend,
                                  p_timend    ,
                                  p_dteprgntst,
                                  0              ,global_v_coduser,
                                  v_coderr    ,v_qtyday1      ,v_qtyday2,         -- output
                                  v_qtyday3   ,v_qtyday4      ,v_qtyday5,
                                  v_qtyday6   ,v_qtyminle     ,v_qtyminrq    ,v_qtyavgwk);
    if v_coderr is not null then
        json_obj.put('response',hcm_secur.get_response(null,get_error_msg_php(v_coderr,global_v_lang)));
    end if;
    hcm_util.cal_dhm_hm(v_qtyday1,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
    json_obj.put('qtyday2dd',v_token1);
    json_obj.put('qtyday2hr',v_token2);
    json_obj.put('qtyday2mi',v_token3);
    hcm_util.cal_dhm_hm(v_qtyday2,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
    json_obj.put('qtyday3dd',v_token1);
    json_obj.put('qtyday3hr',v_token2);
    json_obj.put('qtyday3mi',v_token3);
    hcm_util.cal_dhm_hm(v_qtyday3,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
    json_obj.put('qtyday4dd',v_token1);
    json_obj.put('qtyday4hr',v_token2);
    json_obj.put('qtyday4mi',v_token3);
    hcm_util.cal_dhm_hm(v_qtyday4,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
    json_obj.put('qtyday5dd',v_token1);
    json_obj.put('qtyday5hr',v_token2);
    json_obj.put('qtyday5mi',v_token3);
    hcm_util.cal_dhm_hm(v_qtyday5,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
    json_obj.put('qtyday6dd_1',v_token1);
    json_obj.put('qtyday6hr_1',v_token2);
    json_obj.put('qtyday6mi_1',v_token3);
    hcm_util.cal_dhm_hm(v_qtyday6,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token);
    json_obj.put('qtyday6dd_2',v_token1);
    json_obj.put('qtyday6hr_2',v_token2);
    json_obj.put('qtyday6mi_2',v_token3);

    json_obj.put('qtytime',v_qtyminle);
    json_obj.put('qtyminrq',v_qtyminrq);
      --
    json_obj.put('coderror','200');
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_entitled_flagleave;

--  procedure get_radio_buttons(json_str_input in clob,json_str_output out clob) as
--    json_obj      json_object_t;
--    v_flgleave    varchar2(1 char);
--    v_dtestrt     date;
--    v_dteend      date;
--    v_timstrt     varchar2(4 char);
--    v_timend      varchar2(4 char);
--    v_dtestrtw    date;
--    v_dteendw     date;
--    v_timstrtw    varchar2(4 char);
--    v_timendw     varchar2(4 char);
--    v_timstrtb    varchar2(4 char);
--    v_timendb     varchar2(4 char);
--    v_coderr      varchar2(4000 char);
--    v_qtyday1     number;
--    v_qtyday2     number;
--    v_qtyday3     number;
--    v_qtyday4     number;
--    v_qtyday5     number;
--    v_qtyday6     number;
--    v_qtyavgwk    number;
--    v_qtytime     number;
--    v_codcompy    varchar2(4000 char);
--    v_yrecycle    number;
--    v_dtecycst    date;
--    v_dtecycen    date;
--    v_dayeupd     date;
--    v_typleave    varchar2(4000 char);
--    v_token1      number;
--    v_token2      number;
--    v_token3      number;
--    v_token4      varchar2(4000 char);
--    v_qtyminle		number;
--    v_qtyminrq		number;
--  begin
--    initial_value(json_str_input);
--    json_obj := json_object_t();
--    select  t1.dtestrtw ,t1.dteendw,
--            t1.timstrtw ,t1.timendw,
--            t2.timstrtb ,t2.timendb
--    into    v_dtestrtw  ,v_dteendw,
--            v_timstrtw  ,v_timendw,
--            v_timstrtb  ,v_timendb
--    from    tattence t1,tshiftcd t2
--    where   t1.codshift  = t2.codshift
--    and     t1.dtework   = p_dteleave -- remove dteleave and codempid
--    and     t1.codempid  = p_codempid;--
--    if p_flgleave = 'A' then
--        v_flgleave := p_flgleave;
--        v_dtestrt  := v_dtestrtw;
--        v_dteend   := v_dteendw;
--        v_timstrt  := null;
--        v_timend   := null;
--    elsif p_flgleave = 'M' then
--        v_flgleave := p_flgleave;
--        v_dtestrt  := v_dtestrtw;
--        v_dteend   := v_dteendw;
--        v_timstrt  := v_timstrtw;
--        v_timend   := v_timstrtb;
--        if v_timstrtb is null then
--            v_timend := v_timendw;
--        end if;
--    elsif p_flgleave = 'E' then
--        v_flgleave := p_flgleave;
--        v_dtestrt  := v_dtestrtw;
--        v_dteend   := v_dteendw;
--        v_timstrt  := v_timendb;
--        if v_timendb is null then
--            v_timstrt := v_timstrtw;
--        end if;
--        v_timend   := v_timendw;
--    elsif p_flgleave = 'H' then
--        v_flgleave := p_flgleave;
--        v_dtestrt  := v_dtestrtw;
--        v_dteend   := v_dteendw;
--        v_timstrt  := v_timstrtw;
--        v_timend   := v_timendw;
--    end if;
--    if p_flgtyp = '1' then -- 1- change date-time,2- change flgleave
--        v_dtestrt   := p_dtestr;
--        v_dteend    := p_dteend;
--        v_timstrt   := p_timstr;
--        v_timend    := p_timend;
--    end if;
--    json_obj.put('dtestrt',to_char(v_dtestrt,'dd/mm/yyyy'));
--    json_obj.put('dteend',to_char(v_dteend,'dd/mm/yyyy'));
--    json_obj.put('timstrt',to_char(to_date(v_timstrt,'hh24mi'),'hh24:mi'));
--    json_obj.put('timend',to_char(to_date(v_timend,'hh24mi'),'hh24:mi'));
--    if p_numlereq is not null then
--        select  dayeupd
--        into    v_dayeupd
--        from    tlereqst
--        where   numlereq = p_numlereq;
--        if v_flgleave = 'A' then
--          v_timstrt := null;
--          v_timend  := null;
--        end if;
--        hral56b_batch.gen_entitlement(p_codempid  ,p_numlereq , -- input
--                                v_dayeupd   ,v_flgleave ,
--                                p_codleave  ,p_dteleave ,
--                                v_dtestrt   ,v_timstrt  ,
--                                v_dteend    ,v_timend   ,
--                                p_dteprgntst,
--                                0           ,global_v_coduser,
--                                v_coderr    ,v_qtyday1  , -- output
--                                v_qtyday2   ,v_qtyday3  ,
--                                v_qtyday4   ,v_qtyday5  ,
--                                v_qtyday6   ,v_qtyminle ,
--                                v_qtyminrq  ,v_qtyavgwk );
--        if v_qtyday1 is not null then
--            hcm_util.cal_dhm_hm(v_qtyday2,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token4);
--            json_obj.put('qtyday2dd',v_token1);
--            json_obj.put('qtyday2hr',v_token2);
--            json_obj.put('qtyday2mi',v_token3);
--            hcm_util.cal_dhm_hm(v_qtyday3,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token4);
--            json_obj.put('qtyday3dd',v_token1);
--            json_obj.put('qtyday3hr',v_token2);
--            json_obj.put('qtyday3mi',v_token3);
--            hcm_util.cal_dhm_hm(v_qtyday4,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token4);
--            json_obj.put('qtyday4dd',v_token1);
--            json_obj.put('qtyday4hr',v_token2);
--            json_obj.put('qtyday4mi',v_token3);
--            hcm_util.cal_dhm_hm(v_qtyday5,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token4);
--            json_obj.put('qtyday5dd',v_token1);
--            json_obj.put('qtyday5hr',v_token2);
--            json_obj.put('qtyday5mi',v_token3);
--            hcm_util.cal_dhm_hm(v_qtyday6,0,0,v_qtyavgwk,'1',v_token1,v_token2,v_token3,v_token4);
--            if v_token1 < 0 or v_token2 < 0 or v_token3 < 0 then
--                json_obj.put('qtyday6dd_1',0);
--                json_obj.put('qtyday6hr_1',0);
--                json_obj.put('qtyday6mi_1',0);
--                json_obj.put('qtyday6dd_2',abs(v_token1));
--                json_obj.put('qtyday6hr_2',abs(v_token2));
--                json_obj.put('qtyday6mi_2',abs(v_token3));
--            else
--                json_obj.put('qtyday6dd_1',v_token1);
--                json_obj.put('qtyday6hr_1',v_token2);
--                json_obj.put('qtyday6mi_1',v_token3);
--                json_obj.put('qtyday6dd_2',0);
--                json_obj.put('qtyday6hr_2',0);
--                json_obj.put('qtyday6mi_2',0);
--            end if;
--        end if;
--        json_obj.put('qtytime',v_qtyminle);
--    end if;
--    json_obj.put('coderror','200');
--    json_str_output := json_obj.to_clob;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--  end get_radio_buttons;

  procedure delete_index(json_str_input in clob,json_str_output out clob) is
--    param_json      json;
    param_json_row  json_object_t;
    v_flg           varchar2(10 char);
    v_numlereq      tlereqst.numlereq%type;
  begin
    initial_value(json_str_input);
    for i in 0..param_json.get_size-1 loop null;
      param_json_row  := hcm_util.get_json_t(param_json,to_char(i));
      v_flg           := hcm_util.get_string_t(param_json_row,'flg');
      v_numlereq      := hcm_util.get_string_t(param_json_row,'numlereq');
      if v_flg = 'delete' then
        delete tlereqst where numlereq = v_numlereq;
        delete tlereqd  where numlereq = v_numlereq;
        delete tlereqattch where numlereq = v_numlereq;
      end if;
    end loop;
    commit;
    param_msg_error := get_error_msg_php('HR2425',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end delete_index;

  procedure save_detail(json_str_input in clob,json_str_output out clob) as
    json_obj        json_object_t;
    att_param_json  json_object_t;
    att_param_rows  json_object_t;
    json_obj2       json_object_t;
    v_numlereq      varchar2(50 char);
    v_dteend        date;
    v_summin        number;
    v_sumday        number;
    v_qtyavgwk      number;
    v_yrecycle      number;
    v_dtecycst      date;
    v_dtecycen      date;
    v_codcomp       temploy1.codcomp%type;
    v_numlvl        number;
    v_codshift      tattence.codshift%type;
    p_coderr        varchar2(100 char);
    obj_data        json_object_t;
    v_response      varchar2(4000 char);
    v_timstrt       tlereqst.timstrt%type;
    v_timend        tlereqst.timend%type;
    v_flgdlemx      tleavety.flgdlemx%type;
    --
    att_flg         varchar2(100 char);
    att_attachname  varchar2(100 char);
    att_codleave    varchar2(100 char);
    att_numseq      number;
    att_flgattach   varchar2(100 char);
    att_filedesc    varchar2(100 char);

  begin
    initial_value(json_str_input);
    check_save;
    if param_msg_error is not null then
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    check_warning;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang,param_flgwarn);
      return;
    end if;
    for i in 0..param_json.get_size-1 loop
        json_obj            := hcm_util.get_json_t(param_json,to_char(i));
        p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
        p_dtestr            := to_date(hcm_util.get_string_t(json_obj,'p_dtestr'),'ddmmyyyy');
        p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'ddmmyyyy');
        p_numlereq          := hcm_util.get_string_t(json_obj,'p_numlereq');
        p_codleave          := hcm_util.get_string_t(json_obj,'p_codleave');
        p_dterecod          := to_date(hcm_util.get_string_t(json_obj,'p_dterecod'),'ddmmyyyy');
        p_dteleave          := to_date(hcm_util.get_string_t(json_obj,'p_dteleave'),'ddmmyyyy');
        p_timstr            := replace(hcm_util.get_string_t(json_obj,'p_timstr'),':','');
        p_timend            := replace(hcm_util.get_string_t(json_obj,'p_timend'),':','');
        p_timstr2            := replace(hcm_util.get_string_t(json_obj,'p_timstr'),':','');
        p_timend2            := replace(hcm_util.get_string_t(json_obj,'p_timend'),':','');
        p_flgleave          := hcm_util.get_string_t(json_obj,'p_flgleave');
        p_deslereq          := hcm_util.get_string_t(json_obj,'p_deslereq');
        p_stalereq          := hcm_util.get_string_t(json_obj,'p_stalereq');
        p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'ddmmyyyy');
        p_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
        p_dtecancl          := to_date(hcm_util.get_string_t(json_obj,'p_dtecancl'),'ddmmyyyy');
        p_filename          := hcm_util.get_string_t(json_obj,'p_filename');
        p_numlereqg         := hcm_util.get_string_t(json_obj,'p_numlereqg');
        v_codshift          := hcm_util.get_string_t(json_obj,'p_codshift');
        v_flgdlemx          := hcm_util.get_string_t(json_obj,'p_flgdlemx');
        -- paternity leave --
        p_dayeupd           := to_date(hcm_util.get_string_t(json_obj,'p_dayeupd'),'ddmmyyyy');
        p_dteprgntst        := to_date(hcm_util.get_string_t(json_obj,'p_dteprgntst'),'ddmmyyyy');
        p_timprgnt          := hcm_util.get_string_t(json_obj,'p_timprgnt');
        att_param_json      := hcm_util.get_json_t(json_obj,'param_json');
        att_param_rows      := hcm_util.get_json_t(att_param_json,'rows');
        begin
            select  codcomp, numlvl
            into    v_codcomp, v_numlvl
            from    temploy1
            where   codempid = p_codempid;
        exception when others then null;
        end;
        if p_numlereq is not null then
            v_numlereq := p_numlereq;
        else
            v_numlereq := std_al.gen_req('LEAV','tlereqst','numlereq',0,get_codcompy(get_compful(v_codcomp)),'');
            std_al.upd_req('LEAV',v_numlereq,global_v_coduser,0,get_codcompy(get_compful(v_codcomp)),'');
        end if;

        if p_dtecancl is not null then
            v_dteend := p_dtecancl-1;
        else
            v_dteend := p_dteend;
        end if;

        hral56b_batch.gen_min_req(true,v_numlereq,
                                    p_codempid,p_flgleave,
                                    p_codleave,p_dteleave,
                                    p_dtestr,p_timstr,
                                    v_dteend,p_timend,
                                    global_v_coduser,v_summin,
                                    v_sumday,v_qtyavgwk,p_coderr);
        begin
          insert into
            tlereqst   (numlereq    ,dterecod    ,codempid   ,codleave   ,
                        dtestrt     ,timstrt    ,dteend     ,timend     ,qtymin     ,
                        qtyday      ,deslereq   ,stalereq   ,codappr    ,dteappr    ,
                        codcomp     ,numlvl     ,dtecancl   ,codshift   ,dayeupd    ,
                        filename   ,flgleave   ,dteleave   ,codcreate  ,
                        dteupd      ,coduser    ,numlereqg  ,dteprgntst)
            values     (v_numlereq  ,p_dterecod   ,p_codempid ,p_codleave ,
                        p_dtestr    ,p_timstr2   ,p_dteend   ,p_timend2   ,v_summin   ,
                        v_sumday    ,p_deslereq ,p_stalereq ,p_codappr  ,p_dteappr  ,
                        v_codcomp   ,v_numlvl   ,p_dtecancl ,v_codshift ,null       ,
                        p_filename ,p_flgleave ,p_dteleave ,global_v_coduser   ,
                        sysdate     ,global_v_coduser       ,p_numlereqg,p_dteprgntst);
        exception when dup_val_on_index then
          update tlereqst set dterecod  = p_dterecod,
                              codempid  = p_codempid,
                              codleave  = p_codleave,
                              dtestrt   = p_dtestr,
                              timstrt   = p_timstr,
                              dteend    = p_dteend,
                              timend    = p_timend,
                              qtymin    = v_summin,
                              qtyday    = v_sumday,
                              deslereq  = p_deslereq,
                              stalereq  = p_stalereq,
                              codappr   = p_codappr,
                              dteappr   = p_dteappr,
                              codcomp   = v_codcomp,
                              numlvl    = v_numlvl,
                              dtecancl  = p_dtecancl,
                              codshift  = v_codshift,

                              filename  = p_filename,
                              flgleave  = p_flgleave,
                              dteleave  = p_dteleave,
                              numlereqg = p_numlereqg,
                              dteprgntst = p_dteprgntst,
                              dteupd    = sysdate,
                              coduser   = global_v_coduser
                        where numlereq  = v_numlereq;
        end;

        -- update temploy1 --
        if p_dteprgntst is not null then
          begin
            update temploy1 set dteprgntst = p_dteprgntst
             where codempid = p_codempid;
          exception when others then null;
          end;
        end if;
        -- update document attachment --
        for i in 0..att_param_rows.get_size-1 loop
          json_obj2        := hcm_util.get_json_t(att_param_rows,to_char(i));
          att_attachname   := hcm_util.get_string_t(json_obj2, 'attachname');
          att_codleave     := hcm_util.get_string_t(json_obj2, 'codleave');
          att_flg          := hcm_util.get_string_t(json_obj2, 'flg');
          att_numseq       := to_number(hcm_util.get_string_t(json_obj2,'numseq'));
          att_flgattach    := hcm_util.get_string_t(json_obj2,'flgattach');
          att_filedesc     := hcm_util.get_string_t(json_obj2,'filename');
--          if att_flg in ('add','edit') then
          begin
            insert into tlereqattch (numlereq, numseq, filename, flgattach, filedesc, codleave, codcreate, dtecreate)
              values (v_numlereq, att_numseq, att_attachname, att_flgattach, att_filedesc, p_codleave, global_v_coduser, trunc(sysdate));
          exception when dup_val_on_index then
            begin
              update tlereqattch
                set filename  = att_attachname,
                    coduser   = global_v_coduser
              where numlereq  = v_numlereq
                and numseq    = att_numseq;
              exception when others then
                rollback;
              end;
          end;
--          end if;
        end loop;
        --
        if param_msg_error is not null then
            json_str_output := get_response_message('400',param_msg_error,global_v_lang);
            return;
        end if;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end loop;

    if param_msg_error is null then
      v_response := get_error_msg_php('HR2401', global_v_lang);
      v_response := replace(v_response, '@#$%200' ,null);
      v_response := replace(v_response, '@#$%201' ,null);
      obj_data        := json_object_t();
      obj_data.put('coderror', 200);
      obj_data.put('response', v_response);
      obj_data.put('numlereq', v_numlereq);

      json_str_output := obj_data.to_clob;
      commit;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      rollback;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_detail;

-- 08/03/2021 : comment not use import
--  procedure get_import_process(json_str_input in clob, json_str_output out clob) as
--    obj_row         json_object_t;
--    obj_data        json_object_t;
--    obj_result      json_object_t;
--    v_error         varchar2(1000 char);
--    v_flgsecu       boolean := false;
--    v_rec_tran      number;
--    v_rec_err       number;
--    v_numseq        varchar2(1000 char);
--    v_rcnt          number  := 0;
--  begin
--    initial_value(json_str_input);
--    if param_msg_error is null then
--      format_text_json(json_str_input, v_rec_tran, v_rec_err);
--    end if;
--    --
--    obj_row    := json_object_t();
--    obj_result := json_object_t();
--    obj_row.put('coderror', '200');
--    obj_row.put('rec_tran', v_rec_tran);
--    obj_row.put('rec_err', v_rec_err);
--    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
--    --
--    if p_numseq.exists(p_numseq.first) then
--      for i in p_numseq.first .. p_numseq.last
--      loop
--        v_rcnt      := v_rcnt + 1;
--        obj_data    := json_object_t();
--        obj_data.put('coderror', '200');
--        obj_data.put('text', p_text(i));
--        obj_data.put('error_code', p_error_code(i));
--        obj_data.put('numseq', p_numseq(i));
--        obj_result.put(to_char(v_rcnt-1),obj_data);
--      end loop;
--    end if;
--
--    obj_row.put('datadisp', obj_result);
--    --
--    json_str_output := obj_row.to_clob;
--  exception when others then
--    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--  end;
--
--  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
--    param_json       json_object_t;
--    param_data       json_object_t;
--    param_column     json_object_t;
--    param_column_row json_object_t;
--    param_json_row   json_object_t;
--    json_obj_list    json_list;
--    --
--    data_file 		   varchar2(6000);
--    v_column			   number := 9;
--    v_error				   boolean;
--    v_err_code  	   varchar2(1000);
--    v_err_filed  	   varchar2(1000);
--    v_err_table		   varchar2(20);
--    v_comments  	   varchar2(1000);
--    v_namtbl    	   varchar2(300);
--    i 						   number;
--    j 						   number;
--    k  						   number;
--    v_numseq    	   number := 0;
--    --
--    v_where     	   varchar2(500);
--    v_codapp			   varchar2(10) := 'HRAL51EC3';
--    v_timeout    	   number:= 0;
--    --
--    v_numlereq       tlereqst.numlereq%type;
--    v_codempid		   temploy1.codempid%type;
--    v_codleave       varchar2(1000);
--    v_dtestrt        tlereqst.dtestrt%type;
--    v_timstrt        varchar2(4);
--    vv_timstrt		   varchar2(4);
--    v_dteend         tlereqst.dteend%type;
--    v_timend         varchar2(4);
--    vv_timend			   varchar2(4);
--    v_deslereq       tlereqst.deslereq%type;
--    v_codappr        tlereqst.codappr%type;
--    v_dteappr        tlereqst.dteappr%type;
--    --
--    v_code				   varchar2(100);
--    v_flgsecu			   boolean;
--    v_codcomp	 		   temploy1.codcomp%type;
--    tmp_codcomp	 		 temploy1.codcomp%type;
--    v_codcompap		   temploy1.codcomp%type;
--    v_numlvl         temploy1.numlvl%type;
--    v_staempap		   temploy1.staemp%type;
--    v_numlvlap		   temploy1.numlvl%type;
--    v_typot	    	   totreqd.typot%type;
--
--    t_dtestrt        date;
--    t_dteend         date;
--    v_dtewkst  		   date;
--    v_dtewken   	   date;
--    v_dteotst   	   date;
--    v_dteoten   	   date;
--    v_flag				   varchar2(1);
--    v_numotreq		   totreqd.numotreq%type;
--    v_flgfound  	   boolean;
--    v_cnt					   number := 0;
--    v_chk            varchar2(1);
--    v_zupdsal   	   varchar2(4);
--    v_qtyday1			   number;
--    v_qtyday2			   number;
--    v_qtyday3			   number;
--    v_qtyday4			   number;
--    v_qtyday5			   number;
--    v_qtyday6			   number;
--    v_qtytimle		   number;
--    v_qtytimrq		   number;
--    v_qtyavgwk		   number;
--    v_sumday			   number;
--    v_summin			   number;
--    v_codshift		   tattence.codshift%type;
--    v_dteleave		   date;
--    v_coderr         varchar2(4000 char);
--    v_num            number := 0;
--
--    type text is table of varchar2(4000) index by binary_integer;
--      v_text   text;
--      v_filed  text;
--  begin
--    v_rec_tran  := 0;
--    v_rec_error := 0;
--    --
--    for i in 1..v_column loop
--      v_filed(i) := null;
--    end loop;
--    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
--    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
--    param_column := hcm_util.get_json_t(param_json, 'p_columns');
--        -- get text columns from json
--    for i in 0..param_column.get_size-1 loop
--      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
--      v_num             := v_num + 1;
--      v_filed(v_num)    := hcm_util.get_string_t(param_column_row,'name');
--    end loop;
--    --
--    for r1 in 0..param_data.get_size-1 loop
--      param_json_row  := hcm_util.get_json_t(param_data, to_char(r1));
----      json_obj_list   := param_json_row.get_values;
----      data_file       := regexp_replace(json_obj_list.to_char,'\"|\]|\[|\ ','');
--      begin
--        v_err_code  := null;
--        v_err_filed := null;
--        v_err_table := null;
--        v_numseq    := v_numseq;
--        v_error 	  := false;
--
--        if v_numseq = 0 then
--          <<cal_loop>> loop
--            v_text(1)   := hcm_util.get_string_t(param_json_row,'codempid');
--            v_text(2)   := hcm_util.get_string_t(param_json_row,'codleave');
--            v_text(3)   := hcm_util.get_string_t(param_json_row,'dtestrt');
--            v_text(4)   := hcm_util.get_string_t(param_json_row,'timstrt');
--            v_text(5)   := hcm_util.get_string_t(param_json_row,'dteend');
--            v_text(6)   := hcm_util.get_string_t(param_json_row,'timend');
--            v_text(7)   := hcm_util.get_string_t(param_json_row,'deslereq');
--            v_text(8)   := hcm_util.get_string_t(param_json_row,'codappr');
--            v_text(9)   := hcm_util.get_string_t(param_json_row,'dteappr');
--
----1.Validate --
--            data_file := null;
--            for i in 1..9 loop
--              if v_text(i) is null and i <> 7 then
--                v_error	 	  := true;
--                v_err_code  := 'HR2045';
--                v_err_filed := v_filed(i);
--                exit cal_loop;
--              end if;
--              if data_file is null then
--                data_file := v_text(i);
--              else
--                data_file := data_file||','||v_text(i);
--              end if;
--            end loop;
--            --1.codempid
--            i := 1;
--            begin
--              select codcomp,numlvl
--                into v_codcomp,v_numlvl
--                from temploy1
--               where codempid = upper(v_text(i));
--              --
--              v_flgsecu := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--              if not v_flgsecu then
--                v_error	 	  := true;
--                v_err_code  := 'HR3007';
--                v_err_filed := v_filed(i);
--                exit cal_loop;
--              end if;
--            exception when no_data_found then
--              v_error     := true;
--              v_err_code  := 'HR2010';
--              v_err_table := 'TEMPLOY1';
--              v_err_filed := upper(v_filed(i));
--              exit cal_loop;
--            end;
--            v_codempid := upper(v_text(1));
--
--            --2.codleave
--            i := 2;
--            begin
--              select codleave
--                into v_codleave
--                from tleavecd
--               where codleave = upper(v_text(i));
--            exception when no_data_found then
--              v_error     := true;
--              v_err_code  := 'HR2010';
--              v_err_table := 'TLEAVECD';
--              v_err_filed := v_filed(i);
--              exit cal_loop;
--            end;
--            v_codleave := upper(v_text(i));
--
--            --3.dtestrt
--            i := 3;
--            v_error  := check_date(v_text(i),v_zyear);
--            if v_error then
--              v_error     := true;
--              v_err_code  := 'HR2025';
--              v_err_filed := v_filed(i);
--              exit cal_loop;
--            end if;
--            v_dtestrt := check_dteyre(v_text(i));
--
--            -- 4.timstrt
--            i := 4;
--            if length(v_text(i)) <> 4 then
--              v_error     := true;
--              v_err_code  := 'HR2015';
--              v_err_filed := v_filed(i);
--              exit cal_loop;
--            end if;
--            v_flgfound := check_times(v_text(i));
--            if not v_flgfound then
--              v_error     := true;
--              v_err_code  := 'HR2015';
--              v_err_filed := v_filed(i);
--              exit cal_loop;
--            end if;
--            v_timstrt := v_text(i);
--
--            --5.dteend
--            i := 5;
--            v_error  := check_date(v_text(i),v_zyear);
--            if v_error then
--              v_error     := true;
--              v_err_code  := 'HR2025';
--              v_err_filed := v_filed(i);
--              exit cal_loop;
--            end if;
--            v_dteend := check_dteyre(v_text(i));
--
--            -- 6.timbend
--            i := 6;
--            if length(v_text(i)) <> 4 then
--              v_error     := true;
--              v_err_code  := 'HR2015';
--              v_err_filed := v_filed(i);
--              exit cal_loop;
--            end if;
--            v_flgfound := check_times(v_text(i));
--            if not v_flgfound then
--              v_error     := true;
--              v_err_code  := 'HR2015';
--              v_err_filed := v_filed(i);
--              exit cal_loop;
--            end if;
--            v_timend := v_text(i);
--            --4.,5.,6.,7.
--            t_dtestrt := to_date(to_char(v_dtestrt,'dd/mm/yyyy')||v_timstrt,'dd/mm/yyyyhh24mi');
--            t_dteend  := to_date(to_char(v_dteend,'dd/mm/yyyy')||v_timend,'dd/mm/yyyyhh24mi');
--            if t_dtestrt > t_dteend then
--                v_error     := true;
--                v_err_code  := 'HR2021';
--                v_err_filed := v_filed(5);
--                exit cal_loop;
--            end if;
--
--            -- 7.v_deslereq
--            i := 7;
--            if v_text(i) is not null then
--              if length(v_text(i)) > 200 then
--                v_error     := true;
--                v_err_code  := 'HR2060';
--                v_err_filed := v_filed(i);
--                exit cal_loop;
--              end if;
--            end if;
--            v_deslereq := v_text(i);
--
--            -- 8.codappr
--            i := 8;
--            begin
--              select staemp,codcomp,numlvl
--                into v_staempap,v_codcompap,v_numlvlap
--                from temploy1
--               where codempid = upper(v_text(i));
--              --
--              v_flgsecu := secur_main.secur1(v_codcompap,v_numlvlap,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
--              if not v_flgsecu then
--                v_error	 	  := true;
--                v_err_code  := 'HR3007';
--                v_err_filed := v_filed(i);
--                exit cal_loop;
--              end if;
--            exception when no_data_found then
--              v_error     := true;
--              v_err_code  := 'HR2010' ;
--              v_err_table := 'TEMPLOY1';
--              v_err_filed := v_filed(i) ;
--              exit cal_loop;
--            end;
--            if v_staempap = '9' then
--              v_error     := true;
--              v_err_code  := 'HR2101' ;
--              v_err_filed := v_filed(i);
--              exit cal_loop;
--            elsif v_staempap = '0' then
--              v_error     := true;
--              v_err_code  := 'HR2102' ;
--              v_err_filed := v_filed(i);
--              exit cal_loop;
--            end if;
--            v_codappr := upper(v_text(i));
--
--            -- 9.dteappr
--            i := 9;
--            v_error  := check_date(v_text(i),v_zyear);
--            if v_error then
--              v_error     := true;
--              v_err_code  := 'HR2025';
--              v_err_filed := v_filed(i);
--              exit cal_loop;
--            end if;
--            v_dteappr := check_dteyre(v_text(i));
--
--            --
--            v_err_code := null;
--
--            hral56b_batch.gen_entitlement(v_codempid,null,null,'H',v_codleave,v_dtestrt,v_dtestrt,v_timstrt,v_dteend,v_timend,null,v_zyear,global_v_coduser,
--                                    v_err_code,v_qtyday1,v_qtyday2,v_qtyday3,v_qtyday4,v_qtyday5,v_qtyday6,v_qtytimle,v_qtytimrq,v_qtyavgwk);
--            if v_err_code is not null then
--              v_error     := true;
--              v_err_filed := v_filed(3);
--              exit cal_loop;
--            end if;
--            exit cal_loop;
--          end loop; -- cal_loop
--    --2.insert/update --
--          if not v_error then
--            begin
--              select codcomp
--              into tmp_codcomp
--              from temploy1
--              where codempid = v_codempid;
--            exception when no_data_found then
--              tmp_codcomp := '';
--            end;
--            v_rec_tran := v_rec_tran + 1;
----            v_numlereq := std_al.gen_req('LEAV','tlereqst','numlereq',v_zyear);
--            v_numlereq := std_al.gen_req('LEAV','tlereqst','numlereq',v_zyear,get_codcompy(get_compful(tmp_codcomp)),'');
--            std_al.upd_req('LEAV',v_numlereq,global_v_coduser,v_zyear,get_codcompy(get_compful(tmp_codcomp)),'');
--            --
--            vv_timstrt := v_timstrt;
--            vv_timend  := v_timend;
--            --
--            hral56b_batch.gen_min_req(true,v_numlereq,v_codempid,'H',v_codleave,v_dtestrt,v_dtestrt,vv_timstrt,v_dteend,vv_timend,global_v_coduser,
--                                v_summin,v_sumday,v_qtyavgwk,v_coderr);
--            --
--            if v_sumday > 0 then
--              begin
--                select min(dtework)
--                  into v_dteleave
--                  from tlereqd
--                 where numlereq = v_numlereq;
--              exception when no_data_found then null;
--              end;
--              begin
--                select codshift into v_codshift
--                  from tattence
--                 where codempid = v_codempid
--                   and dtework  = v_dteleave;
--              exception when no_data_found then v_codshift := null;
--              end;
--              begin
--                insert into tlereqst(numlereq,dterecod,dtereq,codempid,codleave,dtestrt,timstrt,dteend,timend,qtymin,qtyday,
--                                     deslereq,stalereq,codappr,dteappr,codcomp,numlvl,dtecancl,codshift,dayeupd,
--                                     filename,flgleave,dteleave,numlereqg,qtyentitle,qtysdayle,qtydayrq,qtydayle,dteupd,coduser)
--                              values(v_numlereq,sysdate,null,v_codempid,v_codleave,v_dtestrt,v_timstrt,v_dteend,v_timend,v_summin,v_sumday,
--                                     v_deslereq,'A',v_codappr,v_dteappr,v_codcomp,v_numlvl,null,v_codshift,null,
--                                     null,'H',v_dteleave,null,null,null,null,null,sysdate,global_v_coduser);
--              exception when dup_val_on_index then null;
--              end;
--            end if;
--          else
--            v_rec_error      := v_rec_error + 1;
--            v_cnt            := v_cnt+1;
--            -- puch value in array
--            p_text(v_cnt)       := data_file;
--            p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']';
--            p_numseq(v_cnt)     := r1;
--          end if;--not v_error
--        end if;--v_numseq = 1
--      exception when others then
--        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
--      end;
--    end loop;
--  end;

  procedure get_drilldown(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_drilldown;
    if param_msg_error is null then
      gen_drilldown(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_drilldown as
  begin -- codempid dtestr dte end
--    if p_dtestr is null then
--        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--        return;
--    end if;
--    if p_dteend is null then
--        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--        return;
--    end if;
    if p_dtestr > p_dteend then
        param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        return;
    end if;
    if p_codempid is not null then
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;
  end;

  procedure gen_drilldown(json_str_output out clob) as
    json_obj json_object_t;
    json_row json_object_t;
    v_count number := 0;
    v_dtework date;
    v_con varchar2(10 char);
    v_token varchar2(400 char);
    cursor c1 is
        select  dtework ,typwork,codshift,
                timstrtw,timendw,
                dtein   ,timin  ,
                dteout  ,timout
        from    tattence
        where   codempid = p_codempid
        and     dtework between p_dtestr and p_dteend
        order by dtework;
    cursor c2 is
        select  codrecod,timtime,dtedate
        from    tatmfile
        where   codempid = p_codempid
        and     dtetime between v_dtework and (v_dtework + 2)
        order by dtetime;
  begin
    json_obj := json_object_t();
    for r1 in c1 loop
        json_row := json_object_t();
        json_row.put('dtework',to_char(r1.dtework,'dd/mm/yyyy'));
        json_row.put('typwork',r1.typwork);
        json_row.put('codshift',r1.codshift);
        v_dtework := r1.dtework;
        v_token := to_char(to_date(r1.timstrtw,'hh24mi'),'hh24:mi') || ' - ' ||
                   to_char(to_date(r1.timendw ,'hh24mi'),'hh24:mi');
        json_row.put('timsten',v_token);
            v_token := to_char(to_date(r1.timin,'hh24mi'),'hh24:mi');
        json_row.put('dtetimin',v_token);
            v_token := to_char(to_date(r1.timout,'hh24mi'),'hh24:mi');
        json_row.put('dtetimout',v_token);
        v_con := null;
        v_token := null;
        for r2 in c2 loop
            if r2.codrecod is not null then
              v_token := substr(v_token||v_con||r2.codrecod||'-'||to_char(r2.dtedate,'dd/mm/yyyy ')||	substr(r2.timtime,1,2)||':'||substr(r2.timtime,3,2),1,600);
            else
              v_token := substr(v_token||v_con||to_char(r2.dtedate,'dd/mm/yyyy ')||	substr(r2.timtime,1,2)||':'||substr(r2.timtime,3,2),1,600);
            end if;
            v_con := ', ';
              end loop;
              json_row.put('atmtime',v_token);
              json_row.put('coderror','200');
              json_obj.put(to_char(v_count),json_row);
              v_count := v_count + 1;
        end loop;
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_flgtype_leave (json_str_input in clob, json_str_output out clob) is
    v_flgtype       tleavety.flgtype%type;
    json_obj        json_object_t;
    obj_data        json_object_t;
  begin
    -- initial_value(json_str_input);
    json_obj      := json_object_t(json_str_input);
    p_codleave    := hcm_util.get_string_t(json_obj, 'p_codleave');
    -- check type leave --
    begin
      select t2.flgtype into v_flgtype
        from tleavecd t1, tleavety t2
       where t1.typleave  = t2.typleave
         and t1.codleave  = p_codleave;
    exception when others then
        v_flgtype  := null;
    end;
    obj_data        := json_object_t();
    obj_data.put('coderror', 200);
    obj_data.put('flgtype',v_flgtype);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_flgtype_leave;

  procedure get_paternity_date (json_str_input in clob, json_str_output out clob) is
    v_dteprgntst    temploy1.dteprgntst%type;
    json_obj        json_object_t;
    obj_data        json_object_t;
  begin
    -- initial_value(json_str_input);
    json_obj      := json_object_t(json_str_input);
    p_codempid    := hcm_util.get_string_t(json_obj, 'p_codempid');
    p_dteleave    := to_date(hcm_util.get_string_t(json_obj, 'p_dteleave'),'dd/mm/yyyy');
    -- default dteprgntst --
    begin
      select dteprgntst into v_dteprgntst
        from temploy1
       where codempid = p_codempid
         and p_dteleave between add_months(dteprgntst, -9) and dteprgntst;
    exception when others then
      v_dteprgntst := null;
    end;
    obj_data        := json_object_t();
    obj_data.put('coderror', 200);
    obj_data.put('dteprgntst',to_char(v_dteprgntst,'dd/mm/yyyy'));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_paternity_date;
end HRAL51E;

/
