--------------------------------------------------------
--  DDL for Package Body M_HRMS6EU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRMS6EU" is
/* Cust-Modify: KOHU-SM2301 */
-- last update: 06/12/2023 09:45

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global value
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
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

  procedure hrms6eu (json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_chk        varchar(3 char);
    v_appno      varchar2(2 char);
    v_date       varchar2(10 char);
    v_codpos     tpostn.codpos%type;
    v_codappr    temploy1.codempid%type;
    v_record     number := 0;
    v_dtereqst   varchar2(10 char);
    v_dtework    varchar2(10 char);
    v_data1      varchar2(10 char);
    v_data2      varchar2(10 char);
    v_data3      varchar2(10 char);
    v_data4      varchar2(10 char);
    v_status     varchar2(50 char);
    v_found      varchar2(1 char);
    v_dtest      date ;
    v_dteen      date ;
    page         varchar2(50 char) := get_label_name('SEARCHAPPR',global_v_lang,160);
    prevpage     number;
    nextpage     number;
    v_start      number;
    v_end        number;
    v_rcnt       number;
    p_count      number;
    v_reccnt     number := 35;
    v_nextappr   varchar2(1000 char);
    v_concat     varchar2(10 char);
    v_row        number := 0;
    -- check null data --
    v_flg_exist     boolean := false;

  cursor c_hrms6eu_c1 is
     select codempid,dtereq,seqno,dtework,typwrko,typwrkn,
            codshifto,codshiftn,typwrkro,typwrkrn,
            codshifro,codshifrn,codcomp,codappr,dteappr,
            remarkap,a.approvno appno,staappr,
            0 qtyapp --user36 KOHU-SM2301 06/12/2023 ||b.approvno qtyapp
       from  tworkreq a 
             --user36 KOHU-SM2301 06/12/2023 ||,twkflowh b
      where  staappr in ('P','A')
        and  ('Y' = chk_workflow.check_privilege('HRES6DE',codempid,dtereq,seqno,(nvl(a.approvno,0) + 1),v_codappr)
              /*user36 KOHU-SM2301 06/12/2023 cancel
              -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                        from   twkflowde c
                                                        where  c.routeno  = a.routeno
                                                        and    c.codempid = v_codappr)
              and ((sysdate - nvl(dteapph,dteinput))*1440) >= (select  hrtotal  from twkflpf where codapp ='HRES6DE'))*/
             )
        /*user36 KOHU-SM2301 06/12/2023 cancel 
        and a.routeno = b.routeno
        and a.codcomp like p_codcomp||'%'
        and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')*/
        order by  codempid,dtereq,seqno;


  cursor c_hrms6eu_c2 is
    select codempid,dtereq,seqno,dtework,typwrko,typwrkn,
           codshifto,codshiftn,typwrkro,typwrkrn,
           codshifro,codshifrn,codcomp,codappr,dteappr,
           remarkap,approvno,staappr
     from  tworkreq
    where codcomp like p_codcomp||'%'
      and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
      and (codempid ,dtereq,seqno) in
                               ( select codempid,dtereq,seqno
                                   from tapwrkrq
                                  where staappr = decode(p_staappr,'Y','A',p_staappr)
                                    and codappr = v_codappr
                                    and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
      order by  codempid,dtereq,seqno;
    --
  begin
    initial_value(json_str_input);
    v_codappr := pdk.check_codempid(global_v_coduser);
    v_dtest   := to_date(replace(p_dtest,'/',null),'ddmmyyyy');
    v_dteen   := to_date(replace(p_dteen,'/',null),'ddmmyyyy');
    -- default value --
    obj_row := json_object_t();
    v_row   := 0;
    -- get data
    IF p_staappr = 'P' THEN
      for r1 in c_hrms6eu_c1 loop
          v_appno  := nvl(r1.appno,0) + 1;
          /*user36 KOHU-SM2301 06/12/2023 cancel
          IF nvl(r1.appno,0)+1 = r1.qtyapp THEN
             v_chk := 'E' ;
          else*/
             v_chk := v_appno;
          --user36 KOHU-SM2301 06/12/2023 ||END IF;
          v_appno  := nvl(r1.appno,0) + 1;
          v_dtereqst  := to_char(r1.dtereq,'dd/mm/yyyy');
          v_dtework   := to_char(r1.dtework, 'dd/mm/yyyy');

          v_concat := '';
          if r1.codshifto is not null then
            v_concat := ' , ';
          end if;
          v_data1     := r1.typwrko||v_concat||r1.codshifto;
          --
          v_concat := '';
          if r1.codshifro is not null then
            v_concat := ' , ';
          end if;
          v_data2     := r1.typwrkro||v_concat||r1.codshifro;
          --
          v_concat := '';
          if r1.codshiftn is not null then
            v_concat := ' , ';
          end if;
          v_data3     := r1.typwrkn||v_concat||r1.codshiftn;
          --
          v_concat := '';
          if r1.codshifrn is not null then
            v_concat := ' , ';
          end if;
          v_data4     := r1.typwrkrn||v_concat||r1.codshifrn;
          --
          v_status   := get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang);
          --
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('approvno',v_appno);
          obj_data.put('chk_appr',v_chk);
          obj_data.put('v_chk',v_chk);
          obj_data.put('image',get_emp_img(r1.codempid));
          obj_data.put('codempid',r1.codempid);
          obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('dtereq',v_dtereqst);
          obj_data.put('numseq',to_char(r1.seqno));
          obj_data.put('dtework',v_dtework);
          obj_data.put('typwrk_codshift_o',v_data1);
          obj_data.put('typwrkr_codshiftr_o',v_data2);
          obj_data.put('typwrk_codshift_n',v_data3);
          obj_data.put('typwrkr_codshiftr_n',v_data4);
          obj_data.put('staappr',r1.staappr);
          obj_data.put('status',v_status);
          obj_data.put('desc_codappr',get_temploy_name(r1.codappr,global_v_lang));
          obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
          obj_data.put('remarkap',r1.remarkap);
          obj_data.put('desc_codempap',get_temploy_name(global_v_codempid,global_v_lang));
          obj_row.put(to_char(v_row),obj_data);
          v_row := v_row+1;
        end loop;
      else
        for r1 in c_hrms6eu_c2 loop
          v_dtereqst  := to_char(r1.dtereq,'dd/mm/yyyy');
          v_dtework   := to_char(r1.dtework, 'dd/mm/yyyy');
          v_concat := '';
          if r1.codshifto is not null then
            v_concat := ' , ';
          end if;
          v_data1     := r1.typwrko||v_concat||r1.codshifto;
          --
          v_concat := '';
          if r1.codshifro is not null then
            v_concat := ' , ';
          end if;
          v_data2     := r1.typwrkro||v_concat||r1.codshifro;
          --
          v_concat := '';
          if r1.codshiftn is not null then
            v_concat := ' , ';
          end if;
          v_data3     := r1.typwrkn||v_concat||r1.codshiftn;
          --
          v_concat := '';
          if r1.codshifrn is not null then
            v_concat := ' , ';
          end if;
          v_data4     := r1.typwrkrn||v_concat||r1.codshifrn;
          --
          v_status   := get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang);
          --
          v_nextappr := null;
          if r1.staappr = 'A' then
             v_nextappr := chk_workflow.get_next_approve('HRES6DE',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.seqno,r1.approvno,global_v_lang);
          end if;
          --
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('approvno',v_appno);
          obj_data.put('chk_appr',v_chk);
          obj_data.put('v_chk',v_chk);
          obj_data.put('image',get_emp_img(r1.codempid));
          obj_data.put('codempid',r1.codempid);
          obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('dtereq',v_dtereqst);
          obj_data.put('numseq',to_char(r1.seqno));
          obj_data.put('dtework',v_dtework);
          obj_data.put('typwrk_codshift_o',v_data1);
          obj_data.put('typwrkr_codshiftr_o',v_data2);
          obj_data.put('typwrk_codshift_n',v_data3);
          obj_data.put('typwrkr_codshiftr_n',v_data4);
          obj_data.put('staappr',r1.staappr);
          obj_data.put('status',v_status);
          obj_data.put('desc_codappr',get_temploy_name(r1.codappr,global_v_lang));
          obj_data.put('dteappr',to_char(r1.dteappr,'dd/mm/yyyy'));
          obj_data.put('remarkap',r1.remarkap);
          obj_data.put('desc_codempap',v_nextappr);

          obj_row.put(to_char(v_row),obj_data);
          v_row := v_row+1;
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6eu;

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

  -- show-detail
  procedure hrms6eu_detail_tab1 (json_str_input in clob, json_str_output out clob) is
    obj_data      json_object_t;
    v_row         number := 0;
    v_tworkreq    tworkreq%rowtype ;
    v_timstrtwe   varchar2(100 char);
    v_timendwe    varchar2(100 char);
    v_timstrtwr   varchar2(100 char);
    v_timendwr    varchar2(100 char);
    v_timstrtwoe  varchar2(100 char);
    v_timendwoe   varchar2(100 char);
    v_timstrtwor  varchar2(100 char);
    v_timendwor   varchar2(100 char);
    v_dtypwrko    varchar2(1000 char);
    v_dtypwrkro   varchar2(1000 char);
    v_dtypwrkn    varchar2(1000 char);
    v_dtypwrkrn   varchar2(1000 char);
    v_chkdata     boolean := false;
    --
 begin
    initial_value (json_str_input);
    begin
     select *
      into v_tworkreq
      from  tworkreq
      where codempid  = p_codempid
        and dtereq    = to_date(p_dtereq,'dd/mm/yyyy')
        and seqno     = p_numseq;
        v_chkdata := true;
      exception when no_data_found then
        v_chkdata := false;
    end;
    --
    if v_tworkreq.typwrko is not null then
      v_dtypwrko  := get_tlistval_name('TYPWRKFUL',v_tworkreq.typwrko,global_v_lang);
    else
      v_dtypwrko  := null;
    end if;

    if v_tworkreq.typwrkro is not null then
      v_dtypwrkro := get_tlistval_name('TYPWRKFUL',v_tworkreq.typwrkro,global_v_lang);
    else
      v_dtypwrkro := null;
    end if;

    if v_tworkreq.typwrkn is not null then
       v_dtypwrkn  := get_tlistval_name('TYPWRKFUL',v_tworkreq.typwrkn,global_v_lang);
    else
       v_dtypwrkn  := null;
    end if;

    if v_tworkreq.typwrkrn is not null then
       v_dtypwrkrn := get_tlistval_name('TYPWRKFUL',v_tworkreq.typwrkrn,global_v_lang);
    else
       v_dtypwrkrn := null;
    end if;

     begin
        select timstrtw,timendw
          into v_timstrtwoe,v_timendwoe
          from tattence
         where codempid = p_codempid
           and dtework  = to_date(v_tworkreq.dtework);
    exception when no_data_found then
            v_timstrtwoe := null;
            v_timendwoe  := null;
    end;

