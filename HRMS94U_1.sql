--------------------------------------------------------
--  DDL for Package Body HRMS94U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS94U" is
-- last update: 27/09/2022 10:44

 procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin

    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global value
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    -- block value
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_dtest             := hcm_util.get_string_t(json_obj,'p_dtest');
    p_dteen             := hcm_util.get_string_t(json_obj,'p_dteen');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtereq            := hcm_util.get_string_t(json_obj,'p_dtereq');
    p_seqno             := hcm_util.get_string_t(json_obj,'p_numseq');
    p_dtereqr           := hcm_util.get_string_t(json_obj,'p_dtereqr');
    --detail
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
  end;

  procedure hrms94u (json_str_input in clob, json_str_output out clob) is
      obj_data      json_object_t;
      obj_row       json_object_t;
      json_obj      json;
      p_codcomp     varchar2(100 char);

      v_codtparg    varchar2(4 char);
      p_start       number;
      p_end         number;
      v_codappr     temploy1.codempid%type;
      v_codpos      varchar2(4 char);
      v_nextappr    varchar2(1000 char);
      v_dtest       date;
      v_dteen       date;
      v_rcnt        number;
      v_appno       varchar2(100 char);
      v_chk         varchar2(100 char) := ' ';
      v_date        varchar2(100 char);
      v_start       number;
      v_end         number;
      v_row         number := 0;
  cursor c1 is
       select codempid,dtereq,numseq,dteyear,codcours,codappr,dteappr,remarkap,a.approvno appno,
              stappr,numclseq,b.approvno qtyapp,codempap
         from  ttrncanrq a,twkflowh b
         where (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
         and   stappr in ('P','A')
         and   ('Y' = chk_workflow.check_privilege('HRMS93E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
               -- Replace Approve
                or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                          from   twkflowde c
                                                          where  c.routeno  = a.routeno
                                                          and    c.codempid = v_codappr)
                and (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRMS93E')))

          and a.routeno = b.routeno
          order by  codempid,dtereq,numseq;


     cursor c2 is
       select codempid,dtereq,numseq,dteyear,codcours,codappr,dteappr,remarkap,a.approvno appno,stappr,
            numclseq,codempap,codcompap,codposap
        from  ttrncanrq a
        where (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
        and (codempid, dtereq, numseq) in
                        (select codempid, dtereq, numseq
                         from  taptrcanrq
                         where staappr = p_staappr
                         and   codappr = v_codappr
                         and   dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
         order by  codempid,dtereq,numseq;

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
        for r1 in c1 loop
          v_appno    := nvl(r1.appno,0) + 1;
          if nvl(r1.appno,0)+1 = r1.qtyapp then
             v_chk := 'E' ;
          else
             v_chk := v_appno ;
          end if;
           ------------
            begin
                select codtparg
                  into v_codtparg
                  from tpotentp
                 where dteyear = r1.dteyear
                   and codcompy = p_codcomp
                   and numclseq = r1.numclseq
                   and codcours = r1.codcours
                   and codempid = r1.codempid;
            exception when no_data_found then
                v_codtparg := null;
            end;
            ------
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('approvno', v_appno);
            obj_data.put('chk_appr', v_chk);
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('dtereq', to_char(r1.dtereq ,'dd/mm/yyyy'));
            obj_data.put('numseq', to_char(r1.numseq));
            obj_data.put('dteyear', to_char(r1.dteyear));
            obj_data.put('numclseq', to_char(r1.numclseq));
            obj_data.put('desc_codcours', get_tcourse_name(r1.codcours, global_v_lang));
            obj_data.put('desc_codtparg', get_tlistval_name('TCODTPARG',v_codtparg,global_v_lang));
            obj_data.put('status', get_tlistval_name('ESSTAREQ',r1.stappr,global_v_lang));
            obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
            obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
            obj_data.put('remark', r1.remarkap);
            obj_data.put('desc_codempap', get_temploy_name(global_v_codempid,global_v_lang));
            obj_data.put('staappr', r1.stappr);
            obj_row.put(to_char(v_row),obj_data);
            v_row := v_row+1;
        end loop;
      else
        for r1 in c2 loop
          v_appno  := nvl(r1.appno,0) + 1;

          v_nextappr := null;
          if r1.stappr = 'A' then
            v_nextappr := chk_workflow.get_next_approve('HRMS93E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.appno,global_v_lang);
          end if;
          --
            begin
                select codtparg
                  into v_codtparg
                  from tpotentp
                 where dteyear = r1.dteyear
                   and codcompy = p_codcomp
                   and numclseq = r1.numclseq
                   and codcours = r1.codcours
                   and codempid = r1.codempid;
            exception when no_data_found then
                v_codtparg := null;
            end;
            ------
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('approvno', v_appno);
            obj_data.put('chk_appr', v_chk);
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('dtereq', to_char(r1.dtereq ,'dd/mm/yyyy'));
            obj_data.put('numseq', to_char(r1.numseq));
            obj_data.put('dteyear', to_char(r1.dteyear));
            obj_data.put('numclseq', to_char(r1.numclseq));
            obj_data.put('desc_codcours', get_tcourse_name(r1.codcours, global_v_lang));
            obj_data.put('desc_codtparg', get_tlistval_name('TCODTPARG',v_codtparg,global_v_lang));
            obj_data.put('status', get_tlistval_name('ESSTAREQ',r1.stappr,global_v_lang));
            obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
            obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
            obj_data.put('remark', r1.remarkap);
            obj_data.put('desc_codempap',v_nextappr);
            obj_data.put('staappr', r1.stappr);
            obj_row.put(to_char(v_row),obj_data);
            v_row := v_row+1;
        end loop;
      end if;
 --   end if;   -- web_service.ess_check_pwd

   json_str_output := obj_row.to_clob;
  exception when others then
   param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms94u;
--
-- gen_detail
  procedure hrms94u_detail_tab1(json_str_input in clob, json_str_output out clob) is
    obj_data    json_object_t;
    v_chkdata   boolean := false;
    v_ttrncanrq ttrncanrq%rowtype;
    v_tyrtrsch  tyrtrsch%rowtype;
    v_dteyear   number ;
    v_count     number := 0;

  begin
    initial_value(json_str_input);
    v_zyear               := pdk.check_year(global_v_lang);

  --  if web_service.ess_check_pwd(global_v_coduser,global_v_codpswd,p_lang) <> 'ERROR' then
      begin
        select * into v_ttrncanrq
          from ttrncanrq
         where codempid = p_codempid
           and dtereq  = to_date(p_dtereq,'dd/mm/yyyy')
           and numseq  = p_numseq;
           v_chkdata := true;
      exception when no_data_found then
           v_chkdata := false;
      end;

        begin
          select * into v_tyrtrsch
            from tyrtrsch
           where codcours = v_ttrncanrq.codcours
             and numclseq  = v_ttrncanrq.numclseq
             and dteyear = v_ttrncanrq.dteyear;
        exception when no_data_found then null;
        end;

        begin
           select nvl(count(codempid),0) into v_count
             from tpotentp
            where dteyear = v_ttrncanrq.dteyear
              and numclseq = v_ttrncanrq.numclseq
              and codcours = v_ttrncanrq.codcours
              and staappr = 'Y';
        exception when no_data_found then
              v_count := 0;
        end;

      v_dteyear := nvl((v_tyrtrsch.dteyear), to_char(to_number(to_char(sysdate,'YYYY')) - v_zyear));

      obj_data := json_object_t();

        if v_chkdata then
              obj_data.put('coderror', '200');
              obj_data.put('codinput', v_ttrncanrq.codinput);
              obj_data.put('desc_codinput', get_temploy_name(v_ttrncanrq.codinput,global_v_lang));
              obj_data.put('codempid', p_codempid);
              obj_data.put('desc_codempid', get_temploy_name(p_codempid,global_v_lang));
              obj_data.put('dtereq', hcm_util.get_date_buddhist_era(v_ttrncanrq.dtereq));
              obj_data.put('dteyear', to_char(v_dteyear));
              obj_data.put('numclseq', to_char(v_ttrncanrq.numclseq));
              obj_data.put('codcours', to_char(v_ttrncanrq.codcours));
              obj_data.put('desc_codcours', get_tcourse_name(v_ttrncanrq.codcours,global_v_lang));
              obj_data.put('dtetrst', hcm_util.get_date_buddhist_era(v_ttrncanrq.dtetrst));
              obj_data.put('dtetren', hcm_util.get_date_buddhist_era(v_ttrncanrq.dtetren));
              obj_data.put('qtytrmin', to_char(trunc(v_ttrncanrq.qtytrmin / 60))||'.'||to_char(mod(v_ttrncanrq.qtytrmin,60),'fm00'));
              obj_data.put('desc_codinsts', get_tinstitu_name(v_ttrncanrq.codinsts,global_v_lang));
              obj_data.put('desc_codhotel', get_thotelif_name(v_ttrncanrq.codhotel,global_v_lang));
              obj_data.put('desc_codinst', get_tinstruc_name(v_ttrncanrq.codinst,global_v_lang));
              obj_data.put('amtemp', to_char(v_count));
              obj_data.put('desreq', v_ttrncanrq.desreq);
        else
              obj_data.put('coderror', '200');
        end if;
  --  end if;   -- web_service.ess_check_pwd

  json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms94u_detail_tab1;
  ----

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
                    p_numseq           in number,
                    p_dtereq          in varchar2) IS

   r_ttrncanrq  ttrncanrq%rowtype;
    rq_numseq   number            := p_numseq;
    v_loop      number            := p_total ;
    rq_codempid temploy1.codempid%type  := p_codempid;
    rq_dtereq   date              := to_date(p_dtereq,'dd/mm/yyyy');
    rq_chk      varchar2(10 char) := p_chk;
    v_appseq    number := p_appseq;
    r_ttrncerq  ttrncerq%rowtype;
    v_approvno  number := null;
    ap_approvno number := null;
    v_count     number := 0;
    v_staappr   varchar2(1 char);
    v_codeappr  temploy1.codempid%type;
    v_approv    temploy1.codempid%type;
    v_desc      varchar2(600 char) := get_label_name('HRESZXEC1', p_lang,99);-- user22 : 04/07/2016 : STA3590287 || v_desc      varchar2(200 char);
    v_codempap  temploy1.codempid%type;
    v_codcompap varchar2(21 char);
    v_codposap  varchar2(4 char);
    v_remark    varchar2(2000 char);
    p_codappr   temploy1.codempid%type := pdk.check_codempid(p_coduser);
    v_max_approv number;

    v_numlereq   varchar2(12 char);
    vv_dtereqr   date;
    vv_seqnor    number;
    v_row_id     varchar2(200 char);


BEGIN
    v_staappr := p_status ;
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
           into r_ttrncanrq
           from ttrncanrq
          where codempid = rq_codempid
            and dtereq = rq_dtereq
            and numseq = rq_numseq;
     exception when others then
            r_ttrncanrq := null ;
     end;
     begin
               select approvno into v_max_approv
               from   twkflowh
               where  routeno = r_ttrncanrq.routeno ;
     exception when no_data_found then
               v_max_approv := 0 ;
     end ;
     if nvl(r_ttrncanrq.approvno,0) < v_appseq then
        ap_approvno :=      v_appseq ;

        begin
           select count(*)
             into v_count
             from taptrcanrq
            where codempid = rq_codempid
              and dtereq   = rq_dtereq
              and numseq   = rq_numseq
              and approvno = ap_approvno;
        exception when no_data_found then
            v_count := 0;
        end;

        if v_count = 0 then
           insert into taptrcanrq(codempid,dtereq,numseq,
                                  approvno,
                                  codappr,dteappr,staappr,remark,
                                  dteapph,
                                  dteupd,coduser,codcreate,codempap,codcompap,codposap)
                  values(rq_codempid,rq_dtereq,rq_numseq,
                         ap_approvno,
                         p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),v_staappr,v_remark,
                          sysdate,
                          trunc(sysdate),p_coduser,p_coduser,r_ttrncanrq.codempap,r_ttrncanrq.codcompap,r_ttrncanrq.codposap);
        else
           update taptrcanrq
                  set codappr  = p_codappr,
                      dteappr  = to_date(p_dteappr,'dd/mm/yyyy'),
                      staappr  = v_staappr,
                      remark   = v_remark,
                      dteupd   = trunc(sysdate),
                      coduser  = p_coduser,
                      dteapph  = sysdate,
                      codempap  = r_ttrncanrq.codempap,
                      codcompap = r_ttrncanrq.codcompap,
                      codposap  = r_ttrncanrq.codposap
                 where codempid = rq_codempid
                   and dtereq   = rq_dtereq
                   and numseq   = rq_numseq
                   and approvno = ap_approvno;

        end if;

       -- Check Next Step
        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;
        v_codempap  :=  p_codappr ;
        v_codcompap :=  r_ttrncanrq.codcompap ;
        v_codposap  :=  r_ttrncanrq.codposap ;

        chk_workflow.find_next_approve('HRMS93E',r_ttrncanrq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr,null);

        if  p_status = 'A' and rq_chk <> 'E'   then
            loop
                 v_approv := chk_workflow.check_next_step('HRMS93E',r_ttrncanrq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                 if  v_approv is not null then
                       v_remark   := v_desc; -- user22 : 04/07/2016 : STA3590287 ||
                       v_approvno := v_approvno + 1 ;
                       v_codeappr := v_approv ;

                       begin
                           select count(*)
                             into v_count
                             from taptrcanrq
                            where codempid   = rq_codempid
                              and dtereq     = rq_dtereq
                              and numseq     = rq_numseq
                              and approvno   =  v_approvno;
                       exception when no_data_found then  v_count := 0;
                       end;

                       if v_count = 0  then
                               insert into taptrcanrq(codempid,dtereq,numseq,
                                     approvno,
                                     codappr,dteappr,staappr,remark,
                                     dteupd,coduser,codcreate,
                                     dteapph,codempap,codcompap,codposap)
                                    values(rq_codempid,rq_dtereq,rq_numseq,
                                     v_approvno,
                                     v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),'A',v_remark,
                                     trunc(sysdate),p_coduser,p_coduser,
                                     sysdate,v_codempap,v_codcompap,v_codposap);
                        else
                               update taptrcanrq
                                   set codappr   = v_codeappr,
                                       dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                                       staappr   = 'A',
                                       remark    =  v_remark,
                                       dteupd    = trunc(sysdate),
                                       coduser   = p_coduser,
                                       dteapph   = sysdate,
                                       codempap  = v_codempap,
                                       codcompap = v_codcompap,
                                       codposap  = v_codposap
                                where  codempid  = rq_codempid
                                  and  dtereq    = rq_dtereq
                                  and  numseq    = rq_numseq
                                  and  approvno  = v_approvno;
                      end if;
                      chk_workflow.find_next_approve('HRMS93E',r_ttrncanrq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);-- user22 : 04/07/2016 : STA3590287 || v_approv := chk_workflow.Check_Next_Approve('HRMS93E',r_ttrncanrq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
                 else
                       exit ;
                  end if;
            end loop;

            update ttrncanrq
                 set    stappr    = v_staappr,
                        codappr   = v_codeappr,
                        approvno  = v_approvno,
                        dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                        remarkap  = v_remark ,
                        dteupd    = trunc(sysdate),
                        coduser   = p_coduser,
                        dteapph   = sysdate
                  where codempid  = rq_codempid
                  and dtereq    = rq_dtereq
                  and numseq   = rq_numseq;

        end if; --<p_status = 'A' and rq_chk <> 'E'   then>

        -- Step 4 => Update Table Request and Insert Transaction
        if v_max_approv = v_approvno then
           rq_chk := 'E' ;
        end if;

        v_staappr := p_status ;
        if rq_chk = 'E' and p_status = 'A' then
            v_staappr := 'Y';
            begin
                 update tyrtrsch
                    set codcancel   = r_ttrncanrq.codcancel,
                        desreq      = r_ttrncanrq.desreq,
                        dtecancel   = r_ttrncanrq.dtereq,
                        codempcanl  = r_ttrncanrq.codempid,
                        codappcanl  = v_codeappr,
                        flgconf     = 'X',
                        coduser     = p_coduser
                  where dteyear   = r_ttrncanrq.dteyear
                    and codcompy  = hcm_util.get_codcomp_level(r_ttrncanrq.codcomp,1)
                    and codcours  = r_ttrncanrq.codcours
                    and numclseq  = r_ttrncanrq.numclseq;
                --------------
                update  tpotentp
                    set flgatend  = 'C',
                        dteapprm  = to_date(p_dteappr,'dd/mm/yyyy'),
                        coduser   = p_coduser
                  where dteyear   = r_ttrncanrq.dteyear
                    and codcompy  = hcm_util.get_codcomp_level(r_ttrncanrq.codcomp,1)
                    and numclseq  = r_ttrncanrq.numclseq
                    and codcours  = r_ttrncanrq.codcours
                    and codempid  = rq_codempid;
            end;
            /*
              begin
                delete from tpotentp
                where dteyear  = r_ttrncanrq.dteyear
                  and numclseq = r_ttrncanrq.numclseq
                  and codcours = r_ttrncanrq.codcours
                  and codempid = rq_codempid;

                delete from tyrtrsch
                where dteyear  = r_ttrncanrq.dteyear
                  and numclseq = r_ttrncanrq.numclseq
                  and codcours = r_ttrncanrq.codcours;
              end;
            */
        end if;

---เข้าทุกกรณี ทั้ง อนุมัติและไม่อนุมัติ
        update ttrncanrq
            set stappr    = v_staappr,
                codappr   = v_codeappr,
                approvno  = v_approvno,
                dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                coduser   = p_coduser,
                remarkap  = v_remark,
                dteapph   = sysdate
        where   codempid  = rq_codempid
          and   dtereq    = rq_dtereq
          and   numseq    = rq_numseq;

        COMMIT;

        -- Send mail
        begin
            select rowid
              into v_row_id
              from ttrncanrq
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq;
        exception when others then
            r_ttrncanrq := null ;
        end;

        begin 
          chk_workflow.sendmail_to_approve( p_codapp           => 'HRMS93E',
                                            p_codtable_req  => 'ttrncanrq',
                                            p_rowid_req     => v_row_id,
                                            p_codtable_appr => 'taptrcanrq',
                                            p_codempid      => rq_codempid,
                                            p_dtereq        => rq_dtereq,
                                            p_seqno         => rq_numseq,
                                            p_staappr       => v_staappr,
                                            p_approvno      => v_approvno,
                                            p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                            p_subject_mail_numseq  => '180',
                                            p_lang          => global_v_lang,
                                            p_coduser       => global_v_coduser);
        exception when others then
          param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
        end;

    end if; --<if nvl(r_ttrncanrq.approvno,0) < v_appseq then >

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
  --

end;

/
