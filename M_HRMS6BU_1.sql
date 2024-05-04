--------------------------------------------------------
--  DDL for Package Body M_HRMS6BU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRMS6BU" is
/* Cust-Modify: KOHU-SM2301 */
-- last update: 04/12/2023 11:11

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    -- parameter block
--    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid');
    p_stdate            := hcm_util.get_string_t(json_obj,'p_stdate');
    p_endate            := hcm_util.get_string_t(json_obj,'p_endate');
    --
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtest             := hcm_util.get_string_t(json_obj,'p_dtest');
    p_dteen             := hcm_util.get_string_t(json_obj,'p_dteen');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    --
    p_dtereq            := hcm_util.get_string_t(json_obj,'p_dtereq');
    p_numseq            := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_dtework           := hcm_util.get_string_t(json_obj,'p_dtework');
    p_stdate            := hcm_util.get_string_t(json_obj,'p_stdate');
    p_endate            := hcm_util.get_string_t(json_obj,'p_endate');
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
  end initial_value;

  procedure hrms6bu(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    --
    v_codappr     temploy1.codempid%type;
    v_codpos      tpostn.codpos%type;
    v_nextappr    varchar2(1000 char);
    v_dtest       date;
    v_dteen       date;
    v_rcnt        number := 0;
    v_row         number := 0;
    v_timin_o     varchar2(5 char);
    v_timout_o    varchar2(5 char);
    v_timin_n     varchar2(5 char);
    v_timout_n    varchar2(5 char);
    v_appno       varchar2(100 char);
    v_chk         varchar2(100 char) := ' ';
    -- check null data --
    v_flg_exist     boolean := false;

  CURSOR c_hrms6bu_c1 IS
    select codempid,get_temploy_name(codempid,global_v_lang) ename,
           dtereq,numseq,dtework,codshift,dteappr,
           codappr,a.approvno appno,codcomp,
           timin,timin2,timout,timout2,
           codreqst,staappr,remarkap,
           0 qtyapp, --user36 KOHU-SM2301 04/12/2023 ||b.approvno qtyapp,
           remark,
           dteino1,timino1,dteouto1,timouto1
     FROM  ttimereq a 
           --user36 KOHU-SM2301 04/12/2023 ||,twkflowh b
     where /*user36 KOHU-SM2301 04/12/2023 cancel 
           codcomp like p_codcomp||'%'
     and   (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
     and   */
            staappr in ('P','A')
     and   ('Y' = chk_workflow.check_privilege('HRES6AE',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
            /*user36 KOHU-SM2301 04/12/2023 cancel
            -- Replace Approve
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                      from   twkflowde c
                                                      where  c.routeno  = a.routeno
                                                      and    c.codempid = v_codappr)
                 and    trunc(((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES6AE'))*/
            )
      --user36 KOHU-SM2301 04/12/2023 cancel ||and a.routeno = b.routeno
      order by  dtereq,codempid,numseq;


  CURSOR c_hrms6bu_c2 IS
     select codempid,get_temploy_name(codempid,global_v_lang) ename,
             dtereq,numseq,dtework,codshift,dteappr,
             codappr,approvno,codcomp,
             timin,timin2,timout,timout2,
             codreqst,staappr,remarkap,
             remark,
            dteino1,timino1,dteouto1,timouto1
      FROM  ttimereq
      where codcomp like p_codcomp||'%'
      and   staappr = p_staappr --User37 #3730 Final Test Phase 1 V11 12/02/2021  
      and   (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
      and (codempid ,dtereq,dtework) in
                      (select codempid ,dtereq,dtework
                       from  taptimrq
                       where staappr = decode(p_staappr,'Y','A',p_staappr)
                       and   codappr = v_codappr
                       and   dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
       order by  dtereq,codempid,numseq;

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
      for r1 in c_hrms6bu_c1 loop
        v_appno  := nvl(r1.appno,0) + 1;
        /*user36 KOHU-SM2301 04/12/2023 cancel
        if nvl(r1.appno,0)+1 = r1.qtyapp then
           v_chk := 'E' ;
        else*/
           v_chk := v_appno;
        --user36 KOHU-SM2301 04/12/2023 cancel ||end if;
        --
        v_timin_o   := substr(r1.timino1,1,2)||':'||substr(r1.timino1,3,2);
        v_timout_o  := substr(r1.timouto1,1,2)||':'||substr(r1.timouto1,3,2);

        v_timin_n   := substr(r1.timin,1,2)||':'||substr(r1.timin,3,2);
        v_timout_n  := substr(r1.timout,1,2)||':'||substr(r1.timout,3,2);
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno',v_appno);
        obj_data.put('chk_appr',v_chk);
        obj_data.put('codempid',r1.codempid);
        obj_data.put('image',get_emp_img(r1.codempid));
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq',to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq',to_char(r1.numseq));
        obj_data.put('dtework',to_char(r1.dtework,'dd/mm/yyyy'));
        obj_data.put('codshift',r1.codshift);
        obj_data.put('timin_o',v_timin_o||' - '||v_timout_o);
        obj_data.put('timin_n',v_timin_n||' - '||v_timout_n);
        obj_data.put('reason',get_tcodec_name('TCODTIME',r1.codreqst,global_v_lang));
        obj_data.put('staappr',r1.staappr);
        obj_data.put('status',get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang));
        obj_data.put('desc_codappr',get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remarkap',r1.remarkap);
        obj_data.put('desc_codempap',get_temploy_name(global_v_codempid,global_v_lang));
        obj_data.put('remark',r1.remark);

        obj_row.put(to_char(v_row),obj_data);
        v_row := v_row+1;
      end loop;
    else
      for r1 in c_hrms6bu_c2 loop
        --
        v_nextappr := null;
        if r1.staappr = 'A' then
          v_nextappr := chk_workflow.get_next_approve('HRES6AE',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
        end if;
        --
        v_timin_o   := substr(r1.timino1,1,2)||':'||substr(r1.timino1,3,2);
        v_timout_o  := substr(r1.timouto1,1,2)||':'||substr(r1.timouto1,3,2);

        v_timin_n   := substr(r1.timin,1,2)||':'||substr(r1.timin,3,2);
        v_timout_n  := substr(r1.timout,1,2)||':'||substr(r1.timout,3,2);
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno',v_appno);
        obj_data.put('chk_appr',v_chk);
        obj_data.put('codempid',r1.codempid);
        obj_data.put('image',get_emp_img(r1.codempid));
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq',to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq',to_char(r1.numseq));
        obj_data.put('dtework',to_char(r1.dtework,'dd/mm/yyyy'));
        obj_data.put('codshift',r1.codshift);
        obj_data.put('timin_o',v_timin_o||' - '||v_timout_o);
        obj_data.put('timin_n',v_timin_n||' - '||v_timout_n);
        obj_data.put('reason',get_tcodec_name('TCODTIME',r1.codreqst,global_v_lang));
        obj_data.put('staappr',r1.staappr);
        obj_data.put('status',get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang));
        obj_data.put('desc_codappr',get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remarkap',r1.remarkap);
        obj_data.put('desc_codempap',v_nextappr);
        obj_data.put('remark',r1.remark);

        obj_row.put(to_char(v_row),obj_data);
        v_row := v_row+1;
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6bu;

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

  -- inout-detail
  procedure hrms6bu_detail_tab1(json_str_input in clob, json_str_output out clob) as
      obj_data        json_object_t;
      v_row           number := 0;
      v_chkdata       boolean := false;
      v_ttimereq      ttimereq%rowtype;
      v_timin_sch     varchar2(10 char);
      v_timout_sch    varchar2(10 char);
      v_timin_sch2    varchar2(10 char);
      v_timout_sch2   varchar2(10 char);
      v_dteine        date;
      v_timine        varchar2(10 char);
      v_dteoute       date;
      v_timoute       varchar2(10 char);
      v_dteinr        date;
      v_timinr        varchar2(10 char);
      v_dteoutr       date;
      v_timoutr       varchar2(10 char);
      v_rcnt          number;
  begin
    initial_value(json_str_input);
    begin
     select * into  v_ttimereq
     from  ttimereq
       where codempid  = p_codempid
       and   dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
       and   numseq    = p_numseq
       and   dtework   = to_date(p_dtework,'dd/mm/yyyy');
       v_chkdata := true;
    exception when others then
     v_ttimereq  :=       null ;
     v_chkdata   := false;
    end ;

    if v_ttimereq.codshift is not null then
        begin
        select  timstrtw,timendw
            into  v_timin_sch,v_timout_sch
            from  tshiftcd
            where codshift = v_ttimereq.codshift;
        exception when no_data_found then null;
        end;
    end if;
    --
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codinput', v_ttimereq.codinput);
    obj_data.put('desc_codinput', get_temploy_name(v_ttimereq.codinput,global_v_lang));
    obj_data.put('codempid', v_ttimereq.codempid);
    obj_data.put('desc_codempid', get_temploy_name(v_ttimereq.codempid,global_v_lang));
    obj_data.put('dtereq', to_char(v_ttimereq.dtereq,'dd/mm/yyyy'));
    obj_data.put('dtework', to_char(v_ttimereq.dtework,'dd/mm/yyyy'));
    obj_data.put('codshift', v_ttimereq.codshift);
    obj_data.put('desc_codshift', get_tshiftcd_name(v_ttimereq.codshift,global_v_lang));
    obj_data.put('timin_sch', call_formattime(v_timin_sch));
    obj_data.put('timout_sch', call_formattime(v_timout_sch));
    obj_data.put('dteine', to_char(v_ttimereq.dteino1,'dd/mm/yyyy'));
    obj_data.put('timine', call_formattime(v_ttimereq.timino1));
    obj_data.put('dteoute', to_char(v_ttimereq.dteouto1,'dd/mm/yyyy'));
    obj_data.put('timoute', call_formattime(v_ttimereq.timouto1));
    obj_data.put('dtein', to_char(v_ttimereq.dtein,'dd/mm/yyyy'));
    obj_data.put('timin', call_formattime(v_ttimereq.timin));
    obj_data.put('dteout', to_char(v_ttimereq.dteout,'dd/mm/yyyy'));
    obj_data.put('timout', call_formattime(v_ttimereq.timout));
    obj_data.put('codreqst', v_ttimereq.codreqst);
    obj_data.put('desc_codreqst', get_tcodec_name('tcodtime',v_ttimereq.codreqst,global_v_lang));
    obj_data.put('remark', v_ttimereq.remark);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6bu_detail_tab1;

  -- gen timework
  procedure hrms6bu_detail_tab2_table(json_str_input in clob, json_str_output out clob) is
    obj_data    json_object_t;
    obj_row     json_object_t;
    v_total     number := 0;
    v_row       number := 0;

    cursor   c_tattence is
      select codempid,dtework,typwork,codshift,timstrtw,timendw,dtein,timin,dteout,timout
        from tattence
       where codempid = p_codempid
         and dtework between to_date(p_stdate,'dd/mm/yyyy') and to_date(p_endate,'dd/mm/yyyy')
    order by dtework;
  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
    -- get data --
    for r1 in c_tattence loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtework', to_char(r1.dtework,'dd/mm/yyyy'));
      obj_data.put('typwork', r1.typwork);
      obj_data.put('codshift', r1.codshift);
      obj_data.put('timework', to_char(to_date(r1.timstrtw,'hh24:mi'),'hh24:mi')||' - '||to_char(to_date(r1.timendw,'hh24:mi'),'hh24:mi'));
      obj_data.put('dtein', to_char(r1.dtein,'dd/mm/yyyy')|| ' ' ||to_char(to_date(r1.timin,'hh24:mi'),'hh24:mi'));
      obj_data.put('dteout', to_char(r1.dteout,'dd/mm/yyyy')|| ' ' ||to_char(to_date(r1.timout,'hh24:mi'),'hh24:mi'));

      obj_row.put(to_char(v_row),obj_data);
      v_row := v_row+1;
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6bu_detail_tab2_table;
  --
   PROCEDURE approve( p_coduser         in varchar2,
                      p_lang            in varchar2,
                      p_total           in varchar2,
                      p_status          in varchar2,
                      p_remark_appr     in varchar2,
                      p_remark_not_appr in varchar2,
                      p_dteappr         in varchar2,
                      p_appno           in number,
                      p_chk             in varchar2,
                      p_codempid        in varchar2,
                      p_numseq          in number,
                      p_dtereqst        in varchar2,
                      p_dtework         in varchar2) is

--  Request
    rq_seqno    number               := p_appno;
    rq_chk      varchar2(10 char)    := p_chk;
    rq_dtework  date                 := to_date(p_dtework,'dd/mm/yyyy');
    rq_codempid varchar2(100 char)   := p_codempid;
    rq_dtereqst date                 := to_date(p_dtereqst,'dd/mm/yyyy');
    rq_numseq   number               := p_numseq;
    v_ttimereq  ttimereq%ROWTYPE;
    ap_approvno NUMBER := NULL;
    --  Values
    v_count     NUMBER := 0;
    v_txt       VARCHAR2(5000 char);
    v_msg_to    VARCHAR2(5000 char);
    v_msg_cc    VARCHAR2(5000 char);
    v_msg_not   VARCHAR2(5000 char);
    msg_error   varchar2(10 char);
    v_pos0      VARCHAR2(200 char);
    v_pos1      VARCHAR2(200 char);
    v_pos2      VARCHAR2(200 char);
    v_pos3      VARCHAR2(200 char);
    v_pos4      VARCHAR2(200 char);
    v_pos5      VARCHAR2(200 char);
    v_staappr   VARCHAR2(1 char) := p_status;
    v_approvno  NUMBER := NULL;
    v_codeappr  temploy1.codempid%type;
    v_approv    temploy1.codempid%type;
    p_codappr   temploy1.codempid%type := pdk.Check_Codempid(p_coduser);
    p_date      DATE;
    v_flag      VARCHAR2(1 char) := 'Y';
    -- Values of tatence
    v_qtynostam   tattence.qtynostam%TYPE;
    v_dteendw     tattence.dteendw%TYPE;
    v_timendw     tattence.timendw%TYPE;
    v_flgatten    tattence.flgatten%TYPE;
    v_codshift1   tattence.codshift%TYPE;
    v_codshift2   tattence.codshift%TYPE;
    vo_dtein      tattence.dtein%TYPE;
    vo_timin      tattence.timin%TYPE;
    vo_dteout     tattence.dteout%TYPE;
    vo_timout     tattence.timout%TYPE;
    vo_codchng    tattence.codchng%TYPE;
    vo_codcomp    tattence.codcomp%TYPE;
    v_codempap    temploy1.codempid%type;
    v_codcompap   tcenter.codcomp%type;
    v_codposap    tpostn.codpos%type;
    v_remark      varchar2(6000 char);

    v_max_approv number;
    v_desc       varchar2(600 char) := get_label_name('HCM_APPRFLW',global_v_lang,10);-- user22 : 04/07/2016 : STA4590287 || v_desc      varchar2(200 char);
    v_row_id     varchar2(200 char);
		v_endw       date;
    v_numrec     number;

    --<< user4 || 07/07/2020
    cursor c_tcontal5 is
      select codchng
        from tcontal5 a
       where codcompy = hcm_util.get_codcomp_level(v_ttimereq.codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontal5 b
                          where b.codcompy  = a.codcompy
                            and b.dteeffec <= trunc(sysdate))
         and codchng  = v_ttimereq.codreqst;
    -->> user4 || 07/07/2020

    begin
      if v_staappr = 'A' then
        v_remark := p_remark_appr;
      elsif v_staappr = 'N' then
        v_remark := p_remark_not_appr;
      end if;
      v_remark  := replace(v_remark,'.',chr(13));
      v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');
   -- Step 1 Check
      IF  p_date < rq_dtereqst THEN
          if  v_flag = 'Y' then
              v_flag := 'N';
          END IF;
          ROLLBACK;
      ELSIF p_date > sysdate THEN
          if  v_flag = 'Y' then
              v_flag := 'N';
          END IF;
          rollback;
      ELSE
          -- Step 2 => Insert Table Request Detail
          ap_approvno := rq_seqno;
          begin
              select *
              into  v_ttimereq
              from  ttimereq
              where codempid  = rq_codempid
              and   dtereq    = rq_dtereqst
              and   numseq    = rq_numseq
              and   dtework   = rq_dtework;
          exception when others then
              v_ttimereq :=       null ;
          end ;
          ---<<< weerayut 01/02/2018 Lock request during payroll
          if get_payroll_active('HRMS6BU',v_ttimereq.codempid,v_ttimereq.dtework,v_ttimereq.dtework) = 'Y' then
            param_msg_error := get_error_msg_php('ES0057',p_lang);
            return;
          end if;
          --->>> weerayut 01/02/2018

          --<<user36 KOHU-SM2301 04/12/2023 
          /*cancel ST11
          begin
                    select approvno into v_max_approv
                    from   twkflowh
                    where  routeno = v_ttimereq.routeno ;
          exception when no_data_found then
                    v_max_approv := 0 ;
          end ;*/
          begin
            select max(approvno) into v_max_approv
            from   tempaprq
            where  codapp    = 'HRES6AE'
            and    codempid  = v_ttimereq.codempid
            and    dtereq    = v_ttimereq.dtereq
            and    numseq    = v_ttimereq.numseq;
          end;
          -->>user36 KOHU-SM2301 04/12/2023

          begin
              select count(*)
              into   v_count
              from   taptimrq
              where  codempid = rq_codempid
              and  dtereq   = rq_dtereqst
              and  numseq   = rq_numseq
              and  dtework  = rq_dtework
              and  approvno = ap_approvno ;
          exception when no_data_found then
                v_count := 0;
          end;
          if v_count = 0 then
                 insert into taptimrq
                         (codempid,dtereq,numseq,dtework,approvno,
                          codappr,dteappr,staappr,
                          remark,dteupd,coduser,dteapph
                          )
                  values (rq_codempid,rq_dtereqst,rq_numseq,rq_dtework,ap_approvno,
                          p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),p_status,
                          v_remark,trunc(sysdate),p_coduser,sysdate);
          else
              update taptimrq
                 set staappr   = p_status,
                     codappr   = p_codappr,
                     dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                     coduser   = p_coduser,
                     remark   = v_remark,
                     dteapph  = sysdate

                where   codempid = rq_codempid
                  and   dtereq   = rq_dtereqst
                  and   numseq   = rq_numseq
                  and   dtework  = rq_dtework
                  and   approvno = ap_approvno ;
          end if;

          -- Step 3 => Check Next Step
          v_codeappr  := p_codappr ;
          v_approvno  := rq_seqno ;
          v_approvno  := ap_approvno;

          /*user36 KOHU-SM2301 04/12/2023 cancel
          chk_workflow.find_next_approve('HRES6AE',v_ttimereq.routeno,rq_codempid,to_char(rq_dtereqst,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

          if  p_status = 'A' and rq_chk <> 'E'   then
          loop
            v_approv := chk_workflow.check_next_step2('HRES6AE',v_ttimereq.routeno,rq_codempid,to_char(rq_dtereqst,'dd/mm/yyyy'),rq_numseq,null,to_char(rq_dtework,'dd/mm/yyyy'),v_approvno,p_codappr);
            if v_approv is not null then
                    v_remark   := v_desc; -- user22 : 04/07/2016 : STA4590287 ||
                    v_approvno := v_approvno + 1 ;
                    v_codeappr := v_approv ;
                    begin
                        select  count(*)
                        into    v_count
                        from    taptimrq
                        where   codempid = rq_codempid
                          and   dtereq   = rq_dtereqst
                          and   numseq   = rq_numseq
                          and   dtework  = rq_dtework
                          and   approvno = v_approvno ;
                    exception when no_data_found then
                           v_count := 0;
                    end;
                      if v_count = 0 then
                          insert into taptimrq
                                       (codempid,dtereq,numseq,dtework,approvno,
                                        codappr,dteappr,staappr,
                                        remark,dteupd,coduser,dteapph
                                        )
                                 values(rq_codempid,rq_dtereqst,rq_numseq,rq_dtework,v_approvno,
                                        v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),'A',-- user22 : 04/07/2016 : STA4590287 || p_codappr,to_date(p_dteappr,'ddmmyyyy'),'A',
                                        v_remark,trunc(sysdate),p_coduser,sysdate
                                        );
                      else
                          update taptimrq set
                              staappr   = 'A',
                              codappr   = v_codeappr,
                              dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                              coduser   = p_coduser,
                              remark    = v_remark,
                              dteapph   = sysdate
                          where   codempid = rq_codempid
                            and   dtereq   = rq_dtereqst
                            and   numseq   = rq_numseq
                            and   dtework  = rq_dtework
                            and   approvno = v_approvno ;
                     end if;
                    chk_workflow.find_next_approve('HRES6AE',v_ttimereq.routeno,rq_codempid,to_char(rq_dtereqst,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);-- user22 : 04/07/2016 : STA4590287 || v_approv := chk_workflow.Check_Next_Approve('HRES6AE',v_ttimereq.routeno,rq_codempid,to_char(rq_dtereqst,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
            else
                    exit ;
            end if;

          end loop ;

          update ttimereq set
                 approvno  = v_approvno ,
                 codappr   = v_codeappr,
                 dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                 staappr   = 'A',
                 remarkap  = v_remark,
                 coduser   = p_coduser,
                 dteapph   = sysdate
          where  codempid  = rq_codempid
            and  dtereq    = rq_dtereqst
            and  numseq    = rq_numseq
            and  dtework   = rq_dtework;
        end if;
        */

        -- Step 4 => Update Table Request and Insert Transaction
        v_staappr := p_status ;
        if v_max_approv = v_approvno then
           rq_chk := 'E' ;
        end if;

        if rq_chk = 'E' and p_status = 'A' then
           v_staappr := 'Y';
           --tattence
           if v_ttimereq.codshift is not null then
             begin
                  select  codshift,dtein,timin,dteout,timout,codchng,codcomp,
                          qtynostam,flgatten,dteendw,timendw
                  into    v_codshift1,vo_dtein,vo_timin,vo_dteout,vo_timout,vo_codchng,vo_codcomp,
                          v_qtynostam,v_flgatten,v_dteendw,v_timendw
                  from    tattence
                  where   codempid = rq_codempid
                    and   dtework  = rq_dtework;
             exception when no_data_found then
                 v_codshift1 := null;
             end;

             --exist tattence
             if v_codshift1 is not null then
               --<< user4 || 07/07/2020
               for r_tcontal5 in c_tcontal5 loop
                 if v_flgatten = 'Y' then
                   v_endw  := to_date(to_char(v_dteendw,'dd/mm/yyyy')||v_timendw,'dd/mm/yyyyhh24mi');
                   if rq_dtework <> to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy') or sysdate >= v_endw then
                     if vo_dtein is null and vo_dteout is null then
                       v_qtynostam := 2;
                     elsif vo_dtein is null or vo_dteout is null then
                       v_qtynostam := 1;
                     end if;
                   else
                     v_qtynostam := 1;
                   end if;
                 elsif v_flgatten = 'O' then
                   if vo_dtein is null and vo_dteout is null then
                     v_qtynostam := 2;
                   end if;
                 end if;
                 exit;
               end loop;
               -->> user4 || 07/07/2020

               if v_ttimereq.dtein  is not null or v_ttimereq.timin  is not null  or
                  v_ttimereq.dteout is not null or v_ttimereq.timout is not null then
                  begin
                    insert into tlogtime
                                        (
                                         codempid,dtework,dteupd,
                                         codshift,coduser,codcomp,
                                         dteinold,timinold,dteoutold,
                                         timoutold,codchngold,dteinnew,
                                         timinnew,dteoutnew,timoutnew,
                                         codchngnew/*,flgwork*/
                                         )
                            values
                                        (
                                         rq_codempid,rq_dtework,sysdate,
                                         v_codshift1,p_coduser,vo_codcomp,
                                         vo_dtein,vo_timin,vo_dteout,
                                         vo_timout,vo_codchng,v_ttimereq.dtein,
                                         v_ttimereq.timin,v_ttimereq.dteout,v_ttimereq.timout,
                                         v_ttimereq.codreqst/*,'W'*/
                                         );
                  exception when dup_val_on_index  then
                    update tlogtime
                    set codshift   = v_codshift1,
                        coduser    = p_coduser,
                        codcomp    = vo_codcomp,
                        dteinold   = vo_dtein,
                        timinold   = vo_timin,
                        dteoutold  = vo_dteout,
                        timoutold  = vo_timout,
                        codchngold = vo_codchng,
                        dteinnew   = v_ttimereq.dtein,
                        timinnew   = v_ttimereq.timin,
                        dteoutnew  = v_ttimereq.dteout,
                        timoutnew  = v_ttimereq.timout,
                        codchngnew = v_ttimereq.codreqst
                        /*flgwork    = 'W'*/
                    where codempid = rq_codempid
                      and dtework = rq_dtework
                      and dteupd = sysdate;
                  end;
               end if;

               if v_ttimereq.dtein is not null then
                  vo_dtein   := v_ttimereq.dtein;
                  vo_codchng := v_ttimereq.codreqst;
               end if;
               if v_ttimereq.timin is not null or v_ttimereq.timin <> ' ' then
                  vo_timin   := v_ttimereq.timin;
                  vo_codchng := v_ttimereq.codreqst;
               end if;
               if v_ttimereq.dteout is not null then
                  vo_dteout  := v_ttimereq.dteout;
                  vo_codchng := v_ttimereq.codreqst;
               end if;
               if v_ttimereq.timout is not null or v_ttimereq.timout <> ' ' then
                  vo_timout  := v_ttimereq.timout;
                  vo_codchng := v_ttimereq.codreqst;
               end if;

               update tattence set
                      dtein    = vo_dtein,
                      timin    = vo_timin,
                      dteout   = vo_dteout,
                      timout   = vo_timout,
                      codchng  = vo_codchng,
                      coduser  = p_coduser,
                      qtynostam= v_qtynostam -- user4 || 07/07/2020
               where  codempid = rq_codempid and
                      dtework  = rq_dtework;
             end if;
           end if;
--<< user22 : 15/02/2022 : ST11 || 
          std_al.cal_tattence(rq_codempid,rq_dtework,rq_dtework,p_coduser,v_numrec);
-->> user22 : 15/02/2022 : ST11 ||            
        end If;

        update ttimereq
        set   staappr   = v_staappr,
              codappr   = v_codeappr,
              approvno  = v_approvno,
              dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
              coduser   = p_coduser,
              --remarkap  = p_remark
              remarkap  = v_remark,
              dteapph   = sysdate
        where  codempid  = rq_codempid
          and  dtereq    = rq_dtereqst
          and  numseq    = rq_numseq
          and  dtework   = rq_dtework;

        commit;
        --Step 5 Send Mail--
        begin
            select rowid
              into v_row_id
              from ttimereq
             where codempid  = rq_codempid
               and dtereq    = rq_dtereqst
               and numseq    = rq_numseq
               and dtework   = rq_dtework;
        exception when others then
            v_ttimereq := null ;
        end ;

        begin 
          chk_workflow.sendmail_to_approve( p_codapp        => 'HRES6AE',
                                            p_codtable_req  => 'ttimereq',
                                            p_rowid_req     => v_row_id,
                                            p_codtable_appr => 'taptimrq',
                                            p_codempid      => rq_codempid,
                                            p_dtereq        => rq_dtereqst,
                                            p_seqno         => rq_numseq,
                                            p_staappr       => v_staappr,
                                            p_approvno      => v_approvno,
                                            p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                            p_subject_mail_numseq  => '40',
                                            p_lang          => global_v_lang,
                                            p_coduser       => global_v_coduser);
        exception when others then
          param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
        end;
      end if;-- end check error

  exception when others then
     rollback;
     param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;

  end;
  --

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
    v_dtework       varchar2(100);

  begin
    begin
      initial_value(json_str_input);
      json_obj := json_object_t(json_str_input).get_object('param_json');
      v_rowcount := json_obj.get_size;
      for i in 0..json_obj.get_size-1 loop
        json_obj2   := hcm_util.get_json_t(json_obj,to_char(i));
        v_staappr   := hcm_util.get_string_t(json_obj2, 'p_staappr');
        v_appseq    := to_number(hcm_util.get_string_t(json_obj2, 'p_approvno'));
        v_chk       := hcm_util.get_string_t(json_obj2, 'p_chk_appr');
        v_seqno     := to_number(hcm_util.get_string_t(json_obj2, 'p_numseq'));
        v_codempid  := hcm_util.get_string_t(json_obj2, 'p_codempid');
        v_dtereq    := hcm_util.get_string_t(json_obj2, 'p_dtereq');
        v_dtework   := hcm_util.get_string_t(json_obj2, 'p_dtework');

        v_staappr := nvl(v_staappr, 'A');
        approve(global_v_coduser,global_v_lang,to_char(v_rowcount),v_staappr,p_remark_appr,p_remark_not_appr,to_char(sysdate,'dd/mm/yyyy'),v_appseq,v_chk,v_codempid,v_seqno,v_dtereq,v_dtework);
        exit when param_msg_error is not null;
      end loop;

    if param_msg_error is not null then
      rollback;
      json_str_output  := get_response_message('400',param_msg_error,global_v_lang);
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
      json_str_output  := get_response_message('400',param_msg_error,global_v_lang);
    end;
  end process_approve;
end;

/
