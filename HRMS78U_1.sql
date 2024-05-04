--------------------------------------------------------
--  DDL for Package Body HRMS78U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS78U" as
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
    json_obj              := json_object_t(json_str);
    p_dtest               := hcm_util.get_string_t(json_obj,'p_dtest');
    p_dteen               := hcm_util.get_string_t(json_obj,'p_dteen');
    p_staappr             := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid            := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_dtereq              := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');
    p_numseq              := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    p_approvno            := to_number(hcm_util.get_string_t(json_obj,'p_approvno'));
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
  end;

  function check_numcont(v_numcont varchar2) return varchar2 is
    v_chkExist     varchar2(2 char);
  begin
    begin
      select 'Y'
      into v_chkExist
      from tloaninf
      where numcont = v_numcont;
    exception when no_data_found then
      v_chkExist := 'N';
    end;
    if v_chkExist = 'Y' then
      return get_error_msg_php('ES0063', global_v_lang);
    else
      return null;
    end if;
  end;
  --
  procedure hrms78u(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;

    v_codappr     temploy1.codempid%type;
    v_nextappr    varchar2(1000 char);
    v_dtest       date;
    v_dteen       date;
    v_row         number;
    v_appno       varchar2(100 char);
    v_chk         varchar2(100 char) := ' ';
    v_date        varchar2(200 char);

    v_codempid    varchar2(4000 char);
    v_numseq      number;
    v_dtereq      varchar2(10 char);
    v_amtappr     varchar2(4000 char);
    v_approvno    number;
    v_yreloan     number;
    v_mthloan     number;

       cursor c_hrms78u_c1 is
       select  codempid,dtereq,numseq,
               amtlon,codlon,numcont,numlon,dtelonst,rateilon,amtlonap,
               staappr,dteappr,codappr,remarkap,
               a.approvno appno,get_tlistval_name('ESSTAREQ',staappr,102) status,b.approvno qtyapp
         from  tloanreq a ,twkflowh b
        where  staappr  in ('P','A')
          and  ('Y' = chk_workflow.check_privilege('HRES77E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
        -- Replace Approve
              or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                        from   twkflowde c
                                                        where  c.routeno  = a.routeno
                                                        and    c.codempid = v_codappr)
              and (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp = 'HRES77E')))
          and a.routeno = b.routeno
          and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
          order by  codempid,dtereq,numseq;

    cursor c_hrms78u_c2 is
      select codempid,dtereq,numseq,
               amtlon,codlon,numcont,numlon,dtelonst,rateilon,amtlonap,
               staappr,dteappr,codappr,remarkap,
               approvno,get_tlistval_name('ESSTAREQ',staappr,102) status
      from tloanreq
      where (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
        and (codempid ,dtereq, numseq) in
                                 ( select codempid, dtereq, numseq
                                     from taploanrq
                                    where staappr = decode(p_staappr,'Y','A',p_staappr)
                                      and codappr = v_codappr
                                      and dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
          order by  codempid,dtereq,numseq;

    cursor c_taptrvrq is
     select codappr , get_temploy_name(codappr,global_v_lang) aname,approvno,
            to_char(dteappr ,'dd/mm/yyyy') dteappr ,typepay,staappr,
            amtappr,to_char(dtepay,'dd/mm/yyyy') dtepay,numperiod,dteyrepay,dtemthpay,remark
       from taptrvrq
      where codempid =  v_codempid
        and dtereq   =  to_date(v_dtereq,'dd/mm/yyyy')
        and numseq   =  v_numseq
        and approvno =  v_approvno;

    begin
      initial_value(json_str_input);
      v_codappr := pdk.check_codempid(global_v_coduser);

      obj_row   := json_object_t();
      v_row     := 0;
      v_dtest   := to_date(replace(p_dtest,'/',null),'ddmmyyyy');
      v_dteen   := to_date(replace(p_dteen,'/',null),'ddmmyyyy');
--      -- get data
      if p_staappr = 'P' then
        for r1 in c_hrms78u_c1 loop
          v_appno  := nvl(r1.appno,0) + 1;
          if nvl(r1.appno,0)+1 = r1.qtyapp then
             v_chk := 'E' ;
          else
             v_chk := v_appno;
          end if;
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('approvno', v_appno);
          obj_data.put('chk_appr', v_chk);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('numseq', to_char(r1.numseq));
          obj_data.put('desc_codlon', get_ttyplone_name(r1.codlon, global_v_lang));
          obj_data.put('amtlon', r1.amtlon);
          --
          v_yreloan  := floor(nvl(r1.numlon, 0) / 12);
          v_mthloan  := mod(nvl(r1.numlon, 0), 12);
          --
          obj_data.put('numlon', v_yreloan || '/' || v_mthloan);
          obj_data.put('numcont', r1.numcont);

          obj_data.put('amtlon2', r1.amtlonap);
          obj_data.put('yearloan', v_yreloan);
          obj_data.put('monthloan', v_mthloan);
          obj_data.put('dtelonst', to_char(r1.dtelonst,'dd/mm/yyyy'));
          obj_data.put('rateilon', r1.rateilon);
          obj_data.put('staappr', r1.staappr);
          obj_data.put('remark', r1.remarkap);
          obj_data.put('status', r1.status);
          obj_data.put('codappr', r1.codappr);
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
          obj_data.put('remarkap', r1.remarkap);
          obj_data.put('staappr', r1.staappr);
          obj_data.put('desc_codempap', get_temploy_name(global_v_codempid,global_v_lang));

          obj_row.put(to_char(v_row),obj_data);
          v_row := v_row+1;
        end loop;
      else
        for r1 in c_hrms78u_c2 loop
          v_nextappr := null;
          if r1.staappr = 'A' then
            v_nextappr := chk_workflow.get_next_approve('HRES77E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
          end if;
          obj_data := json_object_t();
          obj_data.put('approvno', v_appno);
          obj_data.put('chk_appr', v_chk);
          obj_data.put('image', get_emp_img(r1.codempid));
          obj_data.put('codempid', r1.codempid);
          obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
          obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
          obj_data.put('numseq', to_char(r1.numseq));
          obj_data.put('desc_codlon', get_ttyplone_name(r1.codlon, global_v_lang));
          obj_data.put('amtlon', r1.amtlon);
          --
          v_yreloan  := floor(nvl(r1.numlon, 0) / 12);
          v_mthloan  := mod(nvl(r1.numlon, 0), 12);
          --
          obj_data.put('numlon', v_yreloan || '/' || v_mthloan);
          obj_data.put('numcont', r1.numcont);
          obj_data.put('amtlon2', r1.amtlonap);
          obj_data.put('yearloan', v_yreloan);
          obj_data.put('monthloan', v_mthloan);
          obj_data.put('dtelonst', to_char(r1.dtelonst,'dd/mm/yyyy'));
          obj_data.put('rateilon', r1.rateilon);
          obj_data.put('staappr', r1.staappr);
          obj_data.put('remark', r1.remarkap);
          obj_data.put('status', r1.status);
          obj_data.put('codappr', r1.codappr);
          obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
          obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
          obj_data.put('remarkap', r1.remarkap);
          obj_data.put('staappr', r1.staappr);
          obj_data.put('desc_codempap', v_nextappr);

          obj_row.put(to_char(v_row),obj_data);
          v_row := v_row+1;
        end loop;
      end if;
--
      json_str_output := obj_row.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms78u;
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
                    p_amtlon          in varchar2,
                    p_numcont         in varchar2,
                    p_monthloan       in varchar2,
                    p_yearloan        in varchar2,
                    p_dtelonst        in varchar2,
                    p_rateilon        in varchar2) is
    rq_numseq       number                  := p_numseq;
    rq_codempid     temploy1.codempid%type  := p_codempid;
    rq_dtereq       date                    := to_date(p_dtereq,'dd/mm/yyyy');
    rq_chk          varchar2(10 char)       := p_chk;
    v_appseq        number := p_appseq;
    r_tloanreq      tloanreq%rowtype;
    v_approvno      number := null;
    ap_approvno     number := null;
    v_count         number := 0;
    v_staappr       varchar2(1 char);
    v_codeappr      temploy1.codempid%type;
    v_approv        temploy1.codempid%type;
    v_desc          varchar2(600 char)      := get_label_name('HCM_APPRFLW', p_lang,10);-- user22 : 04/07/2016 : STA4590287 || v_desc      varchar2(200 char);
    v_remark        varchar2(2000 char);
    p_codappr       temploy1.codempid%type  := pdk.check_codempid(p_coduser);
    v_max_approv    number;
    v_row_id        varchar2(200 char);
    v_codcomp       temploy1.codcomp%type;
    v_typpayroll    temploy1.typpayroll%type;
    v_formula       tloanreq.formula%type;
    v_statement     tloanreq.statementf%type;
    v_amtlon        tloanreq.amtlon%type;
    v_rateilon      tloanreq.rateilon%type;
    v_numlon        tloanreq.numlon%type;
    v_amtlon_new    tloanreq.amtlon%type;
    v_rateilon_new  tloanreq.rateilon%type;
    v_numlon_new    tloanreq.numlon%type;
    v_amtitotflat_new tloanreq.amtitotflat%type;
    v_amtiflat_new  tloanreq.amtiflat%type;
    v_dteeffec      tloanreq.dteeffec%type;
    v_dtelonen      tloaninf.dtelonen%type;

    cursor c_loanreq2 is
      select *
        from tloanreq2
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and numseq   = rq_numseq;

    cursor c_loanreq3 is
      select *
        from tloanreq3
       where codempid = rq_codempid
         and dtereq   = rq_dtereq
         and numseq   = rq_numseq;
  begin
    v_staappr := p_status ;
    v_zyear   := pdk.check_year(p_lang);

    begin
        select typpayroll
          into v_typpayroll
          from temploy1
         where codempid = rq_codempid;
    exception when others then
        v_typpayroll := null;
    end;
    if v_staappr = 'A' then -- check status = Approve
      v_remark := p_remark_appr;
    elsif v_staappr = 'N' then  -- check status = Not  Approve
      v_remark := p_remark_not_appr;
    end if;
    v_remark  := replace(v_remark,'.',chr(13));
    v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');

    v_amtlon := to_number(p_amtlon);
    v_rateilon := to_number(p_rateilon);
    v_numlon := to_number(p_monthloan) + (p_yearloan * 12);
    begin
     select *
       into r_tloanreq
       from tloanreq
      where codempid = rq_codempid
        and dtereq   = rq_dtereq
        and numseq   = rq_numseq;
    exception when others then
      r_tloanreq := null;
    end;

    begin
      select approvno -- check Max seq Approve
      into   v_max_approv
      from   twkflowh
      where  routeno = r_tloanreq.routeno;
    exception when no_data_found then
      v_max_approv := 0;
    end;

    if nvl(r_tloanreq.approvno,0) < v_appseq then
      ap_approvno := v_appseq;
      begin
         select count(*) into v_count
           from taploanrq
          where codempid = rq_codempid
            and dtereq   = rq_dtereq
            and numseq   = rq_numseq
            and approvno = ap_approvno;
      exception when others then
         v_count := 0;
      end;
      if r_tloanreq.amtlon <> v_amtlon or r_tloanreq.rateilon <> v_rateilon then
         cal_loan(v_amtlon, v_rateilon ,v_numlon,
                  rq_codempid, rq_dtereq, rq_numseq,
                  v_amtlon_new,
                  v_rateilon_new,
                  v_numlon_new,
                  v_amtitotflat_new,
                  v_amtiflat_new);
      else
        v_amtlon_new      := v_amtlon;
        v_rateilon_new    := v_rateilon;
        v_numlon_new      := v_numlon;
        v_amtitotflat_new := r_tloanreq.amtitotflat;
        v_amtiflat_new    := r_tloanreq.amtiflat;
      end if;
      if v_count = 0 then
         insert into taploanrq(codempid,dtereq,numseq,approvno,
                              amtiflat,amtitotflat,amtlon,dteyrpay,formula,
                              mthpay,numlon,prdpay,rateilon,statementf,typpayamt,
                              codappr,dteappr,staappr,remark,
                              dteapph,dteupd,coduser,codcreate)
                values(rq_codempid,rq_dtereq,rq_numseq,ap_approvno,
                       v_amtiflat_new,v_amtitotflat_new,v_amtlon_new,r_tloanreq.dteyrpay,r_tloanreq.formula,
                       r_tloanreq.mthpay, v_numlon_new, r_tloanreq.prdpay, v_rateilon_new, r_tloanreq.statementf, r_tloanreq.typpayamt,
                       p_codappr,to_date(p_dteappr,'dd/mm/yyyy'),v_staappr,v_remark,
                       sysdate,trunc(sysdate),p_coduser,p_coduser);
      else
         update taploanrq
            set amtiflat	  =	v_amtiflat_new,
                amtitotflat	=	v_amtitotflat_new,
                amtlon	    =	v_amtlon_new,
                dteyrpay	  =	r_tloanreq.dteyrpay,
                formula	    =	r_tloanreq.formula,
                mthpay	    =	r_tloanreq.mthpay,
                numlon	    =	v_numlon_new,
                prdpay	    =	r_tloanreq.prdpay,
                rateilon	  =	v_rateilon_new,
                statementf	=	r_tloanreq.statementf,
                typpayamt	=	r_tloanreq.typpayamt,
                codappr   = p_codappr,
                dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                staappr   = v_staappr,
                remark    = v_remark,
                dteupd    = trunc(sysdate),
                coduser   = p_coduser,
                dteapph   = sysdate
           where codempid = rq_codempid
             and dtereq   = rq_dtereq
             and numseq   = rq_numseq
             and approvno = ap_approvno;
      end if;

--       Check Next Step
      v_codeappr  :=  p_codappr ;
      v_approvno  :=  ap_approvno;
--
      chk_workflow.find_next_approve('HRES77E',r_tloanreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr,null);

      if p_status = 'A' and rq_chk <> 'E' then
         v_staappr :=  p_status;
        loop
          v_approv := chk_workflow.check_next_step('HRES77E',r_tloanreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);

          if v_approv is not null then
            v_remark   := v_desc;
            v_approvno := v_approvno + 1 ;
            v_codeappr := v_approv ;

            begin
               select count(*)
                 into v_count
                 from taploanrq
                where codempid  =  rq_codempid
                  and dtereq    =  rq_dtereq
                  and numseq    =  rq_numseq
                  and approvno  =  v_approvno;
            exception when no_data_found then  v_count := 0;
            end;

            if v_count = 0  then
              insert into taploanrq(codempid,dtereq,numseq,approvno,
                              amtiflat,amtitotflat,amtlon,dteyrpay,formula,
                              mthpay,numlon,prdpay,rateilon,statementf,typpayamt,
                              codappr,dteappr,staappr,remark,
                              dteapph,dteupd,coduser,codcreate)
                values(rq_codempid,rq_dtereq,rq_numseq,v_approvno,
                       v_amtiflat_new,v_amtitotflat_new,v_amtlon/*v_amtlon_new*/,r_tloanreq.dteyrpay,r_tloanreq.formula,
                       r_tloanreq.mthpay, v_numlon_new, r_tloanreq.prdpay, v_rateilon_new, r_tloanreq.statementf, r_tloanreq.typpayamt,
                       v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),v_staappr,v_remark,
                       sysdate,trunc(sysdate),p_coduser,p_coduser);
            else
            update taploanrq
                set amtiflat	  =	v_amtiflat_new,
                    amtitotflat	=	v_amtitotflat_new,
                    amtlon	    =	v_amtlon/*v_amtlon_new*/,
                    dteyrpay	  =	r_tloanreq.dteyrpay,
                    formula	    =	r_tloanreq.formula,
                    mthpay	    =	r_tloanreq.mthpay,
                    numlon	    =	v_numlon_new,
                    prdpay	    =	r_tloanreq.prdpay,
                    rateilon	  =	v_rateilon_new,
                    statementf	=	r_tloanreq.statementf,
                    typpayamt	=	r_tloanreq.typpayamt,
                    codappr   = p_codappr,
                    dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
                    staappr   = v_staappr,
                    remark    = v_remark,
                    dteupd    = trunc(sysdate),
                    coduser   = p_coduser,
                    dteapph   = sysdate
               where codempid = rq_codempid
                 and dtereq   = rq_dtereq
                 and numseq   = rq_numseq
                 and approvno = ap_approvno;
            end if;
            chk_workflow.find_next_approve('HRES77E',r_tloanreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr,null);
          else
            exit;
          end if;
        end loop;
      end if; --p_status = 'A' and rq_chk <> 'E'   then

      if v_max_approv = v_approvno then
        rq_chk := 'E';
      end if;
      v_staappr := nvl(p_status,'A');
      if rq_chk = 'E' and p_status = 'A' then
        v_staappr := 'Y';

        begin
          select codcomp
            into v_codcomp
            from temploy1
           where codempid = rq_codempid;
        exception when no_data_found then
          v_codcomp := null;
        end;

        begin
          select dteeffec
            into v_dteeffec
            from tintrteh
           where codcompy = hcm_util.get_codcomp_level(v_codcomp, '1')
             and codlon   = r_tloanreq.codlon
             and dteeffec = (select max(dteeffec)
                               from tintrteh
                              where codcompy = hcm_util.get_codcomp_level(v_codcomp, '1')
                                and codlon   = r_tloanreq.codlon);
        exception when no_data_found then
          null;
        end;
        v_dtelonen  :=  add_months(p_dtelonst,v_numlon_new);
        v_formula := '';
        if r_tloanreq.typintr = '2' then
          v_formula :=  r_tloanreq.formula;
          v_statement := r_tloanreq.statementf;
        end if;
        begin
          insert into tloaninf (numcont, amtiflat, amtitotflat,amtlon, amtnpfin, amtpflat,amtintovr,
                                codcomp,codlon,dteeffec,dteissue,dtelonen,dtelonst,
                                formula, statementf,numlon,rateilon, reaslon,remarkap,
                                staappr,stalon,typintr,
                                codappr,dteappr,
                                codcreate,coduser,
                                codempid,typpayroll
                                )
                      values (p_numcont,  v_amtiflat_new,v_amtitotflat_new,v_amtlon ,v_amtlon_new, 0, (nvl(v_amtitotflat_new,0)-0),
                              v_codcomp, r_tloanreq.codlon, v_dteeffec, p_dtelonst, v_dtelonen , p_dtelonst,
                              v_formula, v_statement, v_numlon_new,v_numlon_new, r_tloanreq.reaslon, v_remark,
                              'Y', 'N', r_tloanreq.typintr,
                              v_codeappr,trunc(sysdate),
                              p_coduser,p_coduser,
                              rq_codempid,v_typpayroll);
        exception when others then null;
        end;

--         delete file before insert
        begin
          delete from tloancol where numcont = p_numcont;
        exception when others then null;
        end;
        for r_loanreq2 in c_loanreq2 loop
          begin
            insert into tloancol (numcont,codcolla,amtcolla,numrefer,descolla,
                                  codcreate,coduser)
                        values (p_numcont,r_loanreq2.codcolla,r_loanreq2.amtcolla,r_loanreq2.numrefer,r_loanreq2.descolla,
                                p_coduser,p_coduser);
          exception when others then null;
          end;
        end loop;

        begin
          delete from tloangar where numcont = p_numcont;
        exception when others then null;
        end;
        for r_loanreq3 in c_loanreq3 loop
          begin
            insert into tloangar (numcont,codempgar,amtgar,
                                  codcreate,coduser)
                        values (p_numcont,r_loanreq3.codempgar,r_loanreq3.amtgar,
                                p_coduser,p_coduser);
          exception when others then null;
          end;
        end loop;
      end if; -- if rq_chk = 'E' and p_status = 'A' then

      update tloanreq
          set staappr   = v_staappr,
              codappr   = v_codeappr,
              approvno  = v_approvno,
              dteappr   = to_date(p_dteappr,'dd/mm/yyyy'),
              coduser   = p_coduser,
              remarkap  = v_remark,
              dteapph   = sysdate,
              numcont   = p_numcont,
              amtlonap  = p_amtlon
        where codempid  = rq_codempid
         and  dtereq    = rq_dtereq
         and  numseq    = rq_numseq;

        begin
            select rowid
              into v_row_id
              from tloanreq
             where codempid = rq_codempid
               and dtereq   = rq_dtereq
               and numseq   = rq_numseq;
        exception when others then
            v_row_id := null;
        end;

        begin 
          chk_workflow.sendmail_to_approve(   p_codapp        => 'HRES77E',
                                              p_codtable_req  => 'tloanreq',
                                              p_rowid_req     => v_row_id,
                                              p_codtable_appr => 'taploanrq',
                                              p_codempid      => rq_codempid,
                                              p_dtereq        => rq_dtereq,
                                              p_seqno         => rq_numseq,
                                              p_staappr       => v_staappr,
                                              p_approvno      => v_approvno,
                                              p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                              p_subject_mail_numseq  => '150',
                                              p_lang          => global_v_lang,
                                              p_coduser       => global_v_coduser);
        exception when others then
          param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
        end;
    end if; -- if nvl(r_tloanreq.approvno,0) < v_appseq then
  exception when others then
    rollback;
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end;
  --
  procedure process_approve(json_str_input in clob, json_str_output out clob) is
    json_obj        json_object_t;
    v_rowcount      number:= 0;
    v_staappr       varchar2(100 char);
    v_appseq        number;
    v_chk           varchar2(10 char);
    v_seqno         number;
    v_codempid      varchar2(100 char);
    v_dtereq        varchar2(100 char);
    v_amtlon	      varchar2(100 char);
    v_numcont	      varchar2(100 char);
    v_amtlon2	      varchar2(100 char);
    v_monthloan	    varchar2(100 char);
    v_yearloan	    varchar2(100 char);
    v_dtelonst	    varchar2(100 char);
    v_rateilon	    varchar2(100 char);
    v_dteappr	      varchar2(100 char);
    p_remark_appr	    varchar2(1000 char);
    p_remark_not_appr	    varchar2(1000 char);
    r_tloanreq	    tloanreq%rowtype;
    v_amtlon_new    tloanreq.amtlon%type;
    v_rateilon_new  tloanreq.rateilon%type;
    v_numlon_new    tloanreq.numlon%type;
  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input);

    v_staappr     := hcm_util.get_string_t(json_obj, 'p_staappr');
    v_appseq      := to_number(hcm_util.get_string_t(json_obj, 'p_approvno'));
    v_chk         := hcm_util.get_string_t(json_obj, 'p_chk_appr');
    v_seqno       := to_number(hcm_util.get_string_t(json_obj, 'p_numseq'));
    v_codempid    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    v_dtereq      := hcm_util.get_string_t(json_obj, 'p_dtereq');
    v_amtlon      := hcm_util.get_string_t(json_obj, 'p_amtlon');
    v_numcont     := hcm_util.get_string_t(json_obj, 'p_numcont');
    v_amtlon2     := hcm_util.get_string_t(json_obj, 'p_amtlon2');
    v_monthloan   := hcm_util.get_string_t(json_obj, 'p_monthloan');
    v_yearloan    := hcm_util.get_string_t(json_obj, 'p_yearloan');
    v_dtelonst    := hcm_util.get_string_t(json_obj, 'p_dtelonst');
    v_rateilon    := hcm_util.get_string_t(json_obj, 'p_rateilon');
    v_dteappr     := hcm_util.get_string_t(json_obj, 'p_dteappr');
    p_remark_appr    := hcm_util.get_string_t(json_obj, 'p_remarkap');
    p_remark_not_appr    := hcm_util.get_string_t(json_obj, 'p_remarkap');
    
    v_staappr := nvl(v_staappr, 'A');
    param_msg_error :=  check_numcont(v_numcont);
      begin
       select *
         into r_tloanreq
         from tloanreq
        where codempid = v_codempid
          and dtereq   = to_date(v_dtereq,'dd/mm/yyyy')
          and numseq   = v_seqno;
      exception when others then
        r_tloanreq := null;
      end;
    if param_msg_error is null then
      approve(global_v_coduser,global_v_lang,to_char(v_rowcount),
              v_staappr,p_remark_appr,p_remark_not_appr,
              to_char(sysdate,'dd/mm/yyyy'),v_appseq,v_chk,
              v_codempid,v_seqno,v_dtereq,
              v_amtlon,v_numcont,v_monthloan,v_yearloan,
              v_dtelonst,v_rateilon);
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

  procedure process_not_approve(json_str_input in clob, json_str_output out clob) is
    json_obj        json_object_t;
    json_obj2       json_object_t;
    json_param      json_object_t;
    r_tloanreq      tloanreq%rowtype;
    v_rowcount      number:= 0;
    v_staappr       varchar2(100 char);
    v_appseq        number;
    v_chk           varchar2(10 char);
    v_seqno         number;
    v_codempid      varchar2(100 char);
    v_dtereq        varchar2(100 char);
    v_amtlon	      varchar2(100 char);
    v_numcont	      varchar2(100 char);
    v_amtlon2	      varchar2(100 char);
    v_monthloan	    varchar2(100 char);
    v_yearloan	    varchar2(100 char);
    v_dtelonst	    varchar2(100 char);
    v_rateilon	    varchar2(100 char);
    v_dteappr	      varchar2(100 char);
    p_remark_appr	    varchar2(1000 char);
    p_remark_not_appr	    varchar2(1000 char);
  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input);
    json_param := hcm_util.get_json_t(json_obj, 'param_json');
    v_rowcount := json_param.get_size;

    p_remark_appr    := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr    := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
    for i in 0..json_param.get_size-1 loop
      json_obj2   := json_object_t(json_param.get(to_char(i)));
      v_staappr   := hcm_util.get_string_t(json_obj2, 'p_staappr');
      v_appseq    := to_number(hcm_util.get_string_t(json_obj2, 'p_approvno'));
      v_chk       := hcm_util.get_string_t(json_obj2, 'p_chk_appr');
      v_seqno     := to_number(hcm_util.get_string_t(json_obj2, 'p_numseq'));
      v_codempid  := hcm_util.get_string_t(json_obj2, 'p_codempid');
      v_dtereq    := hcm_util.get_string_t(json_obj2, 'p_dtereq');

      v_staappr := nvl(v_staappr, 'N');
      begin
       select *
         into r_tloanreq
         from tloanreq
        where codempid = v_codempid
          and dtereq   = to_date(v_dtereq,'dd/mm/yyyy')
          and numseq   = v_seqno;
      exception when others then
        r_tloanreq := null;
      end;
      v_yearloan  := floor(nvl(r_tloanreq.numlon, 0) / 12);
      v_monthloan  := mod(nvl(r_tloanreq.numlon, 0), 12);

      approve(global_v_coduser,global_v_lang,to_char(v_rowcount),
              v_staappr,p_remark_appr,p_remark_not_appr,
              to_char(sysdate,'dd/mm/yyyy'),v_appseq,v_chk,
              v_codempid,v_seqno,v_dtereq,
              r_tloanreq.amtlon,'',v_monthloan,v_yearloan,
              r_tloanreq.dtelonst,r_tloanreq.rateilon);
      exit when param_msg_error is not null;
    end loop;
    if param_msg_error is not null then
      rollback;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    else
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end process_not_approve;
  --
  procedure cal_loan(v_amtlon          in number, v_rateilon in number, v_numlon in number,
                     rq_codempid       in varchar, rq_dtereq in date, rq_numseq  in number,
                     v_amtlon_new      out number,
                     v_rateilon_new    out number,
                     v_numlon_new      out number,
                     v_amtitotflat_new out number,
                     v_amtiflat_new    out number) is
    r_tloanreq  tloanreq%rowtype;
    v_type             varchar2(10 char);
    v_typintr          tloanreq.typintr%type;
    v_formula          tloanreq.formula%type;
    v_statment         tloanreq.statementf%type;
    v_amtlast          number;
    v_amtpint          number;
    v_amtpfin          number;
    v_amtlonap         number;
    v_amttlpay         number;
    v_qtyperiod        number;
    v_qtyperip         number;
    v_amtiflat         number;
    v_amtitotflat      number;

  begin
    begin
     select *
       into r_tloanreq
       from tloanreq
      where codempid = rq_codempid
        and dtereq   = rq_dtereq
        and numseq   = rq_numseq;
    exception when others then
      r_tloanreq := null;
    end;
    v_amtlonap := v_amtlon;
    v_qtyperiod :=  v_numlon;
    v_typintr := r_tloanreq.typintr;
    v_formula :=  r_tloanreq.formula;
