--------------------------------------------------------
--  DDL for Package Body HRAL41E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL41E" is
--10/11/2022 15:17  error NMT: redmine415
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);

    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_codcomp           := replace(hcm_util.get_string_t(json_obj,'p_codcomp'),'-',null);
    p_codcalen          := hcm_util.get_string_t(json_obj,'p_codcalen');
    p_codshift          := hcm_util.get_string_t(json_obj,'p_codshift');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');

    p_numotreq          := hcm_util.get_string_t(json_obj,'p_numotreq');

    p_dtereq            := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_typotreq          := hcm_util.get_string_t(json_obj,'p_typotreq');
    p_timstrta          := replace(hcm_util.get_string_t(json_obj,'p_timstrta'),':','');
    p_timstrtb          := replace(hcm_util.get_string_t(json_obj,'p_timstrtb'),':','');
    p_timstrtd          := replace(hcm_util.get_string_t(json_obj,'p_timstrtd'),':','');
    p_timenda           := replace(hcm_util.get_string_t(json_obj,'p_timenda'),':','');
    p_timendb           := replace(hcm_util.get_string_t(json_obj,'p_timendb'),':','');
    p_timendd           := replace(hcm_util.get_string_t(json_obj,'p_timendd'),':','');
    p_codrem            := hcm_util.get_string_t(json_obj,'p_codrem');
    p_codappr           := hcm_util.get_string_t(json_obj,'p_codappr');
    p_staotreq          := hcm_util.get_string_t(json_obj,'p_staotreq');
    p_dteappr           := to_date(hcm_util.get_string_t(json_obj,'p_dteappr'),'dd/mm/yyyy');
    p_dtecancl          := to_date(hcm_util.get_string_t(json_obj,'p_dtecancl'),'dd/mm/yyyy');
    p_remark            := hcm_util.get_string_t(json_obj,'p_remark');
    p_dayeupd           := to_date(hcm_util.get_string_t(json_obj,'p_dayeupd'),'dd/mm/yyyy');
    p_codcompw          := hcm_util.get_string_t(json_obj,'p_codcompw');
    p_codcompw          := REPLACE(p_codcompw, '-', '');
    p_flgchglv          := hcm_util.get_string_t(json_obj,'p_flgchglv');
    p_qtymin            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_qtymin'));
    p_qtymina           := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_qtymina'));
    p_qtyminb           := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_qtyminb'));
    p_qtymind           := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_qtymind'));
    p_typwork           := hcm_util.get_string_t(json_obj,'p_typwork');
    p_flgProcess        := hcm_util.get_string_t(json_obj,'p_flgProcess');
    p_flgconfirm        := hcm_util.get_string_t(json_obj,'p_flgconfirm');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_index is
    v_flgsecu 	boolean := false;
    v_codcomp   tcenter.codcomp%type;
    v_zupdsal   varchar2(4);
  begin
    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'dtestrt');
      return;
    elsif p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'dteend');
      return;
    end if;
    if p_codempid is null and p_codcomp is null then
      if p_codempid is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codempid');
        return;
      else
        param_msg_error := get_error_msg_php('HR2045',global_v_lang, 'codcomp1');
        return;
      end if;
    end if;
    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021',global_v_lang, 'dteend');
      return;
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
      if not secur_main.secur2(p_codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
      end if;
    elsif p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
      if p_codcalen is not null then
        begin
          select codcodec into p_codcalen
            from tcodwork
           where codcodec = p_codcalen;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tcodwork.codcalen');
          return;
        end;
      end if;
    end if;
  END;

  procedure check_totreqd is
    v_codcomp   temploy1.codcomp%type;
    v_codempid  tattence.codempid%type;
    v_numlvl    temploy1.numlvl%type;
    v_secur     boolean := false;
    --
    v_dtestrtw  date ;
    v_dteendw   date ;
    v_timstrt   varchar2(10);
    v_timend    varchar2(10);
    v_timstrtw  varchar2(10);
    v_timendw   varchar2(10);
    v_dtewkst   date;
    v_dtewken   date;
    v_dteotst   date;
    v_dteoten   date;
    p_type      varchar2(100);
  begin
  	begin
      select codcomp,numlvl	into v_codcomp,v_numlvl
        from temploy1
       where codempid = p_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'temploy1');
      return;
    end;
    --
    v_secur := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
    if not v_secur then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      return;
    end if;
    --
    begin
      select codshift,dtestrtw,timstrtw,dteendw,timendw
        into p_codshift,v_dtestrtw,v_timstrtw,v_dteendw,v_timendw
        from tattence
       where codempid = p_codempid
         and dtework  = p_dtewkreq;
    exception when no_data_found then null;
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tattence');
      return;
    end;
    -- check has processed
    if p_dayeupd is not null and p_dayeupd >= p_dteend then
      param_msg_error := get_error_msg_php('HR1505',global_v_lang);
      return;
    end if;
    --
    if p_qtyminr is null then
      if p_timstrt is null then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,null);
        return;
      end if;
      if p_timend is null then
        param_msg_error   := get_error_msg_php('HR2010',global_v_lang,null);
        return;
      end if;
    end if;

    if p_type = 'A' then
      begin
        select codempid into v_codempid
          from totreqd
         where numotreq = p_numotreq
           and dtewkreq = p_dtewkreq
           and codempid = p_codempid
           and typot    = p_typot;
          param_msg_error := get_error_msg_php('HR2005',global_v_lang,'totreqd');
          return;
      exception when no_data_found then null;
      end;
    end if;
    --
--    v_timstrt  := to_char(p_timstrt,'hh24mi');
--    v_timend   := to_char(p_timend,'hh24mi');
    v_timstrt := p_timstrt;
    v_timstrt := p_timend;
--    p_dtestrt_ot  := p_dtewkreq;
    --
    if p_typot = 'B'   then  --- Before
      if p_timend >  v_timendw then
        p_dteend_ot := v_dteendw - 1;
      else
        p_dteend_ot := v_dteendw;
      end if;
      if p_timstrt > p_timend then
        p_dtestrt_ot := p_dteend_ot - 1;
      else
        p_dtestrt_ot := p_dteend_ot;
      end if;
    elsif p_typot = 'A'   then  --- After
      if p_timstrt <  v_timstrtw then
        p_dtestrt_ot := v_dtestrtw + 1;
      else
        p_dtestrt_ot := v_dtestrtw;
      end if;
      if p_timstrt > p_timend then
        p_dteend_ot := p_dtestrt_ot + 1;
      else
        p_dteend_ot := p_dtestrt_ot;
--        p_dteend_ot := p_dtestrt;
      end if;
    elsif p_typot = 'D'   then  --- During
--      v_dtewkst := to_date(to_char(v_dtestrtw,'dd/mm/yyyy')||v_timstrtw,'dd/mm/yyyyhh24mi');
--      v_dtewken := to_date(to_char(v_dteendw,'dd/mm/yyyy')||v_timendw,'dd/mm/yyyyhh24mi');
      p_dtestrt_ot  := p_dtewkreq;
      if p_timstrt >= p_timend then
        p_dteend_ot := p_dtestrt_ot + 1;
      else
        p_dteend_ot := p_dtestrt_ot;
      end if;
--      --
--      v_dteotst := to_date(to_char(p_dtestrt_ot,'dd/mm/yyyy')||p_timstrt,'dd/mm/yyyyhh24mi');
--      v_dteoten := to_date(to_char(p_dteend_ot,'dd/mm/yyyy')||p_timend,'dd/mm/yyyyhh24mi');
--      if v_dtewkst between v_dteotst and v_dteoten
--      or v_dtewken between v_dteotst and v_dteoten
--      or v_dteotst between v_dtewkst and v_dtewken
--      or v_dteoten between v_dtewkst and v_dtewken then
--        return;
--      end if;
--      --
--      p_dtestrt_ot  := p_dtestrt_ot - 1;
--      p_dteend_ot   := p_dteend_ot  - 1;
--      v_dteotst := v_dteotst - 1;
--      v_dteoten := v_dteoten - 1;
--
--      if v_dtewkst between v_dteotst and v_dteoten
--      or v_dtewken between v_dteotst and v_dteoten
--      or v_dteotst between v_dtewkst and v_dtewken
--      or v_dteoten between v_dtewkst and v_dtewken then
--        return;
--      end if;
--      --
--      p_dtestrt_ot  := p_dtestrt_ot + 2;
--      p_dteend_ot   := p_dteend_ot  + 2;
--      v_dteotst := v_dteotst + 2;
--      v_dteoten := v_dteoten + 2;
--      --
--      if v_dtewkst between v_dteotst and v_dteoten
--      or v_dtewken between v_dteotst and v_dteoten
--      or v_dteotst between v_dtewkst and v_dtewken
--      or v_dteoten between v_dtewkst and v_dtewken then
--        return;
--      end if;
--      --
--      p_dtestrt_ot  := p_dtestrt_ot - 1;
--      p_dtestrt_ot  := p_dtestrt_ot  - 1;
--      v_dteotst := v_dteotst - 1;
--      v_dteoten := v_dteoten - 1;
    end if;
  end check_totreqd;

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

  function check_times (p_time in varchar2) return boolean is
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

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_data(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;

    v_rcnt          number := 0;
    v_total         number := 0;
    v_qtymincal     number;
    v_flgcalpy      boolean;
    v_count_ovrtime number;

    cursor c_totreqst is
      select a.numotreq, a.dtereq, a.codempid, a.typotreq, a.codcomp, a.codcalen, a.dtestrt, a.dteend
        from totreqst a
       where(a.dtestrt    between p_dtestrt and p_dteend
          or a.dteend     between p_dtestrt and p_dteend
          or p_dtestrt    between a.dtestrt and a.dteend
          or p_dteend     between a.dtestrt and a.dteend)
         and a.typotreq   = p_typotreq
         and((p_typotreq  = '1'
         and exists (select b.codempid
                       from totreqd b
                      where a.numotreq    = b.numotreq
                        and b.codempid    = nvl(p_codempid,b.codempid)
                        and b.codcomp     like p_codcomp||'%'
                        and b.codcalen    = nvl(p_codcalen,b.codcalen)))
          or (p_typotreq  = '2'
         and p_codempid  is null
         and codcomp     like p_codcomp||'%'
         and nvl(a.codcalen,'123456789') = nvl(p_codcalen,nvl(a.codcalen,'123456789'))))
    order by a.numotreq desc,a.dtereq;
  /* cursor c_totreqst is
     select  numotreq , dtereq, codempid, typotreq, codcomp, codcalen, dtestrt, dteend from (
      select a.numotreq, a.dtereq, a.codempid, a.typotreq, a.codcomp, a.codcalen, a.dtestrt, a.dteend
        from totreqst a, temploy1 b
       where a.codempid = b.codempid
         and a.typotreq = nvl(p_typotreq,a.typotreq)
        and (a.dtestrt between p_dtestrt and p_dteend or
              a.dteend between p_dtestrt and p_dteend or
              p_dtestrt between a.dtestrt and a.dteend or
              p_dteend between a.dtestrt and a.dteend
             )
         and nvl(a.codempid,'123456789') = nvl(p_codempid,nvl(a.codempid,'123456789'))
         and (a.codcomp like p_codcomp || '%' or (a.codcomp is null and p_codcomp = '%')
          or b.codcomp like p_codcomp || '%')
         and (nvl(a.codcalen,'123456789') = nvl(p_codcalen,nvl(a.codcalen,'123456789'))
          or b.codcalen = nvl(p_codcalen,nvl(b.codcalen,'123456789')))
      union all
      select a.numotreq, a.dtereq, a.codempid, a.typotreq, a.codcomp, a.codcalen, a.dtestrt, a.dteend
        from totreqst a
       where (a.dtestrt between p_dtestrt and p_dteend or
              a.dteend between p_dtestrt and p_dteend or
              p_dtestrt between a.dtestrt and a.dteend or
              p_dteend between a.dtestrt and a.dteend
             )
         and a.codempid is  null
         and a.typotreq = nvl(p_typotreq,a.typotreq)
         and (a.codcomp like p_codcomp || '%' or (a.codcomp is null and p_codcomp = '%')
              )
         and (nvl(a.codcalen,'123456789') = nvl(p_codcalen,nvl(a.codcalen,'123456789'))
              ))

    order by numotreq desc,dtereq;*/
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();

    for i in c_totreqst loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();

      obj_data.put('coderror', '200');
      obj_data.put('rcnt', v_rcnt);

      obj_data.put('numotreq',i.numotreq);
      obj_data.put('dtereq',to_char(i.dtestrt,'dd/mm/yyyy')||'-'||to_char(i.dteend,'dd/mm/yyyy'));
      obj_data.put('codempid',i.codempid);
      obj_data.put('desc_codempid',get_temploy_name(i.codempid, global_v_lang));
      obj_data.put('codcomp',i.codcomp);
      obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp, global_v_lang));
      obj_data.put('codcalen',i.codcalen);
      obj_data.put('desc_codcalen',get_tcodec_name('TCODWORK', i.codcalen, global_v_lang));
      obj_data.put('typotreq',i.typotreq);
      if i.typotreq = '1' then
        obj_data.put('desc_typotreq',get_label_name('HRAL41E2',global_v_lang,40));
      else
        obj_data.put('desc_typotreq',get_label_name('HRAL41E2',global_v_lang,50));
      end if;

      select count(*)
      into  v_count_ovrtime
      from  tovrtime
      where numotreq = i.numotreq
      and   rownum = 1
      and   nvl(dteyrepay,0) > 0;

      if v_count_ovrtime > 0 then
        v_flgcalpy := true;
      else
        v_flgcalpy := false;
      end if;
      obj_data.put('flgcalpy',v_flgcalpy);