--    begin
--        select timstrtw,timendw
--          into v_timstrtwor,v_timendwor
--          from tattencr
--         where codempid = p_codempid
--           and dtework  = to_date(v_tworkreq.dtework);
--    exception when no_data_found then
--        v_timstrtwor := null;
--        v_timendwor  := null;
--    end;

    if v_tworkreq.codshiftn is not null then
        begin
            select timstrtw,timendw
              into v_timstrtwe,v_timendwe
              from tshiftcd
             where codshift = v_tworkreq.codshiftn;
        exception when no_data_found then
            v_timstrtwe := null;
            v_timendwe  := null;
        end;
    end if;
    if v_tworkreq.codshifrn is not null then
        begin
            select timstrtw,timendw
              into v_timstrtwr,v_timendwr
              from tshiftcd
             where codshift = v_tworkreq.codshifrn;
        exception when no_data_found then
            v_timstrtwr := null;
            v_timendwr  := null;
        end;
    end if;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codinput', v_tworkreq.codinput);
    obj_data.put('desc_codinput', get_temploy_name(v_tworkreq.codinput,global_v_lang));
    obj_data.put('codempid', v_tworkreq.codempid);
    obj_data.put('desc_codempid', get_temploy_name(v_tworkreq.codempid,global_v_lang));
    obj_data.put('dtereq', to_char(v_tworkreq.dtereq,'dd/mm/yyyy'));
    obj_data.put('dtework', to_char(v_tworkreq.dtework,'dd/mm/yyyy'));
    obj_data.put('typwrko', v_dtypwrko);
    obj_data.put('typwrkn', v_dtypwrkn);
    obj_data.put('codshifto', v_tworkreq.codshifto);
    obj_data.put('desc_codshifto', get_tshiftcd_name(v_tworkreq.codshifto,global_v_lang));
    obj_data.put('codshiftn', v_tworkreq.codshiftn);
    obj_data.put('desc_codshiftn', get_tshiftcd_name(v_tworkreq.codshiftn,global_v_lang));
    obj_data.put('timstrtwoe', call_formattime(v_timstrtwoe));
    obj_data.put('timendwoe', call_formattime(v_timendwoe));
    obj_data.put('timstrtwe', call_formattime(v_timstrtwe));
    obj_data.put('timendwe', call_formattime(v_timendwe));
    obj_data.put('typwrkro', v_dtypwrkro);
    obj_data.put('typwrkrn', v_dtypwrkrn);
    obj_data.put('codshifro', v_tworkreq.codshifro);
    obj_data.put('desc_codshifro', get_tshiftcd_name(v_tworkreq.codshifro,global_v_lang));
    obj_data.put('codshifrn', v_tworkreq.codshifrn);
    obj_data.put('desc_codshifrn', get_tshiftcd_name(v_tworkreq.codshifrn,global_v_lang));
    obj_data.put('timstrtwor', call_formattime(v_timstrtwor));
    obj_data.put('timendwor', call_formattime(v_timendwor));
    obj_data.put('timstrtwr', call_formattime(v_timstrtwr));
    obj_data.put('timendwr', call_formattime(v_timendwr));
    obj_data.put('remark', v_tworkreq.remark);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6eu_detail_tab1;
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
                    p_numseq          in number,
                    p_dtereq          in varchar2,
                    p_dtework         in varchar2) is

    v_codapp    tempaprq.codapp%type         := 'HRES6DE';
    rq_chk      varchar2(10 char)        := p_chk;
    rq_seqno    number                  := p_appseq;
    rq_dtework  date                    := to_date(p_dtework,'dd/mm/yyyy');
    rq_dtereqst date                    := to_date(p_dtereq,'dd/mm/yyyy');
    rq_codempid temploy1.codempid%type  := p_codempid;
    v_seqno     number                  := p_numseq;

    --  approve
    ap_approvno number := null;

    --  values
    v_count     number :=0;

    v_staappr   varchar2(1 char);
    v_approvno  number := null;
    v_codeappr  temploy1.codempid%type;
    v_approv    temploy1.codempid%type;

    p_codappr   temploy1.codempid%type := pdk.check_codempid(p_coduser);
    p_date      date;
    v_flag      varchar2(1 char) := 'Y';

        -- Values of ........
    v_typwrkn    varchar2(1 char);
    v_codshiftn  tshiftcd.codshift%type;
    v_codshift   tshiftcd.codshift%type;
    v_typwork    varchar2(1 char);
    v_timstrtw   varchar2(4 char);
    v_timendw    varchar2(4 char);
    v_dtestrtw   date ;
    v_dteendw    date ;
   -----------------
    v_typwork2   varchar2(1 char);
    v_codshift2  tshiftcd.codshift%type;
    v_dtestrtw2  date ;
    v_timstrtw2  varchar2(4 char);
    v_dteendw2   date ;
    v_timendw2   varchar2(4 char);
    v_typwrkrn   varchar2(40 char);
    v_tworkreq   tworkreq%rowtype;

    v_remark     varchar2(2000 char);

    v_codempap   temploy1.codempid%type;
    v_codcompap  tcenter.codcomp%type;
    v_codposap   tpostn.codpos%type;
    v_desc       varchar2(600 char) := get_label_name('HCM_APPRFLW',global_v_lang,10);-- user22 : 04/07/2016 : STA4590287 || v_desc      varchar2(200 char);
    v_max_approv number;
    v_codcomp    tcenter.codcomp%type;
    v_row_id     varchar2(200 char);
    v_error      varchar2(1000 char);
    v_numrec     number;
  begin
    v_zyear   := pdk.check_year(p_lang);
    p_date    := to_date(p_dteappr,'DD/MM/YYYY'); -- Date
    --
    v_staappr := p_status ;
    if v_staappr = 'A' then
      v_remark := p_remark_appr;
    elsif v_staappr = 'N' then
      v_remark := p_remark_not_appr;
    end if;
    v_remark  := replace(v_remark,'.',chr(13));
    v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');
    --
    if  p_date < rq_dtereqst then
    if  v_flag = 'Y' then
      --pdk.error_approve('ES0045',null,'p_dteappr',p_lang);
      v_flag := 'N';
    end if;
    elsif p_date > sysdate then
      if  v_flag = 'Y' then
        --pdk.error_approve('HR2020',null,'p_dteappr',p_lang);
        v_flag := 'N';
      end if;
    else
    --------------end check index----------------
    ap_approvno := rq_seqno;
