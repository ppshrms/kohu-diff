--------------------------------------------------------
--  DDL for Package Body HRMS72U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS72U" is
-- last update: 13/02/2023 19:18 //STT-SS2101-redmine-752

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
    p_approvno          := hcm_util.get_string_t(json_obj,'p_approvno');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    --
    p_dtereq            := hcm_util.get_string_t(json_obj,'p_dtereq');
    p_seqno             := hcm_util.get_string_t(json_obj,'p_numseq');
    p_dtereqr           := hcm_util.get_string_t(json_obj,'p_dtereqr');
    -- submit approve
--    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
--    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
  end;

  procedure HRMS72U (json_str_input in clob, json_str_output out clob) is
    obj_data      json_object_t;
    obj_row       json_object_t;
    v_codappr     temploy1.codempid%type;
    v_codpos      tpostn.codpos%type;
    v_typpayroll  temploy1.typpayroll%type;
    v_nextappr    varchar2(1000 char);
    v_dtest       date;
    v_dteen       date;
    v_rcnt        number;
    v_appno       varchar2(100 char);
    v_chk         varchar2(100 char) := ' ';
    v_row         number := 0;
    -- check null data --
    v_flg_exist   boolean := false;

/*
cursor c_HRMS72U_c1 is
     select dtereq,numseq,codempid,codappr,a.approvno appno,codcomp ,
             get_temploy_name(codempid,global_v_lang) ename,staappr,
             get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
             amtexp,amtalw,b.approvno qtyapp,dteappr,remarkap,typpatient,codrel
       from  tmedreq a,twkflowh b
       where   (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
       and   staappr in ('P','A')
        and a.routeno = b.routeno
        order by codempid,dtereq,numseq;
*/


cursor c_HRMS72U_c1 is
     select dtereq,numseq,codempid,codappr,a.approvno appno,codcomp ,
             get_temploy_name(codempid,global_v_lang) ename,staappr,
             get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
             amtexp,amtalw,b.approvno qtyapp,dteappr,remarkap,typpatient,codrel
       from  tmedreq a,twkflowh b
