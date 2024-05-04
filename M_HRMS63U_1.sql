--------------------------------------------------------
--  DDL for Package Body M_HRMS63U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRMS63U" is
/* Cust-Modify: KOHU-SM2301 */
-- last update: 04/12/2023 10:30

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_empid      := hcm_util.get_string_t(json_obj,'codinput');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtest             := hcm_util.get_string_t(json_obj,'p_dtest');
    p_dteen             := hcm_util.get_string_t(json_obj,'p_dteen');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    --
    p_dtereq            := hcm_util.get_string_t(json_obj,'p_dtereq');
    p_seqno             := hcm_util.get_string_t(json_obj,'p_numseq');
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure hrms63u(json_str_input in clob, json_str_output out clob) as
    json_obj      json_object_t;
    v_row         number := 0;
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_codappr     temploy1.codempid%type;
    v_codpos      tpostn.codpos%type;
    v_nextappr    varchar2(1000 char);
    v_dtest       date;
    v_dteen       date;
    v_rcnt        number;
    v_appno       varchar2(100 char);
    v_chk         varchar2(100 char) := ' ';
    v_flg_exist   boolean := false;
    v_timstrt     varchar2(10 char);
    v_timend      varchar2(10 char);

    cursor c_hrms63u_c1 is
      select dtereq,codempid,codappr,a.approvno appno,numlereq,codleave,dteend,dteappr,
             get_temploy_name(codempid,global_v_lang) ename,seqno,staappr,timend,
             codcomp,dtestrt,timstrt,get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
             0 qtyapp, --user36 KOHU-SM2301 04/12/2023 ||b.approvno qtyapp,
             remarkap,deslereq
        from tleaverq a 
             --user36 KOHU-SM2301 04/12/2023 ||,twkflowh b
       where /*user36 KOHU-SM2301 04/12/2023 cancel
              codcomp like p_codcomp||'%'
         and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
         and */
              staappr in ('P','A')
         and ('Y' = chk_workflow.check_privilege('HRES62E',codempid,dtereq,seqno,(nvl(a.approvno,0) + 1),v_codappr)
              /*user36 KOHU-SM2301 04/12/2023 cancel
              -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                        from   twkflowde c
                                                        where  c.routeno  = a.routeno
                                                        and    c.codempid = v_codappr)
              and trunc(((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES62E'))*/
              )
         --user36 KOHU-SM2301 04/12/2023 cancel ||and a.routeno = b.routeno
     order by  codempid,dtereq desc,seqno;

    cursor c_hrms63u_c2 is
     select dtereq,codempid,codappr,approvno,numlereq,codleave,dteend,dteappr,
               get_temploy_name(codempid,global_v_lang) ename,seqno,staappr,timend,
               codcomp,dtestrt,timstrt,get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,remarkap,deslereq
       from tleaverq
      where codcomp like p_codcomp||'%'
        and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
        and (codempid ,dtereq,seqno) in
                      (select codempid ,dtereq,seqno
                       from  taplverq
                       where staappr = decode(p_staappr,'Y','A',p_staappr)
                       and   codappr = v_codappr
                       and   dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr))
       order by  codempid,dtereq,seqno;
  begin
    initial_value(json_str_input);
    v_codappr     := pdk.check_codempid(global_v_coduser);
    v_dtest       := to_date(replace(p_dtest,'/',null),'ddmmyyyy');
    v_dteen       := to_date(replace(p_dteen,'/',null),'ddmmyyyy');
    -- default value --
    obj_row   := json_object_t();
    v_row     := 0;
    -- get data
    if p_staappr = 'P' then
      for r1 in c_hrms63u_c1 loop
        v_appno  := nvl(r1.appno,0) + 1;
        /*user36 KOHU-SM2301 04/12/2023 cancel 
        if nvl(r1.appno,0)+1 = r1.qtyapp then
           v_chk := 'E' ;
        else*/
           v_chk := v_appno;
        --user36 KOHU-SM2301 04/12/2023 cancel ||end if;
        --
        begin
          select codpos into v_codpos
            from temploy1
           where codempid = r1.codempid;
        exception when no_data_found then
          v_codpos := null;
        end;
        --
        v_row := v_row+1;
        v_timstrt := '';
        v_timend  := '';

        if r1.timstrt is not null then
          v_timstrt := substr(r1.timstrt, 1, 2)||':'||substr(r1.timstrt, 3, 2);
        end if;
        if r1.timend is not null then
          v_timend := substr(r1.timend, 1, 2)||':'||substr(r1.timend, 3, 2);
        end if;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno',v_appno);
        obj_data.put('chk_appr',v_chk);
        obj_data.put('codempid',r1.codempid);
        obj_data.put('image',get_emp_img(r1.codempid));
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('dtereq',to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq',to_char(r1.seqno));
        obj_data.put('desc_codleave',get_tleavecd_name(r1.codleave, global_v_lang));
        obj_data.put('dteperiod',to_char(r1.dtestrt ,'DD/MM/YYYY')|| ' '|| substr(r1.timstrt,1,2)||':'|| substr(r1.timstrt,3,2)||'  - '||to_char(r1.dteend ,'DD/MM/YYYY')|| ' '|| substr(r1.timend ,1,2)||':'|| substr(r1.timend ,3,2));
        obj_data.put('dtestrt',to_char(r1.dtestrt ,'DD/MM/YYYY'));
        obj_data.put('dteend',to_char(r1.dteend ,'DD/MM/YYYY'));
        obj_data.put('timstrt',v_timstrt);
        obj_data.put('timend',v_timend);
        obj_data.put('status',r1.status);
        obj_data.put('desc_codappr',get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark',r1.remarkap);
        obj_data.put('desc_codempap',get_temploy_name(global_v_codempid,global_v_lang));
        obj_data.put('deslereq',r1.deslereq);
        obj_data.put('staappr',r1.staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    else
      for r1 in c_hrms63u_c2 loop
        begin
          select codpos into v_codpos
            from temploy1
           where codempid = r1.codempid;
        exception when no_data_found then
          v_codpos := null;
        end;
        --
        v_nextappr := null;
        if r1.staappr = 'A' then
          v_nextappr := chk_workflow.get_next_approve('HRES62E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.seqno,r1.approvno,global_v_lang);
        end if;
        --
        v_row := v_row+1;
        v_timstrt := '';
        v_timend  := '';

        if r1.timstrt is not null then
          v_timstrt := substr(r1.timstrt, 1, 2)||':'||substr(r1.timstrt, 3, 2);
        end if;
        if r1.timend is not null then
          v_timend := substr(r1.timend, 1, 2)||':'||substr(r1.timend, 3, 2);
        end if;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno',v_appno);
        obj_data.put('chk_appr',v_chk);
        obj_data.put('codempid',r1.codempid);
        obj_data.put('image',get_emp_img(r1.codempid));
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('desc_codcomp',get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('dtereq',to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq',to_char(r1.seqno));
        obj_data.put('desc_codleave',get_tleavecd_name(r1.codleave, global_v_lang));
        obj_data.put('dteperiod',to_char(r1.dtestrt ,'DD/MM/YYYY')|| ' '|| substr(r1.timstrt,1,2)||':'|| substr(r1.timstrt,3,2)||'  - '||to_char(r1.dteend ,'DD/MM/YYYY')|| ' '|| substr(r1.timend ,1,2)||':'|| substr(r1.timend ,3,2));
        obj_data.put('dtestrt',to_char(r1.dtestrt ,'DD/MM/YYYY'));
        obj_data.put('dteend',to_char(r1.dteend ,'DD/MM/YYYY'));
        obj_data.put('timstrt',v_timstrt);
        obj_data.put('timend',v_timend);
        obj_data.put('status',r1.status);
        obj_data.put('desc_codappr',get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark',r1.remarkap);
        obj_data.put('desc_codempap',v_nextappr);--boyaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
        obj_data.put('deslereq',r1.deslereq);
        obj_data.put('staappr',r1.staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  -- leave_detail
  procedure hrms63u_detail_tab1(json_str_input in clob, json_str_output out clob) as
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_row        number := 0;

    v_dtestrt    tleaverq.dtestrt%type;
    v_dteend     tleaverq.dteend%type;
    v_dtereq     tleaverq.dtereq%type;
    v_deslereq   tleaverq.deslereq%type;
    v_deslereq1  tleaverq.deslereq%type;
    v_deslereq2  tleaverq.deslereq%type;
    v_codleave   tleaverq.codleave%type;
    v_codcomp    tleaverq.codcomp%type;
    v_timstrt    varchar2(10 char);
    v_timend     varchar2(10 char);
    v_filename   tleaverq.filenam1%type;
--    v_pathweb    tleaverq.varchar2(5000 char);
    v_folder     tfolderd.folder%type;
    v_codinput   tleaverq.codinput%type;
    v_chkdata    boolean := false;
    v_dteprgntst date;
    v_timprgnt   tleaverq.timprgnt%type;
    v_yrecycle    NUMBER(4);
    v_dtecycst    DATE;
    v_dtecycen    DATE;
  begin
    initial_value(json_str_input);
    begin
        select codcomp,codleave,dtestrt,dteend,deslereq,timstrt,timend,filenam1,codinput,dtereq,dteprgntst,timprgnt
        into  v_codcomp,v_codleave,v_dtestrt,v_dteend,v_deslereq,v_timstrt,v_timend,v_filename,v_codinput,v_dtereq,v_dteprgntst,v_timprgnt
        from  tleaverq
        where codempid = p_codempid
        and   dtereq   = to_date(p_dtereq,'DDMMYYYY')
        and   seqno    = p_seqno;
        v_chkdata := true;
    exception when no_data_found then
     v_chkdata := false;
    end;
    --
    begin
      select folder into v_folder
        from tfolderd
       where codapp = 'HRES62E';
    exception when no_data_found then
      null;
    end;
    --.
    obj_data := json_object_t();

    if v_timstrt is not null then
      v_timstrt := substr(v_timstrt, 1, 2)||':'||substr(v_timstrt, 3, 2);
    end if;
    if v_timend is not null then
      v_timend := substr(v_timend, 1, 2)||':'||substr(v_timend, 3, 2);
    end if;

    std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,v_codleave,v_dteend --15/02/2021 ||,v_dtestrt
                      ,v_yrecycle,v_dtecycst,v_dtecycen);

    obj_data.put('coderror', '200');
    obj_data.put('codinput', v_codinput);
    obj_data.put('codempid', p_codempid);
    obj_data.put('desc_codinput', get_temploy_name(v_codinput, global_v_lang));
    obj_data.put('desc_codempid', get_temploy_name(p_codempid, global_v_lang));
    obj_data.put('dtereq', to_char(v_dtereq,'dd/mm/yyyy'));
    obj_data.put('desc_codleave', get_tleavecd_name(v_codleave, global_v_lang));
    obj_data.put('deslereq', v_deslereq);
    obj_data.put('dtestrt', to_char(v_dtestrt,'dd/mm/yyyy'));
    obj_data.put('timstrt', v_timstrt);
    obj_data.put('dteend', to_char(v_dteend,'dd/mm/yyyy'));
    obj_data.put('timend', v_timend);
    obj_data.put('path_filename', get_tsetup_value('PATHDOC')||v_folder||'/'||v_filename);
    obj_data.put('filename', v_filename);
    -- paternity leave --
    obj_data.put('dteprgntst', to_char(v_dteprgntst,'dd/mm/yyyy'));
    obj_data.put('timprgnt', v_timprgnt);
    obj_data.put('dtecycst', to_char(v_dtecycst,'dd/mm/yyyy'));
    obj_data.put('dtecycen', to_char(v_dtecycen,'dd/mm/yyyy'));
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms63u_detail_tab1;
  --

    function Cal_MinLeaveReq(p_codempid varchar2,
                           p_dtereq   date,
                           p_seqno    number,
                           p_codleave varchar2,
                           p_dtestrt  date,
                           p_flgleave tleaverq.flgleave%type) return number is
    v_flgchol     varchar2(1);
    v_codcomp     tcenter.codcomp%type;
    v_yrecycle    number;
    v_dtecycst    date;
    v_dtecycen    date;
    v_date        date;
    v_dtework     date;
    v_strtw       date;
    v_endle       date;
    v_dtelest     date;
    v_timlest     varchar2(4);
    v_dteleen     date;
    v_timleen     varchar2(4);
    v_qtymin      number := 0;
    v_qtyday      number := 0;
    v_sumday      number := 0;
    s_sumday      number := 0;

    cursor c_tleaverq is
      select a.dtestrt,a.dteend,a.timstrt,a.timend,a.dtereq
        from tleaverq a
       where a.codempid = p_codempid
         and a.codleave = p_codleave
         and a.staappr  in ('P','A')
         and a.dtestrt  between v_dtecycst and v_dtecycen
         and not exists (select b.codempid
                           from tleaverq b
                          where a.codempid = b.codempid
                            and a.dtereq   = p_dtereq
                            and a.seqno    = nvl(p_seqno,9999))
       order by dtestrt;

    cursor c_tattence is
      select codempid,dtework,typwork,codshift,codcalen,flgatten,dtestrtw,timstrtw,dteendw,timendw
        from tattence
       where codempid = p_codempid
         and dtework  = v_dtework
      order by codempid,dtework;


  begin
      begin
        select codcomp into v_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
      end;
      std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,p_codleave,p_dtestrt,v_yrecycle,v_dtecycst,v_dtecycen);
      begin
        select flgchol into v_flgchol
          from tleavety
         where typleave = (select typleave
                             from tleavecd
                            where codleave = p_codleave);
      exception when no_data_found then v_flgchol :=  null;
      end;
      --------------------------------------------------
      for r1 in c_tleaverq loop
          v_date   := r1.dtestrt;


          v_sumday := 0;
          <<cal_loop>> loop
              -- yesterday

              if v_date = r1.dtestrt and r1.timstrt is not null then
                  v_dtework := v_date - 1;

                  for r_tattence in c_tattence loop
                      v_dtelest := r1.dtestrt;
                      v_timlest := r1.timstrt;
                      v_dteleen := r_tattence.dteendw;

                      if r_tattence.dteendw = r1.dteend then
                          v_timleen := nvl(r1.timend,r_tattence.timendw);
                      else
                          v_timleen := r_tattence.timendw;
                      end if;
                      hral56b_batch.cal_time_leave(v_flgchol,v_codcomp,r_tattence.codcalen,r_tattence.typwork,r_tattence.codshift,
                                            r_tattence.dtestrtw,r_tattence.timstrtw,r_tattence.dteendw,r_tattence.timendw ,
                                            v_dtelest,v_timlest,v_dteleen,v_timleen,
                                            v_qtymin,v_qtyday,param_qtyavgwk,p_flgleave);

                      if v_qtymin > 0 then
                          v_sumday := v_sumday + v_qtyday;
                          s_sumday := s_sumday + v_qtyday;
                      end if;
                  end loop;


              end if;
              -- today------------------------------------------
              v_dtework := v_date;
              for r_tattence in c_tattence loop

                  if v_date = r1.dtestrt and r1.timstrt is not null then
                      v_dtelest := r1.dtestrt;
                      v_timlest := r1.timstrt;
                  else
                      v_dtelest := r_tattence.dtestrtw;
                      v_timlest := r_tattence.timstrtw;
                  end if;

                  if r1.timend is not null then
                      v_strtw  := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tattence.timstrtw,'dd/mm/yyyyhh24mi');
                      v_endle  := to_date(to_char(r1.dteend,'dd/mm/yyyy')||r1.timend,'dd/mm/yyyyhh24mi');
                      if v_strtw >= v_endle Then
                          exit cal_loop;
                      end if;
                  end if;

                  if r_tattence.dteendw >= r1.dteend and r1.timend is not null then
                      v_dteleen := r1.dteend;
                      v_timleen := r1.timend;
                  else
                      v_dteleen := r_tattence.dteendw;
                      v_timleen := r_tattence.timendw;
                  end if;
                  hral56b_batch.cal_time_leave(v_flgchol,v_codcomp,r_tattence.codcalen,r_tattence.typwork,r_tattence.codshift,
                                        r_tattence.dtestrtw,r_tattence.timstrtw,r_tattence.dteendw,r_tattence.timendw ,
                                        v_dtelest,v_timlest,v_dteleen,v_timleen,
                                        v_qtymin,v_qtyday,param_qtyavgwk,p_flgleave);

                  if v_qtymin > 0 then
                      v_sumday := v_sumday + v_qtyday;
                      s_sumday := s_sumday + v_qtyday;
                  end if;
              end loop;


              --------------------------------------------------
              v_date   := v_date + 1;
              if v_date > r1.dteend then
                  exit cal_loop;
              end if;
          end loop; --<<cal_loop>>
      end loop; --for r1 in c_tleaverq loop;
      return(s_sumday);
  end cal_minleavereq;

  -- entitlement

  procedure hrms63u_detail_tab2(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    v_tleaverq      tleaverq%rowtype;
    v_codempid      temploy1.codempid%type;
    v_qtyavgwk      number := 0;
    v_qtyday1       number := 0;
    v_qtyday2       number := 0;
    v_qtyday3       number := 0;
    v_qtyday4       number := 0;
    v_qtyday5       number := 0;
    v_qtyday6       number := 0;
    v_qtydays       number := 0;
    v_typleave      varchar2(10 char);
    v_staleave      varchar2(10 char);
    v_flgdlemx      varchar2(10 char);
    v_flgwkcal      tleavety.flgwkcal%type;
    v_flgchol       tleavety.flgchol%type;
    v_qtypriyr      number ;
    v_dteeffec      date ;
    v_yrecycle      number;
    v_dtecycst      date;
    v_dtecycen      date;
    v_qtytime       number;
    v_date          date;
    v_sumday        number;

    v_day1          number;
    v_hur1          number;
    v_min1          number;
    v_day2          number;
    v_hur2          number;
    v_min2          number;
    v_day3          number;
    v_hur3          number;
    v_min3          number;
    v_day4          number;
    v_hur4          number;
    v_min4          number;
    v_day5          number;
    v_hur5          number;
    v_min5          number;
    v_day6          number;
    v_hur6          number;
    v_min6          number;

    v_codcomp       temploy1.codcomp%type;
    v_qtyvacat      tleavsum.qtyvacat%type;
    v_qtydleot      tleavsum.qtydleot%type;
    v_qtydlemx      tleavsum.qtydlemx%type;
    v_dtework       tattence.dtework%type;
    v_dtelest       tlereqd.dtework%type;
    v_timlest       tlereqd.timstrt%type;
    v_dteleen       tlereqd.dtework%type;
    v_timleen       tlereqd.timend%type;
    v_qtymin        tlereqd.qtymin%type;
    v_qtyday        tlereqd.qtyday%type;
    v_strtw         date;
    v_endle         date;
    s_sumday        number;

    cursor c_tattence is
        select codempid,dtework,typwork,codshift,codcalen,
               flgatten,dtestrtw,timstrtw,dteendw,timendw
        from   tattence
        where  codempid = p_codempid
        and    dtework  = v_dtework
        order by codempid,dtework;
  begin
    initial_value(json_str_input);
    begin
        select * into v_tleaverq
          from tleaverq
         where codempid = p_codempid
           and dtereq   = to_date(p_dtereq,'ddmmyyyy')
           and seqno    = p_seqno;
    exception when no_data_found then
       null;
    end;

    begin
        select codempid into v_codempid
        from   tattence
        where  codempid = p_codempid
        and    dtework  between v_tleaverq.dtestrt and v_tleaverq.dteend
        and rownum <= 1;
    exception when no_data_found then
       null ;
    end;
    <<main_loop>>
    loop
        if p_codempid is null or v_tleaverq.codleave is null or
             v_tleaverq.dtestrt is null  or v_tleaverq.dteend is null then
            exit main_loop;
        end if;

        begin
            select codempid,codcomp
              into v_codempid,v_codcomp
              from temploy1
             where codempid = p_codempid;
        exception when no_data_found then
            exit main_loop;
        end;

        begin
            select qtyavgwk into v_qtyavgwk
              from tcontral
             where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
               and dteeffec = (select max(dteeffec)
                                 from tcontral
                                where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                  and dteeffec <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'))
               and    rownum <= 1
            order by codcompy,dteeffec;
        exception when no_data_found then
             exit main_loop;
        end;

        begin
            select typleave,staleave into v_typleave,v_staleave
              from tleavecd
             where codleave = v_tleaverq.codleave;
        exception when no_data_found then
          exit main_loop;
        end;

        begin
            select flgdlemx,nvl(qtydlepay,0),flgwkcal,flgchol
              into v_flgdlemx,v_qtyday1,v_flgwkcal,v_flgchol
              from tleavety
             where typleave = v_typleave;
        exception when no_data_found then
            exit main_loop;
        end;

        std_al.entitlement( p_codempid  => p_codempid,
                            p_codleave  => v_tleaverq.codleave,
                            p_dtestrle  => v_tleaverq.dteend, --15/02/2021 || => v_tleaverq.dtestrt,
                            p_zyear     => global_v_zyear ,
                            p_qtyleave  => v_qtyday1,
                            p_qtypriyr  => v_qtypriyr,
                            p_dteeffec  => v_dteeffec);

        std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,v_tleaverq.codleave,v_tleaverq.dteend --15/02/2021 ||,v_tleaverq.dtestrt
                          ,v_yrecycle,v_dtecycst,v_dtecycen);
        v_qtyday1 := nvl(v_qtyday1,0) ;

        if v_flgdlemx = 'Y' and v_staleave = 'O' then
            if v_tleaverq.numlereq is not null then
                begin
                    select nvl(sum(qtyday),0) into v_qtyday2
                      from tleavetr
                     where numlereq = v_tleaverq.numlereq;
                    v_qtytime := 1;
                exception when no_data_found then
                    v_qtyday2 := 0;
                end;
            end if;
        else
            begin
                select nvl(sum(qtydayle),0),nvl(sum(qtytleav),0)
                  into v_qtyday2,v_qtytime
                  from tleavsum
                 where codempid = p_codempid
                   and dteyear  = v_yrecycle - global_v_zyear
                   and typleave = v_typleave;
            exception when no_data_found then
                v_qtyday2 := 0;
            end;
        end if;

        v_qtyday3 := v_qtyday1 - v_qtyday2;
        v_date    := v_tleaverq.dtestrt;
        v_sumday  := 0;

        if v_tleaverq.dtestrt <= v_tleaverq.dteend then
            <<cal_loop>>
            loop
                -- YESTERDAY (TATTENCE)
                if v_date = v_tleaverq.dtestrt and v_tleaverq.timstrt is not null then
                    v_dtework := v_date - 1;
                    for r_tattence in c_tattence loop
                        v_dtelest := v_tleaverq.dtestrt;
                        v_timlest := v_tleaverq.timstrt;
                        v_dteleen := r_tattence.dteendw;
                        if r_tattence.dteendw = v_tleaverq.dteend then
                            v_timleen := nvl(v_tleaverq.timend,r_tattence.timendw);
                        else
                            v_timleen := r_tattence.timendw;
                        end if;
                        hral56b_batch.cal_time_leave(v_flgchol,v_codcomp,
                                                     r_tattence.codcalen,r_tattence.typwork,
                                                     r_tattence.codshift,r_tattence.dtestrtw,
                                                     r_tattence.timstrtw,r_tattence.dteendw,
                                                     r_tattence.timendw,v_dtelest,
                                                     v_timlest,v_dteleen,
                                                     v_timleen,v_qtymin,
                                                     v_qtyday,v_qtyavgwk,v_tleaverq.flgleave);

                        if v_qtymin > 0 then
                            if v_staleave <> 'C' and v_flgdlemx = 'N' and
                                 (not(v_dtework between v_dtecycst and v_dtecycen)) then
                                    param_msg_error   := get_error_msg_php('HR2020',global_v_lang);
                                    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
                                    return;
                            end if;
                            v_sumday := v_sumday + v_qtyday;
                        end if;
                    end loop; -- for r_tattence
                end if; -- v_date = p_dtestrt and :tlereqst.timstrt is not null

                -- TODAY (TATTENCE)
                v_dtework := v_date;
                for r_tattence in c_tattence loop
                    if v_date = v_tleaverq.dtestrt and v_tleaverq.timstrt is not null then
                        v_dtelest := v_tleaverq.dtestrt;
                        v_timlest := v_tleaverq.timstrt;
                    else
                        v_dtelest := r_tattence.dtestrtw;
                        v_timlest := r_tattence.timstrtw;
                    end if;
                if v_tleaverq.timend is not null then
                    v_strtw  := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tattence.timstrtw,'dd/mm/yyyyhh24mi');
                    v_endle  := to_date(to_char(v_tleaverq.dteend,'dd/mm/yyyy')||v_tleaverq.timend,'dd/mm/yyyyhh24mi');
                if v_strtw >= v_endle then
                    exit cal_loop;
                end if;
              end if;
                    if r_tattence.dteendw >= v_tleaverq.dteend and v_tleaverq.timend is not null then
                        v_dteleen := v_tleaverq.dteend;
                        v_timleen := v_tleaverq.timend;
                    else
                        v_dteleen := r_tattence.dteendw;
                        v_timleen := r_tattence.timendw;
                    end if;

                    hral56b_batch.cal_time_leave(v_flgchol,v_codcomp,
                                                r_tattence.codcalen, r_tattence.typwork,
                                                r_tattence.codshift, r_tattence.dtestrtw,
                                                r_tattence.timstrtw, r_tattence.dteendw,
                                                r_tattence.timendw,v_dtelest,
                                                v_timlest,v_dteleen,
                                                v_timleen,v_qtymin,
                                                v_qtyday,v_qtyavgwk,v_tleaverq.flgleave);
                    if v_qtymin > 0 then
                        if v_staleave <> 'C' and v_flgdlemx = 'N' and
                             (not(v_dtework between v_dtecycst and v_dtecycen)) then
                              param_msg_error   := get_error_msg_php('HR2020',global_v_lang);
                              json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
                              return;
                        end if;
                        v_sumday := v_sumday + v_qtyday;
                    end if;
                end loop; -- for r_tattence

                v_date := v_date + 1;
                if v_date > v_tleaverq.dteend then
                    exit cal_loop;
                end if;
            end loop;   -- main_loop
        end if;

        if v_flgdlemx = 'Y' and v_staleave = 'O' then
            if v_sumday > v_qtyday1 then
                v_qtyday5 := v_qtyday1;
                v_qtyday6 := v_sumday - v_qtyday1;
            else
                v_qtyday5 := v_sumday;
                v_qtyday6 := 0;
            end if;
        else
            if v_tleaverq.numlereq is not null then
                begin
                    select nvl(sum(qtyday),0) into v_qtydays
                    from   tleavetr
                    where  numlereq = v_tleaverq.numlereq;
                exception when no_data_found then
                    v_qtydays := 0;
                end;
            end if;
            v_qtydays := v_qtyday2 - v_qtydays;
            if (v_sumday + v_qtydays) > v_qtyday1 then
                if v_qtydays > v_qtyday1 then
                    v_qtyday5 := 0;
                    v_qtyday6 := v_sumday;
                else
                    v_qtyday6 := (v_sumday + v_qtydays) - v_qtyday1;
                    v_qtyday5 := v_sumday - v_qtyday6;
                end if;
            else
                v_qtyday5 := v_sumday;
                v_qtyday6 := 0;
            end if;
        end if;

        if v_staleave <> 'C' and v_flgdlemx = 'N' then
            begin
                select nvl(sum(qtyday),0)   into v_qtyday4
                  from tlereqd
                 where codempid = p_codempid
                   and dtework between v_dtecycst and v_dtecycen
                   and codleave = v_tleaverq.codleave
                   and ((v_tleaverq.numlereq is not null and numlereq <> v_tleaverq.numlereq)
                    or   v_tleaverq.numlereq is null)
                   and dayeupd is null;
            exception when no_data_found then
                v_qtyday4 := 0;
            end;
        else
            begin
                select nvl(sum(qtyday),0)   into v_qtyday4
                  from tlereqd
                 where codempid = p_codempid
                   and dtework is not null
                   and codleave = v_tleaverq.codleave
                   and ((v_tleaverq.numlereq is not null and numlereq <> v_tleaverq.numlereq)
                    or   v_tleaverq.numlereq is null)
                   and dayeupd is null;
            exception when no_data_found then
                v_qtyday4 := 0;
            end;
        end if;

        param_qtyavgwk := v_qtyavgwk;
        s_sumday := Cal_MinLeaveReq(p_codempid,v_tleaverq.dtereq,v_tleaverq.seqno,v_tleaverq.codleave,v_tleaverq.dteend --15/02/2021 ||,v_tleaverq.dtestrt
                                   ,v_tleaverq.flgleave);
        v_qtyday4 := v_qtyday4 + s_sumday;

        cal_dhm(v_qtyavgwk,v_qtyday1,v_day1,v_hur1,v_min1);
        cal_dhm(v_qtyavgwk,v_qtyday2,v_day2,v_hur2,v_min2);
        cal_dhm(v_qtyavgwk,v_qtyday3,v_day3,v_hur3,v_min3);
        cal_dhm(v_qtyavgwk,v_qtyday4,v_day4,v_hur4,v_min4);
--        cal_dhm(v_qtyavgwk,v_qtyday5,v_day5,v_hur5,v_min5);
--        cal_dhm(v_qtyavgwk,v_qtyday6,v_day6,v_hur6,v_min6);
        exit main_loop;
    end loop; -- main_loop
    --
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid',p_codempid);
    obj_data.put('desc_codempid',get_temploy_name(p_codempid,global_v_lang));
    obj_data.put('typleave',v_typleave);
    obj_data.put('desc_typleave',get_tleavety_name(v_typleave,global_v_lang));
    obj_data.put('flgdlemx',v_flgdlemx);
    obj_data.put('day1',nvl(v_day1,0));
    obj_data.put('hur1',nvl(v_hur1,0));
    obj_data.put('min1',nvl(v_min1,0));
    obj_data.put('day2',nvl(v_day2,0));
    obj_data.put('hur2',nvl(v_hur2,0));
    obj_data.put('min2',nvl(v_min2,0));
    obj_data.put('day3',nvl(v_day3,0));
    obj_data.put('hur3',nvl(v_hur3,0));
    obj_data.put('min3',nvl(v_min3,0));
    obj_data.put('day4',nvl(v_day4,0));
    obj_data.put('hur4',nvl(v_hur4,0));
    obj_data.put('min4',nvl(v_min4,0));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms63u_detail_tab2;

  -- leave_record
  procedure hrms63u_detail_tab3(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    v_yrecycle  number;
    v_dtecycst  date;
    v_dtecycen  date;
    v_tleaverq  tleaverq%rowtype ;
    v_staleave  varchar2(120 char);
  begin
    initial_value(json_str_input);
    begin
        select *
        into   v_tleaverq
        from   tleaverq
        where  codempid = p_codempid
        and    dtereq   = to_date(p_dtereq,'DDMMYYYY')
        and    seqno    = p_seqno;
    exception when no_data_found then
       null;
    end;
    begin
      select staleave into v_staleave
        from tleavecd
       where codleave = v_tleaverq.codleave;
    exception when no_data_found then
      null;
    end;
    std_al.cycle_leave(hcm_util.get_codcomp_level(v_tleaverq.codcomp,1),p_codempid,v_tleaverq.codleave,v_tleaverq.dteend --15/02/2021 ||,v_tleaverq.dtestrt
                      ,v_yrecycle,v_dtecycst,v_dtecycen);
    obj_data := json_object_t();
    obj_data.put('codempid',p_codempid);
    obj_data.put('desc_codempid',get_temploy_name(p_codempid,global_v_lang));
    obj_data.put('dtecycst',to_char(v_dtecycst,'DD/MM/YYYY'));
    obj_data.put('dtecycen',to_char(v_dtecycen,'DD/MM/YYYY'));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms63u_detail_tab3;

  -- leave_record table
  procedure hrms63u_detail_tab3_table(json_str_input in clob, json_str_output out clob) as
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_yrecycle  number;
    v_dtecycst  date;
    v_dtecycen  date;
    v_dtework   date;
    v_codshift  varchar2(20 char);
    v_timstrt   varchar2(40 char);
    v_timend    varchar2(40 char);
    v_codleave  varchar2(20 char);
    v_qtymin    number;
    v_numlereq  varchar2(120 char);
    v_count     number := 0;
    v_loop      number := 0;
    v_tleaverq  tleaverq%rowtype ;
    v_staleave  varchar2(120 char);
    v_rcnt      number := 0;
    v_row       number := 0;

    cursor c_leave is
      select dtework,codshift,timstrt,timend,codleave,qtymin,numlereq
        from tleavetr
       where codempid = p_codempid
         and dtework  between v_dtecycst and v_dtecycen
     order by dtework desc,numlereq desc;
  begin
    initial_value(json_str_input);
    begin
        select *
        into   v_tleaverq
        from   tleaverq
        where  codempid = p_codempid
        and    dtereq   = to_date(p_dtereq,'dd/mm/yyyy')
        and    seqno    = p_seqno;
    exception when no_data_found then
       null;
    end;
    begin
        select staleave into v_staleave
          from tleavecd
         where codleave = v_tleaverq.codleave;
    exception when no_data_found then
      null ;
    end;

    std_al.cycle_leave(hcm_util.get_codcomp_level(v_tleaverq.codcomp,1),p_codempid,v_tleaverq.codleave,v_tleaverq.dteend --15/02/2021 ||,v_tleaverq.dtestrt
                      ,v_yrecycle,v_dtecycst,v_dtecycen);
    --
    obj_row := json_object_t();
    v_row   := 0;
    for r1 in c_leave loop
      v_row := v_row+1;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtework',to_char(r1.dtework,'DD/MM/YYYY'));
      obj_data.put('codshift',r1.codshift);
      obj_data.put('timperiod',substr(r1.timstrt,1,2)||':'|| substr(r1.timstrt,3,2)|| '  -  ' || substr(r1.timend,1,2)||':'||substr(r1.timend,3,2));
      obj_data.put('timstrt',substr(r1.timstrt,1,2)||':'|| substr(r1.timstrt,3,2));
      obj_data.put('timend',substr(r1.timend,1,2)||':'||substr(r1.timend,3,2));
      obj_data.put('codleave',r1.codleave);
      obj_data.put('desc_codleave',get_tleavecd_name(r1.codleave, global_v_lang));
      obj_data.put('qtymin',to_char(trunc(r1.qtymin/60)) || ':' ||lpad(mod(r1.qtymin,60),2,'0'));
      obj_data.put('numlereq',r1.numlereq);

      obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms63u_detail_tab3_table;
  --

  PROCEDURE insert_tlereqd
    (p_dtework  tlereqd.dtework%TYPE,
--     p_flgwork  tlereqd.flgwork%TYPE,
     p_timstrt  tlereqd.timstrt%TYPE,
     p_timend   tlereqd.timend%TYPE,
     p_qtymin   tlereqd.qtymin%TYPE,
     p_qtyday   tlereqd.qtyday%TYPE,
     p_codempid temploy1.codempid%type,
     p_codleave VARCHAR2,
     p_coduser  VARCHAR2,
     p_numlereq VARCHAR2,
     p_codcomp  VARCHAR2,
     p_numlvl   number)
  is
       v_count    number;
  begin
       begin
         select   count(*)
           into   v_count
           from   tlereqd
           where  numlereq = p_numlereq
           and    dtework  = trunc(p_dtework)
--           and    flgwork  = p_flgwork
           and    codleave = p_codleave;
       exception when no_data_found then
              v_count := 0;
       end;

     if v_count  = 0 then
          insert into tlereqd (numlereq  ,dtework  ,
                               /*flgwork   ,*/codleave ,
                               codempid  ,timstrt  ,
                               timend    ,qtymin   ,
                               qtyday    ,dayeupd  ,
                               coduser   ,codcomp,numlvl)
                values (p_numlereq ,p_dtework ,
                               /*p_flgwork ,*/p_codleave,
                               p_codempid,p_timstrt ,
                               p_timend  ,p_qtymin  ,
                               p_qtyday  ,null      ,
                               p_coduser ,p_codcomp ,p_numlvl);  -- Modify
     end if;
     commit;

  end; -- Procedure insert_tlereqd
  --

  procedure cal_data (p_save     boolean,
                      p_dtestrt  date,
                      p_dteend   date ,
                      p_codempid varchar2, -- ADD
                      p_timstrt  varchar2, -- ADD
                      p_timend   varchar2, -- ADD
                      p_codleave varchar2, -- ADD
                      p_numlereq varchar2, -- ADD
                      p_coduser  varchar2,-- ADD
                      p_dtereq   varchar2,
                      p_seqno    number,
                      p_qtyday  out number,-- ADD
                      p_qtymin  out number,
                      p_flgleave in tlereqst.flgleave%type) is  -- ADD

    v_codempid    temploy1.codempid%TYPE;
    v_codcomp     temploy1.codcomp%TYPE;
    v_flgwkcal    tleavety.flgwkcal%TYPE;
    v_flgchol     tleavety.flgchol%TYPE;
    v_qtyvacat    tleavsum.qtyvacat%TYPE;
    v_qtydleot    tleavsum.qtydleot%TYPE;
    v_qtydlemx    tleavsum.qtydlemx%TYPE;
    v_tleaverq    tleaverq%rowtype;
    r_tleavetr    tleavetr%ROWTYPE;
    r_tlereqd     tlereqd%ROWTYPE;
    v_error       BOOLEAN;
    v_date        DATE;
    v_dtework     tattence.dtework%TYPE;
    v_dtelest     tlereqd.dtework%TYPE;
    v_timlest     tlereqd.timstrt%TYPE;
    v_dteleen     tlereqd.dtework%TYPE;
    v_timleen     tlereqd.timend%TYPE;
    v_qtymin      tlereqd.qtymin%TYPE;
    v_qtyday      tlereqd.qtyday%TYPE;
    v_sumday      NUMBER;
    v_typleave    tleavecd.typleave%TYPE;
    v_staleave    tleavecd.staleave%TYPE;
    v_flgdlemx    tleavety.flgdlemx%TYPE;
    v_timstrt     tlereqd.timstrt%TYPE;
    v_timend      tlereqd.timstrt%TYPE;
    v_qtypriyr    NUMBER ;
    v_dteeffec    DATE ;
    v_yrecycle    NUMBER(4);
    v_dtecycst    DATE;
    v_dtecycen    DATE;
    v_strtw       DATE;
    v_endle       DATE;

    qty_day       NUMBER ;
    qty_min       NUMBER ;
    qtytime       NUMBER ;
    qtyday1       NUMBER:= 0;
    qtyday2       NUMBER:= 0;
    qtyday3       NUMBER:= 0;
    qtyday4       NUMBER:= 0;
    qtyday5       NUMBER:= 0;
    qtyday6       number:= 0;
    v_numlvl      number;

    p_qtyavgwk    NUMBER;
    v_qtyavgwk    number;

  cursor c_tattence is

      select codempid,dtework,typwork,codshift,codcalen,
             flgatten,dtestrtw,timstrtw,dteendw,timendw
      from   tattence
      where  codempid = p_codempid
      and    dtework  = v_dtework
      order by codempid,dtework;
  begin
    qty_day   := 0 ;
    qty_min   := 0 ;
    v_timstrt := p_timstrt ;
    v_timend  := p_timend  ;
    begin
        select * into v_tleaverq
          from tleaverq
         where codempid = p_codempid
           and dtereq   = to_date(p_dtereq,'ddmmyyyy')
           and seqno    = p_seqno;
    exception when no_data_found then
       null;
    end;
    <<main_loop>>
    loop
        if p_codempid is null or p_codleave is null or
             p_dtestrt is null  or p_dteend is null then
            exit main_loop;
        end if;

        begin
            select codempid,codcomp,numlvl
            into   v_codempid,v_codcomp,v_numlvl
            from   temploy1
            where  codempid = p_codempid;
        exception when no_data_found then
            exit main_loop;
        end;

    begin
        select qtyavgwk
        into   p_qtyavgwk   -- add
        from   tcontral
        where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
        and    dteeffec = (select max(dteeffec)
                                             from   tcontral
                                             where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                             and    dteeffec <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'))
            and    rownum   = 1
            order by codcompy,dteeffec;
    exception when no_data_found then
            exit main_loop;
    end;

        begin
            select typleave,staleave
            into   v_typleave,v_staleave
            from   tleavecd
            where  codleave = p_codleave;
        exception when no_data_found then
            exit main_loop;
        end;

        begin
            select flgdlemx,nvl(qtydlepay,0),flgwkcal,flgchol
            into   v_flgdlemx,qtyday1,v_flgwkcal,v_flgchol
            from   tleavety
            where  typleave = v_typleave;
        exception when no_data_found then
            exit main_loop;
        end;
        std_al.entitlement(p_codempid  => p_codempid,
                           p_codleave  => p_codleave,
                           p_dtestrle  => p_dteend, --15/02/2021 ||p_dtestrt,
                           p_zyear     => global_v_zyear ,
                           p_qtyleave  => qtyday1,
                           p_qtypriyr  => v_qtypriyr,
                           p_dteeffec  => v_dteeffec);

        std_al.cycle_leave(hcm_util.get_codcomp_level(v_codcomp,1),p_codempid,p_codleave,p_dteend --15/02/2021 ||,p_dtestrt
                          ,v_yrecycle,v_dtecycst,v_dtecycen);
        qtyday1 := nvl(qtyday1,0) ;

        if v_flgdlemx = 'Y' and v_staleave = 'O' then
            if p_numlereq is not null then
                begin
                    select nvl(sum(qtyday),0)   into qtyday2
                    from   tleavetr
                    where  numlereq = p_numlereq;
                    qtytime := 1;
                exception when no_data_found then
                    qtyday2 := 0;
                end;
            end if;
        else
            begin
                select nvl(sum(qtydayle),0),nvl(sum(qtytleav),0)
                into   qtyday2,qtytime
                from   tleavsum
                where  codempid = p_codempid
                and    dteyear  = v_yrecycle - global_v_zyear
                and    typleave = v_typleave;
            exception when no_data_found then
                qtyday2 := 0;
            end;
        end if;
        qtyday3 := qtyday1 - qtyday2;
        v_date   := p_dtestrt;
        v_sumday := 0;
        <<cal_loop>>
        loop
              -- yesterday (tattence)
              if v_date = p_dtestrt and v_timstrt is not null then
                 v_dtework := v_date - 1;
                for r_tattence in c_tattence loop
                    v_dtelest := p_dtestrt;
                    v_timlest := v_timstrt;
                    v_dteleen := r_tattence.dteendw;
                    if r_tattence.dteendw = v_tleaverq.dteend then
                        v_timleen := nvl(v_tleaverq.timend,r_tattence.timendw);
                    else
                        v_timleen := r_tattence.timendw;
                    end if;

                       begin
                          select qtydaywk
                            into v_qtyavgwk
                            from tshiftcd
                           where codshift = r_tattence.codshift;
                        exception when no_data_found then null;
                        end;

                        hral56b_batch.cal_time_leave( v_flgchol,v_codcomp,
                                                      r_tattence.codcalen, r_tattence.typwork,
                                                      r_tattence.codshift, r_tattence.dtestrtw,
                                                      r_tattence.timstrtw, r_tattence.dteendw,
                                                      r_tattence.timendw,v_dtelest,
                                                      v_timlest, v_dteleen,
                                                      v_timleen,v_qtymin,
                                                      v_qtyday,v_qtyavgwk,p_flgleave);




                    if v_qtymin > 0 then
                        v_sumday := v_sumday + v_qtyday;
                        qty_day  :=  nvl(qty_day,0)  + nvl(v_qtyday,0) ;
                        qty_min  :=  nvl(qty_min,0)  + nvl(v_qtymin,0)  ;
                        if p_save then
                            insert_tlereqd(v_dtework/*,'W'*/,v_timlest,v_timleen,v_qtymin,v_qtyday,
                                           p_codempid,p_codleave,p_coduser,p_numlereq,v_codcomp,v_numlvl);
                        end if;
                    end if;
                end loop; -- for r_tattence
            end if; -- v_date = p_dtestrt and :tlereqst.timstrt is not null

            -- today (tattence)
            v_dtework := v_date;
            for r_tattence in c_tattence loop
                if v_date = p_dtestrt and v_timstrt is not null then
                    v_dtelest := p_dtestrt;
                    v_timlest := v_timstrt;
                else
                    v_dtelest := r_tattence.dtestrtw;
                    v_timlest := r_tattence.timstrtw;
                end if;

            if v_timend  is not null then
                v_strtw  := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tattence.timstrtw,'dd/mm/yyyyhh24mi');
                v_endle  := to_date(to_char(p_dteend,'dd/mm/yyyy')||v_timend,'dd/mm/yyyyhh24mi');
            if v_strtw >= v_endle then
                        exit cal_loop;
            end if;
            end if;
            --chai
                --if  v_date = p_dteend and v_timend is not null then
                if  r_tattence.dteendw >= p_dteend and v_timend is not null then
                    v_dteleen := p_dteend;
                    v_timleen := v_timend;
                else
                    v_dteleen := r_tattence.dteendw;
                    v_timleen := r_tattence.timendw;
                end if;

                     begin
                          select qtydaywk
                            into v_qtyavgwk
                            from tshiftcd
                           where codshift = r_tattence.codshift;
                    exception when no_data_found then null;
                    end;
                    hral56b_batch.cal_time_leave( v_flgchol,v_codcomp,
                                r_tattence.codcalen, r_tattence.typwork,
                                r_tattence.codshift, r_tattence.dtestrtw,
                                r_tattence.timstrtw, r_tattence.dteendw,
                                r_tattence.timendw,
                                v_dtelest, v_timlest, v_dteleen, v_timleen,
                                v_qtymin,v_qtyday,v_qtyavgwk,p_flgleave);

                if v_qtymin > 0 then
                    v_sumday := v_sumday + v_qtyday;
                    qty_day  :=  nvl(qty_day,0)  + nvl(v_qtyday,0) ;
                    qty_min  :=  nvl(qty_min,0)  + nvl(v_qtymin,0)  ;

                    if p_save then
                    insert_tlereqd(v_dtework/*,'W'*/,v_timlest,v_timleen,v_qtymin,v_qtyday,
                                   p_codempid,p_codleave,p_coduser,p_numlereq,v_codcomp,v_numlvl);
                    end if;
                end if;
            end loop; -- for r_tattence
            v_date := v_date + 1;
            if v_date > p_dteend then
                exit cal_loop;
            end if;
        end loop;   -- main_loop

        if (v_sumday + qtyday2) > qtyday1 then
            if qtyday1 > qtyday2 then
                 qtyday5 := qtyday1 - qtyday2;
                 qtyday6 := v_sumday - (qtyday1 - qtyday2);
            else
                qtyday5 := 0;
                qtyday6 := v_sumday;
            end if;
        else
            qtyday5 := v_sumday;
            qtyday6 := 0;
        end if;

        begin
            select nvl(sum(qtyday),0)
            into qtyday4
            from  tlereqd
            where  dtework between trunc(p_dtestrt,'yyyy')
                                         and     last_day(to_date('12/'||to_char(p_dtestrt,'yyyy'),'mm/yyyy'))
            and  codleave = p_codleave
            and  codempid = p_codempid
            and  dayeupd is null;
        exception when no_data_found then
            qtyday4 := 0;
        end;
        exit main_loop;
    end loop; -- main_loop
    p_qtyday := qty_day;
    p_qtymin := qty_min;
  end;
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
  --
  procedure approve(p_coduser         in varchar2,
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
    v_codapp    varchar2(20 char) := 'HRES62E';
    rq_codempid temploy1.codempid%type  := p_codempid;
    rq_dtereq   date              := to_date(p_dtereq,'dd/mm/yyyy');
    rq_seqno    number            := p_seqno;
    rq_chk      varchar2(10 char) := p_chk;
    v_appseq    number := p_appseq;
    r_tleaverq  tleaverq%rowtype;
    v_numlereq  taplverq.numlereq%type;
    v_approvno  number := null;
    ap_approvno number := null;
    v_count     number := 0;
    v_staappr   varchar2(1 char) := p_status;
    v_codappr   temploy1.codempid%type;
    v_approv    varchar2(20 char);
    v_desc      varchar2(600 char) := get_label_name('HCM_APPRFLW',global_v_lang,10);-- user22 : 04/07/2016 : STA4590287 || v_desc      varchar2(200 char);
    v_codempap    varchar2(20 char);
    v_codcompap   tcenter.codcomp%type;
    v_codposap    tpostn.codpos%type;
    v_qty_min   number;
    v_qty_day   number;
    v_codcompy  temploy1.codcomp%type;

    v_remark    varchar2(2000 char);
    p_codappr   temploy1.codempid%type := pdk.check_codempid(p_coduser);
    v_numlvl    number;

    v_max_approv  number;
    v_row_id      varchar2(200 char);
    v_numrec2     number;
    v_typleave    tleavecd.typleave%type;
    v_loop        number;

    cursor c_tleaverqattch is
      select numseq, filename, filedesc, flgattach, codleave
        from tleaverqattch
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and seqno    = rq_seqno;

  begin
    if v_staappr = 'A' then
      v_remark := p_remark_appr;
    elsif v_staappr = 'N' then
      v_remark := p_remark_not_appr;
    end if;
    v_remark  := replace(v_remark,'.',chr(13));
    v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');

    v_numlereq  := null;

    begin
        select *
        into r_tleaverq
        from tleaverq
        where codempid = rq_codempid
        and dtereq = rq_dtereq
        and seqno  = rq_seqno ;
    exception when others then
        r_tleaverq := null ;
    end;
    ---<<< weerayut 09/01/2018 Lock request during payroll
    if get_payroll_active('HRMS63U',r_tleaverq.codempid,r_tleaverq.dtestrt,r_tleaverq.dteend) = 'Y' then
      param_msg_error := get_error_msg_php('ES0057',p_lang);
      return;
    end if;
    --->>> weerayut 09/01/2018

    --<<user36 KOHU-SM2301 04/12/2023 
    /*cancel ST11
    begin
      select approvno into v_max_approv
      from   twkflowh
      where  routeno = r_tleaverq.routeno ;
    exception when no_data_found then
      v_max_approv := 0 ;
    end ;*/
    begin
      select max(approvno) into v_max_approv
      from   tempaprq
      where  codapp    = 'HRES62E'
      and    codempid  = r_tleaverq.codempid
      and    dtereq    = r_tleaverq.dtereq
      and    numseq    = r_tleaverq.seqno;
    end;
    -->>user36 KOHU-SM2301 04/12/2023

    IF nvl(r_tleaverq.approvno,0) < v_appseq THEN
      ap_approvno :=   v_appseq ;

      begin
          select  count(*)
          into  v_count
          from  taplverq
          where  codempid = rq_codempid
          and    dtereq   = rq_dtereq
          and    seqno    = rq_seqno
          and    approvno = ap_approvno;
      exception when no_data_found then
          v_count := 0;
      end;

      if v_count = 0 then
          insert into taplverq
                  (codempid,dtereq,seqno,approvno,
                  codappr,dteappr,numlereq,staappr,
                  remark,dteupd,coduser,
                  dterec, dteapph)
          values (rq_codempid,rq_dtereq,rq_seqno, ap_approvno,
                  p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),v_numlereq,v_staappr,
                  v_remark,trunc(sysdate),p_coduser,
                  nvl(r_tleaverq.dtesnd,sysdate),sysdate
                  );
       else
          update taplverq
             set codappr  = p_codappr,
                 dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                 numlereq = v_numlereq,
                 staappr  = v_staappr,
                 remark   = v_remark,
                 dteupd   = trunc(sysdate),
                 coduser  = p_coduser,
                 dterec   = nvl(r_tleaverq.dtesnd,sysdate),
                 dteapph  = sysdate
           where codempid = rq_codempid
             and dtereq   = rq_dtereq
             and seqno    = rq_seqno
             and approvno = ap_approvno;
       end if;
       -- Check Next Step

       v_codappr  :=  p_codappr ;
       v_approvno  :=  ap_approvno;

      /*user36 KOHU-SM2301 04/12/2023 cancel
      chk_workflow.find_next_approve(v_codapp,r_tleaverq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);

      if  p_status = 'A' and rq_chk <> 'E'   then
          loop
            v_approv := chk_workflow.check_next_step(v_codapp,r_tleaverq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
             if  v_approv is not null then
                 v_remark   := v_desc; -- user22 : 04/07/2016 : STA4590287 ||
                 v_approvno := v_approvno + 1 ;
                 v_codappr := v_approv ;

                 begin
                      select count(*)
                      into v_count
                      from   taplverq
                      where  codempid   =  rq_codempid
                      and    dtereq   = rq_dtereq
                      and    seqno    = rq_seqno
                      and    approvno =  v_approvno;
                 exception when no_data_found then  v_count := 0;
                 end;

                 if v_count = 0  then
                           INSERT INTO taplverq(codempid,dtereq,seqno,approvno,
                                       codappr,dteappr,numlereq,staappr,remark,
                                       dteupd,coduser,
                                       dterec, dteapph)
                                VALUES(rq_codempid,rq_dtereq,rq_seqno,v_approvno,
                                       v_codappr,to_date(p_dteappr,'dd/mm/yyyy'),v_numlereq,'A',v_remark,
                                       trunc(sysdate),p_coduser,
                                       sysdate,sysdate);
                 else
                      UPDATE taplverq
                         SET codappr   = v_codappr,
                             dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                             numlereq  = v_numlereq,
                             staappr   = 'A',
                             remark    =  v_remark,
                             dteupd    = trunc(sysdate),
                             coduser   = p_coduser,
                             dterec    = sysdate,
                             dteapph   = sysdate
                      WHERE  codempid  = rq_codempid
                        AND  dtereq    = rq_dtereq
                        AND  seqno     = rq_seqno
                        AND  approvno  = v_approvno;
              end if;
              chk_workflow.find_next_approve(v_codapp,r_tleaverq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
            else
              exit ;
            end if;
          end loop ;

          update tleaverq
             set staappr   = v_staappr,
                 codappr   = v_codappr,
                 approvno  = v_approvno,
                 dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                 numlereq  = v_numlereq,
                 remarkap  = v_remark ,
                 dteupd    = trunc(sysdate),
                 coduser   = p_coduser,
                 dteapph   = sysdate
           where codempid  = rq_codempid
             and dtereq    = rq_dtereq
             and seqno     = rq_seqno;
     end if;
      */

   -- Step 4 => Update Table Request and Insert Transaction
     v_staappr := p_status ;
     if v_max_approv = v_approvno then
        rq_chk := 'E' ;
     end if;
     if rq_chk = 'E' and p_status = 'A' then
        v_staappr := 'Y';
        begin
          select get_codcompy(codcomp),numlvl into v_codcompy,v_numlvl
            from temploy1
           where codempid = rq_codempid;
        exception when no_data_found then v_codcompy := '';
        end;
        --
        v_loop := 0;
        loop
          v_loop := v_loop + 1;
          v_numlereq := std_al.gen_req('LEAV','tlereqst','numlereq',global_v_zyear,v_codcompy,'');
          std_al.upd_req('LEAV',v_numlereq,p_coduser,global_v_zyear,v_codcompy,'');
          begin
            select count(*)
              into v_count
              from tlereqst
             where numlereq = v_numlereq;
          end;
          --
          exit when (v_count = 0 or v_loop = 100);
        end loop;

        cal_data(TRUE,r_tleaverq.dtestrt,r_tleaverq.dteend,rq_codempid,
                r_tleaverq.timstrt,r_tleaverq.timend,r_tleaverq.codleave,
                v_numlereq,p_coduser,to_char(r_tleaverq.dtereq,'ddmmyyyy'),r_tleaverq.seqno,v_qty_day,v_qty_min,r_tleaverq.flgleave);

        begin
          insert into tlereqst(numlereq,dterecod,dtereq,codempid,codleave,dtestrt,timstrt,dteend,timend,
                               deslereq,stalereq,qtymin,qtyday,flgleave,dteleave,codshift,filename,
                               codcomp,numlvl,dteappr,codappr,dteprgntst,codcreate,coduser)
                        values(v_numlereq,r_tleaverq.dtereq,r_tleaverq.dtereq,r_tleaverq.codempid,r_tleaverq.codleave,r_tleaverq.dtestrt,r_tleaverq.timstrt,r_tleaverq.dteend,r_tleaverq.timend,
                               r_tleaverq.deslereq,'A',v_qty_min,v_qty_day,r_tleaverq.flgleave,r_tleaverq.dteleave,r_tleaverq.codshift,r_tleaverq.filenam1,
                               r_tleaverq.codcomp,v_numlvl,to_date(p_dteappr,'dd/mm/yyyy'),v_codappr,r_tleaverq.dteprgntst,p_coduser,p_coduser);
        exception when dup_val_on_index then
          null;
        end;
        -- paternity leave (update "dteprgntst" to temploy1) --
        begin
          update temploy1
             set dteprgntst = r_tleaverq.dteprgntst
           where codempid   = rq_codempid;
        exception when others then null;
        end;
--<< user22 : 15/02/2022 : ST11 ||
        hral56b_batch.gen_leave(rq_codempid,null,(r_tleaverq.dtestrt-1),r_tleaverq.dteend,p_coduser,v_numrec2);
-->> user22 : 15/02/2022 : ST11 ||
        -- copy attach file from ess to al
        begin
          delete from tlereqattch where numlereq = v_numlereq;
        exception when others then null;
        end;
        for r_tleaverqattch in c_tleaverqattch loop
          begin
            insert into tlereqattch (numlereq,numseq,filename,
                                     filedesc,flgattach,codleave,
                                     dtecreate,codcreate,coduser)
            values (v_numlereq,r_tleaverqattch.numseq,r_tleaverqattch.filename,
                    r_tleaverqattch.filedesc,r_tleaverqattch.flgattach,r_tleaverqattch.codleave,
                    sysdate,global_v_coduser,global_v_coduser);
          exception when dup_val_on_index then
            null;
          end;
        end loop;
      end if; --rq_chk = 'E' and p_status = 'A'

      update tleaverq
       set    staappr   = v_staappr,
              codappr   = v_codappr,
              approvno  = v_approvno,
              numlereq  = v_numlereq,
              dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
              coduser   = p_coduser,
              remarkap  = v_remark,
              dteapph   = sysdate
      where   codempid = rq_codempid
      and     dtereq    = rq_dtereq
      and     seqno     = rq_seqno;

      commit;
      -- Send mail
      begin
          select rowid
          into   v_row_id
          from   tleaverq
          where  codempid = rq_codempid
          and    dtereq = rq_dtereq
          and    seqno  = rq_seqno ;
      exception when others then
          r_tleaverq := null ;
      end;

      begin
        select typleave into v_typleave
          from tleavecd
         where codleave = r_tleaverq.codleave;
      exception when no_data_found then
        v_typleave := null;
      end;
      begin
          chk_workflow.sendmail_to_approve( p_codapp        => v_codapp,
                                            p_codtable_req  => 'tleaverq',
                                            p_rowid_req     => v_row_id,
                                            p_codtable_appr => 'taplverq',
                                            p_codempid      => rq_codempid,
                                            p_dtereq        => rq_dtereq,
                                            p_seqno         => rq_seqno,
                                            p_staappr       => v_staappr,
                                            p_approvno      => v_approvno,
                                            p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                            p_subject_mail_numseq  => '30',
                                            p_lang          => global_v_lang,
                                            p_coduser       => global_v_coduser,
                                            p_others        => v_typleave);
      exception when others then
        param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
      end;
     end if; -- Check Approve

  exception when others then
     rollback;
     param_msg_error := sqlerrm;
  END;  -- Procedure Approve
  --

  procedure process_approve(json_str_input in clob, json_str_output out clob) is
    json_obj              json_object_t;
    json_obj2             json_object_t;
    v_rowcount            number:= 0;
    v_staappr             varchar2(100);
    v_appseq              number;
    v_chk                 varchar2(10);
    v_seqno               number;
    v_codempid            temploy1.codempid%type;
    v_dtereq              varchar2(100);
  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input).get_object('param_json');
    v_rowcount := json_obj.get_size;
    for i in 0..json_obj.get_size-1 loop
      json_obj2   := json_object_t(json_obj.get(to_char(i)));
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
  --

  procedure datatest(json_str in clob) as
    json_obj    json_object_t  := json_object_t(json_str);

    v_flgcreate varchar2(4000 char);
    v_coduser   varchar2(4000 char);
    v_codcomp   varchar2(4000 char);
    v_codempid  varchar2(4000 char);
    v_numseq    number;
    v_dtereq    date;
    v_routeno   varchar2(4000 char);
    v_numlereq  varchar2(4000 char);
  begin
    v_flgcreate := hcm_util.get_string_t(json_obj,'p_flgcreate');
    v_coduser   := hcm_util.get_string_t(json_obj,'p_coduser');
    v_codcomp   := hcm_util.get_string_t(json_obj,'p_codcomp');
    v_codempid  := hcm_util.get_string_t(json_obj,'p_codempid');
    v_numseq    := to_number(hcm_util.get_string_t(json_obj,'p_dataseed'));
    v_dtereq    := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy hh24.mi.ss');
    v_routeno   := hcm_util.get_string_t(json_obj,'p_routeno');

    if v_flgcreate = 'Y' or v_flgcreate = 'N' then
      delete tleaverq
       where codempid = v_codempid
         and dtereq   = v_dtereq
         and seqno    = v_numseq;

      begin
        select numlereq
          into v_numlereq
          from tleaverq
         where codempid = v_codempid
           and dtereq   = v_dtereq
           and seqno    = v_numseq;

        delete tlereqst
         where numlereq = v_numlereq;
      exception when no_data_found then
        null;
      end;

      delete taplverq
       where codempid = v_codempid
         and dtereq   = v_dtereq
         and seqno    = v_numseq;
    end if;

    if v_flgcreate = 'Y' then
      insert into tleaverq
        (codempid,dtereq,seqno,codleave,
        dtestrt,timstrt,dteend,timend,
        deslereq,numlereq,staappr,dteappr,
        codappr,codcomp,remarkap,approvno,
        routeno,
        flgsend,dteupd,coduser,filenam1,
        codinput,dtecancel,dteinput,dtesnd,
        dteapph,flgagency,flgleave,codshift,
        dteleave)
      values
        (v_codempid,v_dtereq,v_numseq,'P1',
        v_dtereq,null,v_dtereq+2,null,
        'deslereq',null,'P',null,
        null,'TJS000000000000000000',null,0,
        v_routeno,
        'N',v_dtereq,v_coduser,null,
        v_codempid,null,v_dtereq,null,
        null,null,'A','D1',
        v_dtereq);

    end if;

    commit;
  end datatest;

  procedure cal_dhm(p_qtyavgwk     in  number,
                    p_qtyday       in  number,
                    p_day          out number,
                    p_hour         out number,
                    p_min          out number) is
    v_min   number(2) := 0;
    v_hour  number(2) := 0;
    v_day   number := 0;
    v_num   number := 0;
  begin
      if nvl(p_qtyday,0) > 0 then
          v_day   := trunc(p_qtyday / 1);
          v_num   := round(mod((p_qtyday * p_qtyavgwk),p_qtyavgwk),0);
          v_hour  := trunc(v_num / 60);
          v_min   := mod(v_num,60);
      end if;
      p_day := v_day; p_hour := v_hour; p_min := v_min;
  end cal_dhm;

  procedure get_leaveatt(json_str_input in clob,json_str_output out clob) as
    obj_data      json_object_t;
    obj_row       json_object_t;
    obj_data2     json_object_t;
    v_rcnt        number := 0;
    v_folder      varchar2(650 char);
    cursor c1 is
      select b.filename,c.filename attachname ,c.numseq
        from tleaverq a, tleaverqattch b, tleavecdatt c
       where a.codempid     = b.codempid
         and a.dtereq       = b.dtereq
         and a.seqno        = b.seqno
         and a.codleave     = c.codleave
         and b.numseq       = c.numseq
         and a.codempid     = p_codempid
         and a.dtereq       = to_date(p_dtereq,'DDMMYYYY')
         and a.seqno        = p_seqno
       order by c.numseq;
  begin
    initial_value(json_str_input);
    obj_row     := json_object_t();
    begin
      select folder into v_folder
        from tfolderd
       where codapp = 'HRES62E';
    exception when no_data_found then
      null;
    end;
    for r1 in c1 loop
      obj_data      := json_object_t();

      obj_data.put('numseq',r1.numseq);
      obj_data.put('filename',r1.filename);
      obj_data.put('attachname',r1.attachname);
      obj_data.put('path_filename', get_tsetup_value('PATHDOC')||v_folder||'/'||r1.filename);

      obj_row.put(to_char(v_rcnt),obj_data);
      v_rcnt        := v_rcnt+1;
    end loop;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

end;

/