--      obj_data.put('dtereq',to_char(i.dteend,'dd/mm/yyyy'));
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end;

  procedure get_overtime_detail(json_str_input in clob, json_str_output out clob) as
      obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_overtime_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_overtime_detail(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_flgpass	      boolean := true;

    v_rcnt          number := 0;
    v_total         number := 0;
    v_cost_center   varchar2(500 char);
    v_flgchglv_     varchar2(500 char);
    v_flgchglv      varchar2(500 char);
    v_qtymincal     number;
    v_codcompy      tcenter.codcompy%type;

    cursor c_totreqst is
     select numotreq, dtereq, codempid, codcomp, codcalen, dtestrt, dteend,
            codshift, typotreq, timstrta, timenda, timstrtb, timendb, timstrtd, timendd, codrem, codappr,
            dteappr, dtecancl, remark, dayeupd, codcompw,
            dteupd, coduser, flgchglv, qtymina, qtyminb, qtymind, typwork--qtymincal,
      from totreqst
     where numotreq = p_numotreq
     order by numotreq  desc;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    v_codcompy := hcm_util.get_codcompy(p_codcomp);

    for i in c_totreqst loop
      v_total := v_total + 1;
    end loop;

    if v_total > 0 then
      for i in c_totreqst loop
        v_flgpass := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
        if v_flgpass then
          v_rcnt      := v_rcnt+1;
          begin
            select flgchglv  into v_flgchglv_
              from tcontrot
             where codcompy = hcm_util.get_codcompy(i.codcomp)
               and dteeffec = (select max(dteeffec) from tcontrot
                                where codcompy = hcm_util.get_codcompy(i.codcomp)
                                  and dteeffec <= sysdate);
          exception when no_data_found then
            v_flgchglv_ := null;
          end;
          --
          if v_flgchglv_ = 'N' then
            v_flgchglv := v_flgchglv_;
          else
            v_flgchglv := i.flgchglv;
          end if;
          --
          begin
            select costcent into v_cost_center
              from tcenter
             where codcomp = i.codcompw
               and rownum <= 1
          order by codcomp;
          exception when no_data_found then
            v_cost_center := null;
          end;

          begin
            select qtymincal
              into v_qtymincal
              from tcontrot
             where codcompy = v_codcompy
               and dteeffec = (select max(dteeffec)
                                 from tcontrot
                                where codcompy = v_codcompy
                                  and dteeffec <= sysdate);
          exception when no_data_found then
            v_qtymincal := 0;
          end;

          obj_data    := json_object_t();

          obj_data.put('coderror', '200');
          obj_data.put('rcnt', v_rcnt);

          obj_data.put('numotreq',i.numotreq);
          obj_data.put('dtereq',to_char(i.dtereq,'dd/mm/yyyy'));
          obj_data.put('codempid',i.codempid);
          obj_data.put('desc_codempid',get_temploy_name(i.codempid, global_v_lang));
          obj_data.put('codcomp',i.codcomp);
          obj_data.put('codcalen',i.codcalen);
          obj_data.put('desc_codcalen',get_tcodec_name('TCODWORK', i.codcalen, global_v_lang));
          obj_data.put('codshift',i.codshift);
          obj_data.put('desc_codshift',get_tshiftcd_name(i.codshift, global_v_lang));
          obj_data.put('dtestrt',to_char(i.dtestrt,'dd/mm/yyyy'));
          obj_data.put('dteend',to_char(i.dteend,'dd/mm/yyyy'));
          obj_data.put('dtecancl',to_char(i.dtecancl,'dd/mm/yyyy'));
          obj_data.put('typotreq',i.typotreq);
          obj_data.put('timstrta',i.timstrta);
          obj_data.put('timstrtb',i.timstrtb);
          obj_data.put('timstrtd',i.timstrtd);
          obj_data.put('timenda',i.timenda);
          obj_data.put('timendb',i.timendb);
          obj_data.put('timendd',i.timendd);
          obj_data.put('codrem',i.codrem);
          obj_data.put('desc_codrem',get_tcodec_name('TCODOTRQ', i.codrem, global_v_lang));
          obj_data.put('codappr',i.codappr);
          obj_data.put('desc_codappr',get_temploy_name(i.codappr,global_v_lang));
          obj_data.put('dteappr',to_char(i.dteappr,'dd/mm/yyyy'));
          obj_data.put('codcompw',i.codcompw);
          obj_data.put('remark',i.remark);
          obj_data.put('flgchglv',v_flgchglv);
          obj_data.put('flgchglv_',v_flgchglv_);
          obj_data.put('qtymin',hcm_util.convert_minute_to_hour(v_qtymincal));
          obj_data.put('qtymina',hcm_util.convert_minute_to_hour(i.qtymina));
          obj_data.put('qtyminb',hcm_util.convert_minute_to_hour(i.qtyminb));
          obj_data.put('qtymind',hcm_util.convert_minute_to_hour(i.qtymind));
          obj_data.put('typwork',i.typwork);
          obj_data.put('dayeupd',to_char(i.dayeupd,'dd/mm/yyyy'));
          obj_data.put('flgEditBtn',true);
          if i.dayeupd is not null and i.dayeupd >= nvl(i.dtecancl,i.dteend) then
            obj_data.put('flgprocess','Y');
            obj_data.put('flgdtecancl','Y');
          elsif i.dayeupd is not null and i.dayeupd < nvl(i.dtecancl,i.dteend) then
            obj_data.put('flgprocess','Y');
            obj_data.put('flgdtecancl','N');
          else
            obj_data.put('flgprocess','N');
            obj_data.put('flgdtecancl','N');
          end if;

          if i.codcompw is not null then
            obj_data.put('costcenter',v_cost_center);
          end if;

          obj_row.put(to_char(v_rcnt-1),obj_data);
        end if;
      end loop;
    else
      param_msg_error := get_error_msg_php('HR2055',global_v_lang);
    end if;

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end;

  procedure get_employee_detail(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_employee_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_employee_detail(json_str_output out clob) is
    obj_row                     json_object_t;
    obj_data                    json_object_t;

    v_rcnt                      number := 0;
    v_total                     number := 0;
    v_cost_center               varchar2(500 char);

    v_tmp_qtyot_req             number;
    v_tmp_codempid              totreqd.codempid%type;
    v_qtyminotOth_cumulative    number;
    v_codempid_tmp              temploy1.codempid%type;

  cursor c_totreqd is
    select numotreq, dtewkreq, codempid, typot, codcomp, codcompw, codcalen, codshift,
           dtestrt, timstrt, timend, flgchglv,qtyminr
      from totreqd
     where numotreq = p_numotreq
     order by codempid,dtewkreq,decode(typot,'B',1,'D',2,'A',3);

    CURSOR c1_main IS
      SELECT distinct item2 codempid,
             to_date(nvl(item14,'01/01/1900'),'dd/mm/yyyy') dtestrtwk,
             to_date(nvl(item15,'01/01/1900'),'dd/mm/yyyy') dteendwk
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
      ORDER BY codempid,dtestrtwk ;

    CURSOR c1 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         and item2 = v_codempid_tmp
         and to_date(nvl(item14,'01/01/1900'),'dd/mm/yyyy') = v_dtestrtwk
         and to_date(nvl(item15,'01/01/1900'),'dd/mm/yyyy') = v_dteendwk
         AND codapp = 'HRAL41E'
      ORDER BY numseq;
  begin
    -->> user18 ST11 05/08/2021 change std
    begin
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRAL41E';
    exception when others then
        null;
    end;
    v_report_numseq := 0;
    --<< user18 ST11 05/08/2021 change std

    obj_row     := json_object_t();
    obj_data    := json_object_t();
    for i in c_totreqd loop
      begin
        select costcent into v_cost_center
          from tcenter
         where codcomp  = i.codcompw
           and rownum   <= 1
      order by codcomp;
      exception when no_data_found then
        v_cost_center := null;
      end;

      -->> user18 ST11 05/08/2021 change std
      begin
          select qtymxotwk,qtymxallwk,nvl(typalert,'N')
            into v_qtymxotwk,v_qtymxallwk,v_typalert
            from tcontrot
           where codcompy = hcm_util.get_codcompy(i.codcomp)
             and dteeffec = (select max(dteeffec)
                               from tcontrot
                              where codcompy = hcm_util.get_codcompy(i.codcomp)
                                and dteeffec <= sysdate);
      exception when others then
          v_qtymxotwk   := 0;
          v_qtymxallwk  := 0;
          v_typalert    := 'N';
      end;

      v_report_numseq := v_report_numseq + 1;

      if v_typalert <> 'N' then
          v_dtestrtwk   := std_ot.get_dtestrt_period (i.codempid, i.dtewkreq);
          v_dteendwk    := v_dtestrtwk + 6;
          v_qtydaywk    := std_ot.get_qtyminwk(i.codempid, v_dtestrtwk, v_dteendwk);

          if i.typot = 'B' then
              v_qtyminot    := std_ot.get_qtyminot(i.codempid, i.dtewkreq, i.dtewkreq,
                                                   (i.qtyminr), i.timend, i.timstrt,
                                                   null, null, null,
                                                   null, null, null);
          elsif  i.typot = 'D' then
              v_qtyminot    := std_ot.get_qtyminot(i.codempid, i.dtewkreq, i.dtewkreq,
                                                   null, null, null,
                                                   (i.qtyminr), i.timend, i.timstrt,
                                                   null, null, null);
          elsif  i.typot = 'A' then
              v_qtyminot    := std_ot.get_qtyminot(i.codempid, i.dtewkreq, i.dtewkreq,
                                                   null, null, null,
                                                   null, null, null,
                                                   (i.qtyminr), i.timend, i.timstrt);
          end if;
      end if;
      insert into ttemprpt (codempid,codapp,numseq,
                            item1,item2,item3,item4,item5,
                            item6,item7,item8,item9,item10,
                            item11,item12,item13,item14,item15,
                            item16,item17,item18,item19,item20,
                            item21,item22,item23,item24)
      values(global_v_codempid,'HRAL41E',v_report_numseq,
                            nvl(to_char(i.dtewkreq,'dd/mm/yyyy'),''),i.codempid,
                            get_temploy_name(i.codempid, global_v_lang),i.typot,
                            i.codcompw,i.codcalen,i.codshift,
                            to_char(to_date(i.timstrt,'hh24:mi'), 'hh24:mi'),
                            to_char(to_date(i.timend,'hh24:mi'), 'hh24:mi'),
                            decode(nvl(i.qtyminr,0),0,null,hcm_util.convert_minute_to_hour(i.qtyminr)),
                            i.flgchglv,v_cost_center,
                            null, --item13
                            to_char(v_dtestrtwk,'dd/mm/yyyy'),to_char(v_dteendwk,'dd/mm/yyyy'), --item14,item15
                            hcm_util.convert_minute_to_hour(v_qtydaywk),null, --item16,item17
                            hcm_util.convert_minute_to_hour(v_qtyminot),null, --item18,item19
                            0,0,0,i.numotreq,v_staovrot);
      --<< user18 ST11 05/08/2021 change std
    end loop;

    for r1_main in c1_main loop
        v_codempid_tmp  := r1_main.codempid;
        v_dtestrtwk     := r1_main.dtestrtwk;
        v_dteendwk      := r1_main.dteendwk;
        std_ot.get_week_ot(r1_main.codempid, p_numotreq,v_dtestrtwk,'',v_dtestrtwk, v_dteendwk,
                           null, null, null,
                           null, null, null,
                           null, null, null,
                           global_v_codempid,
                           a_dtestweek,a_dteenweek,
                           a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
        v_qtydaywk      := a_sumwork(1);
        v_qtyminotOth   := std_ot.get_qtyminotOth_notTmp (r1_main.codempid ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);
        v_qtyminotOth_cumulative    := v_qtyminotOth;
        for r1 in c1 loop
            v_rcnt          := v_rcnt+1;

            if v_typalert <> 'N' then
                v_qtyminotOth   := std_ot.get_qtyminotOth_notTmp (r1.item2 ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);
                begin
                  SELECT sum(hcm_util.convert_time_to_minute(item18))
                    into v_tmp_qtyot_req
                    FROM ttemprpt
                   WHERE codempid = global_v_codempid
                     AND codapp = 'HRAL41E'
                     and item2 = r1.item2
                     and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
                     and numseq <> r1.numseq;
                exception when others then
                    v_tmp_qtyot_req := 0;
                end;
                v_qtyminotOth := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
                v_qtyot_total   := v_qtyminotOth_cumulative + hcm_util.convert_time_to_minute(r1.item18);
                v_qtytotal      := v_qtydaywk + v_qtyot_total;
                if (v_qtyot_total > v_qtymxotwk or v_qtytotal > v_qtymxallwk) then
                    v_staovrot   := 'Y';
                else
                    v_staovrot   := 'N';
                end if;
                v_qtyminotOth_cumulative := v_qtyot_total;

                update ttemprpt
                   set item24 = v_staovrot,
                       item17 = hcm_util.convert_minute_to_hour(v_qtyminotOth),
                       item19 = hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r1.item18) + v_qtyminotOth),
                       item13 = hcm_util.convert_minute_to_hour(v_qtydaywk + hcm_util.convert_time_to_minute(r1.item18) + v_qtyminotOth)
                 where codempid = r1.codempid
                   and codapp = r1.codapp
                   and numseq = r1.numseq;
            else
                v_staovrot   := 'N';
            end if;
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('seqno',r1.numseq); --dtestrt
            obj_data.put('dtewkreq',r1.item1); --dtewkreq
            obj_data.put('dtewkreqOld',r1.item1); --dtewkreq
            obj_data.put('codempid',r1.item2); -- codempid
            obj_data.put('codempidOld',r1.item2); -- codempid
            obj_data.put('desc_codempid',r1.item3); --desc_codempid
            obj_data.put('typot',r1.item4); --typot
            obj_data.put('codcompw',r1.item5); --codcompw
            obj_data.put('codcalen',r1.item6); --codcalen
            obj_data.put('codshift',r1.item7); --codshift
            obj_data.put('timstrt',r1.item8); --timstrt
            obj_data.put('timend',r1.item9); --timend
            obj_data.put('qtyminr',r1.item10); --qtyminr
            obj_data.put('flgchglv',r1.item11); --flgchglv
            obj_data.put('cost_center',r1.item12); --cost_center
            obj_data.put('qtytotal',hcm_util.convert_minute_to_hour(v_qtydaywk + hcm_util.convert_time_to_minute(r1.item18) + v_qtyminotOth)); --qtytotal
            obj_data.put('dtestrtwk',r1.item14);--dtestrtwk
            obj_data.put('dteendwk',r1.item15);--,dteendwk
            obj_data.put('qtydaywk',r1.item16); --qtydaywk
            obj_data.put('qtyot_reqoth',hcm_util.convert_minute_to_hour(v_qtyminotOth)); --qtyot_reqoth
            obj_data.put('qtyot_req',r1.item18); --qtyot_req
            obj_data.put('qtyot_total',hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r1.item18) + v_qtyminotOth)); --qtyot_total
            obj_data.put('numotreq',r1.item23);
            obj_data.put('staovrot',v_staovrot);
            obj_data.put('typalert',v_typalert);
            obj_row.put(to_char(v_rcnt-1),obj_data);
        end loop;
    end loop;
    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end;

  procedure get_process(json_str_input in clob, json_str_output out clob) as
    obj_row json_object_t;
  begin
    initial_value(json_str_input);
    begin
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRAL41E';
    exception when others then
        null;
    end;
    v_report_numseq := 0;

    if param_msg_error is null then
      gen_process(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := v_report_numseq||dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_process(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;

    v_zupdsal       varchar2(4);
    v_flgsecu       boolean := false;
    v_rcnt          number := 0;
    v_total         number := 0;
    v_cost_center   varchar2(500 char);

    v_timstotb      varchar2(100 char);
    v_timenotb      varchar2(100 char);
    v_timstotd      varchar2(100 char);
    v_timenotd      varchar2(100 char);
    v_timstota      varchar2(100 char);
    v_timenota      varchar2(100 char);

    v_dtest_a       date;
    v_dteen_a       date;
    v_dtest_b       date;
    v_dteen_b       date;
    v_dtest_d       date;
    v_dteen_d       date;

    v_dteotst_a     date;
    v_dteoten_a     date;
    v_dteotst_b     date;
    v_dteoten_b     date;
    v_dteotst_d     date;
    v_dteoten_d     date;

    v_timstrtw      varchar2(100 char);
    v_timendw       varchar2(100 char);

    v_typot         varchar2(100 char);
    v_timstrt       varchar2(100 char);
    v_timend        varchar2(100 char);
    v_qtyminr       number;

    v_condot			varchar2(500);
    v_condextr		varchar2(500);
    v_dtewkreq		date;
    v_dteeffec		date;
    v_totmeal			varchar2(1);

    v_codcomp     temploy1.codcomp%type;
    v_codcompw    temploy1.codcomp%type;
    v_codpos      temploy1.codpos%type;
    v_numlvl      temploy1.numlvl%type;
    v_typemp      temploy1.typemp%type;
    v_codempmt    temploy1.codempmt%type;
    v_codcalen    temploy1.codempmt%type;
    v_jobgrade    temploy1.jobgrade%type;
    v_amtincom1   temploy3.amtincom1%type;
    v_codcurr		  temploy3.codcurr%type;
    v_staemp      temploy1.staemp%type;
    v_dteeffex    temploy1.dteeffex%type;

    v_cond				tcontrot.condot%type;
    v_stmt      	varchar2(1000);
    v_ratechge		tratechg.ratechge%type;
    v_chkreg 			varchar2(100);
    v_zyear				number;
    v_flgcondot		boolean;
    v_flgcondextr	boolean;

    v_codcompy    tcenter.codcompy%type;
    v_codempid    temploy1.codempid%type;
    v_codempid_tmp    temploy1.codempid%type := 'xxxx';

    -->> user18 ST11 03/08/2021 change std
    v_qtyday_req            number;
    v_qtyminotOth_cumulative number;
    v_typalert      tcontrot.typalert%type;
    --<< user18 ST11 03/08/2021 change std

    cursor c_tattence is
      select codempid, dtework, typwork, codshift, codcomp, codcalen, dtestrtw, dteendw, timstrtw, timendw
        from tattence
       where codcomp like p_codcomp||'%'
         and codcalen = nvl(p_codcalen,codcalen)
         and codempid = nvl(p_codempid,codempid)
         and codshift = nvl(p_codshift,codshift)
         and dtework between p_dtestrt and p_dteend
       order by codempid ,dtework ;

    cursor c_ttmovemt is
      select codempid,dteeffec,numseq,
             codcomp,codpos,numlvl,typemp,codempmt,codcalen,jobgrade,
             nvl(stddec(amtincom1,codempid,v_chken),0) amtincom1
        from ttmovemt
       where codempid  = v_codempid --08/03/2021 ||p_codempid
         and dteeffec <= v_dtewkreq
         and staupd in('C','U')
    order by dteeffec desc ,numseq desc;

    cursor c_ttmovemt2 is
      select codempid,dteeffec,numseq,
             codcompt,codposnow,numlvlt,typempt,codempmtt,codcalet,jobgradet,
             nvl(stddec(amtincom1,codempid,v_chken),0) - nvl(stddec(amtincadj1,codempid,v_chken),0) amtincom1
        from ttmovemt
       where codempid = v_codempid --08/03/2021 ||p_codempid
         and dteeffec > v_dtewkreq
         and staupd in('C','U')
    order by dteeffec,numseq;

    cursor c_temp is
      SELECT distinct item2 codempid,
             to_date(item14,'dd/mm/yyyy') dtestrtwk,
             to_date(item15,'dd/mm/yyyy') dteendwk
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
      ORDER BY item2, dtestrtwk;

    CURSOR c_temp2 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
         and item2 = v_codempid_tmp
         and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
      ORDER BY numseq;
    v_tmp_qtyot_req number;
    v_ttemprpt      ttemprpt%rowtype;

    CURSOR c1 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
      ORDER BY numseq;
  begin
    obj_row     := json_object_t();
    obj_data    := json_object_t();
    obj_result  := json_object_t();

    /*08/03/2021 move to under c_tattence
    begin
      select a.codcomp,a.codpos,a.numlvl,a.typemp,a.codempmt,a.codcalen,
             nvl(stddec(b.amtincom1,p_codempid,v_chken),0),b.codcurr,a.jobgrade,
             a.staemp,a.dteeffex
        into v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,
             v_amtincom1,v_codcurr,v_jobgrade,
             v_staemp,v_dteeffex
        from temploy1 a, temploy3 b
       where a.codempid = b.codempid
         and a.codempid = p_codempid;
    exception when no_data_found then null;
    end;*/
    --<<08/03/2021
    if p_codempid is not null then
      begin
        select hcm_util.get_codcompy(codcomp)
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        v_codcompy := null;
      end;
    else
      v_codcompy := hcm_util.get_codcompy(p_codcomp);
    end if;
    -->>08/03/2021

    begin
      select condot,condextr,dteeffec into v_condot,v_condextr,v_dteeffec
      from   tcontrot
      where  codcompy = v_codcompy --08/03/2021 ||hcm_util.get_codcomp_level(v_codcomp,'1')
      and    dteeffec = (select max(dteeffec)
                         from   tcontrot
                         where  codcompy = v_codcompy --08/03/2021 ||hcm_util.get_codcomp_level(v_codcomp,'1')
                         and    dteeffec <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'))
      and    rownum <= 1;
    exception when no_data_found then null;
    end;
    <<main_loop>>
    for i in c_tattence loop
      v_codempid    := i.codempid; --08/03/2021
      v_flgsecu     := secur_main.secur2(i.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_flgsecu then
        --<<08/03/2021
        begin
          select a.codcomp,a.codpos,a.numlvl,a.typemp,a.codempmt,a.codcalen,
                 nvl(stddec(b.amtincom1,p_codempid,v_chken),0),b.codcurr,a.jobgrade,
                 a.staemp,a.dteeffex
            into v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,
                 v_amtincom1,v_codcurr,v_jobgrade,
                 v_staemp,v_dteeffex
            from temploy1 a, temploy3 b
           where a.codempid = b.codempid
             and a.codempid = v_codempid;
        exception when no_data_found then null;
        end;
        -->>08/03/2021

        if (v_staemp = '9' and v_dteeffex <= i.dtework) then
          goto next_day; --08/03/2021 ||exit main_loop;
        end if;
        --<<user36 19/2/2014
        if v_condot is null then
          goto cal_loop;
        else
          v_dtewkreq := i.dtework;

          for r_ttmovemt in c_ttmovemt loop
            v_codcomp   := r_ttmovemt.codcomp;
            v_codpos    := r_ttmovemt.codpos;
            v_numlvl    := r_ttmovemt.numlvl;
            v_typemp    := r_ttmovemt.typemp;
            v_codempmt  := r_ttmovemt.codempmt;
            v_codcalen  := r_ttmovemt.codcalen;
            v_amtincom1 := r_ttmovemt.amtincom1;
            v_jobgrade  := r_ttmovemt.jobgrade;
            exit;
          end loop;

          for r_ttmovemt in c_ttmovemt2 loop
            v_codcomp   := r_ttmovemt.codcompt;
            v_codpos    := r_ttmovemt.codposnow;
            v_numlvl    := r_ttmovemt.numlvlt;
            v_typemp    := r_ttmovemt.typempt;
            v_codempmt  := r_ttmovemt.codempmtt;
            v_codcalen  := r_ttmovemt.codcalet;
            v_amtincom1 := r_ttmovemt.amtincom1;
            v_jobgrade  := r_ttmovemt.jobgradet;
            exit;
          end loop;

          --
          begin
            select value into v_chkreg
            from v$nls_parameters
            where parameter = 'NLS_CALENDAR';
            if v_chkreg = 'Thai Buddha' then
              v_zyear := 543;
            else
              v_zyear := 0;
            end if;
          exception when others then v_zyear := 0;
          end;

          v_ratechge := get_exchange_rate(to_number(to_char(v_dtewkreq,'yyyy')) - v_zyear,to_number(to_char(v_dtewkreq,'mm')),v_codcurr,v_codcurr);--,:global.v_codcurr,v_codcurr);
          v_amtincom1 := v_amtincom1 * v_ratechge;
          --
          v_flgcondot := false;
          if v_condot is not null then
            v_cond := v_condot;
            v_cond := replace(v_cond,'V_HRAL92M1.CODCOMP',''''||v_codcomp||'''');
            v_cond := replace(v_cond,'V_HRAL92M1.CODPOS',''''||v_codpos||'''');
            v_cond := replace(v_cond,'V_HRAL92M1.NUMLVL',v_numlvl);
            v_cond := replace(v_cond,'V_HRAL92M1.JOBGRADE',''''||v_jobgrade||'''');
            v_cond := replace(v_cond,'V_HRAL92M1.TYPEMP',''''||v_typemp||'''');
            v_cond := replace(v_cond,'V_HRAL92M1.CODEMPMT',''''||v_codempmt||'''');
            v_cond := replace(v_cond,'V_HRAL92M1.AMTINCOM1',v_amtincom1);

            v_stmt := 'select count(*) from dual where '||v_cond;
            v_flgcondot := execute_stmt(v_stmt);
          end if;

          if v_flgcondot then
            goto cal_loop;
          else
            begin
              select 'Y' into v_totmeal
              from 	 totmeal
              where  codcompy = hcm_util.get_codcompy(v_codcomp)
              and    dteeffec = v_dteeffec
              and		 rownum = 1;
            exception when no_data_found then v_totmeal := 'N';
            end;
            if v_totmeal = 'Y' then
              if v_condextr is null then
                goto cal_loop;
              else
                v_flgcondextr := false;
                v_cond := v_condextr;
                v_cond := replace(v_cond,'V_HRAL92M2.CODCOMP',''''||v_codcomp||'''');
                v_cond := replace(v_cond,'V_HRAL92M2.CODPOS',''''||v_codpos||'''');
                v_cond := replace(v_cond,'V_HRAL92M2.NUMLVL',v_numlvl);
                v_cond := replace(v_cond,'V_HRAL92M2.JOBGRADE',''''||v_jobgrade||'''');
                v_cond := replace(v_cond,'V_HRAL92M2.TYPEMP',''''||v_typemp||'''');
                v_cond := replace(v_cond,'V_HRAL92M2.CODEMPMT',''''||v_codempmt||'''');
                v_cond := replace(v_cond,'V_HRAL92M2.AMTINCOM1',v_amtincom1);
                v_stmt := 'select count(*) from dual where '||v_cond;
                v_flgcondextr := execute_stmt(v_stmt);

                if v_flgcondextr then
                  goto cal_loop;
                else
                  goto next_day;
                end if;
              end if; --v_condextr is null

            else
              goto next_day;
            end if; --v_totmeal = 'Y'
          end if; --v_flgcondot
        end if; --v_condot is null

        <<cal_loop>>
        loop
          if p_codshift is not null and p_codshift <> i.codshift then
            exit cal_loop;
          end if;
          --
          if (p_typwork = 'W' and i.typwork <> 'W') or
             (p_typwork = 'H' and i.typwork <> 'H') or
             (p_typwork = 'S' and i.typwork <> 'S') or
             (p_typwork = 'T' and i.typwork <> 'T') then
            exit cal_loop;
          end if;
          --
          begin
            select timstotb,timenotb,timstota,timenota,timstotd,timenotd,timstrtw,timendw
            into   v_timstotb,v_timenotb,v_timstota,v_timenota,v_timstotd,v_timenotd,v_timstrtw,v_timendw
            from   tshiftcd
            where  codshift = i.codshift;
          exception when no_data_found then
            v_timstotb := null; v_timenotb := null; v_timenotd := null;
            v_timstota := null; v_timenota := null; v_timenotd := null;
          end;

          -->> user18 ST11 05/08/2021 change std
          v_dtestrtwk   := std_ot.get_dtestrt_period (i.codempid, i.dtework);
          v_dteendwk    := v_dtestrtwk + 6;

          begin
            select qtymxotwk,qtymxallwk,nvl(typalert,'N')
              into v_qtymxotwk,v_qtymxallwk,v_typalert
              from tcontrot
             where codcompy = hcm_util.get_codcompy(v_codcomp)
               and dteeffec = (select max(dteeffec)
                                 from tcontrot
                                where codcompy = hcm_util.get_codcompy(v_codcomp)
                                  and dteeffec <= sysdate);
          exception when others then
            v_qtymxotwk     := 0;
            v_qtymxallwk    := 0;
            v_typalert      := 'N';
          end;
--
--          if not r_tattence.typwork in ('H','T','S') then
--            ttotreqst_qtymind := null;
--            ttotreqst_timdstr := null;
--            ttotreqst_timdend := null;
--          end if;

          v_qtydaywk    := std_ot.get_qtyminwk(i.codempid, v_dtestrtwk, v_dteendwk);

          v_qtyminot    := std_ot.get_qtyminot(i.codempid, i.dtework, i.dtework,
                                               p_qtyminb, p_timendb, p_timstrtb,
                                               p_qtymind, p_timendd, p_timstrtd,
                                               p_qtymina, p_timenda, p_timstrta);

          v_qtyminotb   := std_ot.get_qtyminot(i.codempid, i.dtework, i.dtework,
                                               p_qtyminb, p_timendb, p_timstrtb,
                                               null, null, null,
                                               null, null, null);
          v_qtyminotd   := std_ot.get_qtyminot(i.codempid, i.dtework, i.dtework,
                                               null, null, null,
                                               p_qtymind, p_timendd, p_timstrtd,
                                               null, null, null);
          v_qtyminota   := std_ot.get_qtyminot(i.codempid, i.dtework, i.dtework,
                                               null, null, null,
                                               null, null, null,
                                               p_qtymina, p_timenda, p_timstrta);
          --<< user18 ST11 05/08/2021 change std

          --<<06/03/2021
          /*begin
            select codcompw
              into v_codcompw
              from v_tattence_cc
             where codempid = p_codempid
               and dtework  = p_dtestrt;
          exception when no_data_found then
            v_codcompw := null;
          end;

          --
          if p_codcompw is not null then
            begin
              select costcent into v_cost_center
                from tcenter
               where codcomp  = p_codcompw
                 and rownum   <= 1
            order by codcomp;
            exception when no_data_found then
              v_cost_center := null;
            end;
          else
            p_codcompw := v_codcompw;
          end if;*/

--          if p_codcompw is null or p_codcompw = '' then
--            p_codcompw := v_codcompw;
--          end if;
          if p_codcompw is not null then
            v_codcompw := p_codcompw;
          else
            begin
              select codcompw
                into v_codcompw
                from v_tattence_cc
               where codempid = v_codempid
                 and dtework  = v_dtewkreq;
            exception when no_data_found then
              v_codcompw := null;
            end;
          end if;
          begin
            select costcent into v_cost_center
              from tcenter
             where codcomp  = v_codcompw
               and rownum   <= 1
          order by codcomp;
          exception when no_data_found then
            v_cost_center := null;
          end;
          -->>06/03/2021

          -- Before Work
          if p_timstrtb is not null or p_timendb is not null or p_qtyminb is not null then
            -- check OT in range
            v_dtest_b     := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(v_timstotb, '0000'), 'YYYYMMDDHH24MI');
            v_dteen_b     := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(v_timenotb, nvl(v_timstotb, '0000')), 'YYYYMMDDHH24MI');
            if v_timstotb is null then
              v_dtest_b   := v_dteen_b - 1;
            elsif nvl(to_number(v_timstotb), 0) > nvl(to_number(v_timenotb), 0) then
              v_dteen_b   := i.dtework + 1;
            end if;
            if nvl(to_number(v_timenotb), 0) > nvl(to_number(v_timstrtw), 0) then
              v_dtest_b   := v_dtest_b - 1;
              v_dteen_b   := v_dteen_b - 1;
            end if;

            v_dteotst_b   := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(p_timstrtb, '0000'), 'YYYYMMDDHH24MI');
            v_dteoten_b   := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(p_timendb, nvl(p_timstrtb, '0000')), 'YYYYMMDDHH24MI');
            if nvl(to_number(v_timstrtw), 0) < nvl(to_number(p_timstrtb), 0) then
              v_dteotst_b := v_dteotst_b - 1;
              v_dteoten_b := v_dteoten_b - 1;
            end if;
            if nvl(to_number(p_timstrtb), 0) > nvl(to_number(p_timendb), 0) then
              v_dteoten_b := v_dteoten_b + 1;
            end if;

--<<10/11/2022 15:17  error NMT: redmine415
            --if v_qtyminotb > 0 and (p_qtyminb > 0 or (p_timstrtb is not null and v_dteotst_b between v_dtest_b and v_dteen_b) or (p_timendb is not null and v_dteoten_b between v_dtest_b and v_dteen_b) or (v_dtest_b between v_dteotst_b and v_dteoten_b) or (v_dteen_b between v_dteotst_b and v_dteoten_b)) then
            if  (p_qtyminb > 0 or (p_timstrtb is not null and v_dteotst_b between v_dtest_b and v_dteen_b) or (p_timendb is not null and v_dteoten_b between v_dtest_b and v_dteen_b) or (v_dtest_b between v_dteotst_b and v_dteoten_b) or (v_dteen_b between v_dteotst_b and v_dteoten_b)) then
-->>10/11/2022 15:17  error NMT: redmine415            
              v_typot     		    := 'B';
              v_timstrt 			:= p_timstrtb;
              v_timend  			:= p_timendb;
              v_qtyminr          := p_qtyminb;

              -->> user18 ST11 05/08/2021 change std
              v_report_numseq := v_report_numseq + 1;
              insert into ttemprpt (codempid,codapp,numseq,
                                    item1,item2,item3,item4,item5,
                                    item6,item7,item8,item9,item10,
                                    item11,item12,item13,item14,item15,
                                    item16,item17,item18,item19,item20,
                                    item21,item22,item23,item24)
              values(global_v_codempid,'HRAL41E',v_report_numseq,
                                        to_char(i.dtework,'dd/mm/yyyy'),i.codempid,
                                        get_temploy_name(i.codempid,global_v_lang),
                                        'B',v_codcompw,i.codcalen,i.codshift,
                                        to_char(to_date(v_timstrt,'hh24:mi'), 'hh24:mi'),
                                        to_char(to_date(v_timend,'hh24:mi'), 'hh24:mi'),
                                        decode(nvl(v_qtyminr,0),0,null,hcm_util.convert_minute_to_hour(v_qtyminr)),p_flgchglv,
                                        v_cost_center,
                                        null, --item13
                                        to_char(v_dtestrtwk,'dd/mm/yyyy'),to_char(v_dteendwk,'dd/mm/yyyy'), --item14,item15
                                        hcm_util.convert_minute_to_hour(v_qtydaywk),null, --item16,item17
                                        hcm_util.convert_minute_to_hour(v_qtyminotb),null, --item18,item19
                                        1,0,0,'',v_staovrot);
              --<< user18 ST11 05/08/2021 change std
            end if;
          end if;

          -- During Work
--<<10/11/2022 15:17  error NMT: redmine415          
          --if v_qtyminotd > 0 and (p_timstrtd is not null or p_timendd is not null or (p_qtymind is not null and p_qtymind > 0)) then
          if (p_timstrtd is not null or p_timendd is not null or (p_qtymind is not null and p_qtymind > 0)) then
-->>10/11/2022 15:17  error NMT: redmine415          
                -- check OT in range
                v_dtest_d     := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(v_timstotd, '0000'), 'YYYYMMDDHH24MI');
                v_dteen_d     := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(v_timenotd, nvl(v_timstotd, '0000')), 'YYYYMMDDHH24MI');
                if v_timenotd is null then
                  v_dteen_d   := v_dteen_d + 1;
                elsif nvl(to_number(v_timstotd), 0) > nvl(to_number(v_timenotd), 0) then
                  v_dteen_d   := i.dtework + 1;
                end if;

                v_dteotst_d   := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(p_timstrtd, '0000'), 'YYYYMMDDHH24MI');
                v_dteoten_d   := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(p_timendd, nvl(p_timstrtd, '0000')), 'YYYYMMDDHH24MI');
                if nvl(to_number(v_timstrtw), 0) > nvl(to_number(p_timstrtd), 0) then
                  v_dteotst_d := v_dteotst_d + 1;
                  v_dteoten_d := v_dteoten_d + 1;
                elsif nvl(to_number(p_timstrtd), 0) > nvl(to_number(p_timendd), 0) then
                  v_dteoten_d := v_dteoten_d + 1;
                end if;
                if p_qtymind > 0 or (p_timstrtd is not null and v_dteotst_d between v_dtest_d and v_dteen_d) or (p_timendd is not null and v_dteoten_d between v_dtest_d and v_dteen_d) or (v_dtest_d between v_dteotst_d and v_dteoten_d) or (v_dteen_d between v_dteotst_d and v_dteoten_d) then
      --            if (p_typwork in ('A','H','T','S') and i.typwork in ('H','T','S')) then
                    v_typot     	:= 'D';
                    v_timstrt 		:= p_timstrtd;
                    v_timend  		:= p_timendd;
                    v_qtyminr     := p_qtymind;
                    -->> user18 ST11 05/08/2021 change std
                    v_report_numseq := v_report_numseq + 1;
                    insert into ttemprpt (codempid,codapp,numseq,
                                        item1,item2,item3,item4,item5,
                                        item6,item7,item8,item9,item10,
                                        item11,item12,item13,item14,item15,
                                        item16,item17,item18,item19,item20,
                                        item21,item22,item23,item24)
                    values(global_v_codempid,'HRAL41E',v_report_numseq,
                                        to_char(i.dtework,'dd/mm/yyyy'),i.codempid,
                                        get_temploy_name(i.codempid,global_v_lang),
                                        'D',v_codcompw,i.codcalen,i.codshift,
                                        to_char(to_date(v_timstrt,'hh24:mi'), 'hh24:mi'),
                                        to_char(to_date(v_timend,'hh24:mi'), 'hh24:mi'),
                                        decode(nvl(v_qtyminr,0),0,null,hcm_util.convert_minute_to_hour(v_qtyminr)),p_flgchglv,
                                        v_cost_center,
                                        null, --item13
                                        to_char(v_dtestrtwk,'dd/mm/yyyy'),to_char(v_dteendwk,'dd/mm/yyyy'), --item14,item15
                                        hcm_util.convert_minute_to_hour(v_qtydaywk),null, --item16,item17
                                        hcm_util.convert_minute_to_hour(v_qtyminotd),null, --item18,item19
                                        1,0,0,'',v_staovrot);
                    --<< user18 ST11 05/08/2021 change std
            end if;
          end if;
          -- After Work

--<<10/11/2022 15:17  error NMT: redmine415
          --if v_qtyminota > 0 and (p_timstrta is not null or p_timenda is not null or (p_qtymina is not null and p_qtymina > 0)) then
          if   (p_timstrta is not null or p_timenda is not null or (p_qtymina is not null and p_qtymina > 0)) then
-->>10/11/2022 15:17  error NMT: redmine415  

                -- check OT in range
                v_dtest_a     := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(v_timstota, '0000'), 'YYYYMMDDHH24MI');
                v_dteen_a     := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(v_timenota, nvl(v_timstota, '0000')), 'YYYYMMDDHH24MI');
                if v_timenota is null then
                  v_dteen_a   := v_dtest_a + 1;
                elsif nvl(to_number(v_timstota), 0) > nvl(to_number(v_timenota), 0) then
                  v_dteen_a   := i.dtework + 1;
                end if;
                if nvl(to_number(v_timstota), 0) < nvl(to_number(v_timstrtw), 0) then
                  v_dtest_a   := v_dtest_a + 1;
                  v_dteen_a   := v_dteen_a + 1;
                end if;

                v_dteotst_a   := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(p_timstrta, '0000'), 'YYYYMMDDHH24MI');
                v_dteoten_a   := to_date(to_char(i.dtework, 'YYYYMMDD') || nvl(p_timenda, nvl(p_timstrta, '0000')), 'YYYYMMDDHH24MI');
                if nvl(to_number(v_timstrtw), 0) > nvl(to_number(p_timstrta), 0) then
                  v_dteotst_a := v_dteotst_a + 1;
                  v_dteoten_a := v_dteoten_a + 1;
                elsif nvl(to_number(p_timstrta), 0) > nvl(to_number(p_timenda), 0) then
                  v_dteoten_a := v_dteoten_a + 1;
                end if;

                if p_qtymina > 0 or (p_timstrta is not null and v_dteotst_a between v_dtest_a and v_dteen_a) or (p_timenda is not null and v_dteoten_a between v_dtest_a and v_dteen_a) or (v_dtest_a between v_dteotst_a and v_dteoten_a) or (v_dteen_a between v_dteotst_a and v_dteoten_a) then
                  v_typot           := 'A';
                  v_timstrt         := p_timstrta;
                  v_timend          := p_timenda;
                  v_qtyminr         := p_qtymina;

                  -->> user18 ST11 05/08/2021 change std
                  v_report_numseq := v_report_numseq + 1;
                  insert into ttemprpt (codempid,codapp,numseq,
                                        item1,item2,item3,item4,item5,
                                        item6,item7,item8,item9,item10,
                                        item11,item12,item13,item14,item15,
                                        item16,item17,item18,item19,item20,
                                        item21,item22,item23,item24)
                  values(global_v_codempid,'HRAL41E',v_report_numseq,
                                        to_char(i.dtework,'dd/mm/yyyy'),i.codempid,
                                        get_temploy_name(i.codempid,global_v_lang),
                                        'A',v_codcompw,i.codcalen,i.codshift,
                                        to_char(to_date(v_timstrt,'hh24:mi'), 'hh24:mi'),
                                        to_char(to_date(v_timend,'hh24:mi'), 'hh24:mi'),
                                        decode(nvl(v_qtyminr,0),0,null,hcm_util.convert_minute_to_hour(v_qtyminr)),p_flgchglv,
                                        v_cost_center,
                                        null, --item13
                                        to_char(v_dtestrtwk,'dd/mm/yyyy'),to_char(v_dteendwk,'dd/mm/yyyy'), --item14,item15
                                        hcm_util.convert_minute_to_hour(v_qtydaywk),null, --item16,item17
                                        hcm_util.convert_minute_to_hour(v_qtyminota),null, --item18,item19
                                        1,0,0,'',v_staovrot);
                  --<< user18 ST11 05/08/2021 change std
                end if;
          end if;
          --
          exit cal_loop;
        end loop;
      end if;
      <<next_day>>
      null;
    end loop;

    if v_typalert <> 'N' then
        for r_temp in c_temp loop
            v_codempid_tmp              := r_temp.codempid;
            v_dtestrtwk                 := r_temp.dtestrtwk;
            v_dteendwk                  := r_temp.dteendwk;
            std_ot.get_week_ot(v_codempid_tmp, '',v_dtewkreq,'',v_dtestrtwk,v_dteendwk,
                               null, null, null,
                               null, null, null,
                               null, null, null,
                               global_v_codempid,
                               a_dtestweek,a_dteenweek,
                               a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
            v_qtydaywk                  := a_sumwork(1);
            v_qtyminotOth_cumulative    := std_ot.get_qtyminotOth_notTmp (v_codempid_tmp ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);

            for r2 in c_temp2 loop
              v_qtyot_total     := v_qtyminotOth_cumulative + hcm_util.convert_time_to_minute(r2.item18);
              v_qtytotal        := v_qtydaywk + v_qtyot_total;

              if (v_qtyot_total > v_qtymxotwk or v_qtytotal > v_qtymxallwk) then
                  if v_typalert = '2' then
                    delete ttemprpt
                     where codempid = r2.codempid
                       and codapp = r2.codapp
                       and numseq = r2.numseq;
                  end if;
              end if;
              v_qtyminotOth_cumulative := v_qtyot_total;
            end loop;

            v_qtyminotOth_cumulative    := std_ot.get_qtyminotOth_notTmp (v_codempid_tmp ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);
            for r2 in c_temp2 loop
              v_qtyminotOth := std_ot.get_qtyminotOth_notTmp (r2.item2 ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);
              SELECT sum(hcm_util.convert_time_to_minute(item18))
                into v_tmp_qtyot_req
                FROM ttemprpt
               WHERE codempid = r2.codempid
                 AND codapp = r2.codapp
                 and item2 = r2.item2
                 and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
                 and numseq <> r2.numseq;

              v_qtyminotOth     := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
              v_ttemprpt.item17 := hcm_util.convert_minute_to_hour(v_qtyminotOth);
              v_ttemprpt.item19 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r2.item18) + v_qtyminotOth);
              v_ttemprpt.item13 := hcm_util.convert_minute_to_hour(v_qtydaywk + hcm_util.convert_time_to_minute(r2.item18) + v_qtyminotOth);
              v_qtyot_total     := v_qtyminotOth_cumulative + hcm_util.convert_time_to_minute(r2.item18);
              v_qtytotal        := v_qtydaywk + v_qtyot_total;
              v_ttemprpt.item30 := v_qtyot_total;
              v_ttemprpt.item31 := v_qtytotal;

              if (v_qtyot_total > v_qtymxotwk or v_qtytotal > v_qtymxallwk) then
                  if v_typalert = '1' then
                    v_staovrot   := 'Y';
                  elsif v_typalert = '2' then
                    delete ttemprpt
                     where codempid = r2.codempid
                       and codapp = r2.codapp
                       and numseq = r2.numseq;
                  end if;
              else
                  v_staovrot   := 'N';
              end if;
              v_qtyminotOth_cumulative := v_qtyot_total;

              update ttemprpt
                 set item17 = v_ttemprpt.item17,
                     item19 = v_ttemprpt.item19,
                     item13 = v_ttemprpt.item13,
                     item24 = v_staovrot,
                     item30 = v_ttemprpt.item30,
                     item31 = v_ttemprpt.item31
               where codempid = r2.codempid
                 and codapp = r2.codapp
                 and numseq = r2.numseq;
            end loop;
        end loop;
    end if;

    v_rcnt          := 0;
    for r1 in c1 loop
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('seqno',r1.numseq); --dtestrt
        obj_data.put('dtewkreq',r1.item1); --dtewkreq
        obj_data.put('dtewkreqOld',r1.item1); --dtewkreq
        obj_data.put('codempid',r1.item2); -- codempid
        obj_data.put('codempidOld',r1.item2); -- codempid
        obj_data.put('desc_codempid',r1.item3); --desc_codempid
        obj_data.put('typot',r1.item4); --typot
        obj_data.put('codcompw',r1.item5); --codcompw
        obj_data.put('codcalen',r1.item6); --codcalen
        obj_data.put('codshift',r1.item7); --codshift
        obj_data.put('timstrt',r1.item8); --timstrt
        obj_data.put('timend',r1.item9); --timend
        obj_data.put('qtyminr',r1.item10); --qtyminr
        obj_data.put('flgchglv',r1.item11); --flgchglv
        obj_data.put('cost_center',r1.item12); --cost_center
        obj_data.put('qtytotal',r1.item13); --qtytotal
        obj_data.put('dtestrtwk',r1.item14);--dtestrtwk
        obj_data.put('dteendwk',r1.item15);--,dteendwk
        obj_data.put('qtydaywk',r1.item16); --qtydaywk
        obj_data.put('qtyot_reqoth',r1.item17); --qtyot_reqoth
        obj_data.put('qtyot_req',r1.item18); --qtyot_req
        obj_data.put('qtyot_total',r1.item19); --qtyot_total
        obj_data.put('numotreq',r1.item23);
        obj_data.put('staovrot',r1.item24);
        obj_data.put('typalert',v_typalert);
        obj_data.put('flgAdd',true);
        obj_data.put('flgEditBtn',false);
        obj_result.put(to_char(v_rcnt-1),obj_data);
    end loop;
    -- get row json
    obj_row.put('coderror', '200');
    obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
    obj_row.put('details', obj_result);

    if param_msg_error is null then
      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  end;

  procedure get_cost_center(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    json_obj      json_object_t := json_object_t(json_str_input);
    v_codcenter   varchar2(1000 char);
    v_codcomp     varchar2 (1000 char);
    v_total       number := 0;
  begin
    v_codcomp := hcm_util.get_string_t(json_obj,'p_codcomp');
    begin
--      select codcompgl into v_codcenter
--        from tsecdep
      select costcent into v_codcenter
        from tcenter
       where codcomp = v_codcomp
--       where codcomp like v_codcomp || '%'
         and v_codcomp is not null
         and rownum <= 1
    order by codcomp;
    exception when no_data_found then
      v_codcenter := null;
    end;

    obj_row := json_object_t();
    obj_row.put('coderror', '200');
    obj_row.put('cost_center', v_codcenter);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_after_save is
    v_qtymxotwk             tcontrot.qtymxotwk%type;
    v_qtymxallwk            tcontrot.qtymxallwk%type;
    v_typalert              tcontrot.typalert%type;
    v_tmp_qtyot_req         number;
    v_qtyminb               number;
    v_timendb               varchar2(4000 char);
    v_timstrtb              varchar2(4000 char);
    v_qtymind               number;
    v_timendd               varchar2(4000 char);
    v_timstrtd              varchar2(4000 char);
    v_qtymina               number;
    v_timenda               varchar2(4000 char);
    v_timstrta              varchar2(4000 char);
  begin
    begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = p_codempid;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
    end;

    if p_dtewkreq not between p_dtestrt and p_dteend then
        param_msg_error := get_error_msg_php('AL0021',global_v_lang);
        return;
    end if;

    begin
        select nvl(qtymxotwk,0), qtymxallwk, nvl(typalert,'N')
          into v_qtymxotwk, v_qtymxallwk, v_typalert
          from tcontrot
         where codcompy = hcm_util.get_codcompy(v_codcomp)
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = hcm_util.get_codcompy(v_codcomp)
                              and dteeffec <= sysdate);
    exception when others then
        v_qtymxotwk     := 0;
        v_qtymxallwk    := 0;
        v_typalert      := 'N';
    end;
    if v_typalert <> 'N' then
        if nvl(p_flgconfirm,'N') = 'N' then
            std_ot.get_week_ot(p_codempid, p_numotreq,p_dtereq,'',v_dtestrtwk,v_dteendwk,
                               null, null, null,
                               null, null, null,
                               null, null, null,
                               global_v_codempid,
                               a_dtestweek,a_dteenweek,
                               a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
            v_qtydaywk      := a_sumwork(1);

            v_qtyminotOth := std_ot.get_qtyminotOth_notTmp (p_codempid ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);

            begin
              SELECT sum(hcm_util.convert_time_to_minute(item18))
                into v_tmp_qtyot_req
                FROM ttemprpt
               WHERE codempid = global_v_codempid
                 AND codapp = 'HRAL41E'
                 and item2 = p_codempid
                 and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
                 and numseq < v_report_numseq;
            exception when others then
                v_tmp_qtyot_req := 0;
            end;

            if p_typot = 'B' then
                v_qtyminb   := p_qtyminb;
                v_timendb   := p_timendb;
                v_timstrtb  := p_timstrtb;
            elsif p_typot = 'D' then
                v_qtymind   := p_qtymind;
                v_timendd   := p_timendd;
                v_timstrtd  := p_timstrtd;
            elsif p_typot = 'A' then
                v_qtymina   := p_qtymina;
                v_timenda   := p_timenda;
                v_timstrta  := p_timstrta;
            end if;

            v_qtyminotOth   := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
            v_qtyminot      := std_ot.get_qtyminot(p_codempid, p_dtewkreq, p_dtewkreq,
                                                   v_qtyminb, v_timendb, v_timstrtb,
                                                   v_qtymind, v_timendd, v_timstrtd,
                                                   v_qtymina, v_timenda, v_timstrta);

            v_qtyot_total   := v_qtyminotOth + v_qtyminot;
            v_qtytotal      := v_qtydaywk + v_qtyminotOth + v_qtyminot;
            if (v_qtyot_total > v_qtymxotwk) then
                if v_typalert = '1' then
                    if v_msgerror is null  then
                        v_msgerror      := replace(get_error_msg_php('AL0080',global_v_lang),'@#$%400');
                    end if;
                elsif v_typalert = '2' then
                    param_msg_error := get_error_msg_php('AL0080',global_v_lang);
                end if;
                return;
            end if;

            if (v_qtytotal > v_qtymxallwk) then
                if v_typalert = '1' then
                    if v_msgerror is null then
                        v_msgerror      := replace(get_error_msg_php('AL0081',global_v_lang),'@#$%400');
                    end if;
                elsif v_typalert = '2' then
                    param_msg_error := get_error_msg_php('AL0081',global_v_lang);
                end if;
                return;
            end if;
        end if;
    end if;
  end;

  procedure post_detail(json_str_input in clob, json_str_output out clob) is
    obj_row         json_object_t;
    json_obj        json_object_t;
    param_json      json_object_t;
    param_json_row  json_object_t;
    v_error_code    varchar2(100 char) := '400';
  begin
    initial_value(json_str_input);

    save_overtime_detail;
    if param_msg_error is not null then
        json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
        return;
    end if;
    --

    if p_flgProcess = 'Y' Then
      if p_numotreq is not null then
        delete totreqd where numotreq = p_numotreq;
      end if;
    end if;
    --
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row   := hcm_util.get_json_t(param_json,to_char(i));

        p_codempid       := hcm_util.get_string_t(param_json_row,'codempid');
        p_dtewkreq       := to_date(hcm_util.get_string_t(param_json_row,'dtewkreq'),'dd/mm/yyyy');
        p_typot          := hcm_util.get_string_t(param_json_row,'typot');
        p_codcompw       := hcm_util.get_string_t(param_json_row,'codcompw');
        p_codshift       := hcm_util.get_string_t(param_json_row,'codshift');
        p_timstrt        := replace(hcm_util.get_string_t(param_json_row,'timstrt'),':','');
        p_timend         := replace(hcm_util.get_string_t(param_json_row,'timend'),':','');
        p_dtestrt_ot     := to_date(hcm_util.get_string_t(param_json_row,'dtestrt'),'dd/mm/yyyy');
        p_dteend_ot      := to_date(hcm_util.get_string_t(param_json_row,'dteend'),'dd/mm/yyyy');
        p_qtyminr        := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(param_json_row,'qtyminr'));
        p_flgchglv       := hcm_util.get_string_t(param_json_row,'flgchglv');
        p_flg            := hcm_util.get_string_t(param_json_row,'flg');

        v_dtestrtwk       := to_date(hcm_util.get_string_t(param_json_row,'dtestrtwk'),'dd/mm/yyyy');
        v_dteendwk        := to_date(hcm_util.get_string_t(param_json_row,'dteendwk'),'dd/mm/yyyy');
        v_report_numseq   := hcm_util.get_string_t(param_json_row,'seqno');
        if p_typot = 'B' then
            p_timstrtb  := p_timstrt;
            p_timendb   := p_timend;
            p_qtyminb   := p_qtyminr;
        elsif p_typot = 'D' then
            p_timstrtd  := p_timstrt;
            p_timendd   := p_timend;
            p_qtymind   := p_qtyminr;
        elsif p_typot = 'A' then
            p_timstrta  := p_timstrt;
            p_timenda   := p_timend;
            p_qtymina   := p_qtyminr;
        end if;
        if  p_flg = 'delete' then
          delete_employee_detail;
        else
          param_msg_error := null;
          check_totreqd;
          if param_msg_error is not null then
            param_msg_error   := to_char(p_dtewkreq,'dd/mm/yyyy')||' - '||p_codempid||' '||param_msg_error;
            exit;
          end if;

          save_employee_detail;
          -->> user18 ST11 04/08/2021 change std
          check_after_save;
          if param_msg_error is not null then
            exit;
          end if;
          if v_msgerror is not null then
--            rollback;
--            return;
            exit;
          end if;
          --<< user18 ST11 04/08/2021 change std
        end if;
      end loop;

      if param_msg_error is null and v_msgerror is null then
        v_error_code := '201';
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        commit;
      else
        rollback;
      end if;
    end if;

    obj_row := json_object_t();
    obj_row.put('numotreq', p_numotreq);
    if v_msgerror is not null then
        obj_row.put('coderror', '201');
        obj_row.put('response', v_msgerror);
        obj_row.put('flg', 'warning');
    else
        obj_row.put('coderror', v_error_code);
        obj_row.put('response', replace(param_msg_error,'@#$%'||v_error_code,''));
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end post_detail;

  procedure save_overtime_detail is
    v_check      varchar2(100);
    v_codcomp    varchar2(100);
    v_typ_grp    varchar2(100);
  begin
    begin
      select count(*)  into v_check
        from totreqst
       where numotreq = p_numotreq;
    exception when no_data_found then
      v_check := 0;
    end;

    if p_codcomp is null then
       begin
        select codcomp into v_codcomp
          from temploy1
          where codempid = p_codempid;
        exception when others then
          v_codcomp := null;
       end;
    else
      v_codcomp := p_codcomp;
    end if;

    v_typ_grp := '';
    if p_typotreq = '2' then
      v_typ_grp := 'G';
    end if;



    --
    if v_check = 0 then
      p_numotreq := std_al.gen_req('OTRQ','TOTREQST','NUMOTREQ', global_v_zyear,hcm_util.get_codcompy(v_codcomp),v_typ_grp);
      std_al.upd_req('OTRQ',p_numotreq,global_v_coduser, global_v_zyear,hcm_util.get_codcompy(v_codcomp),v_typ_grp);
      insert into totreqst(numotreq, dtereq, codempid, codcomp, codcalen, dtestrt, dteend,
                           codshift, typotreq, timstrta, timenda, timstrtb, timendb, timstrtd, timendd, codrem, codappr,
                           staotreq, dteappr, dtecancl, remark, dayeupd, codcompw, flgchglv, qtymina, qtyminb, qtymind,
                           typwork, dteupd, dtecreate, coduser, codcreate)
             values(p_numotreq, trunc(sysdate), p_codempid, p_codcomp, p_codcalen, p_dtestrt, p_dteend,
                    p_codshift, p_typotreq, p_timstrta, p_timenda, p_timstrtb, p_timendb, p_timstrtd, p_timendd, p_codrem, p_codappr,
                    p_staotreq, p_dteappr, p_dtecancl, p_remark, p_dayeupd, p_codcompw, p_flgchglv, p_qtymina, p_qtyminb, p_qtymind,
                    p_typwork, trunc(sysdate), trunc(sysdate), global_v_coduser, global_v_coduser);
    else
      if p_dtecancl is not null and p_dtecancl <= p_dayeupd then
        param_msg_error := get_error_msg_php('AL0026',global_v_lang);
        return;
      end if;

      update totreqst set dtereq   = p_dtereq,
                          codempid = p_codempid,
                          codcomp  = p_codcomp,
                          codcalen = p_codcalen,
                          dtestrt  = p_dtestrt,
                          dteend   = p_dteend,
                          codshift = p_codshift,
                          typotreq = p_typotreq,
                          timstrta = p_timstrta,
                          timenda  = p_timenda,
                          timstrtb = p_timstrtb,
                          timendb  = p_timendb,
                          timstrtd = p_timstrtd,
                          timendd  = p_timendd,
                          codrem   = p_codrem,
                          codappr  = p_codappr,
                          staotreq = p_staotreq,
                          dteappr  = p_dteappr,
                          dtecancl = p_dtecancl,
                          remark   = p_remark,
                          dayeupd  = p_dayeupd,
                          codcompw = p_codcompw,
                          flgchglv = p_flgchglv,
                          qtymina  = p_qtymina,
                          qtyminb  = p_qtyminb,
                          qtymind  = p_qtymind,
                          typwork  = p_typwork,
                          dteupd   = trunc(sysdate),
                          coduser  = global_v_coduser
                    where numotreq = p_numotreq;
    end if;
  end;

  procedure save_employee_detail is
    v_codcomp     totreqd.codcomp%type;
    v_codcalen    totreqd.codcalen%type;
  begin
    begin
      select codcomp,codcalen
        into v_codcomp,v_codcalen
        from tattence
       where codempid    = p_codempid
         and dtework     = p_dtewkreq;
    exception when no_data_found then null;
    end;
    /*if p_codempid is not null then
      begin
        select  codcomp
              , codcalen --09/03/2021
        into    v_codcomp
              , v_codcalen --09/03/2021
        from    tattence
        where   codempid    = p_codempid
        and     dtework     = p_dtewkreq;
      exception when no_data_found then
        begin
          select codcomp, codcalen
            into v_codcomp, v_codcalen
            from temploy1
           where codempid = p_codempid;
        exception when no_data_found then
          v_codcomp     := p_codcomp;
          v_codcalen    := p_codcalen;
        end;
      end;
    else
      v_codcomp     := p_codcomp;
      v_codcalen    := p_codcalen;
    end if;*/
    -- check flgchglv
    if p_flgchglv is null then
      p_flgchglv := 'N';
    end if;
    -- check qtyminr is not null
    if nvl(p_qtyminr,0) > 0 then
      p_timstrt    := null;
      p_timend     := null;
      p_dtestrt_ot := null;
      p_dteend_ot  := null;
    else
     p_qtyminr := null;
    end if;
    --
    if param_msg_error is null then
      if  p_flg = 'add' then
        begin
          insert into totreqd(dtewkreq, codempid, typot, codshift, timstrt, timend, qtyminr, dtestrt, dteend,
                              numotreq, codcomp, codcompw, codcalen, flgchglv, coduser, dteupd, codcreate, dtecreate)
                values(p_dtewkreq, p_codempid, p_typot, p_codshift, p_timstrt, p_timend, p_qtyminr, p_dtestrt_ot, p_dteend_ot,
                       p_numotreq, v_codcomp, p_codcompw, v_codcalen, p_flgchglv, global_v_coduser, trunc(sysdate), global_v_coduser, trunc(sysdate));
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
      elsif  p_flg = 'edit' then
        begin
          update totreqd set codshift = p_codshift,
                             timstrt  = p_timstrt,
                             timend   = p_timend,
                             dtestrt  = p_dtestrt_ot,
                             dteend   = p_dteend_ot,
                             qtyminr  = p_qtyminr,
                             codcomp  = v_codcomp,
                             codcompw = p_codcompw,
                             codcalen = v_codcalen,
                             flgchglv = p_flgchglv,
                             coduser  = global_v_coduser,
                             dteupd   = trunc(sysdate)
                       where numotreq = p_numotreq
                         and dtewkreq = p_dtewkreq
                         and codempid = p_codempid
                         and typot    = p_typot;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        end;
      end if;

      update ttemprpt
         set item23 = p_numotreq
       where codapp = 'HRAL41E'
         and codempid = global_v_codempid
         and numseq = v_report_numseq;

    else
      return;
    end if;
  end save_employee_detail;

  procedure delete_employee_detail is
  begin
    begin
      delete from totreqd
            where numotreq = p_numotreq
              and dtewkreq = p_dtewkreq
              and codempid = p_codempid
              and typot    = p_typot;
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end;
  end delete_employee_detail;

  procedure delete_index(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    json_obj        json_object_t;
    global_json     json_object_t;
    param_json      json_object_t;
    param_json_row  json_object_t;
  begin
    initial_value(json_str_input);
    param_json := hcm_util.get_json_t(json_object_t(json_str_input),'json_input_str');
    if param_msg_error is null then
      for i in 0..param_json.get_size-1 loop
        param_json_row   := hcm_util.get_json_t(param_json,to_char(i));
        p_numotreq       := hcm_util.get_string_t(param_json_row,'numotreq');
        p_flg            := hcm_util.get_string_t(param_json_row,'flg');

        if p_flg = 'delete' then
          begin
            delete from totreqst
                  where numotreq = p_numotreq;
          end;
        end if;
      end loop;

      if param_msg_error is null then
        param_msg_error := get_error_msg_php('HR2425',global_v_lang);
        commit;
      else
        rollback;
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end delete_index;

  procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_error         varchar2(1000 char);
    v_flgsecu       boolean := false;
    v_rec_tran      number;
    v_rec_err       number;
    v_numseq        varchar2(1000 char);
    v_rcnt          number  := 0;
  begin
    initial_value(json_str_input);
    -->> user18 ST11 05/08/2021 change std
    begin
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRAL41E';
    exception when others then
        null;
    end;
    v_report_numseq := 0;
    --<< user18 ST11 05/08/2021 change std
    format_text_json(json_str_input, v_rec_tran, v_rec_err);
    --
    if param_msg_error is null then
      obj_row    := json_object_t();
      obj_result := json_object_t();
      obj_row.put('coderror', '200');
      if v_msgerror is null then
          obj_row.put('rec_tran', v_rec_tran);
          obj_row.put('rec_err', v_rec_err);
          obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
      else
          obj_row.put('response', v_msgerror);
          obj_row.put('flg', 'warning');
      end if;
      if p_numseq.exists(p_numseq.first) then
        for i in p_numseq.first .. p_numseq.last
        loop
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('text', p_text(i));
          obj_data.put('error_code', p_error_code(i));
          obj_data.put('numseq', p_numseq(i) + 1);
          obj_result.put(to_char(v_rcnt-1),obj_data);
        end loop;
      end if;

      obj_row.put('datadisp', obj_result);

      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    --
    v_filename  	   varchar2(1000);
    linebuf  			   varchar2(6000);
    data_file 		   varchar2(6000);
    v_column			   number := 12;
    v_error				   boolean;
    v_err_code  	   varchar2(1000);
    v_err_filed  	   varchar2(1000);
    v_err_table		   varchar2(20);
    v_comments  	   varchar2(1000);
    v_namtbl    	   varchar2(300);
    i 						   number;
    j 						   number;
    k 						   number;
    v_numseq    	   number := 0;
    --
    v_dtereq 			   totreqst.dtereq%type;
    v_codempid		   temploy1.codempid%type;
    v_dtewkreq 		   totreqd.dtewkreq%type;
    v_timbstr  		   varchar2(4 char);
    v_timbend  		   varchar2(4 char);
    v_qtyminb  		   varchar2(4 char);
    v_timdstr  		   varchar2(4 char);
    v_timdend  		   varchar2(4 char);
    v_qtymind  		   varchar2(4 char);
    v_timastr  		   varchar2(4 char);
    v_timaend  		   varchar2(4 char);
    v_qtymina  		   varchar2(4 char);
    v_codrem			   totreqst.codrem%type;
    v_codappr			   totreqst.codappr%type;
    v_dteappr			   totreqst.dteappr%type;
    v_flgchglv  	   totreqst.flgchglv%type;
    --
    v_code				   varchar2(100);
    v_codcomp			   temploy1.codcomp%type;
    v_staempap		   temploy1.staemp%type;
    v_numlvlap		   temploy1.numlvl%type;
    v_typot	    	   totreqd.typot%type;
    v_dtestrt  		   totreqd.dtestrt%type;
    v_dteend   		   totreqd.dteend%type;
    v_timstrt  		   totreqd.timstrt%type;
    v_timend    	   totreqd.timend%type;
    v_qtyminr        totreqd.qtyminr%type;
    v_dtewkst  		   date;
    v_dtewken   	   date;
    v_dteotst   	   date;
    v_dteoten   	   date;
    v_codcompw       totreqd.codcompw%type;
    v_flag				   varchar2(1);
    v_numotreq		   totreqd.numotreq%type;
    v_flgfound  	   boolean;
    v_cnt					   number := 0;
    v_codapp			   varchar2(10) := 'HRAL41EP3';
    v_typotreq       varchar2(10);
    v_num            number := 0;
    v_flg_dup        varchar2(1);
    v_typ_grp    varchar2(100);
    type text is table of varchar2(1000) index by binary_integer;
      v_text   text;
      v_filed  text;

    cursor c_tattence is
      select codempid,dtework,codcomp,typwork,codshift,codcalen,dtestrtw,timstrtw,dteendw,timendw
        from tattence
       where codempid = v_codempid
         and dtework  = v_dtewkreq;
  begin
    v_rec_tran  := 0;
    v_rec_error := 0;
    --
    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    p_flgconfirm := hcm_util.get_string_t(param_json, 'flgconfirm');
    -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_filed(v_num)    := hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
      param_json_row  := hcm_util.get_json_t(param_data,to_char(i));
      begin
        v_err_code  := null;
        v_err_filed := null;
        v_err_table := null;
        linebuf     := i;
        v_numseq    := v_numseq;
        v_error 	  := false;
        --
        if v_numseq = 0 then
          <<cal_loop>> loop
            v_text(1)   := hcm_util.get_string_t(param_json_row,'dtereq');
            v_text(2)   := hcm_util.get_string_t(param_json_row,'codempid');
            v_text(3)   := hcm_util.get_string_t(param_json_row,'dtewkreq');
            v_text(4)   := hcm_util.get_string_t(param_json_row,'timbstr');
            v_text(5)   := hcm_util.get_string_t(param_json_row,'timbend');
--            v_text(6)   := hcm_util.get_string_t(param_json_row,'qtyminb');
            v_text(6)   := hcm_util.get_string_t(param_json_row,'timdstr');
            v_text(7)   := hcm_util.get_string_t(param_json_row,'timdend');
--            v_text(9)   := hcm_util.get_string_t(param_json_row,'qtymind');
            v_text(8)  := hcm_util.get_string_t(param_json_row,'timastr');
            v_text(9)  := hcm_util.get_string_t(param_json_row,'timaend');
--            v_text(12)  := hcm_util.get_string_t(param_json_row,'qtymina');
            v_text(10)  := hcm_util.get_string_t(param_json_row,'codrem');
            v_text(11)  := hcm_util.get_string_t(param_json_row,'codcompw');
--            v_text(15)  := hcm_util.get_string_t(param_json_row,'flgchglv');
            v_text(12)  := hcm_util.get_string_t(param_json_row,'codappr');
            v_text(13)  := hcm_util.get_string_t(param_json_row,'dteappr');





            -- push row values
            data_file := null;
            for i in 1..13 loop
              if data_file is null then
                data_file := v_text(i);
              else
                data_file := data_file||','||v_text(i);
              end if;
            end loop;
--1.Validate --
            for i in 1..3 loop
              if v_text(i) is null then
                v_error	 	  := true;
                v_err_code  := 'HR2045';
                v_err_filed := v_filed(i);
                exit cal_loop;
              end if;
            end loop;
            -- check null time
            if v_text(4)  is null and v_text(5)  is null and
               v_text(6)  is null and v_text(7)  is null and
               v_text(8) is null and v_text(9) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              v_err_filed := v_filed(4);
              exit cal_loop;
            end if;
            if v_text(4) is not null or v_text(5) is not null then
                if v_text(4) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(4);
                  exit cal_loop;
                elsif v_text(5) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(5);
                  exit cal_loop;
                end if;
            end if;

            if v_text(6) is not null or v_text(7) is not null then
                if v_text(6) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(7);
                  exit cal_loop;
                elsif v_text(7) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(8);
                  exit cal_loop;
                end if;
            end if;

            if v_text(8) is not null or v_text(9) is not null then
                if v_text(8) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(10);
                  exit cal_loop;
                elsif v_text(9) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(11);
                  exit cal_loop;
                end if;
            end if;

            for i in 10..13 loop
              if v_text(i) is null and i <> 11 then
                v_error	 	:= true;
                v_err_code:= 'HR2045';
                v_err_filed := v_filed(i);
                exit cal_loop;
              end if;
            end loop;

            --1.dtereq
            v_error  := check_date(v_text(1),global_v_zyear);
            if v_error then
              v_error     := true;
              v_err_code  := 'HR2025' ;
              v_err_filed := v_filed(1) ;
              exit cal_loop;
            end if;
            v_dtereq := check_dteyre(v_text(1));

            --2.codempid
            begin
              select codcomp
                into v_codcomp
                from temploy1
               where codempid = upper(v_text(2));
            exception when no_data_found then
              v_error     := true;
              v_err_code  := 'HR2010' ;
              v_err_table := 'TEMPLOY1';
              v_err_filed := v_filed(2);
              exit cal_loop;
            end;
            -- check secure --
            if not secur_main.secur2(upper(v_text(2)),global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
              v_error     := true;
              v_err_code  := 'HR3007' ;
              v_err_filed := v_filed(2);
              exit cal_loop;
            end if;
            v_codempid := upper(v_text(2));

            -- 3.dtewkreq
            v_error  := check_date(v_text(3),global_v_zyear);
            if v_error then
              v_error     := true;
              v_err_code  := 'HR2025';
              v_err_filed := v_filed(3);
              exit cal_loop;
            end if;
            v_dtewkreq := check_dteyre(v_text(3));
            begin
              select codempid
                into v_code
                from tattence
               where codempid = v_codempid
                 and dtework  = v_dtewkreq;
            exception when no_data_found then
              v_error     := true;
              v_err_code  := 'HR2010' ;
              v_err_table := 'TATTENCE';
              v_err_filed := v_filed(3) ;
              exit cal_loop;
            end;

            if v_dtestrtwk is null then
                v_dtestrtwk     := std_ot.get_dtestrt_period (v_codempid, v_dtewkreq);
                v_dteendwk      := v_dtestrtwk + 6;
            end if;

            -- 4.timbstr
            if v_text(4) is not null then
              if length(v_text(4)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(4) ;
                exit cal_loop;
              end if;
              v_flgfound := check_times(v_text(4));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(4) ;
                exit cal_loop;
              end if;
            end if;
            v_timbstr := v_text(4);

            -- 5.timbend
            if v_text(5) is not null then
              if length(v_text(5)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015';
                v_err_filed := v_filed(5);
                exit cal_loop;
              end if;
              v_flgfound := check_times(v_text(5));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(5) ;
                exit cal_loop;
              end if;
            end if;
            v_timbend := v_text(5);

            -- 6.timdstr
            if v_text(6) is not null then
              if length(v_text(6)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(7) ;
                exit cal_loop;
              end if;
              v_flgfound := check_times(v_text(6));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(6) ;
                exit cal_loop;
              end if;
            end if;
            v_timdstr := v_text(6);

            -- 7.timdend
            if v_text(7) is not null then
              if length(v_text(7)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(7) ;
                exit cal_loop;
              end if;
              v_flgfound := check_times(v_text(7));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(7) ;
                exit cal_loop;
              end if;
            end if;
            v_timdend := v_text(7);

            -- 8.timastr
            if v_text(8) is not null then
              if length(v_text(8)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(10) ;
                exit cal_loop;
              end if;
              v_flgfound := check_times(v_text(8));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(8) ;
                exit cal_loop;
              end if;
            end if;
            v_timastr := v_text(8);

            -- 9.timaend
            if v_text(9) is not null then
              if length(v_text(9)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(9) ;
                exit cal_loop;
              end if;
              v_flgfound := check_times(v_text(9));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(9) ;
                exit cal_loop;
              end if;
            end if;
            v_timaend := v_text(9);

            -- 10.codrem
            if upper(v_text(10)) is not null then
              begin
                select codcodec	into v_code
                  from tcodotrq
                 where codcodec = upper(v_text(10));
              exception when no_data_found then
                v_error     := true;
                v_err_code  := 'HR2010';
                v_err_table := 'TCODOTRQ';
                v_err_filed := v_filed(10);
                exit cal_loop;
              end;
            end if;
            v_codrem := upper(v_text(10));

            -- 11.codcompw
            if upper(v_text(11)) is not null then
              begin
                select codcomp	into v_code
                  from tcenter
                 where codcomp = upper(v_text(11));
              exception when no_data_found then
                v_error     := true;
                v_err_code  := 'HR2010';
                v_err_table := 'TCENTER';
                v_err_filed := v_filed(11);
                exit cal_loop;
              end;
              --
              if hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,upper(v_text(11))) is not null then
                v_error     := true;
                v_err_code  := 'HR3007';
                v_err_filed := v_filed(11);
                exit cal_loop;
              end if;
            end if;
            v_codcompw := upper(v_text(11));

            -- 12.codappr
            begin
              select staemp,numlvl
                into v_staempap,v_numlvlap
                from temploy1
               where codempid = upper(v_text(12));
            exception when no_data_found then
              v_error     := true;
              v_err_code  := 'HR2010' ;
              v_err_table := 'TEMPLOY1';
              v_err_filed := v_filed(12) ;
              exit cal_loop;
            end;
            if v_staempap = '9' then
              v_error     := true;
              v_err_code  := 'HR2101' ;
              v_err_filed := v_filed(12);
              exit cal_loop;
            elsif v_staempap = '0' then
              v_error     := true;
              v_err_code  := 'HR2102' ;
              v_err_filed := v_filed(12);
              exit cal_loop;
            end if;
            -- check secure --
            if not secur_main.secur2(upper(v_text(12)),global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
              v_error     := true;
              v_err_code  := 'HR3007' ;
              v_err_filed := v_filed(12);
              exit cal_loop;
            end if;
            v_codappr := upper(v_text(12));

            -- 13.dteappr
            v_error  := check_date(v_text(13),global_v_zyear);
            if v_error then
              v_error     := true;
              v_err_code  := 'HR2025';
              v_err_filed := v_filed(13);
              exit cal_loop;
            end if;
            v_dteappr := check_dteyre(v_text(13));

            exit cal_loop;
          end loop; -- cal_loop

            -->> user18 04/03/2021
            v_qtyminb   := null;
            v_qtymind   := null;
            v_qtymina   := null;
            v_flgchglv  := 'N';
            -- << user18 04/03/2021

    --2.insert/update --
          if not v_error then
            if p_codcomp is null then
               begin
                select codcomp into v_codcomp
                  from temploy1
                  where codempid = v_codempid;
                exception when others then
                  v_codcomp := null;
               end;
            end if;
            v_rec_tran := v_rec_tran + 1;
            v_typotreq := '1';
            begin
              select 'Y'
                into v_flg_dup
                from totreqst
               where dtereq         = v_dtereq
                 and typotreq       = v_typotreq
                 and codempid       = v_codempid
                 and nvl(codappr,'$%#@') = nvl(v_codappr,'$%#@')
                 and nvl(dteappr,trunc(sysdate)) = nvl(v_dteappr,trunc(sysdate))
                 and nvl(codrem,'$%#@') = nvl(v_codrem,'$%#@')
                 and nvl(dtestrt,trunc(sysdate)) = nvl(v_dtewkreq,trunc(sysdate))
                 and nvl(dteend,trunc(sysdate))  = nvl(v_dtewkreq,trunc(sysdate))
                 and nvl(timstrtb,'$%#@') = nvl(v_timbstr,'$%#@')
                 and nvl(timendb,'$%#@') = nvl(v_timbend,'$%#@')
                 and nvl(qtyminb,99999999) = nvl(v_qtyminb,99999999)
                 and nvl(timstrtd,'$%#@') = nvl(v_timdstr,'$%#@')
                 and nvl(timendd,'$%#@') = nvl(v_timdend,'$%#@')
                 and nvl(qtymind,99999999) = nvl(v_qtymind,99999999)
                 and nvl(timstrta,'$%#@') = nvl(v_timastr,'$%#@')
                 and nvl(timenda,'$%#@') = nvl(v_timaend,'$%#@')
                 and nvl(qtymina,99999999) = nvl(v_qtymina,99999999)
                 and nvl(flgchglv,'$%#@') = nvl(v_flgchglv,'$%#@')
                 and nvl(codcompw,'$%#@') = nvl(v_codcompw,'$%#@')
                 and rownum = 1;
            exception when no_data_found then
              v_flg_dup := 'N';
            end;

            if v_flg_dup = 'N' then
              v_numotreq := std_al.gen_req('OTRQ','TOTREQST','NUMOTREQ',global_v_zyear,hcm_util.get_codcompy(v_codcomp));
              v_typ_grp := '';
            if p_typotreq = '2' then
              v_typ_grp := 'G';
            end if;
              std_al.upd_req('OTRQ',v_numotreq,global_v_coduser,global_v_zyear,hcm_util.get_codcompy(v_codcomp),v_typ_grp);
           --   std_al.upd_req('OTRQ',v_numotreq,global_v_coduser,global_v_zyear,'');
              for r_tattence in c_tattence loop
  --              if v_text(4) is not null then
  --                v_typot   := 'B';
  --              elsif v_text(6) is not null then
  --                v_typot   := 'D';
  --              else
  --                v_typot   := 'A';
  --              end if;

                -- change
               /* if v_text(4) is not null then
                  v_typotreq := '2';
                else
                  v_typotreq := '1';
                end if;  */
                --
                begin
                    select nvl(qtymxotwk,0), qtymxallwk, nvl(typalert,'N')
                      into v_qtymxotwk, v_qtymxallwk, v_typalert
                      from tcontrot
                     where codcompy = hcm_util.get_codcompy(r_tattence.codcomp)
                       and dteeffec = (select max(dteeffec)
                                         from tcontrot
                                        where codcompy = hcm_util.get_codcompy(r_tattence.codcomp)
                                          and dteeffec <= sysdate);
                exception when others then
                    v_qtymxotwk     := 0;
                    v_qtymxallwk    := 0;
                    v_typalert      := 'N';
                end;

                if v_typalert <> 'N' then
                  if nvl(p_flgconfirm,'N') = 'N' then

                    p_qtyminb   := v_qtyminb;
                    p_qtymind   := v_qtymind;
                    p_qtymina   := v_qtymina;

                    p_timendb   := v_timbend;
                    p_timstrtb  := v_timbstr;

                    p_timendd   := v_timdend;
                    p_timstrtd  := v_timdstr;

                    p_timenda   := v_timaend;
                    p_timstrta  := v_timastr;

                    std_ot.get_week_ot(v_codempid, v_numotreq,v_dtewkreq,'',v_dtewkreq, v_dtewkreq,
                                       p_qtyminb, p_timendb, p_timstrtb,
                                       p_qtymind, p_timendd, p_timstrtd,
                                       p_qtymina, p_timenda, p_timstrta,
                                       global_v_codempid,
                                       a_dtestweek,a_dteenweek,
                                       a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
                    v_qtydaywk      := a_sumwork(1);
                    v_qtyminotOth   := a_sumotreqoth(1);
                    v_qtyminot      := a_sumotreq(1);
                    v_qtyot_total   := a_sumot(1);
                    v_qtytotal      := a_totwork(1);

                    if (v_qtyot_total > v_qtymxotwk) then
                        if v_typalert = '1' then
                            if v_msgerror is null  then
                                v_msgerror      := replace(get_error_msg_php('AL0080',global_v_lang),'@#$%400');
                                rollback;
                                return;
                            end if;
                        elsif v_typalert = '2' then
                            v_rec_tran := v_rec_tran - 1;
                            v_rec_error     := v_rec_error + 1;
                            v_cnt           := v_cnt+1;

                            p_text(v_cnt)       := data_file;
                            p_error_code(v_cnt) := replace(get_error_msg_php('AL0080',global_v_lang),'@#$%400');
                            p_numseq(v_cnt)     := linebuf;
                        end if;
                        goto next_step_loop;
                    elsif v_qtytotal > v_qtymxallwk then
                        if v_typalert = '1' then
                            if v_msgerror is null  then
                                v_msgerror      := replace(get_error_msg_php('AL0081',global_v_lang),'@#$%400');
                                rollback;
                                return;
                            end if;
                        elsif v_typalert = '2' then
                            v_rec_tran := v_rec_tran - 1;
                            v_rec_error     := v_rec_error + 1;
                            v_cnt           := v_cnt+1;

                            p_text(v_cnt)       := data_file;
                            p_error_code(v_cnt) := replace(get_error_msg_php('AL0081',global_v_lang),'@#$%400');
                            p_numseq(v_cnt)     := linebuf;
                        end if;
                        goto next_step_loop;
                    end if;
                  end if;
                end if;

                insert into totreqst(numotreq,dtereq,typotreq,codempid,
                                     codcomp,codcalen,codshift,
                                     codappr,dteappr,codrem,
                                     dtestrt,dteend,staotreq,typwork,dteupd,coduser,codcreate,remark,
                                     timstrtb,timendb,qtyminb,timstrtd,timendd,qtymind,timstrta,timenda,qtymina,flgchglv,codcompw)-- user22 : 29/06/2016 : STA3590280 ||
                              values(v_numotreq,v_dtereq,v_typotreq,v_codempid,
                                     null,null,null, --09/03/2021 ||r_tattence.codcomp,r_tattence.codcalen,r_tattence.codshift,
                                     v_codappr,v_dteappr,v_codrem,
                                     v_dtewkreq,v_dtewkreq,'A','A',sysdate,global_v_coduser,global_v_coduser,'Import',
                                     v_timbstr,v_timbend,v_qtyminb,v_timdstr,v_timdend,v_qtymind,v_timastr,v_timaend,v_qtymina,v_flgchglv,v_codcompw);-- user22 : 29/06/2016 : STA3590280 ||
  --
  --              insert into totreqst(numotreq,dtereq,typotreq,codempid,codcomp,codcalen,codshift,codappr,dteappr,codrem,
  --                                   dtestrt,dteend,staotreq,typwork,dteupd,coduser,codcreate,remark,
  --                                   timstrtb,timendb,qtyminb,timstrtd,timendd,qtymind,timstrta,timenda,qtymina,flgchglv,codcompw)-- user22 : 29/06/2016 : STA3590280 ||
  --                            values(v_numotreq,v_dtereq,v_typotreq,v_codempid,r_tattence.codcomp,r_tattence.codcalen,r_tattence.codshift,v_codappr,v_dteappr,v_codrem,
  --                                   v_dtewkreq,v_dtewkreq,'A',r_tattence.typwork,sysdate,global_v_coduser,global_v_coduser,'Import',
  --                                   v_timbstr,v_timbend,v_qtyminb,v_timdstr,v_timdend,v_qtymind,v_timastr,v_timaend,v_qtymina,v_flgchglv,v_codcompw);-- user22 : 29/06/2016 : STA3590280 ||
                --
                for i in 1..3 loop
                  v_dtestrt	:= null; v_dteend	:= null;
                  if i = 1 then
                    if v_text(4) is not null then
                      v_typot   := 'B';
                      v_timstrt := v_timbstr;
                      v_timend  := v_timbend;
                      v_qtyminr := v_qtyminb;
                      if v_timend > r_tattence.timendw then
                        v_dteend := r_tattence.dteendw - 1;
                      else
                        v_dteend := r_tattence.dteendw;
                      end if;
                      if v_timstrt > v_timend then
                        v_dtestrt := v_dteend - 1;
                      else
                        v_dtestrt := v_dteend;
                      end if;
                    else
                      goto next_ot_type_loop;
                    end if;
                  elsif i = 2 then
                    if v_text(6) is not null then
                      v_flag    := 'N';
                      v_typot   := 'D';
                      v_timstrt := v_timdstr;
                      v_timend  := v_timdend;
                      v_qtyminr := v_qtymind;
                      v_dtewkst := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tattence.timstrtw,'dd/mm/yyyyhh24mi');
                      v_dtewken := to_date(to_char(r_tattence.dteendw,'dd/mm/yyyy')||r_tattence.timendw,'dd/mm/yyyyhh24mi');
                      v_dtestrt  := v_dtewkreq;
                      if v_timstrt >= v_timend then
                        v_dteend := v_dtestrt + 1;
                      else
                        v_dteend := v_dtestrt;
                      end if;
                      v_dteotst := to_date(to_char(v_dtestrt,'dd/mm/yyyy')||v_timstrt,'dd/mm/yyyyhh24mi');
                      v_dteoten := to_date(to_char(v_dteend,'dd/mm/yyyy')||v_timend,'dd/mm/yyyyhh24mi');
                      --
                      if v_dtewkst between v_dteotst and v_dteoten
                      or v_dtewken between v_dteotst and v_dteoten
                      or v_dteotst between v_dtewkst and v_dtewken
                      or v_dteoten between v_dtewkst and v_dtewken then
                        v_flag := 'Y';
                      end if;
                      --
                      if v_flag = 'N' then
                        v_dtestrt  := v_dtestrt - 1;
                        v_dteend   := v_dteend  - 1;
                        v_dteotst  := v_dteotst - 1;
                        v_dteoten  := v_dteoten - 1;

                        if v_dtewkst between v_dteotst and v_dteoten
                        or v_dtewken between v_dteotst and v_dteoten
                        or v_dteotst between v_dtewkst and v_dtewken
                        or v_dteoten between v_dtewkst and v_dtewken then
                          v_flag := 'Y';
                        end if;
                      end if;
                      --
                      if v_flag = 'N' then
                        v_dtestrt  := v_dtestrt + 2;
                        v_dteend   := v_dteend  + 2;
                      end if;
                    else
                      goto next_ot_type_loop;
                    end if;
                  elsif i = 3 then
                    if v_text(8) is not null then
                      v_typot   := 'A';
                      v_timstrt := v_timastr;
                      v_timend  := v_timaend;
                      v_qtyminr := v_qtymina;
                      if v_timstrt < r_tattence.timstrtw then
                        v_dtestrt := r_tattence.dtestrtw + 1;
                      else
                        v_dtestrt := r_tattence.dtestrtw;
                      end if;
                      if v_timstrt > v_timend then
                        v_dteend := v_dtestrt + 1;
                      else
                        v_dteend := v_dtestrt;
                      end if;
                    else
                      goto next_ot_type_loop;
                    end if;
                  end if;
                  -- 20190320 USER03--
                  -- check qtyminr is not null
                  if nvl(v_qtyminr,0) > 0 then
                    v_timstrt    := null;
                    v_timend     := null;
                    v_dtestrt    := null;
                    v_dteend     := null;
                  end if;
                  --<<09/03/2021
                  if v_codcompw is null then
                    begin
                      select codcompw
                        into v_codcompw
                        from v_tattence_cc
                       where codempid = v_codempid
                         and dtework  = v_dtewkreq;
                    exception when no_data_found then
                      v_codcompw := null;
                    end;
                  end if;
                  -->>09/03/2021
                  --
                  begin
                    insert into totreqd(numotreq,dtewkreq,codempid,typot,flgchglv,
                                        codcomp,codcalen,codshift,dtestrt,timstrt,dteend,timend,qtyminr,dteupd,coduser,codcreate,codcompw)
                                 values(v_numotreq,v_dtewkreq,v_codempid,v_typot,decode(v_flgchglv,'Y',v_flgchglv,'N'),
                                        r_tattence.codcomp,r_tattence.codcalen,r_tattence.codshift,v_dtestrt,
                                        v_timstrt,v_dteend,v_timend,v_qtyminr,sysdate,global_v_coduser,global_v_coduser,v_codcompw);
                  end;
--                  commit;
                  << next_ot_type_loop >>
                  null;
                end loop; -- for i in 1..3
                << next_step_loop >>
                null;
              end loop; -- for r_tattence
--<< user20 Date: 24/08/2021  AL Module- #6050
            else
                v_rec_tran      := v_rec_tran - 1;
                v_rec_error     := v_rec_error + 1;
                v_cnt           := v_cnt+1;
                v_err_code  := 'HR2005';

                p_text(v_cnt)       := data_file;
                p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']';
                p_numseq(v_cnt)     := i;
-->> user20 Date: 24/08/2021  AL Module- #6050
            end if;
          else
            v_rec_error     := v_rec_error + 1;
            v_cnt           := v_cnt+1;

            p_text(v_cnt)       := data_file;
            p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']';
            p_numseq(v_cnt)     := i;
          end if;--not v_error

        end if;--v_numseq = 1
        commit;
      exception when others then
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;

  procedure get_ot_change (json_str_input in clob, json_str_output out clob) is
    json_input      json_object_t;
    json_data       json_object_t;
    v_flgchglv      tcontrot.flgchglv%type;
    v_codcompy      tcenter.codcompy%type;
  begin
    json_input          := json_object_t(json_str_input);
    p_codempid          := hcm_util.get_string_t(json_input,'p_codempid_query');
    p_codcomp           := replace(hcm_util.get_string_t(json_input,'p_codcomp'), '-', null);

    v_flgchglv          := 'N';
    if p_codempid is not null then
      begin
        select hcm_util.get_codcompy(codcomp)
          into v_codcompy
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        v_codcompy        := null;
      end;
    else
      v_codcompy          := hcm_util.get_codcompy(p_codcomp);
    end if;

    begin
      select flgchglv
        into v_flgchglv
        from tcontrot
       where codcompy = v_codcompy
         and dteeffec = (select max(dteeffec)
                           from tcontrot
                          where dteeffec <= sysdate
                            and codcompy = v_codcompy)
         and rownum <= 1;
    exception when no_data_found then
      v_flgchglv      := 'N';
    end;
    json_data       := json_object_t();
    json_data.put('coderror', 200);
    json_data.put('flgchglv_', v_flgchglv);

    json_str_output := json_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_ot_change;

  procedure get_codshift_ot (json_str_input in clob, json_str_output out clob) is
    json_input      json_object_t;
    json_data       json_object_t;
    v_codshift      tattence.codshift%type;
    v_dtestrtw      tattence.dtestrtw%type;
    v_timstrtw      tattence.timstrtw%type;
    v_dteendw       tattence.dteendw%type;
    v_timendw       tattence.timendw%type;
    v_codcompw      temploy1.codcomp%type;
  begin
    json_input          := json_object_t(json_str_input);
    p_codempid          := hcm_util.get_string_t(json_input,'p_codempid_query');
    p_dtewkreq          := to_date(hcm_util.get_string_t(json_input,'p_dtewkreq'),'dd/mm/yyyy');

    begin
      select codshift,dtestrtw,timstrtw,dteendw,timendw
        into v_codshift,v_dtestrtw,v_timstrtw,v_dteendw,v_timendw
        from tattence
       where codempid = p_codempid
         and dtework  = p_dtewkreq;
    exception when no_data_found then
      v_codshift        := null;
    end;

    begin
      select codcompw
        into v_codcompw
        from v_tattence_cc
       where codempid = p_codempid
         and dtework  = p_dtewkreq;
    exception when no_data_found then
      v_codcompw        := null;
    end;

    json_data       := json_object_t();
    json_data.put('coderror', 200);
    json_data.put('codshift', v_codshift);
    json_data.put('dtestrtw', to_char(v_dtestrtw,'dd/mm/yyyy'));
    json_data.put('timstrtw', v_timstrtw);
    json_data.put('dteendw', to_char(v_dteendw,'dd/mm/yyyy'));
    json_data.put('timendw', v_timendw);
    json_data.put('codcompw', v_codcompw);

    json_str_output := json_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_codshift_ot;

  procedure get_codcompw (json_str_input in clob, json_str_output out clob) is
    json_input      json_object_t;
    json_data       json_object_t;
    v_codcompw      varchar2(100 char);
  begin
    json_input          := json_object_t(json_str_input);
    p_codempid          := hcm_util.get_string_t(json_input,'p_codempid_query');
    p_dtestrt          := to_date(hcm_util.get_string_t(json_input,'p_dtestrt'),'dd/mm/yyyy');

    begin
      select hcm_util.get_codcomp_level(codcompw,null,'-','Y')
        into v_codcompw
        from v_tattence_cc
       where codempid = p_codempid
         and dtework  = p_dtestrt;
    exception when no_data_found then
      v_codcompw        := null;
    end;

    json_data       := json_object_t();
    json_data.put('coderror', 200);
    json_data.put('codcompw', v_codcompw);

    json_str_output := json_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_codcompw;

  -->> user18 ST11 05/08/2021 change std
  procedure get_ChkDtereq (json_str_input in clob, json_str_output out clob) is
    obj_input       json_object_t;
    obj_data        json_object_t;
    v_codshift      tattence.codshift%type;
    v_dtestrtw      tattence.dtestrtw%type;
    v_timstrtw      tattence.timstrtw%type;
    v_dteendw       tattence.dteendw%type;
    v_timendw       tattence.timendw%type;
    --
    v_codempid      tattence.codempid%type;
    v_dtewkreq      tattence.dtework%type;
  begin
    initial_value(json_str_input);
    obj_input       := json_object_t(json_str_input);
    v_codempid      := hcm_util.get_string_t(obj_input,'p_codempid_query');
    v_dtestrt       := to_date(hcm_util.get_string_t(obj_input,'p_dtewkreq'),'dd/mm/yyyy');
    v_dtestrtwk     := to_date(hcm_util.get_string_t(obj_input,'p_dtestrtwk'),'dd/mm/yyyy');
    v_dteendwk      := to_date(hcm_util.get_string_t(obj_input,'p_dteendwk'),'dd/mm/yyyy');

    begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = v_codempid;
    exception when others then
        v_codcomp := null;
    end;

    obj_data       := json_object_t();
    obj_data.put('coderror', 200);

    if v_dtestrt not between v_dtestrtwk and v_dteendwk then
        obj_data.put('msgerror', replace(get_error_msg_php('AL0021',global_v_lang),'@#$%400'));
    end if;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_ChkDtereq;

  procedure get_cumulative_hours(json_str_input in clob, json_str_output out clob) as
    obj_input           json_object_t;
    obj_main            json_object_t;

    json_obj            json_object_t;
    v_row               number;
    -- check null data --
    v_rcnt              number := 0;
    obj_row             json_object_t;
    obj_data            json_object_t;

    v_dtestrtwk         date;
    v_dteendwk          date;

    v_qtydaywk          number;
    v_qtymin            number;
    v_qtyot_reqoth      number;
    v_qtyot_req         number;
    v_qtyot_total       number;
    v_qtytotal          number;

    v_codempid          ttotreq.codempid%type;
    v_dtereq            ttotreq.dtereq%type;
    v_numseq            ttotreq.numseq%type;
    v_numotreq          ttotreq.numotreq%type;

    v_qtyminot          number;
    v_qtyminotOth       number;
    v_dteot             date;
    obj_data_rows       json_object_t;
    v_ttemprpt          ttemprpt%rowtype;
    v_ttemprptOld       ttemprpt%rowtype;
    v_codempid_tmp      temploy1.codempid%type;
    v_codempid_old_tmp  temploy1.codempid%type;
    v_tmp_qtyot_req     number;
    v_msg_error         varchar2(2000);
    v_qtymxotwk         tcontrot.qtymxotwk%type;
    v_qtymxallwk        tcontrot.qtymxallwk%type;
    v_qtyminotOth_cumulative number;

    CURSOR c1 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
      ORDER BY numseq;

    CURSOR c2 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
         and item2 = v_codempid_tmp
         and numseq <> v_ttemprpt.numseq
      ORDER BY numseq;

    CURSOR c3 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
         and item2 = v_codempid_old_tmp
      ORDER BY numseq;

    CURSOR c4_main IS
      SELECT distinct item2 codempid,
             to_date(item14,'dd/mm/yyyy') dtestrtwk,
             to_date(item15,'dd/mm/yyyy') dteendwk
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
         and item2 = v_codempid_tmp
      ORDER BY codempid, dtestrtwk;

    CURSOR c4 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
         and item2 = v_codempid_tmp
         and to_date(item14,'dd/mm/yyyy') = v_dtestrtwk
         and to_date(item15,'dd/mm/yyyy') = v_dteendwk
      ORDER BY numseq;

    CURSOR c5_main IS
      SELECT distinct item2 codempid,
             to_date(item14,'dd/mm/yyyy') dtestrtwk,
             to_date(item15,'dd/mm/yyyy') dteendwk
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
         and item2 = v_codempid_old_tmp
      ORDER BY codempid, dtestrtwk;

    CURSOR c5 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRAL41E'
         and item2 = v_codempid_old_tmp
         and to_date(item14,'dd/mm/yyyy') = v_dtestrtwk
         and to_date(item15,'dd/mm/yyyy') = v_dteendwk
      ORDER BY numseq;
  begin
    initial_value(json_str_input);
    obj_input           := json_object_t(json_str_input);
    v_codempid          := hcm_util.get_string_t(obj_input,'p_codempid_query');
    v_codempid_old_tmp  := hcm_util.get_string_t(obj_input,'p_codempidOld_query');
    v_dtestrt           := to_date(hcm_util.get_string_t(obj_input,'p_dtewkreq'),'dd/mm/yyyy');
    p_typot             := hcm_util.get_string_t(obj_input,'p_typot');
    obj_data_rows       := hcm_util.get_json_t(obj_input,'rowdata');

    if p_typot = 'B' then
        p_timstrtb          := hcm_util.get_string_t(obj_input,'p_timstrt');
        p_timendb           := hcm_util.get_string_t(obj_input,'p_timend');
        p_qtyminb           := hcm_util.convert_time_to_minute(hcm_util.get_string_t(obj_input,'p_qtyminr'));
    elsif p_typot = 'D' then
        p_timstrtd          := hcm_util.get_string_t(obj_input,'p_timstrt');
        p_timendd           := hcm_util.get_string_t(obj_input,'p_timend');
        p_qtymind           := hcm_util.convert_time_to_minute(hcm_util.get_string_t(obj_input,'p_qtyminr'));
    elsif p_typot = 'A' then
        p_timstrta          := hcm_util.get_string_t(obj_input,'p_timstrt');
        p_timenda           := hcm_util.get_string_t(obj_input,'p_timend');
        p_qtymina           := hcm_util.convert_time_to_minute(hcm_util.get_string_t(obj_input,'p_qtyminr'));
    end if;

    p_dtereq            := to_date(hcm_util.get_string_t(obj_input,'p_dtereq'),'dd/mm/yyyy');
    p_numotreq          := hcm_util.get_string_t(obj_input,'p_numotreq');
    begin
        select codcomp
          into v_codcomp
          from temploy1
         where codempid = v_codempid;
    exception when others then
        v_codcomp := null;
    end;
    obj_main    := json_object_t();
    obj_row     := json_object_t();
    v_row       := 0;

    obj_data    := json_object_t();
    obj_data    := obj_data_rows;
    obj_data.put('coderror', '200');

    v_ttemprpt.numseq  := hcm_util.get_string_t(obj_data,'seqno'); --seqno
    v_numseq           := hcm_util.get_string_t(obj_data,'seqno');

    v_dtestrtwk   := std_ot.get_dtestrt_period (v_codempid, v_dtestrt);
    v_dteendwk    := v_dtestrtwk + 6;
    std_ot.get_week_ot(v_codempid, p_numotreq,p_dtereq,'',v_dtestrtwk,v_dteendwk,
                       null, null, null,
                       null, null, null,
                       null, null, null,
                       global_v_codempid,
                       a_dtestweek,a_dteenweek,
                       a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);

    v_qtydaywk      := a_sumwork(1);
    v_qtyminotOth   := std_ot.get_qtyminotOth_notTmp (v_codempid ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);
    v_codempid_tmp  := v_codempid;

    begin
        select * into v_ttemprptOld
          FROM ttemprpt
         WHERE codempid = global_v_codempid
           AND codapp = 'HRAL41E'
           and numseq = v_ttemprpt.numseq;
    exception when others then
        v_ttemprptOld := null;
    end;

    SELECT sum(hcm_util.convert_time_to_minute(item18))
      into v_tmp_qtyot_req
      FROM ttemprpt
     WHERE codempid = global_v_codempid
       AND codapp = 'HRAL41E'
       and item2 = v_codempid_tmp
       and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
       and numseq <> v_ttemprpt.numseq;

    v_qtyminotOth := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
    v_qtyminot    := std_ot.get_qtyminot(v_codempid_tmp, v_dtestrt, v_dtestrt,
                                         p_qtyminb, p_timendb, p_timstrtb,
                                         p_qtymind, p_timendd, p_timstrtd,
                                         p_qtymina, p_timenda, p_timstrta);

    if v_codempid is not null then
        obj_data.put('dtestrtwk',to_char(v_dtestrtwk,'dd/mm/yyyy'));
        obj_data.put('dteendwk',to_char(v_dteendwk,'dd/mm/yyyy'));
        obj_data.put('qtydaywk',hcm_util.convert_minute_to_hour(v_qtydaywk));
        obj_data.put('qtyot_reqoth',hcm_util.convert_minute_to_hour(v_qtyminotOth));
        obj_data.put('qtyot_req',hcm_util.convert_minute_to_hour(v_qtyminot));
        obj_data.put('qtyot_total',hcm_util.convert_minute_to_hour(v_qtyminotOth + v_qtyminot));
        obj_data.put('qtytotal',hcm_util.convert_minute_to_hour(v_qtydaywk + v_qtyminotOth + v_qtyminot));
        v_qtyot_total := v_qtyminotOth + v_qtyminot;
        v_qtytotal    := v_qtydaywk + v_qtyminotOth + v_qtyminot;
    else
        obj_data.put('dtestrtwk','');
        obj_data.put('dteendwk','');
        obj_data.put('qtydaywk','');
        obj_data.put('qtyot_reqoth','');
        obj_data.put('qtyot_req','');
        obj_data.put('qtyot_total','');
        obj_data.put('qtytotal','');
        v_qtyot_total := null;
        v_qtytotal    := null;
    end if;

    begin
        select nvl(qtymxotwk,0),qtymxallwk,nvl(typalert,'N')
          into v_qtymxotwk,v_qtymxallwk,v_typalert
          from tcontrot
         where codcompy = hcm_util.get_codcompy(v_codcomp)
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = hcm_util.get_codcompy(v_codcomp)
                              and dteeffec <= sysdate);
    exception when others then
        v_qtymxotwk     := 0;
        v_qtymxallwk    := 0;
        v_typalert      := 'N';
    end;

    if hcm_util.convert_time_to_minute(v_ttemprptOld.item19) <> v_qtyot_total then
        v_ttemprpt.item24   := 'N';
        if (v_qtyot_total > v_qtymxotwk) then
            v_msg_error := replace(get_error_msg_php('AL0080',global_v_lang),'@#$%400');
            v_ttemprpt.item24   := 'Y';
        elsif (v_qtytotal > v_qtymxallwk) then
            v_msg_error := replace(get_error_msg_php('AL0081',global_v_lang),'@#$%400');
            v_ttemprpt.item24   := 'Y';
        end if;
    end if;
    begin
        select max(numseq)
          into v_report_numseq
          from ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRAL41E';
    exception when others then
      v_report_numseq := 0;
    end;

    v_report_numseq     := nvl(v_report_numseq,0) + 1;
    v_ttemprpt.item1    := hcm_util.get_string_t(obj_data,'dtewkreq'); --dtewkreq
    v_ttemprpt.item2    := hcm_util.get_string_t(obj_data,'codempid'); -- codempid
    v_ttemprpt.item3    := get_temploy_name(hcm_util.get_string_t(obj_data,'codempid'),global_v_lang); --desc_codempid
    v_ttemprpt.item4    := hcm_util.get_string_t(obj_data,'typot'); --typot
    v_ttemprpt.item5    := hcm_util.get_string_t(obj_data,'codcompw'); --codcompw
    v_ttemprpt.item6    := hcm_util.get_string_t(obj_data,'codcalen'); --codcalen

    begin
      select codshift
        into v_ttemprpt.item7
        from tattence
       where codempid = v_ttemprpt.item2
         and dtework  = to_date(v_ttemprpt.item1,'dd/mm/yyyy');
    exception when no_data_found then
      v_ttemprpt.item7        := '';
    end;--codshift

    v_ttemprpt.item8    := to_char(to_date(hcm_util.get_string_t(obj_input,'p_timstrt'),'hh24:mi'), 'hh24:mi'); --timstrt
    v_ttemprpt.item9    := to_char(to_date(hcm_util.get_string_t(obj_input,'p_timend'),'hh24:mi'), 'hh24:mi'); --timend
    v_ttemprpt.item10   := hcm_util.get_string_t(obj_input,'p_qtyminr'); --qtyminr
    if hcm_util.convert_time_to_minute(v_ttemprpt.item10) = 0 then
        v_ttemprpt.item10 := null;
    end if;
    v_ttemprpt.item11  := hcm_util.get_string_t(obj_data,'flgchglv'); --flgchglv

    begin
      select costcent into v_ttemprpt.item12
        from tcenter
       where codcomp  = v_ttemprpt.item5
         and rownum   <= 1
    order by codcomp;
    exception when no_data_found then
      v_ttemprpt.item12 := null;
    end;  --cost_center

    v_ttemprpt.item13  := hcm_util.get_string_t(obj_data,'qtytotal'); --qtytotal
    v_ttemprpt.item14  := hcm_util.get_string_t(obj_data,'dtestrtwk'); --dtestrtwk
    v_ttemprpt.item15  := hcm_util.get_string_t(obj_data,'dteendwk'); --dteendwk
    v_ttemprpt.item16  := hcm_util.get_string_t(obj_data,'qtydaywk'); --qtydaywk
    v_ttemprpt.item17  := hcm_util.get_string_t(obj_data,'qtyot_reqoth'); --qtyot_reqoth
    v_ttemprpt.item18  := hcm_util.get_string_t(obj_data,'qtyot_req');--qtyot_req
    v_ttemprpt.item19  := hcm_util.get_string_t(obj_data,'qtyot_total');--,qtyot_total

    if hcm_util.get_boolean_t(obj_data,'flgAdd') then
        v_ttemprpt.item20   := 1;
    else
        v_ttemprpt.item20   := 0;
    end if;
    if hcm_util.get_boolean_t(obj_data,'flgEdit') then
        v_ttemprpt.item21   := 1;
    else
        v_ttemprpt.item21   := 0;
    end if;
    if hcm_util.get_boolean_t(obj_data,'flgDelete') then
        v_ttemprpt.item22   := 1;
    else
        v_ttemprpt.item22   := 0;
    end if;

    begin
      insert into ttemprpt (codempid,codapp,numseq,
                            item1,item2,item3,item4,item5,
                            item6,item7,item8,item9,item10,
                            item11,item12,item13,item14,item15,
                            item16,item17,item18,item19,item20,
                            item21,item22,item24)
      values(global_v_codempid,'HRAL41E',v_ttemprpt.numseq,
                            v_ttemprpt.item1,v_ttemprpt.item2,v_ttemprpt.item3,v_ttemprpt.item4,v_ttemprpt.item5,
                            v_ttemprpt.item6,v_ttemprpt.item7,v_ttemprpt.item8,v_ttemprpt.item9,v_ttemprpt.item10,
                            v_ttemprpt.item11,v_ttemprpt.item12,v_ttemprpt.item13,v_ttemprpt.item14,v_ttemprpt.item15,
                            v_ttemprpt.item16,v_ttemprpt.item17,v_ttemprpt.item18,v_ttemprpt.item19,v_ttemprpt.item20,
                            v_ttemprpt.item21,v_ttemprpt.item22,v_ttemprpt.item24);
    exception when dup_val_on_index then
      update ttemprpt
         set item1 = v_ttemprpt.item1, item2 = v_ttemprpt.item2,
             item3 = v_ttemprpt.item3, item4 = v_ttemprpt.item4,
             item5 = v_ttemprpt.item5, item6 = v_ttemprpt.item6,
             item7 = v_ttemprpt.item7, item8 = v_ttemprpt.item8,
             item9 = v_ttemprpt.item9, item10 = v_ttemprpt.item10,
             item11 = v_ttemprpt.item11, item12 = v_ttemprpt.item12,
             item13 = v_ttemprpt.item13, item14 = v_ttemprpt.item14,
             item15 = v_ttemprpt.item15, item16 = v_ttemprpt.item16,
             item17 = v_ttemprpt.item17, item18 = v_ttemprpt.item18,
             item19 = v_ttemprpt.item19, item20 = v_ttemprpt.item20,
             item21 = v_ttemprpt.item21, item22 = v_ttemprpt.item22,
             item24 = v_ttemprpt.item24
       where codempid = global_v_codempid
         and codapp = 'HRAL41E'
         and numseq = v_ttemprpt.numseq;
    end;

    for r2 in c2 loop
      v_dtestrtwk   := to_date(r2.item14,'dd/mm/yyyy');
      v_dteendwk    := to_date(r2.item15,'dd/mm/yyyy');

      std_ot.get_week_ot(v_codempid_tmp, '','','',v_dtestrtwk,v_dteendwk,
                         null, null, null,
                         null, null, null,
                         null, null, null,
                         global_v_codempid,
                         a_dtestweek,a_dteenweek,
                         a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);

      v_qtyminotOth := std_ot.get_qtyminotOth_notTmp (v_codempid_tmp ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);

      SELECT sum(hcm_util.convert_time_to_minute(item18))
        into v_tmp_qtyot_req
        FROM ttemprpt
       WHERE codempid = r2.codempid
         AND codapp = r2.codapp
         and item2 = r2.item2
         and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
         and numseq <> r2.numseq;

      v_qtyminotOth := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
      v_ttemprpt.item17 := hcm_util.convert_minute_to_hour(v_qtyminotOth);
      v_ttemprpt.item19 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r2.item18) + v_qtyminotOth);
      v_ttemprpt.item13 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r2.item16) + hcm_util.convert_time_to_minute(r2.item18) + v_qtyminotOth);
      update ttemprpt
         set item17 = v_ttemprpt.item17,
             item19 = v_ttemprpt.item19,
             item13 = v_ttemprpt.item13
       where codempid = r2.codempid
         and codapp = r2.codapp
         and numseq = r2.numseq;
    end loop;

    for r4_main in c4_main loop
        v_dtestrtwk                 := r4_main.dtestrtwk;
        v_dteendwk                  := r4_main.dteendwk;
        std_ot.get_week_ot(v_codempid_tmp, '','','',v_dtestrtwk,v_dteendwk,
                           null, null, null,
                           null, null, null,
                           null, null, null,
                           global_v_codempid,
                           a_dtestweek,a_dteenweek,
                           a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
        v_qtydaywk    := a_sumwork(1);

        v_qtyminotOth_cumulative    := std_ot.get_qtyminotOth_notTmp (v_codempid_tmp ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);

        for r4 in c4 loop
            v_qtyot_total   := v_qtyminotOth_cumulative + hcm_util.convert_time_to_minute(r4.item18);
            v_qtytotal      := v_qtydaywk + v_qtyot_total;
            v_ttemprpt.item21 := r4.item21;
            if (v_qtyot_total > v_qtymxotwk or v_qtytotal > v_qtymxallwk) then
                v_ttemprpt.item24   := 'Y';
                if r4.numseq > v_numseq then
                    v_ttemprpt.item21 := 1;
                end if;
            else
                v_ttemprpt.item24   := 'N';
            end if;
            v_qtyminotOth_cumulative := v_qtyot_total;
            update ttemprpt
               set item24 = v_ttemprpt.item24,
                   item21 = v_ttemprpt.item21
             where codempid = r4.codempid
               and codapp = r4.codapp
               and numseq = r4.numseq;
        end loop;
    end loop;

    for r3 in c3 loop
      v_dtestrtwk   := to_date(r3.item14,'dd/mm/yyyy');
      v_dteendwk    := to_date(r3.item15,'dd/mm/yyyy');

      v_qtyminotOth := std_ot.get_qtyminotOth_notTmp (r3.item2 ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);

      SELECT sum(hcm_util.convert_time_to_minute(item18))
        into v_tmp_qtyot_req
        FROM ttemprpt
       WHERE codempid = r3.codempid
         AND codapp = r3.codapp
         and item2 = r3.item2
         and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
         and numseq <> r3.numseq;

      v_qtyminotOth     := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
      v_ttemprpt.item17 := hcm_util.convert_minute_to_hour(v_qtyminotOth);
      v_ttemprpt.item19 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r3.item18) + v_qtyminotOth);
      v_ttemprpt.item13 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r3.item16) + hcm_util.convert_time_to_minute(r3.item18) + v_qtyminotOth);
      update ttemprpt
         set item17 = v_ttemprpt.item17,
             item19 = v_ttemprpt.item19,
             item13 = v_ttemprpt.item13
       where codempid = r3.codempid
         and codapp = r3.codapp
         and numseq = r3.numseq;
    end loop;

    for r5_main in c5_main loop
        v_dtestrtwk                 := r5_main.dtestrtwk;
        v_dteendwk                  := r5_main.dteendwk;
        std_ot.get_week_ot(r5_main.codempid, '','','',v_dtestrtwk,v_dteendwk,
                           null, null, null,
                           null, null, null,
                           null, null, null,
                           global_v_codempid,
                           a_dtestweek,a_dteenweek,
                           a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
        v_qtydaywk    := a_sumwork(1);
        v_qtyminotOth_cumulative    := 0;
        v_qtyminotOth_cumulative    := std_ot.get_qtyminotOth_notTmp (r5_main.codempid ,v_dtestrtwk, v_dteendwk, 'HRAL41E', global_v_codempid);

        for r5 in c5 loop
            v_qtyot_total   := v_qtyminotOth_cumulative + hcm_util.convert_time_to_minute(r5.item18);
            v_qtytotal      := v_qtydaywk + v_qtyot_total;
            if (v_qtyot_total > v_qtymxotwk or v_qtytotal > v_qtymxallwk) then
                v_ttemprpt.item24   := 'Y';
            else
                v_ttemprpt.item24   := 'N';
            end if;
            v_qtyminotOth_cumulative := v_qtyot_total;
            update ttemprpt
               set item24 = v_ttemprpt.item24
             where codempid = r5.codempid
               and codapp = r5.codapp
               and numseq = r5.numseq;
        end loop;
    end loop;

    for r1 in c1 loop
        v_row := v_row+1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('seqno',r1.numseq); --dtestrt
        obj_data.put('dtewkreq',r1.item1); --dtewkreq
        obj_data.put('dtewkreqOld',r1.item1); --dtewkreq
        obj_data.put('codempid',r1.item2); -- codempid
        obj_data.put('codempidOld',r1.item2); -- codempid
        obj_data.put('desc_codempid',r1.item3); --desc_codempid
        obj_data.put('typot',r1.item4); --typot
        obj_data.put('codcompw',r1.item5); --codcompw
        obj_data.put('codcalen',r1.item6); --codcalen
        obj_data.put('codshift',r1.item7); --codshift
        obj_data.put('timstrt',r1.item8); --timstrt
        obj_data.put('timend',r1.item9); --timend
        obj_data.put('qtyminr',r1.item10); --qtyminr
        obj_data.put('flgchglv',r1.item11); --flgchglv
        obj_data.put('cost_center',r1.item12); --cost_center
        obj_data.put('qtytotal',r1.item13); --qtytotal
        obj_data.put('dtestrtwk',r1.item14);--dtestrtwk
        obj_data.put('dteendwk',r1.item15);--,dteendwk
        obj_data.put('qtydaywk',r1.item16); --qtydaywk
        obj_data.put('qtyot_reqoth',r1.item17); --qtyot_reqoth
        obj_data.put('qtyot_req',r1.item18); --qtyot_req
        obj_data.put('qtyot_total',r1.item19); --qtyot_total
        if r1.item20 = 1 then
            obj_data.put('flgAdd',true);
        else
            obj_data.put('flgAdd',false);
        end if;
        if r1.item21 = 1 then
            obj_data.put('flgEdit',true);
        else
            obj_data.put('flgEdit',false);
        end if;
        if r1.item22 = 1 then
            obj_data.put('flgDelete',true);
        else
            obj_data.put('flgDelete',false);
        end if;
        obj_data.put('numotreq',r1.item23);
        obj_data.put('staovrot',r1.item24);
        obj_data.put('typalert',v_typalert);
        obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    obj_main.put('coderror', '200');
    obj_main.put('table', obj_row);
    obj_main.put('msgerror', v_msg_error);
    json_str_output := obj_main.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_cumulative_hours;

  procedure update_temp(json_str_input in clob, json_str_output out clob) as
    obj_input           json_object_t;
    json_obj            json_object_t;
    v_cost_center       tcenter.costcent%type;
    -- check null data --
    obj_data            json_object_t;
    v_codempid          ttotreq.codempid%type;
    v_ttemprpt          ttemprpt%rowtype;
    v_codempid_tmp      temploy1.codempid%type;
  begin
    initial_value(json_str_input);
    obj_input       := json_object_t(json_str_input);
    obj_data        := hcm_util.get_json_t(obj_input,'rowdata');

    v_ttemprpt.numseq  := hcm_util.get_string_t(obj_data,'seqno'); --seqno
    v_ttemprpt.item1  := hcm_util.get_string_t(obj_data,'dtewkreq'); --dtewkreq
    v_ttemprpt.item2  := hcm_util.get_string_t(obj_data,'codempid'); -- codempid
    v_ttemprpt.item3  := get_temploy_name(hcm_util.get_string_t(obj_data,'codempid'),global_v_lang); --desc_codempid
    v_ttemprpt.item4  := hcm_util.get_string_t(obj_data,'typot'); --typot
    v_ttemprpt.item5  := hcm_util.get_string_t(obj_data,'codcompw'); --codcompw
    v_ttemprpt.item6  := hcm_util.get_string_t(obj_data,'codcalen'); --codcalen
    v_ttemprpt.item7  := hcm_util.get_string_t(obj_data,'codshift'); --codshift
    v_ttemprpt.item8  := hcm_util.get_string_t(obj_data,'timstrt'); --timstrt
    v_ttemprpt.item9  := hcm_util.get_string_t(obj_data,'timend'); --timend
    v_ttemprpt.item10  := hcm_util.get_string_t(obj_data,'qtyminr'); --qtyminr
    v_ttemprpt.item11  := hcm_util.get_string_t(obj_data,'flgchglv'); --flgchglv
    v_ttemprpt.item13  := hcm_util.get_string_t(obj_data,'qtytotal'); --qtytotal
    v_ttemprpt.item14  := hcm_util.get_string_t(obj_data,'dtestrtwk'); --dtestrtwk
    v_ttemprpt.item15  := hcm_util.get_string_t(obj_data,'dteendwk'); --dteendwk
    v_ttemprpt.item16  := hcm_util.get_string_t(obj_data,'qtydaywk'); --qtydaywk
    v_ttemprpt.item17  := hcm_util.get_string_t(obj_data,'qtyot_reqoth'); --qtyot_reqoth
    v_ttemprpt.item18  := hcm_util.get_string_t(obj_data,'qtyot_req');--qtyot_req
    v_ttemprpt.item19  := hcm_util.get_string_t(obj_data,'qtyot_total');--,qtyot_total

    begin
        select costcent into v_cost_center
          from tcenter
         where codcomp = v_ttemprpt.item5
           and rownum <= 1
      order by codcomp;
    exception when no_data_found then
        v_cost_center := null;
    end;
    v_ttemprpt.item12  := v_cost_center; --costcent

    if hcm_util.get_boolean_t(obj_data,'flgAdd') then
        v_ttemprpt.item20   := 1;
    else
        v_ttemprpt.item20   := 0;
    end if;
    if hcm_util.get_boolean_t(obj_data,'flgEdit') then
        v_ttemprpt.item21   := 1;
    else
        v_ttemprpt.item21   := 0;
    end if;
    if hcm_util.get_boolean_t(obj_data,'flgDelete') then
        v_ttemprpt.item22   := 1;
    else
        v_ttemprpt.item22   := 0;
    end if;

    begin
        insert into ttemprpt (codempid,codapp,numseq,
                              item1,item2,item3,item4,item5,
                              item6,item7,item8,item9,item10,
                              item11,item12,item13,item14,item15,
                              item16,item17,item18,item19,item20,
                              item21,item22)
        values(global_v_codempid,'HRAL41E',v_ttemprpt.numseq,
                              v_ttemprpt.item1,v_ttemprpt.item2,v_ttemprpt.item3,v_ttemprpt.item4,v_ttemprpt.item5,
                              v_ttemprpt.item6,v_ttemprpt.item7,v_ttemprpt.item8,v_ttemprpt.item9,v_ttemprpt.item10,
                              v_ttemprpt.item11,v_ttemprpt.item12,v_ttemprpt.item13,v_ttemprpt.item14,v_ttemprpt.item15,
                              v_ttemprpt.item16,v_ttemprpt.item17,v_ttemprpt.item18,v_ttemprpt.item19,v_ttemprpt.item20,
                              v_ttemprpt.item21,v_ttemprpt.item22);
    exception when dup_val_on_index then
        update ttemprpt
           set item1 = v_ttemprpt.item1, item2 = v_ttemprpt.item2,
               item3 = v_ttemprpt.item3, item4 = v_ttemprpt.item4,
               item5 = v_ttemprpt.item5, item6 = v_ttemprpt.item6,
               item7 = v_ttemprpt.item7, item8 = v_ttemprpt.item8,
               item9 = v_ttemprpt.item9, item10 = v_ttemprpt.item10,
               item11 = v_ttemprpt.item11, item12 = v_ttemprpt.item12,
               item13 = v_ttemprpt.item13, item14 = v_ttemprpt.item14,
               item15 = v_ttemprpt.item15, item16 = v_ttemprpt.item16,
               item17 = v_ttemprpt.item17, item18 = v_ttemprpt.item18,
               item19 = v_ttemprpt.item19, item20 = v_ttemprpt.item20,
               item21 = v_ttemprpt.item21, item22 = v_ttemprpt.item22
         where codempid = global_v_codempid
           and codapp = 'HRAL41E'
           and numseq = v_ttemprpt.numseq;
    end;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end update_temp;

  --<< user18 ST11 05/08/2021 change std
END HRAL41E;

/