--       where codcomp like p_codcomp||'%'
       where   (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
       and   staappr in ('P','A')
       AND   ('Y' = chk_workflow.check_privilege('HRES71E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
        -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                        from   twkflowde c
                                                        where  c.routeno  = a.routeno
                                                        and    c.codempid = v_codappr)
              and (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES71E')))
        and a.routeno = b.routeno
        order by codempid,dtereq,numseq;

cursor c_HRMS72U_c2 is
   select dtereq,numseq,codempid,approvno,codcomp ,
           get_temploy_name(codempid,global_v_lang) ename,staappr,
           get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
           amtexp,amtalw,codappr,dteappr,remarkap,
           typpatient,codrel
    from  tmedreq
    where   (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
    and   (codempid ,dtereq,numseq) in
                    (select codempid, dtereq,numseq
                       from tapmedrq
                      where staappr = decode(p_staappr,'Y','A',p_staappr)
                        and codappr = v_codappr
                        and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
     order by codempid,dtereq,numseq;

  begin
    initial_value(json_str_input);
    v_codappr := pdk.check_codempid(global_v_coduser); --
    v_dtest   := to_date(replace(p_dtest,'/',null),'ddmmyyyy');
    v_dteen   := to_date(replace(p_dteen,'/',null),'ddmmyyyy');
    -- default value --
    obj_row := json_object_t();
    v_row   := 0;
    -- get data
    if p_staappr = 'P' then
      for r1 in c_HRMS72U_c1 loop
        v_appno  := nvl(r1.appno,0) + 1;
        if nvl(r1.appno,0)+1 = r1.qtyapp then
           v_chk := 'E' ;
        else
           v_chk := v_appno ;
        end if;
        --
        begin
            select codpos,typpayroll
              into v_codpos,v_typpayroll
              from temploy1
             where codempid = r1.codempid;
         exception when no_data_found then
            v_codpos        := null;
            v_typpayroll    := null;
        end;
          --
        v_row    := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno', v_appno);
        obj_data.put('chk_appr', v_chk);
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('desc_typpayroll', get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq', to_char(r1.numseq));
        obj_data.put('amtreq', to_char(r1.amtexp,'fm999,999,990.00'));
        obj_data.put('amtalw', to_char(r1.amtalw,'fm999,999,990.00'));
        obj_data.put('status', r1.status);
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remarkap', r1.remarkap);
        obj_data.put('desc_codempap',chk_workflow.get_next_approve('HRES71E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.appno),'0'),global_v_lang));
        obj_data.put('typpayroll', v_typpayroll);
        obj_data.put('staappr', r1.staappr);
        obj_data.put('typpatient', r1.typpatient);
        obj_data.put('codrel', r1.codrel);
        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    else
      for r1 in c_HRMS72U_c2 loop
         --
         begin
            select codpos,typpayroll
              into v_codpos,v_typpayroll
              from temploy1
             where codempid = r1.codempid;
         exception when no_data_found then
            v_codpos        := null;
            v_typpayroll    := null;
        end;
        --
        v_nextappr := null;
        if r1.staappr = 'A' then
           v_nextappr := chk_workflow.get_next_approve('HRES71E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
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
        obj_data.put('typpayroll', get_tcodec_name('TCODTYPY',v_typpayroll,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq', to_char(r1.numseq));
        obj_data.put('amtreq', to_char(r1.amtexp,'fm999,999,990.00'));
        obj_data.put('amtalw', to_char(r1.amtalw,'fm999,999,990.00'));
        obj_data.put('status', r1.status);
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remarkap', r1.remarkap);
        obj_data.put('desc_codempap',v_nextappr);
        obj_data.put('typpayroll', v_typpayroll);
        obj_data.put('staappr', r1.staappr);
        obj_data.put('typpatient', r1.typpatient);
        obj_data.put('codrel', r1.codrel);
        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end HRMS72U;

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
                    p_amtalw          in number,
                    p_dteyrepay       in number,
                    p_dtemthpay       in number,
                    p_numperiod       in number,
                    p_typpay          in varchar2,
                    p_dtecash         in varchar2
                    ) is

    rq_codempid  temploy1.codempid%type := p_codempid;
    rq_dtereq    date              := to_date(p_dtereq,'dd/mm/yyyy');
    rq_seqno     number            := p_seqno;
    v_appseq     number            := p_appseq;
    rq_chk       varchar2(10 char) := p_chk;
    rec_tmedreq    tmedreq%rowtype;
    rec_tmedreqf   tmedreqf%rowtype;
    v_approvno   number := null;
    ap_approvno  number := null;
    v_count      number := 0;
    v_staappr    varchar2(1 char);
    v_codeappr   temploy1.codempid%type;
    v_approv     temploy1.codempid%type;
    v_codcomp    temploy1.codcomp%type;
    v_codpos     temploy1.codpos%type;
    v_typpayroll temploy1.typpayroll%type;
    v_desc       varchar2(600 char) := get_label_name('HCM_APPRFLW',global_v_lang,10);-- user22 : 04/07/2016 : STA4590287 || v_desc      varchar2(200 char);
    v_remark     varchar2(2000 char);
    p_codappr    temploy1.codempid%type := pdk.check_codempid(p_coduser);
    v_max_approv number;
    v_row_id     varchar2(200 char);
    v_numvcher   varchar2(30 char) := null;
    v_numseq      number;
      cursor c_tmedreqf is
        select *
          from tmedreqf
         where codempid = rq_codempid
          and dtereq = rq_dtereq
          and numseq = rq_seqno;
    begin
--      p_dteappr := to_date(p_dteappr, 'dd/mm/yyyy');
      v_staappr := p_status ;
      v_zyear   := pdk.check_year(p_lang);
      if v_staappr = 'A' then
        v_remark := p_remark_appr;
      elsif v_staappr = 'N' then
        v_remark := p_remark_not_appr;
      end if;
      v_remark  := replace(v_remark,'.',chr(13));
      v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');
      ------
     begin
       select *
         into rec_tmedreq
         from tmedreq
        where codempid = rq_codempid
          and dtereq = rq_dtereq
          and numseq = rq_seqno;
      exception when others then
          rec_tmedreq := null ;
      end ;
      begin
       select *
         into rec_tmedreqf
         from tmedreqf
        where codempid = rq_codempid
          and dtereq = rq_dtereq
          and numseq = rq_seqno;
      exception when others then
          rec_tmedreqf := null ;
      end ;
      ------
     begin
         select approvno into v_max_approv
         from   twkflowh
         where  routeno = rec_tmedreq.routeno ;
      exception when no_data_found then
         v_max_approv := 0 ;
      end ;
      -----
 -- Step 2 => Insert Table Request Detail
      IF nvl(rec_tmedreq.approvno,0) < v_appseq THEN
        ap_approvno := v_appseq ;
           begin
           select count(*)
             into  v_count
             from tapmedrq
            where codempid =  rq_codempid
              and dtereq   =  rq_dtereq
              and numseq   =  rq_seqno
              and approvno =  ap_approvno;
          exception when no_data_found then
              v_count := 0;
          end;

          if v_count = 0 then
             insert into
                 tapmedrq(codempid,dtereq,numseq,approvno,
                          amtalw,typpay,dtecash,dteyrepay,dtemthpay,numperiod,
                          codappr,dteappr,staappr,
                          remark,dtesnd,dteapph,dteupd,coduser,codcreate)
                   values(rq_codempid,rq_dtereq,rq_seqno,ap_approvno,
                          p_amtalw,p_typpay,to_date(p_dtecash, 'dd/mm/yyyy'),p_dteyrepay,p_dtemthpay,p_numperiod,
                          p_codappr,to_date(p_dteappr, 'dd/mm/yyyy'),v_staappr,
                          v_remark,sysdate,sysdate,trunc(sysdate),p_coduser,p_coduser);
          else
              update tapmedrq
                 set amtalw    = p_amtalw,
                     typpay    = p_typpay,
                     dtecash   = to_date(p_dtecash, 'dd/mm/yyyy'),
                     dteyrepay = p_dteyrepay,
                     dtemthpay = p_dtemthpay,
                     numperiod = p_numperiod,
                     codappr   = p_codappr,
                     dteappr   = to_date(p_dteappr, 'dd/mm/yyyy'),
                     staappr   = v_staappr,
                     remark    = v_remark,
                     coduser   = p_coduser,
                     dtesnd    = sysdate,
                     dteapph   = sysdate
               where codempid = rq_codempid
                 and dtereq   = rq_dtereq
                 and numseq   = rq_seqno
                 and approvno = ap_approvno;
          end if;

      -- Step 3 => Check Next Step
        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;
        chk_workflow.find_next_approve('HRES71E',rec_tmedreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,ap_approvno,p_codappr);
        if  p_status = 'A' and rq_chk <> 'E'   then
          loop
            v_approv := chk_workflow.check_next_step('HRES71E',rec_tmedreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
            if  v_approv is not null then
              v_remark   := v_desc; -- user22 : 04/07/2016 : STA4590287 ||
              v_approvno := v_approvno + 1 ;
              v_codeappr := v_approv ;
               begin
                 select  count(*)
                   into  v_count
                   from  tapmedrq
                  where  codempid = rq_codempid
                    and  dtereq   = rq_dtereq
                    and  numseq   = rq_seqno
                    and  approvno = v_approvno;
               exception when no_data_found then
               v_count := 0;
              end;

              if v_count = 0 then
                      insert into
                         tapmedrq(codempid,dtereq,numseq,approvno,
                                  amtalw,typpay,dtecash,dteyrepay,dtemthpay,numperiod,
                                  codappr,dteappr,staappr,
                                  remark,dtesnd,dteapph,dteupd,coduser,codcreate)
                           values(rq_codempid,rq_dtereq,rq_seqno, v_approvno,
                                  p_amtalw,p_typpay,to_date(p_dtecash, 'dd/mm/yyyy'),p_dteyrepay,p_dtemthpay,p_numperiod,
                                  v_codeappr,to_date(p_dteappr, 'dd/mm/yyyy'),v_staappr,
                                  v_remark,sysdate,sysdate,trunc(sysdate),p_coduser,p_coduser);
                  else
                      update tapmedrq
                         set amtalw    = p_amtalw,
                             typpay    = p_typpay,
                             dtecash   = to_date(p_dtecash, 'dd/mm/yyyy'),
                             dteyrepay = p_dteyrepay,
                             dtemthpay = p_dtemthpay,
                             numperiod = p_numperiod,
                             codappr   = p_codappr,
                             dteappr   = to_date(p_dteappr, 'dd/mm/yyyy'),
                             staappr   = v_staappr,
                             remark    = v_remark,
                             coduser   = p_coduser,
                             dtesnd    = sysdate,
                             dteapph   = sysdate
                       where codempid  = rq_codempid
                         and dtereq    = rq_dtereq
                         and numseq    = rq_seqno
                         and approvno  = v_approvno;
                  end if;
              chk_workflow.find_next_approve('HRES71E',rec_tmedreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
            else
              exit ;
            end if;
          end loop ;

          update tmedreq
             set staappr   = 'A',
                 approvno  = v_approvno,
                 amtalw    = p_amtalw ,
                 dteappr   = to_date(p_dteappr, 'dd/mm/yyyy'),
                 remarkap  = v_remark ,
                 coduser   = p_coduser,
                 dteapph   = sysdate
           where codempid  = rq_codempid
             and dtereq    = rq_dtereq
             and numseq    = rq_seqno;
        end if;

        -- Step 4 => Update staappr
        v_staappr := p_status ;
        if v_max_approv = v_approvno then
          rq_chk := 'E' ;
        end if;

        if rq_chk = 'E' and p_status = 'A' then
          v_staappr := 'Y';
          if v_codcomp is null then
             v_codcomp := rec_tmedreq.codcomp;
          end if;

          hrbf16e.gen_numvcher(v_codcomp,global_v_lang,v_numvcher);--user37 gen_numvcher(rec_tmedreq.codcomp,p_lang,v_numvcher);
          ----
          update tmedreq
             set staappr    = v_staappr,
                 codappr    = v_codeappr,
                 approvno   = v_approvno,
                 amtalw     = p_amtalw ,
                 dteappr    = to_date(p_dteappr, 'dd/mm/yyyy'),
                 remarkap   = v_remark ,
                 numvcher   = v_numvcher,
                 coduser    = p_coduser,
                 dteapph    = sysdate
          where  codempid   = rq_codempid
            and  dtereq     = rq_dtereq
            and  numseq     = rq_seqno;

            --tclnsinf
            --rec_tmedreq.amtalw
            --rec_tmedreq.amtovrpay
--<<user14||11/02/2023|| 15:17   redmine752          
            if  rec_tmedreq.amtalw > p_amtalw then
                rec_tmedreq.amtalw :=p_amtalw;
                rec_tmedreq.amtovrpay := rec_tmedreq.amtexp - rec_tmedreq.amtalw;
            end if;
-->>user14||11/02/2023|| 15:17   redmine752            
             begin
              insert into tclnsinf( numvcher,codempid,codcomp,codpos,typpayroll,dtereq,namsick,codrel,codcln,
                                    coddc,typpatient,typamt,dtecrest,dtecreen,qtydcare,dtebill,flgdocmt,
                                    amtexp,amtalw,amtovrpay,amtavai,amtemp,amtpaid,
                                    dteappr,codappr,typpay,dtecash,dteyrepay,dtemthpay,numperiod,flgupd,
                                    flgtranpy,numpaymt,codpaymtap,dtepaymtap,qtyrepaym,amtrepaym,periodpayst,
                                    staappov,codappov,dteappov,remarkap,dtetranpy,codcreate,coduser,
                                    approvno,amtappr,dtepaid,numdocmt,numinvoice)

                          values   (v_numvcher,rq_codempid,rec_tmedreq.codcomp,rec_tmedreq.codpos,rec_tmedreq.typpayroll,rq_dtereq,rec_tmedreq.namsick,rec_tmedreq.codrel,rec_tmedreq.codcln,
                                    rec_tmedreq.coddc,rec_tmedreq.typpatient,rec_tmedreq.typamt,rec_tmedreq.dtecrest,rec_tmedreq.dtecreen,rec_tmedreq.qtydcare,rec_tmedreq.dtebill,rec_tmedreq.flgdocmt,
                                    rec_tmedreq.amtexp,rec_tmedreq.amtalw,rec_tmedreq.amtovrpay,rec_tmedreq.amtavai,rec_tmedreq.amtemp,rec_tmedreq.amtpaid,
                                    to_date(p_dteappr, 'dd/mm/yyyy'),v_codeappr,p_typpay,to_date(p_dtecash, 'dd/mm/yyyy'),p_dteyrepay,p_dtemthpay,p_numperiod,'Y',
                                    'N',null,null,null,null,null,null,
                                    v_staappr,v_codeappr,to_date(p_dteappr, 'dd/mm/yyyy'),v_remark,null,p_coduser,p_coduser,
                                    v_approvno,p_amtalw,rec_tmedreq.dtepaid,rec_tmedreq.numdocmt,rec_tmedreq.numinvoice);
            end;

            --tclnsinff
           -- copy attach file from ess to bf
            begin
              delete from tclnsinff where numvcher = v_numvcher;
            exception when others then null;
            end;
            v_numseq := 1;
            for r_tmedreqf in c_tmedreqf loop
              begin
                insert into tclnsinff(numvcher,numseq,
                                   filename,descfile,
                                   codcreate,coduser)
                            values(v_numvcher,v_numseq,
                                   r_tmedreqf.filename,r_tmedreqf.descfile,
                                   p_coduser,p_coduser);
                v_numseq := v_numseq +1;
              exception when dup_val_on_index then
                null;
              end;
            end loop;

            --tclndoc
            if rec_tmedreq.numdocmt is not null then
                begin
                  update tclndoc
                     set stadocmt    = 'Y',
                         coduser    = p_coduser
                  where  numdocmt   = rec_tmedreq.numdocmt;
                end;
            end if;
        end if;
     --Update Table Request

---เข้าทุกกรณี ทั้ง อนุมัติและไม่อนุมัติ
        begin
          update tmedreq
             set staappr    = v_staappr,
                 codappr    = v_codeappr,
                 approvno   = v_approvno,
                 amtalw     = p_amtalw ,
                 dteappr    = to_date(p_dteappr, 'dd/mm/yyyy'),
                 remarkap   = v_remark ,
                 numvcher   = v_numvcher,
                 coduser    = p_coduser,
                 dteapph    = sysdate
          where  codempid   = rq_codempid
            and  dtereq     = rq_dtereq
            and  numseq     = rq_seqno;
        end;
        commit;

        -- Step 5 => Send Mail
        begin
         select rowid
           into v_row_id
           from tmedreq
          where codempid = rq_codempid
            and dtereq   = rq_dtereq
            and numseq   = rq_seqno;
        exception when others then
            v_row_id :=  null ;
        end ;

        -- Send mail
        begin
          chk_workflow.sendmail_to_approve( p_codapp              => 'HRES71E',
                                            p_codtable_req        => 'tmedreq',
                                            p_rowid_req           => v_row_id,
                                            p_codtable_appr       => 'tapmedrq',
                                            p_codempid            => rq_codempid,
                                            p_dtereq              => rq_dtereq,
                                            p_seqno               => rq_seqno,
                                            p_staappr             => v_staappr,
                                            p_approvno            => v_approvno,
                                            p_subject_mail_codapp => 'AUTOSENDMAIL',
                                            p_subject_mail_numseq => '120',--คำร้องขอเบิกค่ารักษาพยาบาล
                                            p_lang                => global_v_lang,
                                            p_coduser             => global_v_coduser);
        exception when others then
          param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
        end;
      end if; --Check Approve

    exception when others then
     rollback;
     param_msg_error := sqlerrm;
    end;  --PROCEDURE approve

  --  
  procedure process_approve(json_str_input in clob, json_str_output out clob) as
    json_obj              json_object_t;
    json_obj2             json_object_t;
    v_rowcount            number:= 0;
    v_staappr             varchar2(100);
    v_codcomp             varchar2(100);
    v_appseq              number;
    v_chk                 varchar2(10);
    v_seqno               number;
    v_codempid            varchar2(100);
    v_dtereq              varchar2(100);
    v_dteappr             varchar2(100);
    v_amtalw              number;
    v_typpay              varchar2(100);
    v_dtecash             varchar2(100);
    v_dteyrepay           number;
    v_dtemthpay           number;
    v_numperiod           number;

--
    rec_tmedreq    tmedreq%rowtype;
    v2_typrel         varchar2(10);
    v_amtwidrwy   number:=0;
    v_qtywidrwy   number:=0;
    v_amtwidrwt   number:=0;
    v_amtacc        number:=0;
    v_amtacc_typ   number:=0;
    v_qtyacc           number:=0;
    v_qtyacc_typ   number:=0;
    v_amtbal          number:=0;
--

  begin
      initial_value(json_str_input);
      json_obj      := json_object_t(json_str_input);
      json_obj2     := hcm_util.get_json_t(json_obj, 'param_json');
      v_rowcount    := json_obj2.get_size;

      v_staappr   := hcm_util.get_string_t(json_obj, 'p_staappr');
      v_appseq    := to_number(hcm_util.get_string_t(json_obj, 'p_approvno'));
      v_chk       := hcm_util.get_string_t(json_obj, 'p_chk_appr');
      v_seqno     := to_number(hcm_util.get_string_t(json_obj2, 'numseq'));
      v_codempid  := hcm_util.get_string_t(json_obj2, 'codempid');
      v_dtereq    := hcm_util.get_string_t(json_obj2, 'dtereq');
      v_dteappr   := hcm_util.get_string_t(json_obj2, 'dteappr');
      v_amtalw    := to_number(hcm_util.get_string_t(json_obj2, 'amtalw'));
      v_typpay    := hcm_util.get_string_t(json_obj2, 'typpay');
      v_dtecash       := hcm_util.get_string_t(json_obj2, 'dtecash');
      v_dteyrepay     := to_number(hcm_util.get_string_t(json_obj2, 'dteyrepay'));
      v_dtemthpay     := to_number(hcm_util.get_string_t(json_obj2, 'dtemthpay'));
      v_numperiod     := to_number(hcm_util.get_string_t(json_obj2, 'numperiod'));
      p_remark_appr      := hcm_util.get_string_t(json_obj2, 'remarkApprove');
      p_remark_not_appr  := hcm_util.get_string_t(json_obj2, 'remarkApprove');

      v_staappr := nvl(v_staappr, 'A');
--<<user14||11/02/2023|| 15:17   redmine752
        if v_staappr = 'A' then
                begin
                   select *
                     into rec_tmedreq
                     from tmedreq
                    where codempid = p_codempid
                      and dtereq = to_date(p_dtereq,'dd/mm/yyyy')
                      and numseq = p_seqno;
                  exception when others then
                      rec_tmedreq := null ;
              end ;
                if rec_tmedreq.codrel = 'M' then 
                   v2_typrel := 'F';
                else  
                   v2_typrel := rec_tmedreq.codrel;
                end if;    


               if rec_tmedreq.codempid is not null then
                          std_bf.get_medlimit(rec_tmedreq.codempid, rec_tmedreq.dtereq, rec_tmedreq.dtecrest, 'xyz', rec_tmedreq.typamt, v2_typrel,
                                                         v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, v_amtacc, v_amtacc_typ,
                                                         v_qtyacc, v_qtyacc_typ, v_amtbal);                    

--insert _ttemprpt('BF','BF',622,'v_amtbal='||v_amtbal,'=v_amtalw='||v_amtalw,null,'v_typrel='||v2_typrel);

                        if nvl(v_amtbal,0) <> 0 then
                                 if v_amtalw  > nvl(v_amtbal,0) then                  
                                      param_msg_error := get_error_msg_php('HR6546',global_v_lang);         
                                end if;
                            end if;                          
                 end if; --if rec_tmedreq.codempid is not null then
        end if;
-->>user14||11/02/2023|| 15:17   redmine752

--param_msg_error := rec_tmedreq.codempid||'=='||rec_tmedreq.dtereq||'=p_seqno='||p_seqno||'==='||rec_tmedreq.dtecrest||'=='|| rec_tmedreq.typamt||'=='||v2_typrel;
      if param_msg_error is null then
         approve (global_v_coduser, global_v_lang, '1', v_staappr, p_remark_appr, p_remark_not_appr,
                          to_char(trunc(sysdate),'dd/mm/yyyy'), v_appseq, v_chk, p_codempid, p_seqno, p_dtereq,
                          v_amtalw, v_dteyrepay, v_dtemthpay, v_numperiod, v_typpay, v_dtecash);

    end if;

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
  procedure gen_approve(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);
    v_flgexist      varchar2(2 char);
    v_amount        number := 0;

    tmedreq_rec     tmedreq%rowtype;
    tapmedrq_rec    tapmedrq%rowtype;
    v_codempid      tmedreq.codempid%type;
    v_numseq        tmedreq.numseq%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_dtereq        varchar2(100 char);
    v_codrel        tmedreq.codrel%type;
    v_namsick       tmedreq.namsick%type;
    v_flgdocmt      tmedreq.flgdocmt%type;
    v_typpay        tmedreq.typpay%type;
    v_dtecrest      tmedreq.dtecrest%type;
    v_dtecreen      tmedreq.dtecreen%type;
    v_dtebill       tmedreq.dtebill%type;
    v_minperiod     varchar2(100 char);


    v2_typrel         varchar2(10);
    v_amtwidrwy   number:=0;
    v_qtywidrwy   number:=0;
    v_amtwidrwt   number:=0;
    v_amtacc        number:=0;
    v_amtacc_typ   number:=0;
    v_qtyacc           number:=0;
    v_qtyacc_typ   number:=0;
    v_amtbal          number:=0;

  begin
    begin
      select * into tmedreq_rec
        from tmedreq
       where codempid = p_codempid
         and dtereq = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq = p_seqno;
      v_flgexist := 'Y';
    exception when no_data_found then
      tmedreq_rec := null;
      v_flgexist := 'N';
    end;

    -- get data from previous approver
    begin
      select * into tapmedrq_rec
        from tapmedrq
       where codempid = tmedreq_rec.codempid
         and dtereq   = tmedreq_rec.dtereq
         and numseq   = tmedreq_rec.numseq
         and approvno = tmedreq_rec.approvno;
    exception when no_data_found then
      tapmedrq_rec := null;
    end;

    obj_data := json_object_t();
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codempid', tmedreq_rec.codempid);
    obj_data.put('codappr', chk_workflow.get_next_approve('HRES71E',tmedreq_rec.codempid,to_char(tmedreq_rec.dtereq,'dd/mm/yyyy'),tmedreq_rec.numseq,nvl(trim(tmedreq_rec.approvno),'0'),global_v_lang) );
    obj_data.put('numseq',tmedreq_rec.numseq );
    obj_data.put('dteappr',to_char(sysdate,'dd/mm/yyyy') );

--<<user14||11/02/2023|| 15:17   redmine752
    --obj_data.put('amtalw', nvl(tapmedrq_rec.amtalw,tmedreq_rec.amtalw)); -- obj_data.put('amtalw', tmedreq_rec.amtalw);
    if tmedreq_rec.codrel = 'M' then 
       v2_typrel := 'F';
    else  
       v2_typrel := tmedreq_rec.codrel;
    end if;  
    std_bf.get_medlimit(tmedreq_rec.codempid, tmedreq_rec.dtereq, tmedreq_rec.dtecrest, 'xyz', tmedreq_rec.typamt, v2_typrel,
                                                         v_amtwidrwy, v_qtywidrwy, v_amtwidrwt, v_amtacc, v_amtacc_typ,
                                                         v_qtyacc, v_qtyacc_typ, v_amtbal);     
         
    --obj_data.put('amtalw', nvl(tapmedrq_rec.amtalw, v_amtbal)); -- obj_data.put('amtalw', tmedreq_rec.amtalw);        
    obj_data.put('amtalw',     least(nvl(tapmedrq_rec.amtalw,  tmedreq_rec.amtalw), nvl(v_amtbal,0)) ); -- obj_data.put('amtalw', tmedreq_rec.amtalw);
-->>user14||11/02/2023|| 15:17   redmine752

    obj_data.put('status', get_tlistval_name('ESSTAREQ',trim(tmedreq_rec.staappr),global_v_lang) );
    obj_data.put('typpay', nvl(tapmedrq_rec.typpay,tmedreq_rec.typpay) ); -- obj_data.put('typpay', tmedreq_rec.typpay );
    obj_data.put('dtecash', nvl(to_char(tapmedrq_rec.dtecash,'dd/mm/yyyy'),to_char(sysdate,'dd/mm/yyyy'))); -- obj_data.put('dtecash', '');

    --<< user4 || 27/01/2023 || Redmine 4449#568
    /*
    obj_data.put('numperiod', '' );
    obj_data.put('dtemthpay', '' );
    obj_data.put('dteyrepay', '' );
    */
    begin
        select min(dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0'))
          into v_minperiod
          from tdtepay
         where codcompy         = hcm_util.get_codcomp_level(tmedreq_rec.codcomp,1)
           and typpayroll       = tmedreq_rec.typpayroll
           and trunc(sysdate)   >= dtestrt 
           and trunc(sysdate)   <= dteend ;
    exception when no_data_found then
        v_minperiod := to_char(sysdate,'yyyymm')||'01'; 
    end;
    v_minperiod := nvl(v_minperiod, to_char(sysdate,'yyyymm')||'01'); 

    obj_data.put('numperiod', nvl(tapmedrq_rec.numperiod,to_char(to_number(substr(v_minperiod,7,2)))) );
    obj_data.put('dtemthpay', nvl(tapmedrq_rec.dtemthpay,to_char(to_number(substr(v_minperiod,5,2)))) );
    obj_data.put('dteyrepay', nvl(tapmedrq_rec.dteyrepay,substr(v_minperiod,1,4)) );
    -->> user4 || 27/01/2023 || Redmine 4449#568

    obj_data.put('remarkApprove', '' );
   --obj_data.put('remarkApprove', 'xxxxxxxxxxxxxxxxxx' );

    obj_data.put('staappr', tmedreq_rec.staappr );

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  procedure get_approve(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_approve(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;
    procedure gen_detail(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);
    v_flgexist      varchar2(2 char);
    v_amount        number := 0;

    tmedreq_rec     tmedreq%rowtype;
    tclnsinf_rec    tclnsinf%rowtype;
    v_codempid      tmedreq.codempid%type;
    v_numseq        tmedreq.numseq%type;
    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_dtereq        varchar2(100 char);
    v_codrel        tmedreq.codrel%type;
    v_namsick       tmedreq.namsick%type;
    v_flgdocmt      tmedreq.flgdocmt%type;
    v_typpay        tmedreq.typpay%type;
    v_dtecrest      tmedreq.dtecrest%type;
    v_dtecreen      tmedreq.dtecreen%type;
    v_dtebill       tmedreq.dtebill%type;
    v_desc_codcln   tclninf.desclne%type;
  begin
    begin
      select * into tmedreq_rec
        from tmedreq
       where codempid = p_codempid
         and dtereq = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq = p_seqno;
    exception when no_data_found then
      tmedreq_rec := null;
    end;
    begin
      select * into tclnsinf_rec
        from tclnsinf
       where numvcher = tmedreq_rec.numvcher;
    exception when no_data_found then
      tclnsinf_rec := null;
    end;
--    if v_flgexist = 'Y' then
      begin
        select codpos into v_codpos
          from temploy1
          where codempid = p_codempid;
      end;
      v_codempid  := tmedreq_rec.codempid;
      v_codcomp   := tmedreq_rec.codcomp;
      v_codpos    := v_codpos;
      v_dtereq    := to_char(tmedreq_rec.dtereq,'dd/mm/yyyy');
      v_codrel    := tmedreq_rec.codrel;
      v_namsick   := tmedreq_rec.namsick;
      v_flgdocmt  := tmedreq_rec.flgdocmt;
      v_typpay    := tmedreq_rec.typpay;
      v_dtecrest  := tmedreq_rec.dtecrest;
      v_dtecreen  := tmedreq_rec.dtecreen;
      v_dtebill   := tmedreq_rec.dtebill;
      v_numseq   := tmedreq_rec.numseq;
--    end if;

    obj_data := json_object_t();
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('codcomp', v_codcomp);
    obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp,global_v_lang));
    obj_data.put('desc_codpos', get_tpostn_name(v_codpos,global_v_lang));
    obj_data.put('numvcher', tmedreq_rec.numvcher);
    obj_data.put('dtereq', v_dtereq);
    obj_data.put('codrel', get_tlistval_name('TTYPRELATE',v_codrel,global_v_lang));
    if v_codrel = 'E' then
      obj_data.put('namsick', get_temploy_name(tmedreq_rec.codempid,global_v_lang));
    else
      obj_data.put('namsick', tmedreq_rec.namsick);
    end if;
    begin
      select decode(global_v_lang,'101',desclne
                           ,'102',desclnt
                           ,'103',descln3
                           ,'104',descln4
                           ,'105',descln5) as descln
          into v_desc_codcln
          from tclninf
         where codcln = tmedreq_rec.codcln;
    exception when no_data_found then
      null;
    end;
    obj_data.put('codcln', tmedreq_rec.codcln || ' - ' || v_desc_codcln);
    obj_data.put('coddc', tmedreq_rec.coddc || ' - ' || get_tdcinf_name(tmedreq_rec.coddc, global_v_lang));
    obj_data.put('typpatient', get_tlistval_name('TYPPATIENT',tmedreq_rec.typpatient,global_v_lang));
    obj_data.put('typamt', get_tlistval_name('TYPAMT',tmedreq_rec.typamt,global_v_lang));
    obj_data.put('dtecrest', to_char(v_dtecrest,'dd/mm/yyyy'));
    obj_data.put('dtecreen', to_char(v_dtecreen,'dd/mm/yyyy'));
    obj_data.put('dtebill', to_char(v_dtebill,'dd/mm/yyyy'));
    obj_data.put('qtydcare', tmedreq_rec.qtydcare);
    obj_data.put('flgdocmt', get_tlistval_name('TFLGDOCMT',v_flgdocmt,global_v_lang));
    obj_data.put('numdocmt', tmedreq_rec.numdocmt );
    obj_data.put('amtavai', to_char(nvl(tmedreq_rec.amtavai,0),'fm999,999,990.90'));
    obj_data.put('amtexp', to_char(nvl(tmedreq_rec.amtexp,0) ,'fm999,999,990.90'));
    obj_data.put('amtalw', to_char(nvl(tmedreq_rec.amtalw,0),'fm999,999,990.90'));
    obj_data.put('amtovrpay', to_char(nvl(tmedreq_rec.amtovrpay,0) ,'fm999,999,990.90'));
    obj_data.put('amtemp', to_char(nvl(tmedreq_rec.amtemp,0),'fm999,999,990.90') );
    obj_data.put('amtpaid', to_char(nvl(tmedreq_rec.amtpaid,0) ,'fm999,999,990.90'));
    obj_data.put('dtepaid', to_char(tmedreq_rec.dtepaid,'dd/mm/yyyy') );
    obj_data.put('dteappr', to_char(tmedreq_rec.dteappr,'dd/mm/yyyy') );
    obj_data.put('dtedue', to_char(tclnsinf_rec.dtecash,'dd/mm/yyyy') );
    obj_data.put('codappr', tmedreq_rec.codappr || ' - ' ||  get_temploy_name(tmedreq_rec.codappr,global_v_lang) );
    obj_data.put('typpay', get_tlistval_name('TYPEPAY',v_typpay,global_v_lang) );

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_detail_table(json_str_output out clob)as
    obj_data        json_object_t;
    obj_row         json_object_t;
    v_rcnt          number := 0;
    p_check         varchar2(10 char);

    v_amount        number := 0;
    v_host_folder   varchar2(4000 char):= get_tsetup_value('PATHWORKPHP');
    cursor c1 is
      select seqno, filename, descfile
        from tmedreqf
       where codempid = p_codempid
         and dtereq = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq = p_seqno
       order by seqno;
  begin
    obj_row := json_object_t();
    obj_data := json_object_t();
    for r1 in c1 loop
      v_rcnt      := v_rcnt+1;
      obj_data    := json_object_t();
      obj_data.put('numseq', r1.seqno);
      obj_data.put('filename', r1.filename);
      obj_data.put('path_filename', get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRES71E')||'/'||r1.filename);
      obj_data.put('descfile', r1.descfile);
      obj_row.put(to_char(v_rcnt-1),obj_data);
    end loop;

    json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_table(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_detail_table(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

end;

/