--- for dtesnd 09/12/08 ---
    begin
      select *
        into v_tworkreq
        from tworkreq
       where codempid = rq_codempid
         and seqno    = v_seqno
         and dtereq   = rq_dtereqst;
    exception when no_data_found then
      v_tworkreq := null;
    end;
    ---<<< weerayut 10/01/2018 Lock request during payroll
    if get_payroll_active('HRMS6EU',v_tworkreq.codempid,v_tworkreq.dtework,v_tworkreq.dtework) = 'Y' then
      param_msg_error := get_error_msg_php('ES0057',p_lang);
      return;
    end if;
    --->>> weerayut 10/01/2018
    --user36 KOHU-SM2301 06/12/2023
    /*cancel ST11
    begin
      select approvno into v_max_approv
      from   twkflowh
      where  routeno = v_tworkreq.routeno ;
    exception when no_data_found then
      v_max_approv := 0 ;
    end ;*/
    begin
      select max(approvno) into v_max_approv
      from   tempaprq
      where  codapp    = 'HRES6DE'
      and    codempid  = v_tworkreq.codempid
      and    dtereq    = v_tworkreq.dtereq
      and    numseq    = v_tworkreq.seqno;
    end;
    -->>user36 KOHU-SM2301 06/12/2023

--- for dtesnd 09/12/08 ---
    begin
        select  count(*)
        into   v_count
        from   tapwrkrq
        where codempid = rq_codempid
          and dtereq   = rq_dtereqst
          and seqno    = v_seqno
          and approvno = ap_approvno ;
    exception when no_data_found then
      v_count := 0;
    end;

    if v_count = 0 then

       insert into tapwrkrq
               (codempid,dtereq,seqno,dtework,approvno,
                codappr,dteappr,staappr,
                remarkap,dteupd,coduser,
                dterec, dteapph)
        values (rq_codempid,rq_dtereqst,v_seqno,rq_dtework,ap_approvno,
                p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),p_status,
                v_remark,trunc(sysdate),p_coduser,
                nvl(v_tworkreq.dtesnd,sysdate),sysdate
                );
    else
        update tworkreq set
            staappr   = rq_chk,
            codappr   = p_codappr,
            dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
            coduser   = p_coduser,
            remarkap  = v_remark,
            dteapph  = sysdate
       where codempid = rq_codempid and
             dtereq   = rq_dtereqst and
             seqno    = v_seqno  and
             approvno = ap_approvno ;
    end if;

    -- Check Next Step
    v_codeappr  :=  p_codappr ;
    v_approvno  :=  rq_seqno;

    /*user36 KOHU-SM2301 06/12/2023 cancel
    chk_workflow.find_next_approve(v_codapp,v_tworkreq.routeno,rq_codempid,to_char(rq_dtereqst,'dd/mm/yyyy'),v_seqno,ap_approvno,p_codappr);

    if  p_status = 'A' and rq_chk <> 'E' then
      --loop check next step
      loop
        v_approv := chk_workflow.check_next_step(v_codapp,v_tworkreq.routeno,rq_codempid,to_char(rq_dtereqst,'dd/mm/yyyy'),v_seqno,v_approvno,p_codappr);
        if  v_approv is not null then
          v_remark   := v_desc; -- user22 : 04/07/2016 : STA4590287 ||
          v_approvno := v_approvno + 1 ;
          v_codeappr := v_approv ;
          begin
            select  count(*) into v_count
             from   tapwrkrq
             where  codempid = rq_codempid
             and    dtereq   = rq_dtereqst
             and    seqno    = v_seqno
             and    approvno = v_approvno;
          exception when no_data_found then  v_count := 0;
          end;
          if v_count = 0 then
              insert into tapwrkrq
                                  (
                                   codempid,dtereq,seqno,dtework,
                                   approvno,codappr,dteappr,
                                   staappr,remarkap,coduser,
                                   dterec, dteapph
                                   )
                          values
                                  (
                                   rq_codempid,rq_dtereqst,v_seqno,rq_dtework,
                                   v_approvno,v_codeappr,trunc(sysdate),
                                   'A',v_remark,p_coduser,
                                   sysdate,sysdate
                                   );
          else
              update tapwrkrq set codappr   = v_codeappr,
                                  dteappr   = trunc(sysdate),
                                  staappr   = 'A',
                                  remarkap  = v_remark ,
                                  coduser   = p_coduser,
                                  dterec    = sysdate,
                                  dteapph   = sysdate 
               where  codempid = rq_codempid
                 and  dtereq   = rq_dtereqst
                 and  seqno    = v_seqno
                 and  approvno = v_approvno;
          end if;
          chk_workflow.find_next_approve(v_codapp,v_tworkreq.routeno,rq_codempid,to_char(rq_dtereqst,'dd/mm/yyyy'),v_seqno,v_approvno,p_codappr);-- user22 : 04/07/2016 : STA4590287 || v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_tworkreq.routeno,rq_codempid,to_char(rq_dtereqst,'dd/mm/yyyy'),v_seqno,v_approvno,p_codappr);
        else
          exit ;
        end if;
      end loop ;
         update tworkreq set  approvno  = v_approvno,
                              codappr   = v_codeappr,
                              dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                              staappr   = v_staappr,
                              remarkap  = v_remark,
                              coduser   = p_coduser,
                              dteapph   = sysdate
                       where codempid   = rq_codempid
                         and dtereq     = rq_dtereqst
                         and seqno      = v_seqno;

    END IF;
    -- End Check Next Step
    */

    v_staappr := p_status ;
    if v_max_approv = v_approvno then
      rq_chk := 'E' ;
    end if;

    if rq_chk = 'E' and p_status = 'A' then
      v_staappr := 'Y';
    end if;

    update tworkreq
       set approvno  = v_approvno,
           staappr   = v_staappr,
           codappr   = v_codeappr,
           dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
           dteupd    = trunc(sysdate),
           coduser   = p_coduser,
           remarkap  = v_remark,
           dteapph   = sysdate
     where codempid = rq_codempid 
       and dtereq   = rq_dtereqst
       and seqno    = v_seqno;

    if rq_chk = 'E' and p_status = 'A' then
      begin
        select *
        into v_tworkreq
        from tworkreq
        where codempid = rq_codempid
         and seqno    = v_seqno
         and dtereq   = rq_dtereqst;
      exception when no_data_found then  v_tworkreq := null;
      end;

      begin
        select  typwork,codshift,dtestrtw,timstrtw,dteendw,timendw
            into  v_typwork,v_codshift,v_dtestrtw,v_timstrtw,v_dteendw,v_timendw
            from  tattence
            where codempid = rq_codempid
            and   dtework  = rq_dtework;
        exception when no_data_found then   v_codshift := null;
      end;

      if v_codshift is not null then  --exist tattence
        if v_codshift <> v_tworkreq.codshiftn then
          begin
            insert into tlogtime(codempid,dtework,dteupd,
                                 codshift,coduser,codcomp,
                                 codshifold,codshifnew)
                          values(rq_codempid,rq_dtework,sysdate,
                                 nvl(v_tworkreq.codshiftn,v_codshift),p_coduser,v_codcomp,
                                 v_codshift,v_tworkreq.codshiftn);
          exception when dup_val_on_index then
            update tlogtime
               set codshifold = v_codshift,
                   codshifnew = v_tworkreq.codshiftn
             where codempid   = rq_codempid
               and dtework    = rq_dtework
               and dteupd     = sysdate;
          end;
        end if;--v_codshift <> v_tworkreq.codshiftn
        if v_typwork <> v_tworkreq.typwrkn then
          begin
            insert into tlogtime(codempid,dtework,dteupd,
                                 codshift,coduser,codcomp,
                                 typworkold,typworknew)
                          values(rq_codempid,rq_dtework,sysdate,
                                 nvl(v_tworkreq.codshiftn,v_codshift),p_coduser,v_codcomp,
                                 v_typwork,v_tworkreq.typwrkn);
          exception when dup_val_on_index then
            update tlogtime
               set typworkold = v_typwork,
                   typworknew = v_tworkreq.typwrkn
             where codempid   = rq_codempid
               and dtework    = rq_dtework
               and dteupd     = sysdate;
          end;
        end if;--v_typwork <> v_tworkreq.typwrkn
        --
        if v_tworkreq.typwrkn is not null then
          v_typwork  := v_tworkreq.typwrkn;
        end if;
        if v_tworkreq.codshiftn is not null then
          begin
            select  timstrtw,timendw
                into  v_timstrtw,v_timendw
                from  tshiftcd
                where codshift = v_tworkreq.codshiftn;
            exception when no_data_found then   null;
          end;
          v_codshift  := v_tworkreq.codshiftn;
          v_dtestrtw  := v_tworkreq.dtework;
          if to_number(v_timstrtw) <= to_number(v_timendw) then
            v_dteendw := v_tworkreq.dtework;
          else
            v_dteendw := v_tworkreq.dtework + 1;
          end if;
        end if; --if :data.codshiftn is not null then

        begin
          update tattence set typwork  = v_typwork,
                              codshift = v_codshift,
                              dtestrtw = v_dtestrtw,
                              timstrtw = v_timstrtw,
                              dteendw  = v_dteendw,
                              timendw  = v_timendw
          where  codempid = rq_codempid
          and    dtework  = rq_dtework;
        end;
      end if;  --exist tattence
