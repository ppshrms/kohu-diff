--------------------------------------------------------
--  DDL for Package Body HRMS89U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS89U" is
-- last update: 27/09/2022 10:44

  procedure initial_value(json_str in clob) is
    json_obj            json_object_t;
    obj_syncond         json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_lrunning   := hcm_util.get_string_t(json_obj,'p_lrunning');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    ---------------------------------------------
    p_dtereqst          := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereqst')),'dd/mm/yyyy');
    p_dtereqen          := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereqen')),'dd/mm/yyyy');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtereq            := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereq')),'dd/mm/yyyy');
    p_numseq            := hcm_util.get_string_t(json_obj,'p_numseq');
    p_codjob            := hcm_util.get_string_t(json_obj,'p_codjob');

    p_amtincom          := hcm_util.get_string_t(json_obj,'p_amtincom');
    p_codbrlc           := hcm_util.get_string_t(json_obj,'p_codbranc');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempr           := hcm_util.get_string_t(json_obj,'p_codempinst');
    p_codempmt          := hcm_util.get_string_t(json_obj,'p_codempmt');
    p_codpos            := hcm_util.get_string_t(json_obj,'p_codpos');
    p_codrearq          := hcm_util.get_string_t(json_obj,'p_codrearq');
    p_flgcond           := hcm_util.get_string_t(json_obj,'p_flgcond');
    p_flgjob            := hcm_util.get_string_t(json_obj,'p_flgjob');
    p_flgrecut          := hcm_util.get_string_t(json_obj,'p_flgrecut');
    p_qtyreq            := hcm_util.get_string_t(json_obj,'p_qtyreq');
    p_remarkap          := hcm_util.get_string_t(json_obj,'p_remarkap');

    obj_syncond         := hcm_util.get_json_t(json_obj,'p_syncond');
    p_syncond           := hcm_util.get_string_t(obj_syncond,'code');
    p_statement         := hcm_util.get_string_t(obj_syncond,'statement');

    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');

    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  function char_time_to_format_time (p_tim varchar2) return varchar2 is
  begin
    if p_tim is not null then
      return substr(p_tim, 1, 2) || ':' || substr(p_tim, 3, 2);
    else
      return p_tim;
    end if;
  exception when others then
    return p_tim;
  end;

  procedure check_index is
    v_count_comp  number := 0;
    v_secur  boolean := false;
  begin
    null;
  end;
  --
 procedure gen_index(json_str_output out clob) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    v_total         number;
    v_rcnt          number := 0;

    v_nextappr      varchar2(1000 char);
    v_dtest         date;
    v_dteen         date;
    v_appno         varchar2(100 char);
    v_chk           varchar2(100 char) := ' ';
    v_date          VARCHAR2(10 char);
    v_dtereq        VARCHAR2(10 char);
    v_dteeffec      VARCHAR2(10 char);
    v_staappr       VARCHAR2(50 char);
    v_codproc       VARCHAR2(50 char);
    v_row           NUMBER := 0;

    v_numexemp      VARCHAR2(4000 CHAR);
    v_codempid      VARCHAR2(4000 CHAR);
    v_numseq        NUMBER;
    v_flgblist      varchar2(100 char);
    v_flgssm        varchar2(100 char);

--    cursor c1 is
--      select codempid,dtereq,numseq,codcomp,codpos,qtyreq,staappr,codappr,
--             approvno,remarkap,routeno
--        from tjobreq
--        where codempid = global_v_codempid
--          and dtereq between nvl(p_dtereqst,dtereq) and nvl(p_dtereqen,dtereq)
--          order by dteinput Desc,numseq Desc;
    cursor c1 is
        select codempid,dtereq,numseq,codpos,qtyreq,staappr,codappr,
                 a.routeno,
                  dteappr,remarkap,a.approvno appno,codcomp,b.approvno qtyapp
          from tjobreq a,twkflowh b
         where staappr in ('P','A')
