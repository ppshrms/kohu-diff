--------------------------------------------------------
--  DDL for Package Body HRMS47U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS47U" is

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
    p_codkpi            := hcm_util.get_string_t(json_obj,'p_codkpi');
    p_dtereqr           := hcm_util.get_string_t(json_obj,'p_dtereqr');
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
  end;

  procedure hrms47u (json_str_input in clob, json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_chk           varchar2(4 char);
    v_date          varchar2(10 char);
    v_codappr       varchar2(50 char);
    v_dtest         date ;
    v_dteen         date ;
    v_rcnt          number;
    v_nextappr      varchar2(1000 char);
    v_appno         varchar2(100 char);
    v_row           number := 0;
    -- check null data --
    v_flg_exist     boolean := false;
    v_codpos        temploy1.codpos%type;

    CURSOR c_hrms47u_c1 IS
       select  a.*,b.approvno qtyapp
         FROM  tkpireq a ,twkflowh b
         where codcomp like p_codcomp||'%'
         and   (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
         and   staappr in ('P','A')
         and   ('Y' = chk_workflow.check_privilege('HRES17E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
                -- Replace Approve
                or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                          from   twkflowde c
                                                          where  c.routeno  = a.routeno
                                                          and    c.codempid = v_codappr)
                     and    (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES17E')))
          and a.routeno = b.routeno
          order by  codempid,dtereq,numseq;

    CURSOR c_hrms47u_c2 IS
       select  *
         from  tkpireq
         where codcomp like p_codcomp||'%'
         and   (codempid = nvl(p_codempid,codempid) /*or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%'*/)
         and   (codempid, dtereq, numseq) in
                          (select codempid, dtereq, numseq
                           from  tapkpirq
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
      for r1 in c_hrms47u_c1 loop
        --
        v_appno  := nvl(r1.approvno,0) + 1;
        if nvl(r1.approvno,0)+1 = r1.qtyapp then
           v_chk := 'E' ;
        else
           v_chk := v_appno;
        end if;
        
        v_nextappr := null;
        v_nextappr := chk_workflow.get_next_approve('HRES17E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
        
        begin
            select codpos
              into v_codpos
              from temploy1
              where codempid = r1.codempid;        
        exception when no_data_found then
            v_codpos := null;
        end;

        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('no', v_row + 1 );
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq ,'dd/mm/yyyy'));
        obj_data.put('numseq', r1.numseq);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos', v_codpos);
        obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('dteyear', r1.dteyreap);
        obj_data.put('numtime', r1.numtime);
        obj_data.put('status', get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang));
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark', r1.remarkap);
        obj_data.put('desc_codempap', v_nextappr);  
        obj_data.put('chk_appr', v_chk);
        obj_data.put('approvno', v_appno);
        obj_row.put(to_char(v_row),obj_data);
        v_row := v_row+1;
      end loop;
    else
      for r1 in c_hrms47u_c2 loop
        --
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('no', v_row + 1 );
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq ,'dd/mm/yyyy'));
        obj_data.put('numseq', r1.numseq);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codpos', v_codpos);
        obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('dteyear', r1.dteyreap);
        obj_data.put('numtime', r1.numtime);
        obj_data.put('status', get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang));
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark', r1.remarkap);
        obj_data.put('desc_codempap', '');  
        obj_data.put('chk_appr', v_chk);
        obj_data.put('approvno', v_appno);

        obj_row.put(to_char(v_row),obj_data);
        v_row := v_row+1;
      end loop;
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end HRMS47U;

  --req-detail
  procedure hrms47u_detail (json_str_input in clob, json_str_output out clob) is
    obj_data        json_object_t;
    obj_detail      json_object_t;
    obj_table       json_object_t;
    v_row           number := 0;
    v_objective     tkpireq.objective%type;

    cursor c_tkpireq2 is
      select * 
        from tkpireq2
       where codempid = p_codempid
         and dtereq = to_date(p_dtereq,'ddmmyyyy')
         and numseq = p_numseq
    order by decode(typkpi,'D',1,'J',2,'I',3 ), codkpi ;
  begin
    initial_value (json_str_input);
    begin
        select objective
          into v_objective
          from tkpireq
         where codempid = p_codempid
           and dtereq = to_date(p_dtereq,'ddmmyyyy')
           and numseq = p_numseq ;
    exception when no_data_found then
      null;
    end ;
    --
    obj_detail  := json_object_t();
    obj_detail.put('coderror', '200');
    obj_detail.put('objective', v_objective);
    
    obj_table   := json_object_t();
    for r1 in c_tkpireq2 loop
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('typkpi', get_tlistval_name('TYPKPI',r1.typkpi,global_v_lang));
        obj_data.put('codkpi', r1.codkpi);
        obj_data.put('kpides', r1.kpides);
        obj_data.put('target', r1.target);
        obj_data.put('mtrfinish', r1.mtrfinish);
        obj_data.put('pctwgt', r1.pctwgt);
        obj_data.put('targtstr', to_char(r1.targtstr,'dd/mm/yyyy'));
        obj_data.put('targtend', to_char(r1.targtend,'dd/mm/yyyy'));
        obj_table.put(to_char(v_row),obj_data);
        v_row := v_row+1;
    end loop;
    
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('detail', obj_detail);
    obj_data.put('table', obj_table);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms47u_detail;

   -- OT.
  procedure hrms47u_kpiPopup (json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    obj_detail   json_object_t;
    obj_table1   json_object_t;
    obj_table2   json_object_t;
    v_seq        number := 0;
    v_dteworkst  date;
    v_dteworken  date;
    v_dtework    date;
    v_typot      tovrtime.typot%type;
    v_ot_time    varchar2(100 char);
    v_ttotreq    ttotreq%rowtype ;
    v_rcnt       number;

    cursor c_tkpireq4 is
        select *
          from tkpireq4
         where codempid = p_codempid
           and dtereq = to_date(p_dtereq,'ddmmyyyy')
           and numseq = p_numseq
           and codkpi = p_codkpi
      order by score desc;

    cursor c_tkpireq3 is
        select *
          from tkpireq3
         where codempid = p_codempid
           and dtereq = to_date(p_dtereq,'ddmmyyyy')
           and numseq = p_numseq
           and codkpi = p_codkpi
      order by planno;

  begin
    initial_value (json_str_input);
    
    v_seq := 0;
    obj_table1 := json_object_t();
    for r1 in c_tkpireq4 loop
        v_seq       := v_seq + 1 ;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('color', '<i class=''fas fa-circle'' style=''color: '||r1.color||';''></i>');
        obj_data.put('grade', r1.grade);
        obj_data.put('desgrade', r1.desgrade);
        obj_data.put('score', r1.score);
        obj_data.put('kpides', r1.kpides);
        obj_data.put('stakpi', get_tlistval_name('STAKPI',r1.stakpi,global_v_lang));
        obj_table1.put(to_char(v_seq-1),obj_data);
    end loop;
    
    v_seq := 0;
    obj_table2 := json_object_t();
    for r2 in c_tkpireq3 loop
        v_seq       := v_seq + 1 ;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('plandes', r2.plandes);
        obj_data.put('targtstr', to_char(r2.targtstr,'dd/mm/yyyy'));
        obj_data.put('targtend', to_char(r2.targtend,'dd/mm/yyyy'));
        obj_table2.put(to_char(v_seq-1),obj_data);
    end loop;
    
    obj_detail := json_object_t();
    obj_detail.put('coderror', '200');
    obj_detail.put('tab1', obj_table1);
    obj_detail.put('tab2', obj_table2);
    json_str_output := obj_detail.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms47u_kpiPopup;


  PROCEDURE insert_data  (p_tkpireq   in tkpireq%rowtype,
                        p_codappr   in varchar2,
                        p_dteappr   in date,
                        p_coduser   in varchar2,
                        p_lang      in varchar2) is

    v_count     number := 0;

    cursor c_tkpireq2 is
        select *
          from tkpireq2
         where codempid = p_tkpireq.codempid
           and dtereq = p_tkpireq.dtereq
           and numseq = p_tkpireq.numseq
      order by codkpi;

    cursor c_tkpireq4 is
        select *
          from tkpireq4
         where codempid = p_tkpireq.codempid
           and dtereq = p_tkpireq.dtereq
           and numseq = p_tkpireq.numseq
      order by codkpi,score desc;

    cursor c_tkpireq3 is
        select *
          from tkpireq3
         where codempid = p_tkpireq.codempid
           and dtereq = p_tkpireq.dtereq
           and numseq = p_tkpireq.numseq
      order by planno;

  BEGIN
    
    begin
        insert into tobjemp(dteyreap,numtime,codempid,codcomp,
                            objective,dtecreate,codcreate,dteupd,coduser)
                      values(p_tkpireq.dteyreap,p_tkpireq.numtime,p_tkpireq.codempid,p_tkpireq.codcomp,
                             p_tkpireq.objective,sysdate,p_codappr,sysdate,p_codappr);    
    exception when dup_val_on_index then
        update tobjemp
           set codcomp = p_tkpireq.codcomp,
               objective = p_tkpireq.objective,
               dteupd = sysdate,
               coduser = p_codappr
         where dteyreap = p_tkpireq.dteyreap
           and numtime = p_tkpireq.numtime
           and codempid = p_tkpireq.codempid;
    end;

    for r1 in c_tkpireq2 loop
        begin
            insert into tkpiemp(dteyreap,numtime,codempid,codkpi,typkpi,
                                kpides,target,mtrfinish,pctwgt,targtstr,
                                targtend,grade,qtyscor,qtyscorn,
                                achieve,mtrrn,codcomp,codpos,
                                dtecreate,codcreate,dteupd,coduser)
                          values(r1.dteyreap,r1.numtime,r1.codempid,r1.codkpi,r1.typkpi,
                                 r1.kpides,r1.target,r1.mtrfinish,r1.pctwgt,r1.targtstr,
                                 r1.targtend,r1.grade,r1.qtyscor,r1.qtyscorn,
                                 r1.achieve,r1.mtrrn,r1.codcomp,r1.codpos,
                                 sysdate,global_v_coduser,sysdate,global_v_coduser);    
        exception when dup_val_on_index then
            update tkpiemp
               set typkpi = r1.typkpi,
                   kpides = r1.kpides,
                   target = r1.target,
                   mtrfinish = r1.mtrfinish,
                   pctwgt = r1.pctwgt,
                   targtstr = r1.targtstr,
                   targtend = r1.targtend,
                   grade = r1.grade,
                   qtyscor = r1.qtyscor,
                   qtyscorn = r1.qtyscorn,
                   achieve = r1.achieve,
                   mtrrn = r1.mtrrn,
                   codcomp = r1.codcomp,
                   codpos = r1.codpos,
                   dteupd = sysdate,
                   coduser = p_codappr
             where dteyreap = r1.dteyreap
               and numtime = r1.numtime
               and codempid = r1.codempid
               and codkpi = r1.codkpi;
        end;
    end loop; -- for r_tkpireq2
    
    for r2 in c_tkpireq4 loop
        null;
        begin
            insert into tkpiempg(dteyreap,numtime,codempid,codkpi,
                                 grade,desgrade,score,color,kpides,stakpi,
                                 dtecreate,codcreate,dteupd,coduser)
                          values(r2.dteyreap,r2.numtime,r2.codempid,r2.codkpi,
                                 r2.grade,r2.desgrade,r2.score,r2.color,r2.kpides,r2.stakpi,
                                 sysdate,global_v_coduser,sysdate,global_v_coduser);    
        exception when dup_val_on_index then
            update tkpiempg
               set desgrade = r2.desgrade,
                   score = r2.score,
                   color = r2.color,
                   kpides = r2.kpides,
                   stakpi = r2.stakpi,
                   dteupd = sysdate,
                   coduser = p_codappr
             where dteyreap = r2.dteyreap
               and numtime = r2.numtime
               and codempid = r2.codempid
               and codkpi = r2.codkpi
               and grade = r2.grade;
        end;
    end loop; -- for r_tkpireq2
    
    for r3 in c_tkpireq3 loop
        null;
        begin
            insert into tkpiemppl(dteyreap,numtime,codempid,codkpi,planno,
                                  plandes,targtstr,targtend,dtewstr,dtewend,workdesc,
                                  dtecreate,codcreate,dteupd,coduser)
                          values(r3.dteyreap,r3.numtime,r3.codempid,r3.codkpi,r3.planno,
                                 r3.plandes,r3.targtstr,r3.targtend,r3.dtewstr,r3.dtewend,r3.workdesc,
                                 sysdate,global_v_coduser,sysdate,global_v_coduser);    
        exception when dup_val_on_index then
            update tkpiemppl
               set plandes = r3.plandes,
                   targtstr = r3.targtstr,
                   targtend = r3.targtend,
                   dtewstr = r3.dtewstr,
                   dtewend = r3.dtewend,
                   workdesc = r3.workdesc,
                   dteupd = sysdate,
                   coduser = p_codappr
             where dteyreap = r3.dteyreap
               and numtime = r3.numtime
               and codempid = r3.codempid
               and codkpi = r3.codkpi
               and planno = r3.planno;
        end;
    end loop; -- for r_tkpireq2

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
    v_tkpireq   tkpireq%ROWTYPE;
    v_approvno  NUMBER := NULL;
    ap_approvno NUMBER := NULL;
    v_count     number := 0;
    v_staappr   varchar2(1 char);
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

    begin
          select *   
          into v_tkpireq
          from  tkpireq
          where codempid =  rq_codempid
          and   dtereq   =  rq_dtereq
          and   numseq   =  rq_seqno;
    exception when others then
          v_tkpireq :=  null;
    end;

    begin
      select approvno into v_max_approv
      from   twkflowh
      where  routeno = v_tkpireq.routeno ;
    exception when no_data_found then
      v_max_approv := 0 ;
    end ;

    if v_tkpireq.staappr <> 'Y' then
      ap_approvno :=  v_appseq;

      -- Step 2 => Insert Table Request Detail
      begin
        select  count(*)   into  v_count
          from  tapkpirq
         where  codempid = rq_codempid
           and  dtereq   = rq_dtereq
           and  numseq   = rq_seqno
           and  approvno = ap_approvno;
      exception when no_data_found then
        v_count := 0;
      end;

      if v_count = 0 then
          insert into
             tapkpirq(
                      codempid,dtereq,numseq,approvno,
                      codappr,dteappr,staappr,
                      remark,coduser,dteapph,codcreate
                      )
          values
                      (
                      rq_codempid,rq_dtereq,rq_seqno, ap_approvno,
                      p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),v_staappr,
                      v_remark,p_coduser,sysdate,p_coduser
                      );
      else
              update tapkpirq
                 set codappr  = p_codappr,
                     dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
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
      v_routeno   := v_tkpireq.routeno ;

      chk_workflow.find_next_approve('HRES17E',v_routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);

      if v_staappr = 'A' and rq_chk <> 'E' then
        loop
          v_approv := chk_workflow.check_next_step('HRES17E',v_tkpireq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
          if  v_approv is not null then
            v_remark   := v_desc;
            v_approvno := v_approvno + 1 ;
            v_codeappr := v_approv ;
            begin
              select  count(*) into v_count
               from   tapkpirq
               where  codempid = rq_codempid
               and    dtereq   = rq_dtereq
               and    numseq   = rq_seqno
               and    approvno = v_approvno;
            exception when no_data_found then  v_count := 0;
            end;
            if v_count = 0 then
              insert into  tapkpirq
                    (codempid,dtereq,numseq,approvno,codappr,dteappr,staappr,
                    remark,coduser,dteapph,codcreate)
              values(rq_codempid,rq_dtereq,rq_seqno,v_approvno,
                     v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),'a',
                     v_remark,p_coduser,sysdate,p_coduser
                     );
            else
              update tapkpirq
                 set codappr   = v_codeappr,
                     dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                     staappr   = 'A',
                     remark    =  v_remark,
                     coduser   = p_coduser,
                     dteapph   = sysdate 
                where codempid = rq_codempid
                  and dtereq   = rq_dtereq
                  and numseq   = rq_seqno
                  and approvno = v_approvno;
            end if;
            chk_workflow.find_next_approve('HRES17E',v_routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
          else
            exit ;
          end if;
        end loop ;

        update tkpireq set  approvno  = v_approvno,
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
        insert_data(v_tkpireq,v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),-- user22 : 04/07/2016 : STA4590287 || v_numotreq,p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),
                   p_coduser,p_lang);
      end if;

      update tkpireq
      set 
          staappr   = v_staappr,
          codappr   = v_codeappr,
          approvno  = v_approvno,
          dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
          remarkap  = v_remark,
          dteapph   = sysdate,
          coduser   = p_coduser
      where codempid = rq_codempid
        and dtereq   = rq_dtereq
        and numseq   = rq_seqno;

      commit;

      begin
        select rowid into  v_row_id
         from tkpireq
        where codempid =  rq_codempid
          and dtereq   =  rq_dtereq
          and numseq   =  rq_seqno ;
      exception when others then
       v_row_id :=  null ;
      end ;

      --sendnmail
      chk_workflow.sendmail_to_approve( p_codapp        => 'HRES17E',
                                        p_codtable_req  => 'tkpireq',
                                        p_rowid_req     => v_row_id,
                                        p_codtable_appr => 'tapkpirq',
                                        p_codempid      => rq_codempid,
                                        p_dtereq        => rq_dtereq,
                                        p_seqno         => rq_seqno,
                                        p_staappr       => v_staappr,
                                        p_approvno      => v_approvno,
                                        p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                        p_subject_mail_numseq  => '210',
                                        p_lang          => global_v_lang,
                                        p_coduser       => global_v_coduser);
    end if;
  exception when others then
     rollback;
     param_msg_error := sqlerrm;
  end;  -- Procedure Approve
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
      approve(global_v_coduser,global_v_lang,to_char(v_rowcount),v_staappr,p_remark_appr,p_remark_not_appr,to_char(sysdate,'dd/mm/yyyy'),v_appseq,v_chk,v_codempid,v_seqno,v_dtereq);
    end loop;
    if param_msg_error is not null then
      rollback;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    elsif param_msg_error is not null then
      rollback;
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;   
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end process_approve;
end;

/