--    if v_type = '1' then
    if  v_typintr = '1' then
      v_amttlpay  := ceil(v_amtlonap/  ((1- (1/ power((1+ ((v_rateilon/12)/100)  ), v_qtyperiod)))  /  ((v_rateilon/12)/100) ));
      v_amtpint  := 0;
    elsif v_typintr = '2' then
      --v_amtiflat         :=  v_amtlonap * (v_rateilon/12/100);
      v_qtyperip  := 0;
      v_statment := v_formula;
      v_statment := replace(v_statment, '[A]', v_amtlonap);
      --v_statment := replace(v_statment, '[R]',(v_rateilon/12/100)  );
      v_statment := replace(v_statment, '[R]',(v_rateilon/100)  );
      v_statment := replace(v_statment, '[T]',  v_qtyperiod);
      v_statment := replace(v_statment, '[P]', (v_qtyperiod - v_qtyperip));
      v_statment := 'select '||v_statment||' from dual';
      v_statment := replace(v_statment,'{','');
      v_statment := replace(v_statment,'}','');
      v_amtiflat    := execute_qty(v_statment);

      v_amtitotflat     :=  v_amtiflat* v_qtyperiod;
      v_amttlpay        :=  (v_amtlonap  +  v_amtitotflat)/v_qtyperiod;
      v_amttlpay        := ceil(v_amttlpay);
      v_amtpint          := v_amtiflat;
    elsif v_typintr =  '3' then
      v_amtitotflat     :=  v_amtlonap * (v_rateilon/100) * (v_qtyperiod/12);
      v_amtiflat        :=  v_amtitotflat / v_qtyperiod;          
      --v_amtiflat        :=  v_amtlonap * (v_rateilon/12/100);
      --v_amtitotflat     :=  v_amtiflat* v_qtyperiod;
      v_amttlpay        :=  (v_amtlonap  +  v_amtitotflat)/v_qtyperiod;
      v_amttlpay        := ceil(v_amttlpay);
      v_amtpint         := v_amtiflat;
    end if;  --v_amtlast = ? , v_amtpint  = ?
    v_amtlon_new    := v_amttlpay;
    v_rateilon_new  := v_rateilon;
    v_numlon_new    := v_qtyperiod;
    v_amtitotflat_new := v_amtitotflat;
    v_amtiflat_new    := v_amtiflat;

  end cal_loan;

end hrms78u;

/
