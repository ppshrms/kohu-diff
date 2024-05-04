--------------------------------------------------------
--  DDL for Package Body HRMSS5U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMSS5U" is
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
    p_dtest             := hcm_util.get_string_t(json_obj,'p_dtest');
    p_dteen             := hcm_util.get_string_t(json_obj,'p_dteen');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    
    p_dtereq           := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereq')),'dd/mm/yyyy');
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
  end;

  procedure gen_index (json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_chk        varchar2(4 char);
    v_date       varchar2(10 char);
    v_codappr    varchar2(50 char);
    v_codpos     varchar2(4 char);
    v_dtest      date ;
    v_dteen      date ;
    v_nextappr   varchar2(1000 char);
    v_appno      varchar2(100 char);
    v_row        number := 0;

    CURSOR c_HRMSS5U_c1 IS
     select codempid,dtereq,numseq,codappr,a.approvno
            appno,codcomp,codpos,
            get_temploy_name(codempid,global_v_lang) ename,staappr,
            get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
            dtestart,b.approvno qtyapp,dteappr,remarkap
       from  tircreq a ,twkflowh b
       where  staappr  in ('P','A')
        AND  ('Y' = chk_workflow.check_privilege('HRESS4E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
            -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                        from   twkflowde c
                                                        where  c.routeno  = a.routeno
                                                        and    c.codempid = v_codappr)
                   and    ((sysdate - nvl(dteapph,dteinput))*1440) >= (select  hrtotal  from twkflpf where codapp ='HRESS4E')))
        and a.routeno = b.routeno
        and (a.codempid = nvl(p_codempid,a.codempid) or lower(get_temploy_name(a.codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
        ORDER BY  codempid,dtereq,numseq;


   CURSOR c_HRMSS5U_c2 IS
    select codempid,dtereq,numseq,codappr,approvno,codcomp,codpos,
            get_temploy_name(codempid,global_v_lang) ename,staappr,dteappr,remarkap,
            get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
            dtestart
    from tircreq
    where (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
      and (codempid ,dtereq,numseq) in
                               ( select codempid,dtereq,numseq
                                   from tapempch
                                  where staappr = decode(p_staappr,'Y','A',p_staappr)
                                    and typreq  = 'HRESS4E'
                                    and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
      order by  codempid,dtereq,numseq;
   
  begin
    
    v_codappr  := pdk.check_codempid(global_v_coduser);
    v_dtest    := to_date(replace(p_dtest,'/',null),'ddmmyyyy');
    v_dteen    := to_date(replace(p_dteen,'/',null),'ddmmyyyy');
    -- default value --
    obj_row := json_object_t();
    v_row   := 0;
      -- get data
      
   if p_staappr = 'P' then
      for r1 in c_HRMSS5U_c1 loop
      
      v_appno  := nvl(r1.appno,0) + 1;
          IF nvl(r1.appno,0)+1 = r1.qtyapp THEN
             v_chk := 'E' ;
          end if;
          
          begin
            select codpos into v_codpos
             from temploy1
            where codempid = r1.codempid;
          exception when no_data_found then
            v_codpos := '';
          end;
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
        obj_data.put('desc_codpos_temploy1', get_tpostn_name(v_codpos,global_v_lang));
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('status', r1.status);
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));        
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark', r1.remarkap);
        obj_data.put('codappr', ' ');       
        obj_data.put('desc_codempap', get_temploy_name(global_v_codempid,global_v_lang));
        obj_data.put('staappr', r1.staappr);  
        obj_row.put(to_char(v_row),obj_data);
        v_row := v_row+1;     
        end loop;  
    else
        for r1 in c_HRMSS5U_c2 loop
           v_date := to_char(r1.dtereq ,'DD/MM/YYYY');
            begin
                select codpos into v_codpos
                  from temploy1
                 where codempid = r1.codempid;
            exception when no_data_found then
                v_codpos := '';
            end;
              --
            v_nextappr := null;
            if r1.staappr = 'A' then
                v_nextappr := chk_workflow.get_next_approve('HRESS4E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
            end if;
            --
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('approvno', v_appno);
            obj_data.put('chk_appr', v_chk);
            obj_data.put('image', get_emp_img(r1.codempid));
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', r1.ename);
            obj_data.put('dtereq', v_date);
            obj_data.put('numseq', r1.numseq);        
            obj_data.put('desc_codpos_temploy1', get_tpostn_name(v_codpos,global_v_lang));
            obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
            obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
            obj_data.put('status', r1.status);
            obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));        
            obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
            obj_data.put('remark', r1.remarkap);
            obj_data.put('codappr', ' ');       
            obj_data.put('desc_codempap', v_nextappr);
            obj_data.put('staappr', r1.staappr); 
            obj_row.put(to_char(v_row),obj_data);
            v_row := v_row+1;                              
        end loop;
      end if;  
       
    json_str_output := obj_row.to_clob;   
 
  end;
  
  procedure get_index (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  
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
    v_codapp    varchar2(8 char)    := 'HRESS4E';
    v_flag      varchar2(1 char)    := 'Y';
    rq_codempid varchar2(10 char)   := p_codempid;
    rq_dtereq   date                := to_date(p_dtereq,'dd/mm/yyyy');
    rq_seqno    number              := p_seqno;
    v_appseq    number              := p_appseq;
    rq_chk      varchar2(1 char)    := p_chk;
    v_tircreq   tircreq%rowtype;
    v_approvno  number              := 0;
    ap_approvno number              := 0;
    v_count     number              := 0;
    v_staappr   varchar2(1 char);
    p_codappr   temploy1.codempid%type := pdk.check_codempid(p_coduser);
    v_codeappr  temploy1.codempid%type;
    v_codpos    temploy1.codpos%type;
    v_codcomp   temploy1.codcomp%type;
    v_approv    varchar2(10 char);
    v_desc      varchar2(600 char) := get_label_name('HCM_APPRFLW',global_v_lang,10);
    v_codempap  temploy1.codempid%type;
    v_routeno   varchar2(15 char);
    v_remark    varchar2(7000 char);
    v_max_approv number;
    v_row_id     varchar2(200 char);

begin
    if v_staappr = 'A' then
      v_remark := p_remark_appr;
    elsif v_staappr = 'N' then
      v_remark := p_remark_not_appr;
    end if;
    v_remark  := replace(v_remark,'.',chr(13));
    v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');
    -- Step 1 => Check Data
    begin
         select *
           into  v_tircreq
           from  tircreq
          where  codempid  = rq_codempid
            and   dtereq   = rq_dtereq
            and   numseq   = rq_seqno;
        exception when others then
         v_tircreq :=       null ;
    end ;
  
    begin
        select approvno into v_max_approv
          from   twkflowh
         where  routeno = v_tircreq.routeno ;
      exception when no_data_found then
          v_max_approv := 0 ;
    end ;   

   if v_tircreq.staappr <> 'Y' then
    ap_approvno :=  v_appseq ;
    if to_date(p_dteappr,'dd/mm/yyyy') > trunc(sysdate) then
        IF v_flag = 'Y' THEN
          pdk.error_approve('HR2020',null,'datebox',p_lang);
          v_flag := 'N';
         END IF;
    end if;
    if to_date(p_dteappr,'dd/mm/yyyy') < v_tircreq.dtereq then
        IF v_flag = 'Y' THEN
          pdk.error_approve('ES0045',null,'datebox',p_lang);
          v_flag := 'N';
        END IF;
    end if;
    -- End Check Data    
    
    begin
      select count(*) into v_count
        from tapempch
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and numseq   = rq_seqno
         and typreq   = v_codapp
         and approvno = ap_approvno;
    exception when no_data_found then
      v_count := 0;
    end;

    -- Step 2 => Insert Table Request Detail
    if v_count = 0 then
            insert into tapempch
                                (
                                 codempid,dtereq,numseq,typreq,
                                 approvno,codappr,dteappr,
                                 staappr,remark,coduser,codcreate,dteapph
                                 )
                        values
                                (
                                 rq_codempid,rq_dtereq,rq_seqno,v_codapp,
                                 ap_approvno,p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),
                                 p_status,v_remark,p_coduser,p_coduser,sysdate);
    else
        update tapempch set codappr   = p_codappr,
                            dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                            staappr   = p_status,
                            remark    = v_remark ,
                            coduser   = p_coduser,
                            dteapph   = sysdate 
            where codempid = rq_codempid
              and dtereq   = rq_dtereq
              and numseq   = rq_seqno
              and typreq   = v_codapp
              and approvno = ap_approvno;
    end if;

    -- Step 3 => Check Next Step
    v_codeappr  :=  p_codappr ;
    v_approvno  :=  ap_approvno;
    v_codempap  :=  p_codappr;
    chk_workflow.find_next_approve(v_codapp,v_tircreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,ap_approvno,p_codappr,null);
    IF  p_status = 'A' and rq_chk <> 'E'   THEN
       loop
           v_approv := chk_workflow.check_next_step(v_codapp,v_tircreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
           if  v_approv is not null then
           	   v_remark   := v_desc; -- user22 : 04/07/2016 : STA4590287 || 
               v_approvno := v_approvno + 1 ;
               v_codeappr := v_approv ;
                begin
                  select count(*) into v_count
                    from tapempch
                   where codempid = rq_codempid
                     and dtereq   = rq_dtereq
                     and numseq   = rq_seqno
                     and typreq   = v_codapp
                     and approvno = v_approvno;
                exception when no_data_found then
                  v_count := 0;
                end;
                if v_count = 0 then
                        insert into tapempch
                                            (
                                             codempid,dtereq,numseq,typreq,
                                             approvno,codappr,dteappr,
                                             staappr,remark,coduser,codcreate,dteapph                                             
                                             )
                                    values
                                            (
                                             rq_codempid,rq_dtereq,rq_seqno,v_codapp,
                                             v_approvno,v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),
                                             p_status,v_remark,p_coduser,p_coduser,sysdate
                                            );
                else
                    update tapempch set codappr   = v_codeappr,
                                        dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                                        staappr   = p_status,
                                        remark    = v_remark,
                                        coduser   = p_coduser,
                                        dteapph   = sysdate
                        where codempid = rq_codempid
                          and dtereq   = rq_dtereq
                          and numseq   = rq_seqno
                          and typreq   = v_codapp
                          and approvno = v_approvno;
                end if;
                chk_workflow.find_next_approve(v_codapp,v_tircreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);-- user22 : 04/07/2016 : STA4590287 || v_approv := chk_workflow.Check_Next_Approve(v_codapp,v_tircreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
           else
             exit ;
           end if;
         end loop ;
           
         update tircreq
            set   staappr   = v_staappr,
                  codappr   = v_codeappr,
                  approvno  = v_approvno,
                  dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                  remarkap  = v_remark ,
                  coduser   = p_coduser,
                  dteapph   = sysdate
            where codempid = rq_codempid
              and dtereq   = rq_dtereq
              and numseq   = rq_seqno;
    end if;
    -- End Check Next Step

    -- Step 4 => Update Table Request and Insert Transaction
    v_staappr := p_status ;
    if v_max_approv = v_approvno then
      rq_chk := 'E' ;
    end if; 

    if rq_chk = 'E' and p_status = 'A' then
       v_staappr := 'Y';
    end if;

    update tircreq
    set   staappr   = v_staappr,
          codappr   = v_codeappr,
          approvno  = v_approvno,
          dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
          remarkap  = v_remark ,
          coduser   = p_coduser,
          dteapph   = sysdate
    where codempid = rq_codempid
      and dtereq   = rq_dtereq
      and numseq   = rq_seqno;

    begin
     select *
     into  v_tircreq
     from  tircreq
     where codempid = rq_codempid
     and   dtereq   = rq_dtereq
     and   numseq   = rq_seqno;
    exception when others then
     v_tircreq :=       null ;
    end ;

    if rq_chk = 'E' and p_status = 'A' then
        begin
         select count(*)
         into   v_count
         from   tappeinf
         where  codempid = rq_codempid
           and  dtereq   = rq_dtereq
           and  codcomp  = v_tircreq.codcomp
           and  codpos   = v_tircreq.codpos
           and  numreqst = v_tircreq.numreqst;
        exception when no_data_found then
            v_count := 0;
        end;

       begin
         select codpos,codcomp
         into   v_codpos,v_codcomp
         from   temploy1
         where  codempid = rq_codempid;
        exception when no_data_found then
            v_codpos  := null;
            v_codcomp := null;
        end;

        if v_count  = 0 then
            insert into tappeinf
                                (codempid,dtereq,numreqst,codcomp,codpos,codbrlc,codcompe,codpose,codjob,
                                 dtestrt,codappr,dteappr,
                                 status,numreqrq,codposrq,
                                 coduser,codcreate
                                 )
                    values       (rq_codempid,rq_dtereq,v_tircreq.numreqst,v_tircreq.codcomp,v_tircreq.codpos,null,v_codcomp,v_codpos,null,
                                  v_tircreq.dtestart,v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),
                                  'P',null,v_tircreq.codpos,
                                  p_coduser,p_coduser
                                 );
        else
             update tappeinf set
                                codappr = v_codeappr,
                                dteappr = to_date(p_dteappr,'dd/mm/yyyy'),
                                coduser = p_coduser
                 where  codempid = rq_codempid
                   and  codcomp  = v_tircreq.codcomp
                   and  codpos   = v_tircreq.codpos
                   and  dtestrt  = v_tircreq.dtestart;
         end if;
         null;
    end if;

     update   tircreq
        set   staappr   = v_staappr,
              codappr   = v_codeappr,
              approvno  = v_approvno,
              dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
              remarkap  = v_remark ,
              coduser   = p_coduser,
              dteapph   = sysdate
        where codempid = rq_codempid
          and dtereq   = rq_dtereq
          and numseq   = rq_seqno;
        commit ;
        
    -- Step 5 => Send Mail
        begin
         select rowid
           into v_row_id
           from tircreq
          where codempid = rq_codempid
            and dtereq   = rq_dtereq
            and numseq   = rq_seqno;
        exception when others then
         v_tircreq :=       null ;
        end ;
        
      --sendmail
      begin 
        chk_workflow.sendmail_to_approve( p_codapp        => 'HRESS4E',
                                          p_codtable_req  => 'tircreq',
                                          p_rowid_req     => v_row_id,
                                          p_codtable_appr => 'tapempch',
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
  
    end if;--if v_tircreq.staappr <> 'Y' then
  exception when others then
    rollback;
    param_msg_error := sqlerrm;
  END;  -- Procedure Approve
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
  
  procedure gen_detail(json_str_output out clob) is
    obj_data        json_object_t;
    obj_row         json_object_t;
    obj_result      json_object_t;
    obj_tab         json_object_t;
    obj_tab1        json_object_t;
    obj_temp        json_object_t;
    obj_syncond     json_object_t;
    v_rcnt          number;
    v_job_remark    tjobcode.statement%type;
    v_namjob        tjobcode.namjobe%type;
    v_syncond       tjobcode.syncond%type;
    v_codpos        treqest2.codpos%type;
    v_codjob        treqest2.codjob%type;
    v_numreqst      treqest2.numreqst%type;
    
    v_codcomp       tircreq.codcomp%type;
    v_remarks       tircreq.remarks%type;
    v_dtestart      tircreq.dtestart%type;
    
    cursor c1 is
      select b.numreqst,b.codpos,b.codcomp,b.codjob,b.dteopen,b.qtyreq,b.codbrlc,
             b.dteclose,b.desnote,syncond,statement,flgcond,flgjob,a.desnote remarks
        from  treqest2 b,treqest1 a
        where b.numreqst = v_numreqst
          and b.codpos = v_codpos
          and b.numreqst = a.numreqst;
          
    cursor c2 is
      select decode(global_v_lang,'101', namjobe ,
                                 '102', namjobt,
                                 '103', namjob3,
                                 '104', namjob4,
                                 '105', namjob5,namjobe) namjob,desjob,amtcolla,
                                 qtyguar,syncond,statement
        from  tjobcode
        where codjob = v_codjob;
        
     cursor c3 is
      select itemno,namitem,descrip
        from  tjobdet
        where codjob = v_codjob
        order by itemno;
        
     cursor c4 is
      select itemno,namitem,descrip
        from  tjobresp
        where codjob = v_codjob
       order by itemno;
        
    cursor c5 is
      select codedlv,codmajsb,numgpa
        from  tjobeduc
        where codjob = v_codjob
      order by seqno;
      
    
  begin
  
   obj_tab := json_object_t();
   obj_tab1 := json_object_t();
   
   begin
    select codcomp,codpos,codjob,remarks,dtestart,numreqst
      into v_codcomp,v_codpos,v_codjob,v_remarks,v_dtestart,v_numreqst
      from tircreq
     where codempid = p_codempid
       and dtereq = p_dtereq
       and numseq = p_numseq;
   exception when no_data_found then
   v_codcomp := null;
   v_codpos := null;
   v_codjob := null;
   v_remarks := null;
   v_dtestart := null;
   end;
   obj_tab1.put('codcomp', v_codcomp);
   obj_tab1.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang));
   obj_tab1.put('codpos', v_codpos);
   obj_tab1.put('desc_codpos',  get_tpostn_name(v_codpos,global_v_lang));
   obj_tab1.put('codjob', v_codjob);
   obj_tab1.put('desc_codjob', get_tjobcode_name(v_codjob,global_v_lang));
   obj_tab1.put('remarks', v_remarks);
   obj_tab1.put('dtestart', to_char(v_dtestart,'dd/mm/yyyy'));
   
    
    obj_result := json_object_t();
    obj_result.put('coderror', 200);
    obj_data := json_object_t();
    
    for r1 in c1 loop
    
    begin 
      select statement ,decode(global_v_lang,'101', namjobe ,
                                 '102', namjobt,
                                 '103', namjob3,
                                 '104', namjob4,
                                 '105', namjob5,namjobe) namjob
      into v_job_remark,v_namjob
      from tjobcode
      where codjob = r1.codjob;
    exception when no_data_found then
      v_job_remark := null;
    end;
    
    if r1.flgjob = 'Y' then
      v_syncond := get_logical_desc(v_job_remark);
    end if;
    
    if r1.flgcond = 'Y' then
      v_syncond := get_logical_desc(r1.statement);
    end if;
    
     obj_data.put('coderror', 200);
      obj_data.put('numreqst', r1.numreqst);
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('codjob', r1.codjob);
      obj_data.put('desc_codjob', v_namjob);
      obj_data.put('companyold', get_tcodec_name('tcodloca',r1.codbrlc,global_v_lang));
      obj_data.put('desnote', r1.desnote);
      obj_data.put('remark', r1.remarks);
      obj_data.put('syncond',v_syncond); 
    end loop;
    obj_result.put('treqest2', obj_data);
    
    obj_data := json_object_t();
    for r2 in c2 loop
      obj_data.put('coderror', 200);
      obj_data.put('namjob', r2.namjob);
      obj_data.put('desjob', r2.desjob);
      obj_data.put('amtcolla', to_char(r2.amtcolla,'fm999,999,999,990.00'));
      obj_data.put('qtyguar', r2.qtyguar);
      obj_data.put('syncond',get_logical_desc(r2.statement)); 
    end loop;
    obj_result.put('tjobcode', obj_data);
    
    obj_row  := json_object_t();
    obj_data := json_object_t();
    obj_temp := json_object_t();
    v_rcnt := 0;
    for r3 in c3 loop
      v_rcnt := v_rcnt + 1;
      obj_data.put('coderror', 200);
      obj_data.put('itemno', r3.itemno);
      obj_data.put('namitem', r3.namitem);
      obj_data.put('descrip', r3.descrip);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    obj_temp.put('rows', obj_row);
    obj_result.put('tjobdet', obj_temp);
    
    obj_row  := json_object_t();
    obj_data := json_object_t();
    obj_temp := json_object_t();
    v_rcnt := 0;
    for r4 in c4 loop
      v_rcnt := v_rcnt + 1;
      obj_data.put('coderror', 200);
      obj_data.put('itemno', r4.itemno);
      obj_data.put('namitem', r4.namitem);
      obj_data.put('descrip', r4.descrip);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    obj_temp.put('rows', obj_row);
    obj_result.put('tjobresp', obj_temp);
    
    obj_row  := json_object_t();
    obj_data := json_object_t();
    obj_temp := json_object_t();
    v_rcnt := 0;
    for r5 in c5 loop
      v_rcnt := v_rcnt + 1;
      obj_data.put('coderror', 200);
      obj_data.put('codedlv', r5.codedlv);
      obj_data.put('desc_codedlv', get_tcodec_name('TCODEDUC',r5.codedlv,global_v_lang));
      obj_data.put('codmajsb', r5.codmajsb);
      obj_data.put('desc_codmajsb', get_tcodec_name('TCODMAJR',r5.codmajsb,global_v_lang));
      obj_data.put('numgpa', r5.numgpa);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;
    obj_temp.put('rows', obj_row);
    obj_result.put('tjobeduc', obj_temp);
    
    
    obj_tab.put('coderror', 200);
    obj_tab.put('tab1', obj_tab1);
    obj_tab.put('tab2', obj_result);
    
    
    json_str_output := obj_tab.to_clob;
  end;
  
  procedure get_detail (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_detail(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
end;

/
