--------------------------------------------------------
--  DDL for Package Body HRMS6LU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS6LU" is
-- last update: 27/09/2022 10:44

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global value
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    -- block value
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtest             := hcm_util.get_string_t(json_obj,'p_dtest');
    p_dteen             := hcm_util.get_string_t(json_obj,'p_dteen');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    --
    p_dtereq            := hcm_util.get_string_t(json_obj,'p_dtereq');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_dtereqr           := hcm_util.get_string_t(json_obj,'p_dtereqr');
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
  end;

  procedure hrms6lu (json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_chk        varchar2(4 char);
    v_date       varchar2(10 char);
    v_dteot_st   varchar2(10 char);
    v_dteot_en   varchar2(10 char);
    v_dteot      varchar2(30 char);
    v_timstr     varchar2(30 char) := null;
    v_timend     varchar2(30 char) := null;
    v_timbstr    varchar2(30 char) := null;
    v_timdstr    varchar2(30 char) := null;
    v_timastr    varchar2(30 char) := null;
    v_codappr    varchar2(50 char);
    v_dtest      date ;
    v_dteen      date ;
    v_rcnt       number;
    v_nextappr   varchar2(1000 char);
    v_appno      varchar2(100 char);
    v_row        number := 0;
    -- check null data --
    v_flg_exist     boolean := false;
    v_chk_staovrot  varchar2(2 char);
    r_ttotreq       ttotreq%rowtype;
    v_codcompy      temploy1.codcomp%type;
    v_qtymxotwk     tcontrot.qtymxotwk%type;
    v_qtymxallwk    tcontrot.qtymxallwk%type;
    v_staovrot      ttotreq.staovrot%type;

    CURSOR c_hrms6lu_c1 IS
       select  codempid,dtereq,numseq,dtestrt,dteend,
               timbstr,timbend,timdstr,timdend,timastr,timaend,
               get_tcodec_name('TCODOTRQ',codrem,global_v_lang) desrem,
               get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,numotreq,
               codappr,a.approvno appno,codcomp ,dteappr,remarkap,
               get_temploy_name(codempid,global_v_lang) ename,staappr,b.approvno qtyapp,remark,
               a.qtyminb,a.qtymind,a.qtymina, a.staovrot
         FROM  ttotreq a ,twkflowh b
         where codcomp like p_codcomp||'%'
         and   (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
         and   staappr in ('P','A')
         and   ('Y' = chk_workflow.check_privilege('HRES6KE',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
                -- Replace Approve
                or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                          from   twkflowde c
                                                          where  c.routeno  = a.routeno
                                                          and    c.codempid = v_codappr)
                     and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES6KE')))
          and a.routeno = b.routeno
          order by  codempid,dtereq,numseq;

    CURSOR c_hrms6lu_c2 IS
       select  codempid,dtereq,numseq,dtestrt,dteend,
               timbstr,timbend,timdstr,timdend,timastr,timaend,
               get_tcodec_name('TCODOTRQ',codrem,global_v_lang) desrem,
               get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,numotreq,
               codappr,approvno,codcomp ,codappr cod,dteappr,remarkap,
               get_temploy_name(codempid,global_v_lang) ename,staappr,remark,
               qtyminb,qtymind,qtymina,staovrot
         from  ttotreq
         where codcomp like p_codcomp||'%'
         and   (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
         and   (codempid, dtereq, numseq) in
                          (select codempid, dtereq, numseq
                           from  taptotrq
                           where staappr = decode(p_staappr,'Y','A',p_staappr)
                           and   codappr = v_codappr
                           and   dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
          ORDER BY  codempid,dtereq,numseq;

  begin
    initial_value(json_str_input);
    v_codappr  := pdk.check_codempid(global_v_coduser);
    v_dtest    := to_date(replace(p_dtest,'/',null),'ddmmyyyy');
    v_dteen    := to_date(replace(p_dteen,'/',null),'ddmmyyyy');
    -- default value --
    obj_row := json_object_t();
    v_row   := 0;
    -- get data
    if p_staappr = 'P' then
      for r1 in c_hrms6lu_c1 loop
         v_timbstr  := null;
         v_timdstr  := null;
         v_timastr  := null;
        --
        v_appno  := nvl(r1.appno,0) + 1;
        if nvl(r1.appno,0)+1 = r1.qtyapp then
           v_chk := 'E' ;
        else
           v_chk := v_appno;
        end if;
        --
        v_date     := to_char(r1.dtereq ,'DD/MM/')||to_char(r1.dtereq,'YYYY');
        v_dteot_st := to_char(r1.dtestrt ,'DD/MM/')||to_char(r1.dtestrt,'YYYY');
        v_dteot_en := to_char(r1.dteend ,'DD/MM/')||to_char(r1.dteend,'YYYY');
        v_dteot    := v_dteot_st ||' - '|| v_dteot_en;
        --
        if r1.timbstr is not null then
            v_timstr  := substr(r1.timbstr,1,2)||':'||substr(r1.timbstr,3,2);
            v_timend  := substr(r1.timbend,1,2)||':'||substr(r1.timbend,3,2);
            v_timbstr := v_timstr ||' - '||v_timend;
        else
          v_timbstr := hcm_util.convert_minute_to_time(r1.qtyminb);
          if v_timbstr is not null then
            v_timbstr := v_timbstr || ' ' || get_label_name('HRMS6LU1',global_v_lang,210);
          end if;
        end if;

        if r1.timdstr is not null then
            v_timstr  := substr(r1.timdstr,1,2)||':'||substr(r1.timdstr,3,2);
            v_timend  := substr(r1.timdend,1,2)||':'||substr(r1.timdend,3,2);
            v_timdstr := v_timstr ||' - '||v_timend;
        else
          v_timdstr := hcm_util.convert_minute_to_time(r1.qtymind);
          if v_timdstr is not null then
            v_timdstr := v_timdstr || ' ' || get_label_name('HRMS6LU1',global_v_lang,210);
          end if;
        end if;
        if r1.timastr is not null then
            v_timstr  := substr(r1.timastr,1,2)||':'||substr(r1.timastr,3,2);
            v_timend  := substr(r1.timaend,1,2)||':'||substr(r1.timaend,3,2);
            v_timastr := v_timstr ||' - '||v_timend;
        else
          v_timastr := hcm_util.convert_minute_to_time(r1.qtymina);
          if v_timastr is not null then
            v_timastr := v_timastr || ' ' || get_label_name('HRMS6LU1',global_v_lang,210);
          end if;
        end if;
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno', v_appno);
        obj_data.put('chk_appr', v_chk);
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', r1.ename);
        obj_data.put('dtereq', to_char(r1.dtereq ,'dd/mm/yyyy'));
        obj_data.put('numseq', r1.numseq);
        obj_data.put('dteot', v_dteot);
        obj_data.put('dtestrt', to_char(r1.dtestrt,'dd/mm/yyyy'));
        obj_data.put('dteend', to_char(r1.dteend,'dd/mm/yyyy'));
        obj_data.put('timbstr', v_timbstr);
        obj_data.put('timdstr', v_timdstr);
        obj_data.put('timastr', v_timastr);
        obj_data.put('desrem', r1.desrem);
        obj_data.put('status', r1.status);
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remarkap', r1.remarkap);
        obj_data.put('desc_codempap',get_temploy_name(global_v_codempid,global_v_lang));
        obj_data.put('remark', r1.remark);
        obj_data.put('staappr', r1.staappr);
        v_staovrot := r1.staovrot;
--    if nvl(r1.staovrot,'N') = 'N' then

    begin
      select * into r_ttotreq
        from ttotreq
       where codempid = r1.codempid
         and dtereq = r1.dtereq
         and numseq = r1.numseq ;
    exception when no_data_found then
        r_ttotreq := null;
    end;

    begin
        select hcm_util.get_codcomp_level(codcomp,1)
          into v_codcompy
          from temploy1
         where codempid = r1.codempid;
    exception when no_data_found then
          v_codcompy := null;
    end;

    begin
        select qtymxotwk,qtymxallwk
          into v_qtymxotwk,v_qtymxallwk
          from tcontrot
         where codcompy = v_codcompy
          and dteeffec = (select max(dteeffec)
         from tcontrot
        where codcompy = v_codcompy);
    exception when no_data_found then
        v_qtymxotwk := 0;
        v_qtymxallwk := 0;
    end;

        std_ot.get_week_ot(r_ttotreq.codempid, r_ttotreq.numotreq,r_ttotreq.dtereq,r_ttotreq.numseq,r_ttotreq.dtestrt,r_ttotreq.dteend,
                           r_ttotreq.qtyminb, r_ttotreq.timbend, r_ttotreq.timbstr,
                           r_ttotreq.qtymind, r_ttotreq.timdend, r_ttotreq.timdstr,
                           r_ttotreq.qtymina, r_ttotreq.timaend, r_ttotreq.timastr,
                           global_v_codempid,
                           a_dtestweek,a_dteenweek,
                           a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
            for n in 1..v_qtyperiod loop
                v_staovrot := 'N';
                if a_sumot(n) > v_qtymxotwk then
                    v_staovrot := 'Y';
                end if;
                if a_totwork(n) > v_qtymxallwk then
                    v_staovrot := 'Y';
                end if;

                if v_staovrot = 'Y' then
                    begin
                      update ttotreq
                      set staovrot = 'Y'
                    where codempid = r1.codempid
                      and dtereq = r1.dtereq
                      and numseq = r1.numseq ;
                    end;
                    commit;
                end if;

            end loop;
--    end if;
        obj_data.put('chk_staovrot', nvl(v_staovrot,'N'));

        obj_row.put(to_char(v_row),obj_data);
        v_row := v_row+1;
      end loop;
    else
      for r1 in c_hrms6lu_c2 loop
        v_timbstr  := null;
        v_timdstr  := null;
        v_timastr  := null;
        v_date     := to_char(r1.dtereq ,'DD/MM/')||to_char(r1.dtereq,'YYYY');
        v_dteot_st := to_char(r1.dtestrt ,'DD/MM/')||to_char(r1.dtestrt,'YYYY');
        v_dteot_en := to_char(r1.dteend ,'DD/MM/')||to_char(r1.dteend,'YYYY');
        v_dteot    := v_dteot_st ||' - '|| v_dteot_en;
        --
        if r1.timbstr is not null then
            v_timstr  := substr(r1.timbstr,1,2)||':'||substr(r1.timbstr,3,2);
            v_timend  := substr(r1.timbend,1,2)||':'||substr(r1.timbend,3,2);
            v_timbstr := v_timstr ||' - '||v_timend;
        else
          v_timbstr := hcm_util.convert_minute_to_time(r1.qtyminb);
          if v_timbstr is not null then
            v_timbstr := v_timbstr || ' ' || get_label_name('HRMS6LU1',global_v_lang,210);
          end if;
        end if;
        if r1.timdstr is not null then
            v_timstr  := substr(r1.timdstr,1,2)||':'||substr(r1.timdstr,3,2);
            v_timend  := substr(r1.timdend,1,2)||':'||substr(r1.timdend,3,2);
            v_timdstr := v_timstr ||' - '||v_timend;
        else
          v_timdstr := hcm_util.convert_minute_to_time(r1.qtymind);
          if v_timdstr is not null then
            v_timdstr := v_timdstr || ' ' || get_label_name('HRMS6LU1',global_v_lang,210);
          end if;
        end if;
        if r1.timastr is not null then
            v_timstr  := substr(r1.timastr,1,2)||':'||substr(r1.timastr,3,2);
            v_timend  := substr(r1.timaend,1,2)||':'||substr(r1.timaend,3,2);
            v_timastr := v_timstr ||' - '||v_timend;
        else
          v_timastr := hcm_util.convert_minute_to_time(r1.qtymina);
          if v_timastr is not null then
            v_timastr := v_timastr || ' ' || get_label_name('HRMS6LU1',global_v_lang,210);
          end if;
        end if;
        --
        v_nextappr := null;
        if r1.staappr = 'A' then
          v_nextappr := chk_workflow.get_next_approve('HRES6KE',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
        end if;
        --
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno', v_appno);
        obj_data.put('chk_appr', v_chk);
        obj_data.put('image', get_emp_img(r1.codempid));--User37 #5638 Final Test Phase 1 V11 30/03/2021 obj_data.put('image', r1.codempid);
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', r1.ename);
        obj_data.put('dtereq', to_char(r1.dtereq ,'dd/mm/yyyy'));
        obj_data.put('numseq', r1.numseq);
        obj_data.put('dteot', v_dteot);
        obj_data.put('dtestrt', to_char(r1.dtestrt,'dd/mm/yyyy'));
        obj_data.put('dteend', to_char(r1.dteend,'dd/mm/yyyy'));
        obj_data.put('timbstr', v_timbstr);
        obj_data.put('timdstr', v_timdstr);
        obj_data.put('timastr', v_timastr);
        obj_data.put('desrem', r1.desrem);
        obj_data.put('status', r1.status);
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remarkap', r1.remarkap);
        obj_data.put('desc_codempap', v_nextappr);
        obj_data.put('remark', r1.remark);
        obj_data.put('staappr', r1.staappr);
        obj_data.put('chk_staovrot', nvl(r1.staovrot,'N'));

        obj_row.put(to_char(v_row),obj_data);
        v_row := v_row+1;
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6lu;

  --
  function call_formattime(ptime varchar2) return varchar2 is
    v_time varchar2(20 char);
    hh     varchar2(2 char);
    mm     varchar2(2 char);
  begin
    v_time := ptime;
    hh     := substr(v_time,1,2);
    mm     := substr(v_time,3,2);
    if(v_time = '') or (v_time is null)then
      return v_time;
    else
      return (hh || ':' || mm);
    end if;
  end;
  --<< user32 ST11 23/08/2021 change std detail cumulative overtime for week period
--  function get_dtestrt_period (p_codempid varchar2 ,p_dtestrot date) return date is
--    v_codcomp       tattence.codcomp%type;
--    v_codcalen      tattence.codcalen%type;
--    v_codcompt      tgrpwork.codcomp%type;
--    v_startday      tgrpwork.startday%type;
--    v_daystrtot     tgrpwork.startday%type;
--    v_dtestrtwk     date;
--    v_strtweek      date;
--    v_monday        number;
--  begin
--      begin
--          select codcomp, codcalen
--            into v_codcomp, v_codcalen
--            from tattence
--           where codempid = p_codempid
--             and dtework = p_dtestrot;
--      exception when no_data_found then
--        v_codcomp   := null;
--        v_codcalen  := null;
--      end;
--
--      v_codcompt    := get_tgrpwork_codcomp(v_codcomp ,v_codcalen);
--
--      begin
--          select startday
--            into v_startday
--            from tgrpwork
--           where codcomp = v_codcompt
--             and codcalen = v_codcalen
--             and dteeffec = (select max(dteeffec)
--                               from tgrpwork
--                              where codcomp = v_codcompt
--                                and codcalen = v_codcalen
--                                and dteeffec <= trunc(sysdate));
--      exception when no_data_found then
--        v_startday   := null;
--      end;
--
----      v_daystrtot  := to_char(  to_date(p_dtestrot ,'dd/mm/yyyy')  ,'D');
--
----      if v_daystrtot = v_startday then
----        v_dtestrtwk := p_dtestrot;
----      else
----        v_strtweek  := trunc(p_dtestrot,'IW');
---- 		v_monday  := to_char(v_strtweek,'D');
----        if v_startday = 2 then
----            v_dtestrtwk := v_strtweek;
----        elsif v_startday = 1 then
----            v_dtestrtwk := v_strtweek - 1;
----        else
----            v_dtestrtwk := v_strtweek + (v_startday - 2);
----        end if;
----      end if;
--      begin
--          Select NEXT_DAY(TRUNC(p_dtestrot,'IW'),v_startday)
--            into v_dtestrtwk
--            From dual;
--      exception when others then
--        v_dtestrtwk := sysdate;
--      end;
--
--      if v_dtestrtwk > p_dtestrot then
--          v_dtestrtwk := v_dtestrtwk - 7;
--      end if;
--    return v_dtestrtwk;
--  end get_dtestrt_period;
--  function get_qtydaywk(v_codempid varchar2, v_dtestrtwk date, v_dteendwk date) return number is
--    v_qtydaywk      number;
--    v_qtymin        number;
--  begin
--      begin
--          select sum(qtyhwork)
--            into v_qtydaywk
--            from tattence
--           where codempid = v_codempid
--             and dtework between v_dtestrtwk and v_dteendwk;
--      exception when no_data_found then
--        v_qtydaywk := null;
--      end;
--
--      begin
--          select sum(qtymin)
--            into v_qtymin
--            from tleavetr
--           where codempid = v_codempid
--             and dtework between v_dtestrtwk and v_dteendwk;
--      exception when no_data_found then
--        v_qtymin := null;
--      end;
--      v_qtydaywk := nvl(v_qtydaywk,0) - nvl(v_qtymin,0);
--    return v_qtydaywk;
--  end get_qtydaywk;
--  function get_qtyminotOth(v_codempid varchar2, v_dtestrtwk date, v_dteendwk date, v_dtereq date, v_numseq number, v_numotreq varchar2,v_addby varchar2 default null) return number is
--    v_qtydaywk      number;
--    v_qtymin        number;
--    v_qtyminotOth   number;
--    v_dteot         date;
--    v_count     number;
--
--    cursor c2 is
--      select dtestrt, dteend,
--             timbstr, timbend,
--             timdstr, timdend,
--             timastr, timaend,
--             qtyminb, qtymind, qtymina,numseq
--        from ttotreq
--       where codempid = v_codempid
--         and dtestrt between v_dtestrtwk and v_dteendwk
--         and nvl(flgchglv,'N') = 'N'
--         and staappr in ('P','A')
--         and codempid||to_char(dtereq,'yyyymmdd')||numseq <>
--             v_codempid||to_char(v_dtereq,'yyyymmdd')||v_numseq
--         and  ((v_addby is not null and not exists(select item1
--                          from ttemprpt
--                         where to_date(item1,'dd/mm/yyyy') = ttotreq.dtestrt
--                           and item2 = v_codempid
--                           and nvl(item3,0) = ttotreq.numseq
--                           and codempid = v_addby
--                           and codapp = 'HRMS6KE3')    )
--                or v_addby is null)
--      order by dtereq desc, numseq desc;
--
--    cursor c3 is
--      select dtestrt, timstrt,
--             dteend, timend,
--             qtyminr
--        from totreqd
--       where codempid = v_codempid
--         and dtewkreq between v_dtestrtwk and v_dteendwk
--         and nvl(flgchglv,'N') = 'N'
--         and numotreq <> nvl(v_numotreq,'xxxx')
--         and dayeupd is null;
--
--    cursor c4 is
--      select sum(qtyminot) qtyminot
--        from tovrtime
--       where codempid = v_codempid
--         and dtework between v_dtestrtwk and v_dteendwk
--         and numotreq <> nvl(v_numotreq,'xxxx');
--  begin
--      v_qtyminotOth := 0;
--      for r2 in c2 loop
--        v_dteot := r2.dtestrt;
--        for i2 in 0..(r2.dteend-r2.dtestrt) loop
--            v_dteot := v_dteot + i2;
--            if r2.qtyminb is not null then
--                v_qtyminotOth := nvl(v_qtyminotOth,0) + nvl(r2.qtyminb,0);
--            else
--                v_qtyminotOth := nvl(v_qtyminotOth,0) +
--                              abs((to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, r2.timbend),'dd/mm/yyyy hh24:mi') -
--                                   to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, r2.timbstr),'dd/mm/yyyy hh24:mi'))) * 24*60;
--            end if;
--
--            if r2.qtymind is not null then
--                v_qtyminotOth := nvl(v_qtyminotOth,0) + nvl(r2.qtymind,0);
--            else
--                v_qtyminotOth := nvl(v_qtyminotOth,0) +
--                              abs((to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, r2.timdend),'dd/mm/yyyy hh24:mi') -
--                                   to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, r2.timdstr),'dd/mm/yyyy hh24:mi'))) * 24*60;
--            end if;
--
--            if r2.qtymina is not null then
--                v_qtyminotOth := nvl(v_qtyminotOth,0) + nvl(r2.qtymina,0);
--            else
--                v_qtyminotOth := nvl(v_qtyminotOth,0) +
--                              abs((to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, r2.timaend),'dd/mm/yyyy hh24:mi') -
--                                   to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, r2.timastr),'dd/mm/yyyy hh24:mi'))) * 24*60;
--            end if;
--        end loop;
--      end loop;
--
--      for r3 in c3 loop
--        if r3.qtyminr is not null then
--            v_qtyminotOth := nvl(v_qtyminotOth,0) + nvl(r3.qtyminr,0);
--        else
--            v_qtyminotOth := nvl(v_qtyminotOth,0) +
--                             abs((to_date(hcm_util.convert_date_time_to_dtetime(r3.dteend, r3.timend),'dd/mm/yyyy hh24:mi') -
--                                  to_date(hcm_util.convert_date_time_to_dtetime(r3.dtestrt, r3.timstrt),'dd/mm/yyyy hh24:mi'))) * 24*60;
--        end if;
--      end loop;
--
--      for r4 in c4 loop
--        v_qtyminotOth := nvl(v_qtyminotOth,0) + nvl(r4.qtyminot,0);
--      end loop;
--    return v_qtyminotOth;
--  end get_qtyminotOth;
--  function get_qtyminot(v_dtestrt date, v_dteend date,
--                        v_qtyminb number,v_timbend varchar2,v_timbstr varchar2,
--                        v_qtymind number,v_timdend varchar2,v_timdstr varchar2,
--                        v_qtymina number,v_timaend varchar2,v_timastr varchar2) return number is
--
--    v_qtyminot   number;
--    v_dteot         date;
--  begin
--      v_dteot := v_dtestrt;
--      for i2 in 0..(v_dteend - v_dtestrt) loop
--        v_dteot := v_dtestrt + i2;
--        if v_qtyminb is not null then
--            v_qtyminot := nvl(v_qtyminot,0) + nvl(v_qtyminb,0);
--        else
--            v_qtyminot := nvl(v_qtyminot,0) +
--                          abs((to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, v_timbend),'dd/mm/yyyy hh24:mi') -
--                               to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, v_timbstr),'dd/mm/yyyy hh24:mi'))) * 24*60;
--        end if;
--
--        if v_qtymind is not null then
--            v_qtyminot := nvl(v_qtyminot,0) + nvl(v_qtymind,0);
--        else
--            v_qtyminot := nvl(v_qtyminot,0) +
--                          abs((to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, v_timdend),'dd/mm/yyyy hh24:mi') -
--                               to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, v_timdstr),'dd/mm/yyyy hh24:mi'))) * 24*60;
--        end if;
--
--        if v_qtymina is not null then
--            v_qtyminot := nvl(v_qtyminot,0) + nvl(v_qtymina,0);
--        else
--            v_qtyminot := nvl(v_qtyminot,0) +
--                          abs((to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, v_timaend),'dd/mm/yyyy hh24:mi') -
--                               to_date(hcm_util.convert_date_time_to_dtetime(v_dteot, v_timastr),'dd/mm/yyyy hh24:mi'))) * 24*60;
--        end if;
--      end loop;
--    return v_qtyminot;
--  end get_qtyminot;
--
  --req-detail
  procedure hrms6lu_detail_tab1 (json_str_input in clob, json_str_output out clob) is
    obj_data      json_object_t;
    v_row         number := 0;
    r_ttotreq     ttotreq%rowtype;
    v_timbstr     VARCHAR2(30 char);
    v_timdstr     VARCHAR2(30 char);
    v_timastr     VARCHAR2(30 char);
    v_timbend     VARCHAR2(30 char);
    v_timdend     varchar2(30 char);
    v_timaend     varchar2(30 char);
    v_qtyminb     varchar2(30 char);
    v_qtymind     varchar2(30 char);
    v_qtymina     varchar2(30 char);
    v_chkdata     boolean := false;
    v_cost_center varchar2(200 char);

    v_dtestrtwk         date;
    v_dteendwk          date;
    v_dtestrtwk2        date;
    v_dteendwk2         date;
    v_qtydaywk          number;
    v_qtymin            number;
    v_qtyot_reqoth      number;
    v_qtyot_req         number;
    v_qtyot_total       number;
    v_qtytotal          number;
    v_qtyminot          number;
    v_qtyminotOth       number;
    v_msg_error         varchar2(2000);
    v_qtymxotwk         tcontrot.qtymxotwk%type;
    v_qtymxallwk        tcontrot.qtymxallwk%type;
    p_numotreq          totreqst.numotreq%type;
    v_tmp_qtyot_req     number;
    cursor c_ttotreq is
      select * from ttotreq
      where codempid = p_codempid
      and dtereq = r_ttotreq.dtereq
      and numseq = r_ttotreq.numseq
      order by codempid ;
  begin
    initial_value (json_str_input);
    begin
      select * into r_ttotreq
      from  ttotreq
      where codempid = p_codempid
      and dtereq = to_date(p_dtereq,'ddmmyyyy')
      and numseq = p_numseq ;

      if r_ttotreq.timbstr is not null then
          v_timbstr  := substr(r_ttotreq.timbstr,1,2)||':'||substr(r_ttotreq.timbstr,3,2);
          v_timbend  := substr(r_ttotreq.timbend,1,2)||':'||substr(r_ttotreq.timbend,3,2);
      end if;
      if r_ttotreq.timdstr is not null then
          v_timdstr  := substr(r_ttotreq.timdstr,1,2)||':'||substr(r_ttotreq.timdstr,3,2);
          v_timdend  := substr(r_ttotreq.timdend,1,2)||':'||substr(r_ttotreq.timdend,3,2);
      end if;
      if r_ttotreq.timastr is not null then
          v_timastr  := substr(r_ttotreq.timastr,1,2)||':'||substr(r_ttotreq.timastr,3,2);
          v_timaend  := substr(r_ttotreq.timaend,1,2)||':'||substr(r_ttotreq.timaend,3,2);
      end if;
      if r_ttotreq.qtyminb is not null then
        v_qtyminb := hcm_util.convert_minute_to_time(r_ttotreq.qtyminb)|| ' ' || get_label_name('HRMS6LU1',global_v_lang,210);
      end if;
      if r_ttotreq.qtymind is not null then
        v_qtymind := hcm_util.convert_minute_to_time(r_ttotreq.qtymind)|| ' ' || get_label_name('HRMS6LU1',global_v_lang,210);
      end if;
      if r_ttotreq.qtymina is not null then
        v_qtymina := hcm_util.convert_minute_to_time(r_ttotreq.qtymina)|| ' ' || get_label_name('HRMS6LU1',global_v_lang,210);
      end if;
    exception when others then
      null;
    end ;
    --
    begin
      select costcent into v_cost_center
        from tcenter
       where codcomp = r_ttotreq.codcompw
         and rownum <= 1
    order by codcomp;
    exception when no_data_found then
      v_cost_center := null;
    end;
    --
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codinput', r_ttotreq.codinput);
    obj_data.put('desc_codinput', get_temploy_name(get_codempid(r_ttotreq.codinput),global_v_lang));
    obj_data.put('codempid', p_codempid);
    obj_data.put('desc_codempid', get_temploy_name(p_codempid,global_v_lang));
    obj_data.put('dtereq', to_char(r_ttotreq.dtereq,'dd/mm/yyyy'));
    obj_data.put('dtestrt', to_char(r_ttotreq.dtestrt,'dd/mm/yyyy'));
    obj_data.put('dteend', to_char(r_ttotreq.dteend,'dd/mm/yyyy'));
    obj_data.put('timbstr', v_timbstr);
    obj_data.put('timbend', v_timbend);
    obj_data.put('timdstr', v_timdstr);
    obj_data.put('timdend', v_timdend);
    obj_data.put('timastr', v_timastr);
    obj_data.put('timaend', v_timaend);
    obj_data.put('qtyminrb', v_qtyminb);
    obj_data.put('qtyminrd', v_qtymind);
    obj_data.put('qtyminra', v_qtymina);
    obj_data.put('codcompw', r_ttotreq.codcompw);
    obj_data.put('desc_codcompw', get_tcenter_name(r_ttotreq.codcompw, global_v_lang));
    obj_data.put('costcent', v_cost_center);
    obj_data.put('desc_costcent',nvl(get_tcoscent_name(v_cost_center,global_v_lang), ' '));
    obj_data.put('codrem', r_ttotreq.codrem);
    obj_data.put('flgchglv', nvl(r_ttotreq.flgchglv,'N'));
    obj_data.put('desc_codrem', get_tcodec_name('TCODOTRQ',r_ttotreq.codrem,global_v_lang));
    obj_data.put('remark', r_ttotreq.remark);

       begin
          select nvl(typalert,'N')
            into v_typalert
            from tcontrot
           where codcompy = hcm_util.get_codcomp_level(r_ttotreq.codcomp,1)
             and dteeffec = (select max(dteeffec)
                               from tcontrot
                              where codcompy = hcm_util.get_codcomp_level(r_ttotreq.codcomp,1)
                                and dteeffec <= sysdate);
      exception when others then
          v_qtymxotwk     := 0;
          v_qtymxallwk    := 0;
          v_typalert      := 'N';
      end;

    obj_data.put('typalert', v_typalert);
    --
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6lu_detail_tab1;

  procedure hrms6lu_detail_tab1_table(json_str_input in clob, json_str_output out clob) is
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_row         number := 0;
    r_ttotreq     ttotreq%rowtype;
  begin
    initial_value (json_str_input);
    begin
      select * into r_ttotreq
        from ttotreq
       where codempid = p_codempid
         and dtereq = to_date(p_dtereq,'ddmmyyyy')
         and numseq = p_numseq ;
    exception when no_data_found then
        r_ttotreq := null;
    end;
    obj_row := json_object_t();
    std_ot.get_week_ot(r_ttotreq.codempid, r_ttotreq.numotreq,r_ttotreq.dtereq,r_ttotreq.numseq,r_ttotreq.dtestrt,r_ttotreq.dteend,
                       r_ttotreq.qtyminb, r_ttotreq.timbend, r_ttotreq.timbstr,
                       r_ttotreq.qtymind, r_ttotreq.timdend, r_ttotreq.timdstr,
                       r_ttotreq.qtymina, r_ttotreq.timaend, r_ttotreq.timastr,
                       global_v_codempid,
                       a_dtestweek,a_dteenweek,
                       a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
    for n in 1..v_qtyperiod loop
        obj_data          := json_object_t();
        obj_data.put('dtestrtwk',to_char(a_dtestweek(n),'dd/mm/yyyy'));
        obj_data.put('dteendwk',to_char(a_dteenweek(n),'dd/mm/yyyy'));
        obj_data.put('qtydaywk',hcm_util.convert_minute_to_hour(a_sumwork(n)));
        obj_data.put('qtyot_reqoth',hcm_util.convert_minute_to_hour(a_sumotreqoth(n)));
        obj_data.put('qtyot_req',hcm_util.convert_minute_to_hour(a_sumotreq(n)));
        obj_data.put('qtyot_total',hcm_util.convert_minute_to_hour(a_sumot(n)));
        obj_data.put('qtytotal',hcm_util.convert_minute_to_hour(a_totwork(n)));
        obj_row.put(to_char(n - 1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6lu_detail_tab1_table;

   -- OT.
  procedure hrms6lu_detail_tab2 (json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    v_seq        number := 0;
    v_dteworkst  date;
    v_dteworken  date;
    v_dtework    date;
    v_typot      tovrtime.typot%type;
    v_ot_time    varchar2(100 char);
    v_ttotreq    ttotreq%rowtype ;
    v_rcnt       number;

    cursor c_hrms6lu_c1 is
        select dtework,codempid,typot,typwork,dtestrt,timstrt,
               dteend,timend,qtyminot,codcomp,amtmeal,qtyleave
          from tovrtime
         where codempid = p_codempid
           and dtework  between v_dteworkst and  v_dteworken
      order by codcomp,codempid,dtework,typot;

  begin
    initial_value (json_str_input);
    begin
      select *
        into  v_ttotreq
        from  ttotreq
       where  codempid = p_codempid
         and  dtereq = to_date(p_dtereq,'ddmmyyyy')
         and  numseq = p_numseq ;
    exception when others then
      null;
    end ;
    --
    v_dteworkst  := add_months(v_ttotreq.dteend,-1);
    v_dteworken  := v_ttotreq.dteend ;
    for r1 in c_hrms6lu_c1 loop
      v_seq := v_seq + 1 ;
      if r1.timstrt is not null then
          v_ot_time := to_char(r1.dtestrt,'dd/mm/yyyy')||' '||
                               substr(r1.timstrt,1,2)||':'||substr(r1.timstrt,3,2)||' - '||
                               to_char(r1.dteend,'dd/mm/yyyy')||' '||
                               substr(r1.timend,1,2)||':'||substr(r1.timend,3,2);
      end if;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid);
      obj_data.put('desc_codempid', get_temploy_name(p_codempid,global_v_lang));
      obj_data.put('dteworkst', to_char(v_dteworkst,'dd/mm/yyyy'));
      obj_data.put('dteend', to_char(v_ttotreq.dteend,'dd/mm/yyyy'));
    end loop;

    -- when no_data_found
    if v_seq = 0 then
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid);
      obj_data.put('desc_codempid', get_temploy_name(p_codempid,global_v_lang));
      obj_data.put('dteworkst', to_char(v_dteworkst,'dd/mm/yyyy'));
      obj_data.put('dteend', to_char(v_ttotreq.dteend,'dd/mm/yyyy'));
    end if;
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6lu_detail_tab2;

  -- over-time
  procedure hrms6lu_detail_tab2_table (json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_seq        number;
    v_dteworkst  date;
    v_dteworken  date;
    v_dtework    date;
    v_typot      tovrtime.typot%type;
    v_ttotreq    ttotreq%rowtype ;
    v_rcnt       number;
    v_row        number := 0;

    cursor c_hrms6lu_c1 is
      select dtework,codempid,typot,typwork,dtestrt,timstrt,
             dteend,timend,qtyminot,codcomp,amtmeal,qtyleave
        from tovrtime
       where codempid = p_codempid
         and dtework  between v_dteworkst and  v_dteworken
          order by codcomp,codempid,dtework,typot;

  begin
    initial_value (json_str_input);
    obj_row := json_object_t();
    v_row   := 0;
    begin
      select * into  v_ttotreq
      from   ttotreq
      where  codempid = p_codempid
        and  dtereq = to_date(p_dtereq,'dd/mm/yyyy')
        and  numseq = p_numseq ;
    exception when others then
      null;
    end;
    --
    v_dteworkst  := add_months(v_ttotreq.dteend,-1);
    v_dteworken  := v_ttotreq.dteend;
    --
    for r1 in c_hrms6lu_c1 loop
      v_seq := v_seq + 1 ;
      --
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtework', to_char(r1.dtework,'dd/mm/yyyy'));
      obj_data.put('typwork', r1.typwork);
      obj_data.put('typot', r1.typot);
      obj_data.put('dtestrt', to_char(r1.dtestrt,'dd/mm/yyyy'));
      obj_data.put('dteend', to_char(r1.dteend,'dd/mm/yyyy'));
      obj_data.put('timstrt', substr(r1.timstrt,1,2)||':'||substr(r1.timstrt,3,2));
      obj_data.put('timend', substr(r1.timend,1,2)||':'||substr(r1.timend,3,2));

      obj_row.put(to_char(v_row),obj_data);
      v_row := v_row+1;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6lu_detail_tab2_table;

  -- detail-attend
  procedure hrms6lu_detail_tab3_table (json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_ttotreq    ttotreq%rowtype ;
    v_dtework    date ;
    v_seq        number;
    v_rcnt       number;
    v_row        number := 0;

   cursor c_att is
     select codempid, dtework, typwork, codshift,
            timstrtw, timendw, dtein, timin, dteout, timout
       from tattence
      where codempid = p_codempid
        and dtework between v_ttotreq.dtestrt and v_ttotreq.dteend
    order by dtework;
  begin
    initial_value (json_str_input);
    obj_row := json_object_t();
    v_row   := 0;
    begin
      select * into  v_ttotreq
      from  ttotreq
      where codempid = p_codempid
        and dtereq   = to_date(p_dtereq,'ddmmyyyy')
        and numseq   = p_numseq;
    exception when others then
        null ;
    end;
    --
    for r1 in c_att loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtework', to_char(r1.dtework,'dd/mm/yyyy'));
      obj_data.put('typwork', r1.typwork);
      obj_data.put('codshift', r1.codshift);
      --
      obj_data.put('timstrtw', substr(r1.timstrtw,1,2)||':'||substr(r1.timstrtw,3,2));
      obj_data.put('timendw', substr(r1.timendw,1,2)||':'||substr(r1.timendw,3,2));
      obj_data.put('timin', substr(r1.timin,1,2)||':'||substr(r1.timin,3,2));
      obj_data.put('timout', substr(r1.timout,1,2)||':'||substr(r1.timout,3,2));

      obj_row.put(to_char(v_row),obj_data);
      v_row := v_row+1;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6lu_detail_tab3_table;
  --
  PROCEDURE insert_data  (p_ttotreq   in ttotreq%rowtype,
                        p_staemp    in temploy1.staemp%type,
                        p_dteeffex  in temploy1.dteeffex%type,
                        p_numotreq  in varchar2,
                        p_codappr   in varchar2,
                        p_dteappr   in date,
                        p_coduser   in varchar2,
                        p_lang      in varchar2) is

    v_timenotb  varchar2(4 char) ;
    v_timstota  varchar2(4 char) ;
    v_gentime   varchar2(1 char) ;
    v_typot     varchar2(1 char) ;
    v_timstrt   varchar2(4 char) ;
    v_timend    varchar2(4 char) ;
    v_timstrtb  varchar2(4 char);
    v_timendb   varchar2(4 char);
    v_timstrtd  varchar2(4 char);
    v_timendd   varchar2(4 char);
    v_timstrta  varchar2(4 char);
    v_timenda   varchar2(4 char);
    v_dtestrt   date ;
    v_dteend    date ;
    v_dtestrtw  date ;
    v_dteendw   date ;
    v_timstrtw  varchar2(10 char) ;
    v_timendw   varchar2(10 char) ;
    v_count     number := 0;
    v_codshift  tattence.codshift%type;
    v_typwork   tattence.typwork%type;
    v_codcalen  temploy1.codcalen%type;
    v_dtewkst   date;
    v_dtewken   date;
    v_dteotst   date;
    v_dteoten   date;
    v_qtyminb   number;
    v_qtymind   number;
    v_qtymina   number;
    v_qtyotreq  number;
    v_typalert  tcontrot.typalert%type;

    cursor c_tattence is
        select codempid,dtework,typwork,codshift,dtestrtw,
               dteendw,timstrtw,timendw,codcalen
        from   tattence
        where  codempid = p_ttotreq.codempid
        and    dtework  between p_ttotreq.dtestrt and p_ttotreq.dteend
        order by codempid,dtework;

  BEGIN
    << main_loop >>
    loop
    if p_staemp = '0' or (p_staemp = '9' and p_dteeffex <= p_ttotreq.dtestrt) then
        exit main_loop;
    end if;
    if   p_ttotreq.timbstr is null and p_ttotreq.timbend is null and
         p_ttotreq.timdstr is null and p_ttotreq.timdend is null and
         p_ttotreq.timastr is null and p_ttotreq.timaend is null and
         p_ttotreq.qtyminb is null and
         p_ttotreq.qtymind is null and
         p_ttotreq.qtymina is null then
        v_gentime := 'N';
    else
        v_gentime := 'Y';
    end if;

    if v_gentime = 'Y' then
        -- After Work
        if p_ttotreq.timastr is not null or p_ttotreq.timaend is not null then
            v_typot  := 'A' ;
            v_timstrt   := p_ttotreq.timastr;
            v_timend    := p_ttotreq.timaend;
            v_timstrta  := p_ttotreq.timastr;
            v_timenda   := p_ttotreq.timaend;
        end if;
        if p_ttotreq.qtymina is not null then
            v_typot  := 'A' ;
            v_qtymina   := p_ttotreq.qtymina;
        end if;
        -- Befor Work
        if p_ttotreq.timbstr is not null or p_ttotreq.timbend is not null then
            v_typot     := 'B' ;
            v_timstrt   := p_ttotreq.timbstr;
            v_timend    := p_ttotreq.timbend;
            v_timstrtb  := p_ttotreq.timbstr;
            v_timendb   := p_ttotreq.timbend;
        end if;
        if p_ttotreq.qtyminb is not null then
            v_typot  := 'B' ;
            v_qtyminb   := p_ttotreq.qtyminb;
        end if;
        --During
        if p_ttotreq.timdstr is not null and p_ttotreq.timdend is not null then
            v_typot     := 'D' ;
            v_timstrt   := p_ttotreq.timdstr;
            v_timend    := p_ttotreq.timdend;
            v_timstrtd  := p_ttotreq.timdstr;
            v_timendd   := p_ttotreq.timdend;
        end if;
        if p_ttotreq.qtymind is not null then
            v_typot  := 'D' ;
            v_qtymind   := p_ttotreq.qtymind;
        end if;
        begin
            select codcalen
              into v_codcalen
              from temploy1
             where codempid = p_ttotreq.codempid;
        exception when no_data_found then
            null;
        end;

        begin
            select codshift, typwork
              into v_codshift, v_typwork
              from tattence
             where codempid = p_ttotreq.codempid
               and dtework  = p_ttotreq.dtestrt
               and rownum   = 1;
        exception when no_data_found then
            null;
        end;

        insert into totreqst(numotreq,
                             dtereq,typotreq,codempid,codcomp,codappr,dteappr,codrem,dayeupd,
                             dtestrt,dteend,
                             staotreq,coduser,codshift,typwork,codcalen,flgchglv,remark,codcompw,
                             timstrtb,timendb,timstrtd,timendd,timstrta,timenda,
                             qtyminb,qtymind,qtymina,codcreate)
                      values(p_numotreq,
                             p_ttotreq.dtereq,1,p_ttotreq.codempid,p_ttotreq.codcomp,p_codappr,p_dteappr,p_ttotreq.codrem,null,
                             p_ttotreq.dtestrt,p_ttotreq.dteend,
                             'A',p_coduser,v_codshift,v_typwork,v_codcalen,p_ttotreq.flgchglv,p_ttotreq.remark,p_ttotreq.codcompw,
                             v_timstrtb,v_timendb,v_timstrtd,v_timendd,v_timstrta,v_timenda,
                             v_qtyminb,v_qtymind,v_qtymina,global_v_codempid);


    end if;
    v_typot   := null;
    v_timstrt := null;
    v_timend  := null;
    begin
      select nvl(typalert,'1')
        into v_typalert
        from tcontrot
       where codcompy = hcm_util.get_codcomp_level(p_ttotreq.codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontrot
                          where codcompy = hcm_util.get_codcomp_level(p_ttotreq.codcomp,1)
                            and dteeffec <= sysdate);
    exception when others then
      v_typalert      := '1';
    end;
    for r_tattence in c_tattence loop
        if (p_staemp = '9' and p_dteeffex <= r_tattence.dtework) then
            exit main_loop;
        end if;
        << cal_loop >>
        loop
        if v_gentime = 'Y' then
            if p_ttotreq.timbend is null or p_ttotreq.timastr is null then
                begin
                  select timenotb,timstota
                  into   v_timenotb,v_timstota
                  from   tshiftcd
                  where  codshift = r_tattence.codshift ;
                exception when no_data_found then
                    v_timenotb := null ;
                    v_timstota := null ;
                end ;
            end if;
            if v_typalert <> 'N' then
              v_qtyotreq := p_ttotreq.qtyotreq;
            else
              v_qtyotreq := null;
            end if;
            -- After Work
--            if p_ttotreq.timastr is not null or p_ttotreq.timaend is not null or p_ttotreq.qtymina is not null then
            if p_ttotreq.timastr is not null or p_ttotreq.timaend is not null or p_ttotreq.qtymina <> 0 then
                v_typot     := 'A' ;
                v_dtestrt   := r_tattence.dtework;
                v_timstrt   := nvl(p_ttotreq.timastr,v_timstota) ;
                v_timend    := p_ttotreq.timaend ;

                if v_timstrt <  r_tattence.timstrtw then
                  v_dtestrt := r_tattence.dtestrtw + 1;
                else
                  v_dtestrt := r_tattence.dtestrtw;
                end if;
                if v_timstrt >= v_timend then
                   v_dteend := v_dtestrt + 1;
                else
                   v_dteend  := v_dtestrt;
                end if;

                if p_ttotreq.qtymina is not null then
                  v_dtestrt := null;
                  v_timstrt := null;
                  v_dteend  := null;
                  v_timend  := null;
                end if;

                insert into totreqd
                                  (
                                   numotreq,codempid,dtewkreq,
                                   typot,codcomp,dtestrt,
                                   dteend,timstrt,timend,
                                   codcalen,codshift,coduser,
                                   codcompw,flgchglv,qtyminr,qtyotreq,
                                   codcreate
                                   )
                        values
                                  (
                                   p_numotreq,r_tattence.codempid,r_tattence.dtework,
                                   v_typot,p_ttotreq.codcomp,v_dtestrt,
                                   v_dteend,v_timstrt,v_timend,
                                   r_tattence.codcalen,r_tattence.codshift,p_coduser,
                                   p_ttotreq.codcompw,p_ttotreq.flgchglv,p_ttotreq.qtymina,v_qtyotreq,
                                   p_coduser
                                   );
             end if;

             -- Befor Work
             if p_ttotreq.timbstr is not null or p_ttotreq.timbend is not null or p_ttotreq.qtyminb <> 0 then
                v_dtestrt  := r_tattence.dtework;
                v_typot     := 'B' ;
                v_timstrt   := p_ttotreq.timbstr;
                v_timend    := nvl(p_ttotreq.timbend,v_timenotb) ;
                if v_timend >  r_tattence.timendw then
                  v_dteend := r_tattence.dteendw - 1;
                else
                  v_dteend := r_tattence.dteendw;
                end if;
                if v_timstrt > v_timend then
                  v_dtestrt := v_dteend - 1;
                else
                  v_dtestrt := v_dteend;
                end if;

                if p_ttotreq.qtyminb is not null then
                  v_dtestrt := null;
                  v_timstrt := null;
                  v_dteend  := null;
                  v_timend  := null;
                end if;

                insert into totreqd
                                  (
                                   numotreq,codempid,dtewkreq,
                                   typot,codcomp,dtestrt,
                                   dteend,timstrt,timend,
                                   codcalen,codshift,coduser,
                                   codcompw,flgchglv,qtyminr,qtyotreq,
                                   codcreate
                                   )
                        values
                                  (
                                   p_numotreq,r_tattence.codempid,r_tattence.dtework,
                                   v_typot,p_ttotreq.codcomp,v_dtestrt,
                                   v_dteend,v_timstrt,v_timend,
                                   r_tattence.codcalen,r_tattence.codshift,p_coduser,
                                   p_ttotreq.codcompw,p_ttotreq.flgchglv,p_ttotreq.qtyminb,v_qtyotreq,
                                   p_coduser
                                   );
            end if;

            -- During Work
            if /*r_tattence.typwork in ('H','T','S','L') and*/ (p_ttotreq.timdstr is not null and p_ttotreq.timdend is not null or p_ttotreq.qtymind <> 0) then
              v_dtestrt  := r_tattence.dtework;
              v_typot     := 'D' ;
              v_timstrt   := p_ttotreq.timdstr;
              v_timend    := p_ttotreq.timdend;
              v_dtestrt   := r_tattence.dtework;
              v_dtewkst := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tattence.timstrtw,'dd/mm/yyyyhh24mi');
              v_dtewken := to_date(to_char(r_tattence.dteendw,'dd/mm/yyyy')||r_tattence.timendw,'dd/mm/yyyyhh24mi');
              if v_timstrt >= v_timend then
                v_dteend := v_dtestrt + 1;
              else
                v_dteend := v_dtestrt;
              end if;
              --
              v_dteotst := to_date(to_char(v_dtestrt,'dd/mm/yyyy')||v_timstrt,'dd/mm/yyyyhh24mi');
              v_dteoten := to_date(to_char(v_dteend,'dd/mm/yyyy')||v_timend,'dd/mm/yyyyhh24mi');
              if v_dtewkst between v_dteotst and v_dteoten
              or v_dtewken between v_dteotst and v_dteoten
              or v_dteotst between v_dtewkst and v_dtewken
              or v_dteoten between v_dtewkst and v_dtewken then
                null;
              else
                v_dtestrt := v_dtestrt - 1;
                v_dteend  := v_dteend  - 1;
                v_dteotst := v_dteotst - 1;
                v_dteoten := v_dteoten - 1;

                if v_dtewkst between v_dteotst and v_dteoten
                or v_dtewken between v_dteotst and v_dteoten
                or v_dteotst between v_dtewkst and v_dtewken
                or v_dteoten between v_dtewkst and v_dtewken then
                  null;
                else
                  v_dtestrt := v_dtestrt + 2;
                  v_dteend  := v_dteend  + 2;
                  v_dteotst := v_dteotst + 2;
                  v_dteoten := v_dteoten + 2;

                  if v_dtewkst between v_dteotst and v_dteoten
                  or v_dtewken between v_dteotst and v_dteoten
                  or v_dteotst between v_dtewkst and v_dtewken
                  or v_dteoten between v_dtewkst and v_dtewken then
                    null;
                  else
                    v_dtestrt := v_dtestrt - 1;
                    v_dteend  := v_dteend  - 1;
                    v_dteotst := v_dteotst - 1;
                    v_dteoten := v_dteoten - 1;
                  end if;
                end if;
              end if;

              if p_ttotreq.qtymind is not null then
                v_dtestrt := null;
                v_timstrt := null;
                v_dteend  := null;
                v_timend  := null;
              end if;

              insert into totreqd(numotreq,codempid,dtewkreq,
                                  typot,codcomp,dtestrt,
                                  dteend,timstrt,timend,
                                  codcalen,codshift,coduser,
                                  codcompw,flgchglv,qtyminr,qtyotreq,
                                  codcreate)
                           values(p_numotreq,r_tattence.codempid,r_tattence.dtework,
                                  v_typot,p_ttotreq.codcomp,v_dtestrt,
                                  v_dteend,v_timstrt,v_timend,
                                  r_tattence.codcalen,r_tattence.codshift,p_coduser,
                                  p_ttotreq.codcompw,p_ttotreq.flgchglv,p_ttotreq.qtymind,v_qtyotreq,
                                  p_coduser);
            end if;--r_tattence.typwork in ('H','T','S','L')
          end if;
          exit cal_loop;
        end loop;
    end loop; -- for r_tattence
        exit main_loop;
    end loop;
  END;
  --
  PROCEDURE Approve(p_coduser         in varchar2,
                    p_lang            in varchar2,
                    p_total           in varchar2,
                    p_status          in varchar2,
                    p_remark_appr     in varchar2,
                    p_remark_not_appr in varchar2,
                    p_dteappr         in varchar2,
                    p_appseq          in number,
                    p_chk             in varchar2,
                    p_codempid        in varchar2,
                    p_seqno           in number,
                    p_dtereq          in varchar2) is

    --  Request
    rq_codempid varchar2(10 char):= p_codempid;
    rq_dtereq   date            := to_date(p_dtereq,'dd/mm/yyyy');
    rq_seqno    number          := p_seqno;
    v_appseq    number          := p_appseq;
    rq_chk      VARCHAR2(1 char):= p_chk;
    v_ttotreq   ttotreq%ROWTYPE;
    v_approvno  NUMBER := NULL;
    ap_approvno NUMBER := NULL;
    v_count     number := 0;
    v_staappr   varchar2(1 char);
    v_numotreq  taptotrq.numotreq%TYPE;
    p_codappr   temploy1.codempid%type := pdk.Check_Codempid(p_coduser);
    v_codeappr  temploy1.codempid%type;
    v_approv    VARCHAR2(10 char);
    v_desc      varchar2(600 char) := get_label_name('HCM_APPRFLW',global_v_lang,10);

    v_codempap  temploy1.codempid%type;
    v_routeno   VARCHAR2(15 char);
    v_codcompap tcenter.codcomp%type;
    v_codposap  tpostn.codpos%type;
    v_staemp    VARCHAR2(10 char);
    v_dteeffex  DATE ;
    v_remark    VARCHAR2(7000 char);
    v_max_approv number;
    v_row_id     varchar2(200 char);

    v_qtymxotwk     tcontrot.qtymxotwk%type;
    v_qtymxallwk    tcontrot.qtymxallwk%type;

    v_dtestrtwk     date;
    v_dtestrtwk2    date;
    v_typalert      tcontrot.typalert%type;
    
    --
    vv_codcompy          temploy1.codcomp%type;
    vv_loop              number;
    vv_count             number;

  begin
    v_staappr :=  p_status;
    v_zyear   := pdk.check_year(p_lang);
    if v_staappr = 'A' then
      v_remark := p_remark_appr;
    elsif v_staappr = 'N' then
      v_remark := p_remark_not_appr;
    end if;
    v_remark  := replace(v_remark,'.',chr(13));
    v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');

    v_numotreq  := null ;
    begin
          select *   into v_ttotreq
          from  ttotreq
          where codempid =  rq_codempid
          and   dtereq   =  rq_dtereq
          and   numseq   =  rq_seqno;
    exception when others then
          v_ttotreq :=  null;
    end;

    ---<<< weerayut 31/01/2018 Lock request during payroll
    if get_payroll_active('HRMS6LU',v_ttotreq.codempid,v_ttotreq.dtestrt,v_ttotreq.dteend) = 'Y' then
      param_msg_error := get_error_msg_php('ES0057',p_lang);
      return;
    end if;
    --->>> weerayut 31/01/2018
    begin
      select approvno into v_max_approv
      from   twkflowh
      where  routeno = v_ttotreq.routeno ;
    exception when no_data_found then
      v_max_approv := 0 ;
    end ;

    if v_ttotreq.staappr <> 'Y' then
      begin
        select staemp,dteeffex
        into   v_staemp,v_dteeffex
        from   temploy1
        where  codempid = rq_codempid ;
        if v_staemp = '0' then
           param_msg_error := rq_codempid||' - '||get_error_msg_php('HR2102',p_lang);
           return ;
        elsif v_staemp = '9' and v_ttotreq.dtestrt >= v_dteeffex then
           param_msg_error := rq_codempid||' - '||get_error_msg_php('HR2101',p_lang);
           return ;
        end if;
      exception when others then
         param_msg_error := rq_codempid||' - '||get_error_msg_php('HR2010',p_lang, 'TEMPLOY1');
         return ;
      end ;
      ap_approvno :=  v_appseq;

      -- Step 2 => Insert Table Request Detail
      begin
        select  count(*)   into  v_count
          from  taptotrq
         where  codempid = rq_codempid
           and  dtereq   = rq_dtereq
           and  numseq   = rq_seqno
           and  approvno = ap_approvno;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
          insert into
             taptotrq(
                      codempid,dtereq,numseq,approvno,
                      codappr,dteappr,numotreq,staappr,
                      remark,coduser,dteapph
                      )
          values
                      (
                      rq_codempid,rq_dtereq,rq_seqno, ap_approvno,
                      p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),v_numotreq,v_staappr,
                      v_remark,p_coduser,sysdate
                      );
      else
              update taptotrq
                 set codappr  = p_codappr,
                     dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                     numotreq = v_numotreq,
                     staappr  = v_staappr,
                     remark   = v_remark,
                     coduser  = p_coduser,
                     dteapph  = sysdate
               where  codempid = rq_codempid
                 and  dtereq   = rq_dtereq
                 and  numseq   = rq_seqno
                 and  approvno = ap_approvno;
      end if;

      -- Step 3 => Check Next Step
      v_codeappr  := p_codappr ;
      v_approvno  := ap_approvno;
      v_routeno   := v_ttotreq.routeno ;

      chk_workflow.find_next_approve('HRES6KE',v_routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);

      if v_staappr = 'A' and rq_chk <> 'E' then
        loop
          v_approv := chk_workflow.check_next_step('HRES6KE',v_ttotreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
          if  v_approv is not null then
            v_remark   := v_desc;
            v_approvno := v_approvno + 1 ;
            v_codeappr := v_approv ;
            begin
              select  count(*) into v_count
               from   taptotrq
               where  codempid = rq_codempid
               and    dtereq   = rq_dtereq
               and    numseq   = rq_seqno
               and    approvno = v_approvno;
            exception when no_data_found then  v_count := 0;
            end;
            if v_count = 0 then
              insert into  taptotrq
                    (codempid,dtereq,numseq,approvno,codappr,dteappr,numotreq,staappr,
                    remark,coduser,dteapph)
              values(rq_codempid,rq_dtereq,rq_seqno,v_approvno,
                     v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),v_numotreq,'a',
                     v_remark,p_coduser,sysdate
                     );
            else
              update taptotrq
                 set codappr   = v_codeappr,
                     dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                     numotreq  = v_numotreq,
                     staappr   = 'A',
                     remark    =  v_remark,
                     coduser   = p_coduser,
                     dteapph   = sysdate
                where codempid = rq_codempid
                  and dtereq   = rq_dtereq
                  and numseq   = rq_seqno
                  and approvno = v_approvno;
            end if;
            chk_workflow.find_next_approve('HRES6KE',v_routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
          else
            exit ;
          end if;
        end loop ;

        update ttotreq set  approvno  = v_approvno,
                            codappr   = v_codeappr,
                            dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                            staappr   = v_staappr,
                            remarkap  = v_remark,
                            coduser   = p_coduser,
                            dteapph   = sysdate
                     where codempid   = rq_codempid
                       and dtereq     = rq_dtereq
                       and numseq     = rq_seqno;
      end if;
      -- End Check Next Step

      -- Step 4 => Update Table Request and Insert Transaction
      v_staappr := p_status ;
      if v_max_approv = v_approvno then
        rq_chk := 'E' ;
      end if;

      if rq_chk = 'E' and p_status = 'A' then
        v_staappr := 'Y';
        -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 19/04/2024 | 4449#1915 (bk)
        -- v_numotreq := std_al.gen_req('OTRQ','TOTREQST','NUMOTREQ',v_zyear);
        -- std_al.upd_req('OTRQ',v_numotreq,p_coduser,v_zyear,'');
        -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 19/04/2024 | 4449#1915 (bk)
        
         -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 19/04/2024 | 4449#1915 (add)
            begin
                select get_codcompy(codcomp)
                into vv_codcompy
                from temploy1
                where codempid = p_codempid;
            exception when no_data_found then 
                vv_codcompy := null;
            end;
        
        vv_loop := 0;
        loop
            vv_loop := vv_loop + 1;
            
            v_numotreq 	:= std_al.gen_req ('OTRQ','TOTREQST','NUMOTREQ',v_zyear,vv_codcompy,'') ;
            std_al.upd_req('OTRQ',v_numotreq,p_coduser,v_zyear,vv_codcompy,'');
            
            begin
                select count(*)
                into vv_count
                from totreqst
                where numotreq = v_numotreq;
            exception when no_data_found then
                null;
            end;
            
            exit when (vv_count = 0 or vv_loop = 100);
        end loop;
        -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 19/04/2024 | 4449#1915 (add)

        insert_data(v_ttotreq,v_staemp,v_dteeffex,
                   v_numotreq,v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),-- user22 : 04/07/2016 : STA4590287 || v_numotreq,p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),
                   p_coduser,p_lang);
      end if;

      update ttotreq
      set
          staappr   = v_staappr,
          codappr   = v_codeappr,
          approvno  = v_approvno,
          dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
          numotreq  = v_numotreq,
          remarkap  = v_remark,
          dteapph   = sysdate,
          coduser   = p_coduser
      where codempid = rq_codempid
        and dtereq   = rq_dtereq
        and numseq   = rq_seqno;

      commit;

      begin
        select rowid into  v_row_id
         from ttotreq
        where codempid =  rq_codempid
          and dtereq   =  rq_dtereq
          and numseq   =  rq_seqno ;
      exception when others then
       v_ttotreq :=  null ;
      end ;

      --sendmail
      begin 
        chk_workflow.sendmail_to_approve( p_codapp        => 'HRES6KE',
                                          p_codtable_req  => 'ttotreq',
                                          p_rowid_req     => v_row_id,
                                          p_codtable_appr => 'taptotrq',
                                          p_codempid      => rq_codempid,
                                          p_dtereq        => rq_dtereq,
                                          p_seqno         => rq_seqno,
                                          p_staappr       => v_staappr,
                                          p_approvno      => v_approvno,
                                          p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                          p_subject_mail_numseq  => '60',
                                          p_lang          => global_v_lang,
                                          p_coduser       => global_v_coduser);
      exception when others then
        param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
      end;
    end if;
  exception when others then
     rollback;
     param_msg_error := sqlerrm;
  end;  -- Procedure Approve
  --
--  procedure check_approve (json_param in json_object_t)is
--    v_codempid  temploy1.codempid%type;
--    v_codrem    tcodotrq.codcodec%type;
--    v_numlvl    temploy1.numlvl%type;
--    v_staemp    temploy1.staemp%type;
--    v_dteeffex  temploy1.dteeffex%type;
--
--    v_qtyday    number(2);
--    v_flgsecu   boolean;
--
--    v_qtymxotwk     tcontrot.qtymxotwk%type;
--    v_qtymxallwk    tcontrot.qtymxallwk%type;
--
--    v_dtestrtwk     date;
--    v_dtestrtwk2    date;
--    v_typalert      tcontrot.typalert%type;
--
--    v_staappr       varchar2(100);
--    v_appseq        number;
--    v_chk           varchar2(10);
--    v_seqno         number;
--    v_dtereq        varchar2(100);
--    json_obj2       json_object_t;
--    v_ttotreq       ttotreq%rowtype;
--
--  begin
--    for i in 0..json_param.get_size-1 loop
--      json_obj2   := hcm_util.get_json_t(json_param,to_char(i));
--      v_staappr   := hcm_util.get_string_t(json_obj2, 'p_staappr');
--      v_appseq    := to_number(hcm_util.get_string_t(json_obj2, 'p_approvno'));
--      v_chk       := hcm_util.get_string_t(json_obj2, 'p_chk_appr');
--      v_seqno     := to_number(hcm_util.get_string_t(json_obj2, 'p_numseq'));
--      v_codempid  := hcm_util.get_string_t(json_obj2, 'p_codempid');
--      v_dtereq    := hcm_util.get_string_t(json_obj2, 'p_dtereq');
--      begin
--            select *   into v_ttotreq
--            from  ttotreq
--            where codempid =  v_codempid
--            and   dtereq   =  to_date(v_dtereq,'dd/mm/yyyy')
--            and   numseq   =  v_seqno;
--      exception when others then
--            v_ttotreq :=  null;
--      end;
--       begin
--          select qtymxotwk,qtymxallwk,nvl(typalert,'1')
--            into v_qtymxotwk,v_qtymxallwk,v_typalert
--            from tcontrot
--           where codcompy = hcm_util.get_codcomp_level(v_ttotreq.codcomp,1)
--             and dteeffec = (select max(dteeffec)
--                               from tcontrot
--                              where codcompy = hcm_util.get_codcomp_level(v_ttotreq.codcomp,1)
--                                and dteeffec <= sysdate);
--      exception when others then
--          v_qtymxotwk     := 0;
--          v_qtymxallwk    := 0;
--          v_typalert      := '1';
--      end;
--
--      v_qtymxotwk         := nvl(v_qtymxotwk,0);
--      v_msgerror          := null;
--      ttotreq_staovrot    := 'N';
--      if (p_qtyot_total > v_qtymxotwk) then
--          if v_typalert = '1' then
--              ttotreq_staovrot    := 'Y';
--              v_msgerror          := replace(get_error_msg_php('ESZ002',global_v_lang),'@#$%400');
--          elsif v_typalert = '2' then
--              param_msg_error := get_error_msg_php('ESZ002',global_v_lang);
--          end if;
--          return;
--      end if;
--
--      if (p_qtytotal > v_qtymxallwk) then
--          if v_typalert = '1' then
--              ttotreq_staovrot    := 'Y';
--              v_msgerror          := replace(get_error_msg_php('ESZ003',global_v_lang),'@#$%400');
--          elsif v_typalert = '2' then
--              param_msg_error := get_error_msg_php('ESZ003',global_v_lang);
--          end if;
--          return;
--      end if;
--    end loop;
--
--    --<< user18 ST11 03/08/2021 change std
--  end;
  procedure process_approve(json_str_input in clob, json_str_output out clob) is
    json_obj        json_object_t;
    json_obj2       json_object_t;
    v_rowcount      number:= 0;
    v_staappr       varchar2(100);
    v_appseq        number;
    v_chk           varchar2(10);
    v_seqno         number;
    v_codempid      varchar2(100);
    v_dtereq        varchar2(100);

  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input).get_object('param_json');