--           and ((p_codempid is not null and staappr = p_staappr)
--            or  (p_codempid is null     and staappr in ('P','A')))
           and ('Y' = chk_workflow.check_privilege('HRES88E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
            or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                        from twkflowde c
                                                       where c.routeno  = a.routeno
                                                         and c.codempid = v_codappr)
           and (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES88E')))
           and a.routeno = b.routeno
           and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
      order by  codempid,dtereq,numseq;


    cursor c2 is
        select codempid,dtereq,numseq,codpos,qtyreq,staappr,codappr,
               routeno,dteappr,remarkap,approvno appno,codcomp
          from tjobreq
         where (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
           and (codempid ,dtereq,numseq) in
                      (select codempid, dtereq ,numseq
                       from  tapjobrq
                       where staappr = decode(p_staappr,'Y','A',p_staappr)
                       and   codappr = v_codappr
                       and   dteappr between nvl(p_dtereqst,dteappr) and nvl(p_dtereqen,dteappr) )
      order by codempid,dtereq,numseq;

  begin
    v_rcnt      := 0;
    obj_row     := json_object_t();
    obj_data    := json_object_t();

    if p_staappr = 'P' then
      obj_row  := json_object_t();
      FOR r1 IN c1 LOOP
        --if secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
            v_rcnt      := v_rcnt + 1;
            v_appno     := nvl(r1.appno,0) + 1;
            v_row       := v_row+1;
            IF nvl(r1.appno,0)+1 = r1.qtyapp THEN
               v_chk := 'E' ;
            ELSE
               v_chk := v_appno ;
            end if;
            v_dtereq    := to_char(r1.dtereq,'dd/mm/yyyy');

            v_staappr   := get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang);

            v_codempid  := r1.codempid;
            v_numseq    := r1.numseq;


            obj_data := json_object_t();
            obj_data.put('coderror', '200');

            obj_data.put('approvno', v_appno);
            obj_data.put('chk_appr', v_chk);
            obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
            obj_data.put('numseq', r1.numseq);
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
            obj_data.put('codpos', r1.codpos);
            obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
            obj_data.put('qtyreq', r1.qtyreq);
            obj_data.put('staappr', r1.staappr);
            obj_data.put('status', get_tlistval_name('ESSTAREQ', r1.staappr,global_v_lang));
            obj_data.put('remarkap', r1.remarkap);
            obj_data.put('desc_codappr', get_temploy_name(get_codempid(r1.codappr),global_v_lang));
            obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES88E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.appno),'0'),global_v_lang));
            obj_data.put('codemprc', r1.codempid);
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
            obj_row.put(to_char(v_row-1),obj_data);
        --end if;
      end loop;
    else
      obj_row  := json_object_t();
      for r1 in c2 loop
        if secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal) then
           v_rcnt := v_rcnt + 1;
            v_staappr   := get_tlistval_name('ESSTAREQ',r1.staappr,global_v_lang);
            v_row       := v_row+1;
            --
            v_nextappr := null;
            if r1.staappr = 'A' then
              v_nextappr := chk_workflow.get_next_approve('HRES88E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.appno,global_v_lang);
            end if;
            --
            v_chk := 'E' ;
            v_codempid := r1.codempid;
            v_numseq := r1.numseq;

            --
            obj_data := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('approvno', v_appno);
            obj_data.put('chk_appr', v_chk);
            obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
            obj_data.put('numseq', r1.numseq);
            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
            obj_data.put('codpos', r1.codpos);
            obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
            obj_data.put('qtyreq', r1.qtyreq);
            obj_data.put('staappr', r1.staappr);
            obj_data.put('status', get_tlistval_name('ESSTAREQ', r1.staappr,global_v_lang));
            obj_data.put('remarkap', r1.remarkap);
            obj_data.put('desc_codappr', get_temploy_name(get_codempid(r1.codappr),global_v_lang));
            obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRMS89U',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.appno),'0'),global_v_lang));
            obj_data.put('codemprc', r1.codempid);
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
            obj_row.put(to_char(v_row-1),obj_data);
        end if;
      end loop;
    end if;

--    for r1 in c1 loop
--      v_rcnt := v_rcnt+1;
--      obj_data.put('coderror', 200);
--      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
--      obj_data.put('numseq', r1.numseq);
--      obj_data.put('codcomp', r1.codcomp);
--      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
--      obj_data.put('codpos', r1.codpos);
--      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
--      obj_data.put('qtyreq', r1.qtyreq);
--      obj_data.put('staappr', r1.staappr);
--      obj_data.put('status', get_tlistval_name('ESSTAREQ', r1.staappr,global_v_lang));
--      obj_data.put('remarkap', r1.remarkap);
--      obj_data.put('desc_codappr', get_temploy_name(get_codempid(r1.codappr),global_v_lang));
--      obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRMS89U',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.approvno),'0'),global_v_lang));
--      obj_row.put(to_char(v_rcnt-1),obj_data);
--
--    end loop;


--    if v_rcnt = 0 then
--      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tjobreq');
--      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
--      return;
--    end if;

    json_str_output := obj_row.to_clob;
  end;

 procedure get_index (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        v_codappr := pdk.check_codempid(global_v_coduser);
--        check_index();
        if param_msg_error is null then
            gen_index(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


 function gen_numreq(p_lang in varchar2,
                     p_codcomp in varchar2,
                     p_dteopen in date ) return varchar2 is

    v_last_day      varchar2(2 char);
    v_year          number;
    v_month         varchar2(2 char);
    v_numreqst      varchar2(20 char);
    t_numreqst      varchar2(20 char);
    v_count         number :=0;
    v_seq           number :=0;
    v_dteopen       date;
    v_year_disp     varchar2(2 char);
    v_month_disp    varchar2(2 char);
    v_codcompy      tcompny.codcompy%type;

  begin
    v_zyear     :=  pdk.check_year(p_lang);
    v_year      :=  to_number(to_char(p_dteopen,'yyyy'));
    v_month     :=  lpad(to_char(p_dteopen,'mm'),2,0);
    v_last_day  :=  to_char(last_day(p_dteopen),'dd');
    v_codcompy  :=  lpad(hcm_util.get_codcomp_level(p_codcomp,1),4,0);

    begin
      select count(*) --00010 20 06 0001
        into v_count
        from treqest1
       where trunc(dtereq) between to_date('01'||v_month||(v_year-v_zyear),'dd/mm/yyyy')
                               and to_date(v_last_day||v_month||(v_year-v_zyear),'dd/mm/yyyy');
    end ;

    v_seq := v_count + 1;
    if v_year > 2500 then
      v_year_disp := substr((v_year-v_zyear),3,2);--2564
    else
      v_year_disp := substr(v_year,3,2); --2021
    end if;
    v_numreqst := v_codcompy||v_year_disp||v_month||lpad(v_seq,7,'0');
    --
    loop
      begin
        select numreqst into t_numreqst
          from treqest1
         where numreqst = v_numreqst;
      exception when no_data_found then
        return(v_numreqst);
      end;
      v_seq := v_seq + 1;
      v_numreqst := v_codcompy||v_year_disp||v_month||lpad(v_seq,7,'0');
    end loop;
    return (v_numreqst);
  END gen_numreq;
   --
  PROCEDURE approve(p_coduser         in varchar2,
                    p_lang            in varchar2,
                    p_total           in varchar2,
                    p_status          in varchar2,
                    p_remark_appr     in varchar2,
                    p_remark_not_appr in varchar2,
                    p_dteappr         in date,
                    p_appseq          in number,
                    p_chk             in varchar2,
                    p_codempid        in varchar2,
                    p_seqno           in number,
                    p_dtereq          in date,
                    p_dtereqr         in date,
                    p_dteopen         in date,
                    p_dteclose        in date,
                    p_codemprc        in varchar2,
                    p_desnote         in varchar2
                    ) is

    v_tjobreq    tjobreq %rowtype;
    v_numreqst   varchar2(15 char);
    rq_codempid  temploy1.codempid%type := p_codempid;
    rq_dtereq    date              := trunc(p_dtereq);
    rq_seqno     number            := p_seqno;
    v_appseq     number            := p_appseq;
    rq_chk       varchar2(10 char) := p_chk;
    v_approvno   number := null;
    ap_approvno  number := null;
    v_count      number := 0;
    v_staappr    varchar2(1 char);
    v_codeappr   temploy1.codempid%type;
    v_approv     temploy1.codempid%type;
    v_desc       varchar2(600 char) := get_label_name('HCM_APPRFLW',global_v_lang,10);-- user22 : 04/07/2016 : STA4590287 || v_desc      varchar2(200 char);
    v_remark     varchar2(2000 char);
    p_codappr    temploy1.codempid%type := pdk.check_codempid(p_coduser);
    v_max_approv number;
    v_row_id     varchar2(200 char);

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
      into  v_tjobreq
      from  tjobreq
      where codempid = rq_codempid
        and dtereq   = rq_dtereq
        and numseq   = rq_seqno;
     exception when no_data_found then
       v_tjobreq := null;
     end;

        begin
        select  approvno
          into v_max_approv
          from  twkflowh
         where  routeno = v_tjobreq.routeno ;
        exception when no_data_found then
            v_max_approv := 0 ;
      end ;

   if nvl(v_tjobreq.approvno,0) < v_appseq THEN
    -----------------------------------------------
    ap_approvno :=  v_appseq;
    -- Step 2 => Insert Table Request Detail
      begin
        select  count(*)
        into    v_count
        from    tapjobrq
        where   codempid = rq_codempid
        and     dtereq   = rq_dtereq
        and     numseq   = rq_seqno
        and     approvno = ap_approvno;
      exception when no_data_found then
          v_count := 0;
      end;

     if v_count = 0 then
      insert into tapjobrq(codempid,dtereq,numseq,approvno,
                           codemprc,dteopen,dteclose,codappr,dteappr,
                           staappr,remark,dtesnd,dteapph,
                           coduser,codcreate)
                    values(rq_codempid,rq_dtereq,rq_seqno,ap_approvno,
                           p_codemprc,p_dteopen,p_dteclose,p_codappr,p_dteappr,
                           v_staappr,v_remark,sysdate,sysdate,
                           p_coduser, p_coduser );
       else
        update tapjobrq
          set codemprc = p_codemprc,
              dteopen  = p_dteopen,
              dteclose = p_dteclose,
              codappr  = p_codappr,
              dteappr  = p_dteappr,
              staappr  = v_staappr,
              remark   = v_remark,
              dtesnd   = sysdate,
              dteapph  = sysdate,
              coduser  = p_coduser,
              dteupd   = trunc(sysdate)
          where  codempid = rq_codempid
          and    dtereq   = rq_dtereq
          and    numseq   = rq_seqno
          and    approvno = ap_approvno;
      end if;
      --End  Update Data


      -- Step 3 => Check Next Step
      v_codeappr  := p_codappr ;
      v_approvno  := ap_approvno;

      chk_workflow.find_next_approve('HRES88E',v_tjobreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,ap_approvno,p_codappr,null);
      if p_status = 'A' and rq_chk <> 'E'   then
         v_staappr := p_status;
         loop
            v_approv := chk_workflow.check_next_step('HRES88E',v_tjobreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
             if  v_approv is not null then
                 v_remark   := v_desc; -- user22 : 04/07/2016 : STA3590287 ||
                 v_approvno := v_approvno + 1 ;
                 v_codeappr := v_approv ;
                 begin
                     select     count(*)
                       into     v_count
                       from     tapjobrq
                      where     codempid = rq_codempid
                        and     dtereq   = rq_dtereq
                        and     numseq   = rq_seqno
                        and     approvno = v_approvno;
                 exception when no_data_found then
                 v_count := 0;
                 end;

                 if v_count = 0 then
                     insert into tapjobrq (codempid,dtereq,numseq,approvno,
                                           codemprc,dteopen,dteclose,codappr,dteappr,
                                           staappr,remark,dtesnd,dteapph,
                                           coduser,codcreate)
                                  values  (rq_codempid,rq_dtereq,rq_seqno,ap_approvno,
                                           p_codemprc,p_dteopen,p_dteclose,v_codeappr,p_dteappr,
                                           v_staappr,v_remark,sysdate,sysdate,
                                           p_coduser, p_coduser );
                  else
                       update tapjobrq
                          set codemprc = p_codemprc,
                              dteopen  = p_dteopen,
                              dteclose = p_dteclose,
                              codappr  = v_codeappr,
                              dteappr  = p_dteappr,
                              staappr  = v_staappr,
                              remark   = v_remark,
                              dtesnd   = sysdate,
                              dteapph  = sysdate,
                              coduser  = p_coduser,
                              dteupd   = trunc(sysdate)
                      where   codempid = rq_codempid
                        and   dtereq   = rq_dtereq
                        and   numseq   = rq_seqno
                        and   approvno = ap_approvno;
                end if;
                chk_workflow.find_next_approve('HRES88E',v_tjobreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr,null);-- INSERT2
            else
               exit ;
            end if;
         end loop ;

         begin
           update tjobreq
            set   staappr   = v_staappr,
                  codappr   = v_codeappr,
                  dteappr   = p_dteappr,
                  coduser   = p_coduser,
                  remarkap  = v_remark,
                  approvno  = v_approvno,
                  dteapph   = sysdate
          where   codempid  = rq_codempid
            and   dtereq    = rq_dtereq
            and   numseq    = rq_seqno;
         end;
      end if;
      -- End Check Next Step

      -- Step 4 => Update Table Request and Insert Transaction
      if v_max_approv = v_approvno then
         rq_chk := 'E' ;
      end if;

      if rq_chk = 'E' and p_status = 'A' then
         v_numreqst := gen_numreq(p_lang, p_codcomp,p_dteopen) ;
         v_staappr := 'Y';
             begin
               update tjobreq
                set   approvno  = v_appseq,
                      staappr   = v_staappr,
                      codappr   = v_codeappr,
                      dteappr   = p_dteappr,
                      remarkap  = v_remark,
                      dteapph   = sysdate,
                      numreqst  = v_numreqst,
                      coduser   = p_coduser
              where   codempid  = rq_codempid
                and   dtereq    = rq_dtereq
                and   numseq    = rq_seqno;
             end;

          -- treqest1
            begin
              insert into treqest1
                                  (
                                   numreqst,codcomp,codemprq,dtereq,codempap,dteaprov,
                                   codemprc,codintview,codappchse,desnote,stareq,dterec,filename,
                                   coduser,codcreate
                                  )
                          values
                                  (
                                   v_numreqst,p_codcomp,v_tjobreq.codempid,v_tjobreq.dtereq,p_codappr,sysdate,
                                   p_codemprc,p_codemprc,p_codemprc,p_desnote,'N',null,null,
                                   p_coduser,p_coduser
                                  );
            end;

          -- treqest2
            begin
              insert into treqest2
                                  (
                                   numreqst,codpos,codcomp,codjob,codempmt,
                                   codbrlc,amtincom,flgrecut,dtereqm,
                                   dteopen,codrearq,codempr,
                                   flgjob,flgcond,syncond,statement,
                                   desnote,qtyreq,dteclose,codemprc,
                                   dteupd,coduser,codcreate
                                  )
                          values
                                  (
                                   v_numreqst,p_codpos,p_codcomp,v_tjobreq.codjob,v_tjobreq.codempmt,
                                   v_tjobreq.codbrlc,v_tjobreq.amtincom,v_tjobreq.flgrecut,null,
                                   p_dteopen,v_tjobreq.codrearq,null,
                                   v_tjobreq.flgjob,v_tjobreq.flgcond,v_tjobreq.syncond,null,
                                   null,v_tjobreq.qtyreq,p_dteclose,p_codemprc,
                                   trunc(sysdate),p_coduser,p_coduser
                                  );
           end;
      end if;
     --Update Table Request


---เข้าทุกกรณี ทั้ง อนุมัติและไม่อนุมัติ
     begin
       update tjobreq
        set   staappr   = v_staappr,
              codappr   = v_codeappr,
              dteappr   = p_dteappr,
              coduser   = p_coduser,
              remarkap  = v_remark,
              approvno  = v_appseq,
              numreqst  = v_numreqst,
              dteapph   = sysdate
      where   codempid  = rq_codempid
        and   dtereq    = rq_dtereq
        and   numseq    = rq_seqno;
     end;
     commit;

 -- Send mail
         begin
          select rowid
          into  v_row_id
          from  tjobreq
          where codempid = rq_codempid
            and dtereq   = rq_dtereq
            and numseq   = rq_seqno;
         exception when no_data_found then
           v_tjobreq := null;
         end;

        -- Send mail

        begin
          chk_workflow.sendmail_to_approve( p_codapp        => 'HRES88E',
                                            p_codtable_req  => 'tjobreq',
                                            p_rowid_req     => v_row_id,
                                            p_codtable_appr => 'tapjobrq',
                                            p_codempid      => rq_codempid,
                                            p_dtereq        => rq_dtereq,
                                            p_seqno         => rq_seqno,
                                            p_staappr       => v_staappr,
                                            p_approvno      => v_approvno,
                                            p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                            p_subject_mail_numseq  => '160',
                                            p_lang          => global_v_lang,
                                            p_coduser       => global_v_coduser);
        exception when others then
          param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
        end;
      end if; --Check Approve

    exception when others then
         rollback;
--         param_msg_error := sqlerrm;
         param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    end; -- Process approve
  --

 procedure process_approve(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    json_obj2       json_object_t;
    v_rowcount      number:= 0;
    v_staappr       varchar2(100);
    v_appseq        number;
    v_chk           varchar2(10);
    v_seqno         number;
    v_codempid      varchar2(100);
    v_dtereq        date;
    v_dtereqr       date;
    v_codemprc      varchar2(400);
    v_codcomp       varchar2(400);
    v_codpos        varchar2(400);
    v_codappr       varchar2(400);
    v_dteopen       date;
    v_dteclose      date;
    v_desnote       varchar2(400);
--    v_dtestr        varchar2(400);
--    v_dteend        varchar2(400);
--    param_flgwarn   varchar2(200);

  begin
    begin
      initial_value(json_str_input);
      json_obj := json_object_t(json_str_input).get_object('param_json');
      v_rowcount := json_obj.get_size;
--      for i in 0..json_obj.get_size-1 loop
        json_obj2   := json_obj;
        v_staappr   := hcm_util.get_string_t(json_obj2, 'p_staappr');
        v_appseq    := to_number(hcm_util.get_string_t(json_obj2, 'p_approvno'));
        v_chk       := hcm_util.get_string_t(json_obj2, 'p_chk_appr');
        v_seqno     := to_number(hcm_util.get_string_t(json_obj2, 'p_numseq'));
        v_codempid  := hcm_util.get_string_t(json_obj2, 'p_codempid');
        v_dtereq    := to_date(hcm_util.get_string_t(json_obj2, 'p_dtereq'),'dd/mm/yyyy');
        v_dtereqr   := to_date(hcm_util.get_string_t(json_obj2, 'p_dtereqr'),'dd/mm/yyyy');
        v_codemprc  := hcm_util.get_string_t(json_obj2, 'p_codemprc');
        p_codcomp   := hcm_util.get_string_t(json_obj2, 'p_codcomp'); -- user4 || 27/10/2022 || v_codcomp   := hcm_util.get_string_t(json_obj2, 'p_codcomp');
        p_codpos    := hcm_util.get_string_t(json_obj2, 'p_codpos');-- user4 || 27/10/2022 || v_codpos    := hcm_util.get_string_t(json_obj2, 'p_codpos');
        v_codappr   := hcm_util.get_string_t(json_obj2, 'p_codappr');
        v_dteopen   := to_date(hcm_util.get_string_t(json_obj2, 'p_dteopen'),'dd/mm/yyyy');
        v_dteclose  := to_date(hcm_util.get_string_t(json_obj2, 'p_dteclose'),'dd/mm/yyyy');
        v_desnote   := hcm_util.get_string_t(json_obj2, 'p_desnote');
--        v_dtestr    := hcm_util.get_string_t(json_obj2, 'p_dtestr');
--        v_dteend    := hcm_util.get_string_t(json_obj2, 'p_dteend');
--        param_flgwarn   := hcm_util.get_string_t(json_obj2, 'p_flgwarn');
        v_staappr := nvl(v_staappr, 'A');
        approve(global_v_coduser,global_v_lang,to_char(v_rowcount),v_staappr,p_remark_appr,p_remark_not_appr,sysdate,v_appseq,v_chk,v_codempid,v_seqno,v_dtereq,v_dtereqr,v_dteopen,v_dteclose,v_codemprc,v_desnote);
--        exit when param_msg_error is not null;
--      end loop;

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

--    exception when others then
--      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
--      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end;
  end process_approve;

  procedure gen_detail(json_str_output out clob) is
    obj_data        json_object_t;
    obj_syncond        json_object_t;
    v_total         number;
    v_numseq        number := 0;
    v_rcnt          number := 0;
    v_rcnt2          number := 0;
    v_pathweb       varchar2(4000 char);
    v_codasset      tasetinf.codasset%type;
    v_job_remark    tjobcode.statement%type;
    v_namjob        tjobcode.namjobe%type;
    cursor c1 is
      select codempid,dtereq,numseq,codcomp,codpos,codjob,qtyreq,staappr,codappr,
             approvno,remarkap,routeno,codempmt,amtincom,flgrecut
             ,codrearq,syncond,statement,codempr,codbrlc,flgjob,flgcond,numreqst
        from tjobreq
        where codempid = p_codempid
          and dtereq = p_dtereq
          and numseq = p_numseq;


  begin

    v_rcnt := 0;

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

      v_rcnt := v_rcnt+1;
      obj_data.put('coderror', 200);
      obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
      obj_data.put('numreqst', r1.numreqst);
      obj_data.put('numseq', r1.numseq);
      obj_data.put('codcomp', r1.codcomp);
      obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
      obj_data.put('codpos', r1.codpos);
      obj_data.put('desc_codpos', get_tpostn_name(r1.codpos,global_v_lang));
      obj_data.put('codjob', r1.codjob);
      obj_data.put('desc_codjob', get_tjobcode_name(r1.codjob,global_v_lang));
      obj_data.put('codempmt', r1.codempmt);
      obj_data.put('desc_codempmt',  get_tcodec_name('tcodempl', r1.codempmt, global_v_lang));
      obj_data.put('codbrlc', r1.codbrlc);
      obj_data.put('desc_codbrlc', get_tcodec_name('tcodloca',r1.codbrlc,global_v_lang));
      obj_data.put('amtincom', to_char(r1.amtincom, 'fm999,999,999,999,990.00'));
      obj_data.put('qtyreq', r1.qtyreq);
      obj_data.put('staappr', r1.staappr);
      obj_data.put('status', get_tlistval_name('ESSTAREQ', r1.staappr,global_v_lang));
      obj_data.put('flgjob', r1.flgjob);
      obj_data.put('flgcond', r1.flgcond);
      obj_data.put('remarkap', r1.remarkap);
      obj_data.put('codrearq', get_tlistval_name('TCODREARQ',r1.codrearq,global_v_lang));
      obj_data.put('flgrecut', get_tlistval_name('FLGRECUT',r1.flgrecut,global_v_lang));
      obj_data.put('codappr', r1.codappr);
      obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
--      obj_data.put('item1', to_char(r1.dtereq,'dd/mm/yyyy'));
--      obj_data.put('dteopen', to_char(r1.dtereq,'dd/mm/yyyy'));
--      obj_data.put('dteclose', to_char(r1.dtereq,'dd/mm/yyyy'));
      if r1.codempr is not null then
        obj_data.put('codempr', r1.codempr || ' - ' ||get_temploy_name(r1.codempr,global_v_lang));
      end if;

      obj_data.put('syncond',get_logical_desc(r1.statement));
      if r1.flgjob = 'Y' then
        obj_data.put('statement',get_logical_desc(v_job_remark));
      end if;


    end loop;

    if v_rcnt = 0 then
      obj_data.put('coderror', 200);
      obj_data.put('dtereq', to_char(sysdate,'dd/mm/yyyy'));
      obj_data.put('numseq', 1);
    end if;

    json_str_output := obj_data.to_clob;
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

  procedure gen_job_remark(json_str_output out clob) is
    obj_data        json_object_t;
    v_job_remark    varchar2(1000 char);
  begin

    begin
      select statement
      into v_job_remark
      from tjobcode
      where codjob = p_codjob;
    exception when no_data_found then
      v_job_remark := null;
    end;


    obj_data := json_object_t();

    obj_data.put('coderror', 200);

    obj_data.put('job_remark', get_logical_desc(v_job_remark));

    json_str_output := obj_data.to_clob;
  end;

  procedure get_job_remark (json_str_input in clob,json_str_output out clob) is
    begin
        initial_value(json_str_input);
        if param_msg_error is null then
            gen_job_remark(json_str_output);
        else
            json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        end if;
    exception when others then
        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure check_detail_save as
   p_temp         varchar2(100 char);
   v_secur        boolean := false;
   v_dte_tempst   date;
   v_dte_tempend  date;
   v_temp         number :=0;
   v_exist        varchar2(1 char) := 'N';
  begin
   null;

  end;

  procedure detail_save(json_str_output out clob) as
    v_codapp          varchar2(10) := 'HRMS89U';
    param_json_row    json_object_t;
    param_json        json_object_t;
    v_flg             varchar2(100 char);
    v_seqno           tassetreq.seqno%type;
    v_routeno    			tjobreq.routeno%type;
    v_approvno    	  tjobreq.approvno%type;
    v_table			      varchar2(50 char);
    v_error			      varchar2(100 char);
    v_codempid_next   temploy1.codempid%type;
    v_codempap        temploy1.codempid%type;
    v_codcompap       tcenter.codcomp%type;
    max_approvno      tjobreq.approvno%type;
    v_count           number := 0;
    v_remark          varchar2(200) := get_label_name('HRES62EC2',global_v_lang,130);
  begin
    v_approvno         :=  0 ;
   tjobreq_staappr    := 'A' ;

    chk_workflow.find_next_approve(v_codapp,v_routeno,global_v_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,global_v_codempid,null);
    if v_routeno is null then
        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflph');
        return;
      end if;

      chk_workflow.find_approval(v_codapp,global_v_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,v_table,v_error);
      if v_error is not null then
        param_msg_error := get_error_msg_php(v_error,global_v_lang,v_table);
        return;
      end if;

      --Loop Check Next step
     loop
       v_codempid_next := chk_workflow.check_next_step(v_codapp,v_routeno,global_v_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,global_v_codempid);

       if  v_codempid_next is not null then

          begin
            select approvno
              into max_approvno
              from twkflowh
             where routeno = v_routeno;
          exception when no_data_found then
            max_approvno := 0;
          end;
        v_approvno          := v_approvno + 1 ;
        tjobreq_codappr    := v_codempid_next ;
        tjobreq_staappr    := 'A' ;
        tjobreq_dteappr    := trunc(sysdate);
        tjobreq_remarkap   := v_remark;
        tjobreq_approvno   := v_approvno ;
        if max_approvno <> v_approvno then

            begin
                select  count(*) into v_count
                 from   tapjobrq
                 where  codempid = global_v_codempid
                 and    dtereq   = p_dtereq
                 and    numseq    = p_numseq
                 and    approvno =  v_approvno;
            exception when no_data_found then  v_count := 0;
            end;

            if v_count = 0 then
              insert into tapjobrq
                      (codempid,dtereq,numseq,approvno,
                       codappr,dteappr,
                       staappr,remark,coduser)--dterec, dteapph
              values  (global_v_codempid,p_dtereq,p_numseq,v_approvno,
                       v_codempid_next,trunc(sysdate),
                       'A',v_remark,global_v_coduser);--sysdate,sysdate
            else
              update tapjobrq  set codappr   = v_codempid_next,
                                  dteappr   = trunc(sysdate),
                                  staappr   = 'A',
                                  remark    = v_remark ,
                                  coduser   = global_v_coduser
              where codempid  = global_v_codempid
              and    dtereq   = p_dtereq
              and    numseq    = p_numseq
              and   approvno  = v_approvno;
            end if;

            chk_workflow.find_next_approve(v_codapp,v_routeno,global_v_codempid,to_char(p_dtereq,'dd/mm/yyyy'),p_numseq,v_approvno,global_v_codempid,null);
           end if;
       else
          exit ;
       end if;
     end loop ;
    tjobreq_approvno     := v_approvno ;
    tjobreq_routeno      := v_routeno ;

  end ;

  procedure save_tjobreq is
  v_numseq    tjobreq.numseq%type;
  begin

    begin
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);

      if p_numseq is null then
        begin
          select max(numseq) + 1
          into v_numseq
          from tjobreq
          where codempid = global_v_codempid
          and dtereq = p_dtereq;
        exception when no_data_found then
          v_numseq := 1;
        end;
      end if;

      insert into tjobreq
      (codempid,dtereq,numseq,codcomp,codpos,codjob,
      codempmt,qtyreq,amtincom,
      flgrecut,codrearq,staappr,
      dteupd,coduser,codappr,dteappr,approvno,
      remarkap,flgjob,
      flgcond,routeno,
      syncond,statement,codempr,codbrlc
       )
      values
      (global_v_codempid,p_dtereq,v_numseq,p_codcomp,p_codpos,p_codjob,
      p_codempmt,p_qtyreq,p_amtincom,
      p_flgrecut,p_codrearq,tjobreq_staappr,
      trunc(sysdate),global_v_coduser,tjobreq_codappr,tjobreq_dteappr,tjobreq_approvno,
      p_remarkap,p_flgjob,
      p_flgcond,tjobreq_routeno,
      p_syncond,p_statement,p_codempr,p_codbrlc
       );
    exception when dup_val_on_index then
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      begin
        update tjobreq
        set   codjob  = p_codjob,
              codempmt  = p_codempmt,
              qtyreq  = p_qtyreq,
              amtincom  = p_amtincom,
              flgrecut  = p_flgrecut,
              codrearq  = p_codrearq,
              staappr   = tjobreq_staappr,
              dteupd    = trunc(sysdate),
              coduser  = global_v_coduser,
              codappr  = tjobreq_codappr,
              dteappr   = tjobreq_dteappr,
              approvno   = tjobreq_approvno,
              remarkap    = p_remarkap,
              flgjob  = p_flgjob,
              flgcond   = p_flgcond,
              routeno   = tjobreq_routeno,
              syncond    = p_syncond,
              statement    = p_statement,
              codempr   = p_codempr,
              codbrlc  = p_codbrlc
        where codempid  = global_v_codempid
          and numseq     = p_numseq
          and dtereq    = p_dtereq;
        exception when others then
          rollback;
        end;
    end;

  end;

  procedure post_detail_save(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_detail_save;

    if param_msg_error is null then

      detail_save(json_str_output);

        if param_msg_error is null then
          save_tjobreq;
          commit;

           json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        else
         json_str_output := get_response_message(null,param_msg_error,global_v_lang);
         return;
        end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure delete_index(json_str_output out clob) is
    obj_data        json_object_t;
    v_job_remark    varchar2(1000 char);
  begin

    begin
      update  tjobreq
         set  staappr   = 'C',
              dtecancel = trunc(sysdate),
              coduser 	= global_v_coduser
       where  codempid  = global_v_codempid
         and  dtereq    = p_dtereq
         and  numseq    = p_numseq;
    exception when others then
      null;
    end;

    param_msg_error := get_error_msg_php('HR2421',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);

  end;

  procedure post_delete(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      delete_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;


end;

/
