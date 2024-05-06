--------------------------------------------------------
--  DDL for Package Body HRMS6NU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS6NU" is
-- last update: 27/09/2022 10:44

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    --global value
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
    p_seqno             := hcm_util.get_string_t(json_obj,'p_numseq');
    p_dtereqr           := hcm_util.get_string_t(json_obj,'p_dtereqr');
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
  end;

  procedure hrms6nu (json_str_input in clob, json_str_output out clob) is
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_codappr     temploy1.codempid%type;
    v_codpos      tpostn.codpos%type;
    v_nextappr    varchar2(1000 char);
    v_dtest       date;
    v_dteen       date;
    v_rcnt        number;
    v_appno       varchar2(100 char);
    v_chk         varchar2(100 char) := ' ';
    v_row         number := 0;
    -- check null data --
    v_flg_exist   boolean := false;

    cursor c_hrms6nu_c1 is
      select dtereq,codempid,codappr,a.approvno appno,codleave,dteend,dteappr,
             get_temploy_name(codempid,global_v_lang) ename,seqno,staappr,
             codcomp,dtestrt,get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
             b.approvno qtyapp,remarkap,dtereqr,seqnor
        FROM tleavecc a ,twkflowh b
       WHERE codcomp like p_codcomp||'%'
         and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
         and staappr in ('P','A')
         AND ('Y' = chk_workflow.check_privilege('HRES6ME',codempid,dtereq,seqno,(nvl(a.approvno,0) + 1),v_codappr)
                -- Replace Approve
                or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                          from   twkflowde c
                                                          where  c.routeno  = a.routeno
                                                          and    c.codempid = v_codappr)
                and trunc(((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES6ME')))
        and a.routeno = b.routeno
     ORDER BY  codempid,dtereq,seqno;

    cursor c_hrms6nu_c2 is
      select dtereq,codempid,codappr,approvno,codleave,dteend,dteappr,
             get_temploy_name(codempid,global_v_lang) ename,seqno,staappr,
               codcomp,dtestrt,get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,remarkap,dtereqr,seqnor
        from tleavecc
       where codcomp like p_codcomp||'%'
         and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
         and (codempid ,dtereq,seqno) in
                       (select codempid ,dtereq,seqno
                          from taplvecc
                         where staappr = decode(p_staappr,'Y','A',p_staappr)
                           and codappr = v_codappr
                           and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
       ORDER BY  codempid,dtereq,seqno;
  begin
    initial_value(json_str_input);
    v_codappr := pdk.check_codempid(global_v_coduser);
    v_dtest   := to_date(replace(p_dtest,'/',null),'ddmmyyyy');
    v_dteen   := to_date(replace(p_dteen,'/',null),'ddmmyyyy');
    -- default value --
    obj_row := json_object_t();
    v_row   := 0;
    -- get data
    if p_staappr = 'P' then
      for r1 in c_hrms6nu_c1 loop
        v_appno  := nvl(r1.appno,0) + 1;
        if nvl(r1.appno,0)+1 = r1.qtyapp then
           v_chk := 'E' ;
        else
           v_chk := v_appno ;
        end if;
        --
        select codpos into v_codpos
          from temploy1
         where codempid = r1.codempid;
        --
        v_row    := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno', v_appno);
        obj_data.put('chk_appr', v_chk);
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq', to_char(r1.seqno));
        obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));
        obj_data.put('dteperiod', to_char(r1.dtestrt ,'DD/MM/YYYY')||'  - '||to_char(r1.dteend ,'DD/MM/YYYY'));
        obj_data.put('status', r1.status);
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark', r1.remarkap);
        obj_data.put('desc_codempap',get_temploy_name(global_v_codempid,global_v_lang));
        obj_data.put('seqnor', to_char(r1.seqnor));
        obj_data.put('dtereqr', to_char(r1.dtereqr,'dd/mm/yyyy'));
        obj_data.put('staappr', r1.staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    else
      for r1 in c_hrms6nu_c2 loop
        select codpos into v_codpos
          from temploy1
         where codempid = r1.codempid;
        --
        v_nextappr := null;
        if r1.staappr = 'A' then
           v_nextappr := chk_workflow.get_next_approve('HRES6ME',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.seqno,r1.approvno,global_v_lang);
        end if;
        --
        v_row    := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno', v_appno);
        obj_data.put('chk_appr', v_chk);
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq', to_char(r1.seqno));
        obj_data.put('desc_codleave', get_tleavecd_name(r1.codleave, global_v_lang));
        obj_data.put('dteperiod', to_char(r1.dtestrt ,'DD/MM/YYYY')||'  - '||to_char(r1.dteend ,'DD/MM/YYYY'));
        obj_data.put('status', r1.status);
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark', r1.remarkap);
        obj_data.put('desc_codempap', v_nextappr);
        obj_data.put('seqnor', to_char(r1.seqnor));
        obj_data.put('dtereqr', to_char(r1.dtereqr,'dd/mm/yyyy'));
        obj_data.put('staappr', r1.staappr);

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6nu;

  -- leave_detail
  procedure hrms6nu_detail_tab1(json_str_input in clob, json_str_output out clob) is
    obj_data    json_object_t;
    v_dtestrt   date;
    v_dteend    date;
    v_desreq    varchar2(200 char);
    v_codleave  varchar2(10 char);
    v_chkdata   boolean := false;
  begin
    initial_value(json_str_input);
    begin
        select codleave,dtestrt,dteend,desreq
        into   v_codleave,v_dtestrt,v_dteend,v_desreq
        from   tleavecc
        where  codempid = p_codempid
        and    dtereq   = to_date(p_dtereq,'DDMMYYYY')
        and    seqno    = p_seqno
        and    dtereqr  = to_date(p_dtereqr,'DDMMYYYY');
        v_chkdata := true;
    exception when no_data_found then
       v_chkdata := false;
    end;
    --
    obj_data := json_object_t();
    if v_chkdata then
      obj_data.put('coderror', '200');
      obj_data.put('codempid', p_codempid);
      obj_data.put('desc_codempid', get_temploy_name(p_codempid, global_v_lang));
      obj_data.put('dtereq', hcm_util.get_date_buddhist_era(to_date(p_dtereq,'dd/mm/yyyy')));
      obj_data.put('codleave', v_codleave);
      obj_data.put('desc_codleave', get_tleavecd_name(v_codleave, global_v_lang));
      obj_data.put('dtestrt', hcm_util.get_date_buddhist_era(v_dtestrt));
      obj_data.put('dteend', hcm_util.get_date_buddhist_era(v_dteend));
      obj_data.put('remark', v_desreq);
    else
      obj_data.put('coderror', '200');
    end if;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms6nu_detail_tab1;
  --
  PROCEDURE approve(p_coduser         in varchar2,
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
                    p_dtereq          in varchar2,
                    p_dtereqr         in varchar2) is

    rq_codempid  temploy1.codempid%type := p_codempid;
    rq_dtereq    date              := to_date(p_dtereq,'dd/mm/yyyy');
    v_dtereqr    date              := to_date(p_dtereqr,'dd/mm/yyyy');
    rq_seqno     number            := p_seqno;
    v_appseq     number            := p_appseq;
    rq_chk       varchar2(10 char) := p_chk;
    r_tleavecc   tleavecc%rowtype;
    v_approvno   number := null;
    ap_approvno  number := null;
    v_count      number := 0;
    v_staappr    varchar2(1 char);
    v_codeappr   temploy1.codempid%type;
    v_approv     temploy1.codempid%type;
    v_desc       varchar2(600 char) := get_label_name('HCM_APPRFLW',global_v_lang,10);-- user22 : 04/07/2016 : STA4590287 || v_desc      varchar2(200 char);
    v_codempap   temploy1.codempid%type;
    v_codcompap  tcenter.codcomp%type;
    v_codposap   tpostn.codpos%type;

    v_remark     varchar2(2000 char);
    p_codappr    temploy1.codempid%type := pdk.check_codempid(p_coduser);
    v_max_approv number;
    v_numlereq   varchar2(15 char);
    vv_dtereqr   date;
    vv_seqnor    number;
    v_row_id     varchar2(200 char);
    v_numrec2    number;
    v_dtestrt    date;
    v_dteend     date;

    begin
      v_staappr := p_status ;
      v_zyear   := pdk.check_year(p_lang);
      if v_staappr = 'A' then
        v_remark := p_remark_appr;
      elsif v_staappr = 'N' then
        v_remark := p_remark_not_appr;
      end if;
      v_remark  := replace(v_remark,'.',chr(13));
      v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');
      --
      begin
        select *
        into r_tleavecc
        from tleavecc
        where codempid = rq_codempid
        and dtereq = rq_dtereq
        and seqno  = rq_seqno
        and dtereqr = v_dtereqr ;
      exception when others then
        r_tleavecc := null ;
      end;

      ---<<< weerayut 09/01/2018 Lock request during payroll
      if get_payroll_active('HRMS6NU',r_tleavecc.codempid,r_tleavecc.dtestrt,r_tleavecc.dteend) = 'Y' then
        param_msg_error := get_error_msg_php('ES0057',p_lang);
        return;
      end if;
      --->>> weerayut 09/01/2018

      begin
        select approvno into v_max_approv
        from   twkflowh
        where  routeno = r_tleavecc.routeno ;
      exception when no_data_found then
        v_max_approv := 0 ;
      end ;

      IF nvl(r_tleavecc.approvno,0) < v_appseq THEN
        ap_approvno := v_appseq ;

        begin
          select  count(*)
          into  v_count
          from  taplvecc
          where  codempid = rq_codempid
          and    dtereq   = rq_dtereq
          and    seqno    = rq_seqno
          and    approvno = ap_approvno;
        exception when no_data_found then
          v_count := 0;
        end;

        if v_count = 0 then
          insert into taplvecc
                  (codempid,dtereq,seqno,approvno,
                  codappr,dteappr,staappr,
                  remark,dteupd,coduser,
                  dterec, dteapph)
          values (rq_codempid,rq_dtereq,rq_seqno, ap_approvno,
                  p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),v_staappr,
                  v_remark,trunc(sysdate),p_coduser,
                  nvl(r_tleavecc.dtesnd,sysdate),sysdate
                  );
        else
          update taplvecc
             set codappr  = p_codappr,
                 dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                 staappr  = v_staappr,
                 remark   = v_remark,
                 dteupd   = trunc(sysdate),
                 coduser  = p_coduser,
                 dterec   = nvl(r_tleavecc.dtesnd,sysdate),
                 dteapph  = sysdate
           where codempid = rq_codempid
             and dtereq   = rq_dtereq
             and seqno    = rq_seqno
             and approvno = ap_approvno;
        end if;
        -- Check Next Step

        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;

        chk_workflow.find_next_approve('HRES6ME',r_tleavecc.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,ap_approvno,p_codappr);

        if  p_status = 'A' and rq_chk <> 'E'   then
          loop
            v_approv := chk_workflow.check_next_step('HRES6ME',r_tleavecc.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
            if  v_approv is not null then
              v_remark   := v_desc; -- user22 : 04/07/2016 : STA4590287 ||
              v_approvno := v_approvno + 1 ;
              v_codeappr := v_approv ;

              begin
                select count(*)
                into v_count
                from   taplvecc
                where  codempid   =  rq_codempid
                and    dtereq   = rq_dtereq
                and    seqno    = rq_seqno
                and    approvno =  v_approvno;
              exception when no_data_found then  v_count := 0;
              end;

              if v_count = 0  then
                INSERT INTO taplvecc(codempid,dtereq,seqno,approvno,
                           codappr,dteappr,staappr,remark,
                           dteupd,coduser,
                           dterec, dteapph)
                    VALUES(rq_codempid,rq_dtereq,rq_seqno,v_approvno,
                           v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),'A',v_remark,
                           trunc(sysdate),p_coduser,
                           sysdate,sysdate);
              else
                UPDATE taplvecc
                   SET codappr   = v_codeappr,
                       dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
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
              chk_workflow.find_next_approve('HRES6ME',r_tleavecc.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);-- user22 : 04/07/2016 : STA4590287 || v_approv := chk_workflow.Check_Next_Approve('HRES6ME',r_tleavecc.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
            else
              exit ;
            end if;
          end loop ;

          UPDATE tleavecc
             SET staappr   = v_staappr,
                 codappr   = v_codeappr,
                 approvno  = v_approvno,
                 dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                 remarkap  = v_remark ,
                 dteupd    = trunc(sysdate),
                 coduser   = p_coduser,
                 dteapph   = sysdate
           WHERE codempid  = rq_codempid
             AND dtereq    = rq_dtereq
             AND seqno     = rq_seqno
             AND dtereqr   = v_dtereqr ;
        end if;

        -- Step 4 => Update staappr
        v_staappr := p_status ;
        if v_max_approv = v_approvno then
          rq_chk := 'E' ;
        end if;

        if rq_chk = 'E' and p_status = 'A' then
          v_staappr := 'Y';
          update tleaverq
             set staappr = 'C'
           where codempid  = rq_codempid
             and dtereq    = r_tleavecc.dtereqr
             and seqno     = r_tleavecc.seqnor;

          --<< user39 || STA4580130 || 03/09/2015
          begin
            select dtereqr ,seqnor into vv_dtereqr ,vv_seqnor
            from  tleavecc
            where codempid  =  rq_codempid
            and   dtereq    =  rq_dtereq
            and   seqno     =  rq_seqno;
          exception when no_data_found then
            vv_dtereqr := null; vv_seqnor := null;
          end;

          begin
            select numlereq,dtestrt,dteend
              into v_numlereq,v_dtestrt,v_dteend -- user22 : 15/02/2022 : ST11 || select  numlereq into v_numlereq          
            from    tleaverq
            where   codempid  =  rq_codempid
            and     dtereq    =  vv_dtereqr
            and     seqno     =  vv_seqnor;
          exception when no_data_found then
            v_numlereq := null; v_dtestrt := null; v_dteend := null;
          end;
          -->> user39 || STA4580130 || 03/09/2015

--<< user22 : 15/02/2022 : ST11 ||
          hral56b_batch.gen_leave(rq_codempid,null,v_dtestrt,v_dteend,p_coduser,v_numrec2);        
-->> user22 : 15/02/2022 : ST11 ||
        end if;

        begin
            update tleavecc
               set    staappr   = v_staappr,
                      codappr   = v_codeappr,
                      approvno  = v_approvno,
                      dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                      coduser   = p_coduser,
                      remarkap  = v_remark,
                      dteapph   = sysdate,
                      numlereq  = v_numlereq  --  user39 || STA4580130 || 03/09/2015
              where   codempid  = rq_codempid
              and     dtereq    = rq_dtereq
              and     seqno     = rq_seqno
              and     dtereqr   = v_dtereqr ;
        end;  
        COMMIT;

        begin
            select rowid
            into   v_row_id
            from   tleavecc
            where  codempid = rq_codempid
            and    dtereq = rq_dtereq
            and    seqno  = rq_seqno
            and    dtereqr = v_dtereqr ;
        exception when others then
            r_tleavecc := null ;
        end;

        -- Send mail
        begin
          chk_workflow.sendmail_to_approve( p_codapp        => 'HRES6ME',
                                            p_codtable_req  => 'tleavecc',
                                            p_rowid_req     => v_row_id,
                                            p_codtable_appr => 'taplvecc',
                                            p_codempid      => rq_codempid,
                                            p_dtereq        => rq_dtereq,
                                            p_seqno         => rq_seqno,
                                            p_staappr       => v_staappr,
                                            p_approvno      => v_approvno,
                                            p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                            p_subject_mail_numseq  => '70',
                                            p_lang          => global_v_lang,
                                            p_coduser       => global_v_coduser);
        exception when others then
          param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
        end;
      end if; --Check Approve

    exception when others then
     rollback;
     param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end;
  --

  procedure process_approve(json_str_input in clob, json_str_output out clob) as
    json_obj              json_object_t;
    json_obj2             json_object_t;
    v_rowcount            number:= 0;
    v_staappr             varchar2(100);
    v_appseq              number;
    v_chk                 varchar2(10);
    v_seqno               number;
    v_codempid            varchar2(100);
    v_dtereq              varchar2(100);
    v_dtereqr             varchar2(100);

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
        v_dtereqr   := hcm_util.get_string_t(json_obj2, 'p_dtereqr');

        v_staappr := nvl(v_staappr, 'A');
        approve(global_v_coduser,global_v_lang,to_char(v_rowcount),v_staappr,p_remark_appr,p_remark_not_appr,to_char(sysdate,'dd/mm/yyyy'),v_appseq,v_chk,v_codempid,v_seqno,v_dtereq,v_dtereqr);
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
  --
end;

/