--<< user22 : 15/02/2022 : ST11 || 
      std_al.cal_tattence(rq_codempid,rq_dtework,rq_dtework,p_coduser,v_numrec);
-->> user22 : 15/02/2022 : ST11 ||
    end if;
    if p_status = 'N' then --refused 'n'
      update tworkreq set staappr  = 'N',
                          codappr  = p_codappr,
                          dteappr  = p_date,
                          coduser  = p_coduser,
                          remarkap = v_remark,
                          approvno = v_approvno
                   where codempid  = rq_codempid
                   and   dtereq    = rq_dtereqst
                   and   seqno     = v_seqno;

    end if;
    commit;

    begin
      select rowid
        into v_row_id
        from tworkreq
       where codempid = rq_codempid
         and seqno    = v_seqno
         and dtereq   = rq_dtereqst;
    exception when no_data_found then
      v_tworkreq := null;
    end;

    --sendmail
    begin
        chk_workflow.sendmail_to_approve( p_codapp        => 'HRES6DE',
                                          p_codtable_req  => 'tworkreq',
                                          p_rowid_req     => v_row_id,
                                          p_codtable_appr => 'tapwrkrq',
                                          p_codempid      => rq_codempid,
                                          p_dtereq        => rq_dtereqst,
                                          p_seqno         => v_seqno,
                                          p_staappr       => v_staappr,
                                          p_approvno      => v_approvno,
                                          p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                          p_subject_mail_numseq  => '50',
                                          p_lang          => global_v_lang,
                                          p_coduser       => global_v_coduser);
    exception when others then
        param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
    end;
   end if;
  exception when others then
     rollback;
     param_msg_error := sqlerrm;
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
--      param_msg_error := get_error_msg_php('HR2402',global_v_lang);
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
    end;
  end process_approve;
end;

/