--    check_approve(json_obj);
    v_rowcount := json_obj.get_size;
    for i in 0..json_obj.get_size-1 loop
      json_obj2   := hcm_util.get_json_t(json_obj,to_char(i));
      v_staappr   := hcm_util.get_string_t(json_obj2, 'p_staappr');
      v_appseq    := to_number(hcm_util.get_string_t(json_obj2, 'p_approvno'));
      v_chk       := hcm_util.get_string_t(json_obj2, 'p_chk_appr');
      v_seqno     := to_number(hcm_util.get_string_t(json_obj2, 'p_numseq'));
      v_codempid  := hcm_util.get_string_t(json_obj2, 'p_codempid');
      v_dtereq    := hcm_util.get_string_t(json_obj2, 'p_dtereq');

      v_staappr := nvl(v_staappr, 'A');
      approve(global_v_coduser,global_v_lang,to_char(v_rowcount),v_staappr,p_remark_appr,p_remark_not_appr,to_char(sysdate,'dd/mm/yyyy'),v_appseq,v_chk,v_codempid,v_seqno,v_dtereq);
      exit when param_msg_error is not null;
    end loop;
    if param_msg_error is not null then
      rollback;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    elsif param_msg_error is not null then
      rollback;
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      if param_msg_error_mail is not null then
        json_str_output := get_response_message(201,param_msg_error_mail,global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      end if;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end process_approve;
end;

/
