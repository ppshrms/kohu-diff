--------------------------------------------------------
--  DDL for Package Body HRMS75U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRMS75U" is
-- last update: 02/02/2023 17:16  ||STT-SS-2101 /redmine 661

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
    p_dtest             := hcm_util.get_string_t(json_obj,'p_dtest');
    p_dteen             := hcm_util.get_string_t(json_obj,'p_dteen');
    p_staappr           := hcm_util.get_string_t(json_obj,'p_staappr');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    --
    p_dtereq            := hcm_util.get_string_t(json_obj,'p_dtereq');
    p_seqno             := hcm_util.get_string_t(json_obj,'p_numseq');
    p_dtereqr           := hcm_util.get_string_t(json_obj,'p_dtereqr');
    p_dteapprp          := hcm_util.get_string_t(json_obj,'p_dteappr');
    -- submit approve
    p_remark_appr       := hcm_util.get_string_t(json_obj, 'p_remark_appr');
    p_remark_not_appr   := hcm_util.get_string_t(json_obj, 'p_remark_not_appr');
  end;

  procedure hrms75u_index (json_str_input in clob, json_str_output out clob) is
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
    v_codunit     VARCHAR2(20 char);
    v_typebf      VARCHAR2(20 char);
    v_qtywidrw    VARCHAR2(200 char);
    v_dteyrepay     tdtepay.dteyrepay%type;
    v_dtemthpay     tdtepay.dtemthpay%type;
    v_numperiod     tdtepay.numperiod%type;
    v_codcompy     temploy1.codcomp%type;
    v_typpayroll     temploy1.typpayroll%type;
    v_dtepaymt     tdtepay.dtepaymt%type;

    v_flgsecur2       boolean := false;
    v_codunit2       tobfcde.codunit%type;
    v_flglimit2          tobfcde.codunit%type;
    v_typepay2      tobfcde.typepay%type;
    v_typebf2         tobfcde.typebf%type;

    v_amtvalue2    number;
    v_qtytacc2      number; --Time Acc.
    v_amtacc2       number;--Amount Acc.
    v_qtywidrw2    number;
    v_amtwidrw2   number;
    v_qtytalw2       number;
    v_errorno2      varchar2(30 char);

    cursor c_hres75u_c1 is
       select codempid,codappr,a.approvno appno,codobf,dtereq,numseq,amtappr,desnote,numvcher,dteappr,
                 get_temploy_name(codappr,global_v_lang) appname,staappr,amtwidrw,remarkap,get_temploy_name(codempid,global_v_lang) ename,
                 get_tobfcde_name(codobf,global_v_lang) obfname,get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status,
                 b.approvno qtyapp, typepay,qtywidrw,
                 a.typrelate codrel
            from tobfreq a,twkflowh b
           where staappr IN ('P','A')
           and   ('Y' = chk_workflow.check_privilege('HRES74E',codempid,dtereq,numseq,(nvl(a.approvno,0) + 1),v_codappr)
                  -- Replace Approve
                  or ((a.routeno,nvl(a.approvno,0)+ 1) in ( select routeno,numseq
                                                            from   twkflowde c
                                                            where  c.routeno  = a.routeno
                                                            and    c.codempid = v_codappr)
                  and (((sysdate - nvl(dteapph,dteinput))*1440)) >= (select  hrtotal  from twkflpf where codapp ='HRES74E')))

            and a.routeno = b.routeno
            and a.dtereq between nvl(v_dtest,dtereq) and nvl(v_dteen,dtereq)
            and (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
            order by  codempid,dtereq,numseq;

    cursor c_hres75u_c2 is
       select codempid,codappr,approvno,codobf,dtereq,numseq,amtappr,desnote,numvcher,dteappr,
                   get_temploy_name(codappr,global_v_lang) appname,staappr,amtwidrw,remarkap,get_temploy_name(codempid,global_v_lang) ename,
                   get_tobfcde_name(codobf,global_v_lang) obfname,get_tlistval_name('ESSTAREQ',staappr,global_v_lang) status, typepay,qtywidrw,
                   typrelate codrel
              from tobfreq
             where (codempid = nvl(p_codempid,codempid) or lower(get_temploy_name(codempid,global_v_lang)) like '%'||lower(p_codempid)||'%')
               and (codempid ,dtereq,numseq) in (select codempid, dtereq ,numseq
                                                   from  tapobfrq
                                                   where staappr = decode(p_staappr,'Y','A',p_staappr)
                                                   and   codappr = v_codappr
                                                   and   dteappr between nvl(v_dtest,dteappr) and nvl(v_dteen,dteappr) )
             order by  codempid,dtereq;
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
      for r1 in c_hres75u_c1 loop
        v_appno  := nvl(r1.appno,0) + 1;
        if nvl(r1.appno,0)+1 = r1.qtyapp then
           v_chk := 'E' ;
        else
           v_chk := v_appno ;
        end if;
        --
         begin
            select codunit,typebf
              into v_codunit,v_typebf
              from tobfcde
             where codobf = r1.codobf;
          exception when no_data_found then
            v_codunit := null;
          end;

          begin
            select hcm_util.get_codcomp_level(codcomp,1),typpayroll
            into v_codcompy,v_typpayroll
            from temploy1
            where codempid = r1.codempid;
          exception when no_data_found then
            v_codcompy := null;
            v_typpayroll := null;
          end;

          begin
            select dteyrepay,dtemthpay,numperiod,dtepaymt
            into v_dteyrepay,v_dtemthpay,v_numperiod,v_dtepaymt
            from tdtepay
            where trunc(sysdate) between dtestrt and dteend
              and codcompy = v_codcompy
              and typpayroll = v_typpayroll
              and rownum = 1;
            exception when no_data_found then
--<< user4 || 31/01/2023 || 4449#661
               /*v_dteyrepay := null;
               v_dtemthpay := null;
               v_numperiod := null;*/
               v_dteyrepay := to_char(sysdate,'yyyy');
               v_dtemthpay := to_char(to_number(to_char(sysdate,'mm')));
               v_numperiod := '1';
-->> user4 || 31/01/2023 || 4449#661
            end;
        v_dtepaymt := sysdate; -- user4 || 31/01/2023 || 4449#661
        --
        if v_typebf = 'C' then
          v_qtywidrw := to_char(r1.qtywidrw,'fm999,999,990.00');
        elsif v_typebf = 'T' then
          v_qtywidrw := r1.qtywidrw;
        end if;
        v_row    := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno', v_appno);
        obj_data.put('chk_appr', v_chk);
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq', to_char(r1.numseq));
        obj_data.put('codobf', r1.codobf);
        obj_data.put('desc_codobf',r1.obfname);
        obj_data.put('codunit', v_codunit);
        obj_data.put('desc_codunit', get_tcodunit_name(v_codunit,global_v_lang));

--<<STT-SS-2101/redmine661
        begin
                std_bf.get_benefit(r1.codempid, r1.codobf, r1.codrel, r1.dtereq,null,null,0,'Y',
                                            v_codunit2,v_amtvalue2,v_typepay2,v_typebf2,v_flglimit2,
                                            v_qtytacc2, --Time Acc.
                                            v_amtacc2,  --Amount Acc.
                                            v_qtywidrw2, --Quantity Budget
                                            v_amtwidrw2, --Amount Budget
                                            v_qtytalw2,  --Time Budget
                                            v_errorno2);

            exception when others then null;
        end;

        obj_data.put('qtywidrw', v_qtywidrw);
        --obj_data.put('amtappr', to_char(r1.amtappr,'fm999,999,990.00'));        1/2
        --obj_data.put('qtywidrw', 1.1);  if r1.amtappr is nul then end if; if v_typebf2 <> 'C' then null; end if;
        v_amtwidrw2  := least(v_amtwidrw2, nvl(r1.qtywidrw,0) );
        --obj_data.put('amtappr', 'v_typebf2='||v_typebf2||'=v_qtytwidrw2='||v_amtwidrw2||'=v_qtytalw2='||v_qtytalw2);
        obj_data.put('amtappr', to_char(nvl(r1.amtappr,v_amtwidrw2),'fm999,999,990.00'));
-->>STT-SS-2101/redmine661


        obj_data.put('status', r1.status);
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark',r1.remarkap );
        obj_data.put('desc_codempap', chk_workflow.get_next_approve('HRES74E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,nvl(trim(r1.appno),'0'),global_v_lang));
        obj_data.put('typepay',r1.typepay);
        obj_data.put('staappr',r1.staappr);

        obj_data.put('dteyrepay',v_dteyrepay);
        obj_data.put('dtemthpay',v_dtemthpay);
        obj_data.put('numperiod',v_numperiod);
        obj_data.put('dtepay',to_char(v_dtepaymt,'dd/mm/yyyy'));

        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    else
      for r1 in c_hres75u_c2 loop
         begin
            select codunit,typebf
              into v_codunit,v_typebf
              from tobfcde
             where codobf = r1.codobf;
          exception when no_data_found then
            v_codunit := null;
          end;
        --
        v_nextappr := null;
        if r1.staappr = 'A' then
           v_nextappr := chk_workflow.get_next_approve('HRES74E',r1.codempid,to_char(r1.dtereq,'dd/mm/yyyy'),r1.numseq,r1.approvno,global_v_lang);
        end if;
        --
        if v_typebf = 'C' then
          v_qtywidrw := to_char(r1.qtywidrw,'fm999,999,990.00');
        elsif v_typebf = 'T' then
          v_qtywidrw := r1.qtywidrw;
        end if;
        v_row    := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('approvno', v_appno);
        obj_data.put('chk_appr', v_chk);
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('dtereq', to_char(r1.dtereq,'dd/mm/yyyy'));
        obj_data.put('numseq', to_char(r1.numseq));
        obj_data.put('codobf', r1.codobf);
        obj_data.put('desc_codobf',r1.obfname);
        obj_data.put('codunit', v_codunit);
        obj_data.put('desc_codunit', get_tcodunit_name(v_codunit,global_v_lang));
        obj_data.put('qtywidrw', v_qtywidrw);
        obj_data.put('amtappr', to_char(r1.amtappr,'fm999,999,990.00'));
        obj_data.put('status', r1.status);
        obj_data.put('desc_codappr', get_temploy_name(r1.codappr,global_v_lang));
        obj_data.put('dteappr', to_char(r1.dteappr,'dd/mm/yyyy'));
        obj_data.put('remark',convert(r1.remarkap,'AL32UTF8','utf8')); -- user4 || 29/03/2023 || 4449#876 || obj_data.put('remark',r1.remarkap );
        obj_data.put('desc_codempap',v_nextappr);
        obj_data.put('typepay',r1.typepay);
        obj_data.put('staappr',r1.staappr);
        obj_row.put(to_char(v_row-1),obj_data);
      end loop;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end hrms75u_index;

  procedure gen_period(json_str_output out clob)as
    obj_data        json_object_t;
    v_codcompy      temploy1.codcomp%type;
    v_typpayroll    temploy1.typpayroll%type;

    cursor c1 is
      select dteyrepay,dtemthpay,numperiod
        from tdtepay
        where to_date(p_dteapprp,'dd/mm/yyyy') between dtestrt and dteend
          and codcompy = v_codcompy
          and typpayroll = v_typpayroll;
  begin
    begin
      select hcm_util.get_codcompy(codcomp),typpayroll
        into v_codcompy,v_typpayroll
        from temploy1
       where codempid = p_codempid;
    end;
    obj_data    := json_object_t();
    obj_data.put('coderror', '200');
    for i in c1 loop
      obj_data.put('dteyrepay', i.dteyrepay);
      obj_data.put('dtemthpay', i.dtemthpay);
      obj_data.put('numperiod', i.numperiod);
      exit;
    end loop;

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_period(json_str_input in clob, json_str_output out clob) as
   obj_row json_object_t;
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_period(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

 PROCEDURE gen_numvcher ( p_codcomp      in varchar2,
                          p_lang         in varchar2,
                          v_numvcher     in out varchar2 ) IS
   v_count      number      :=0;
   v_seq        number      :=0;
   v_year       number(4)   := to_number(to_char(sysdate,'yyyy'));
   v_month      varchar2(2) := lpad(to_number(to_char(sysdate,'mm')),2,0);
   v_buddha     number(4)   := 543;
   v_codcompy   varchar2(4) := hcm_util.get_codcomp_level(p_codcomp,1);
   v_length     number      := length(hcm_util.get_codcomp_level(p_codcomp,1));

  begin
        v_zyear   := pdk.check_year(p_lang);

        if v_year > 2500 then
            v_year := substr(v_year - v_buddha,3,2);--2564
        else
            v_year := substr((v_year),3,2); --2021
        end if;
         --------------
        begin
                select count(*) ----001 21 0004
                  into v_count
                  from tobfreq
                 where substr(numvcher,1,v_length)        = v_codcompy
                   and substr(numvcher,(v_length+1),2)    = to_number(v_year)
                   and substr(numvcher,(v_length+2)+1,2)  = v_month;


--                 where numvcher like v_codcompy||'%'
--                   and to_char(dtereq,'yyyy') = to_char(sysdate,'yyyy');
        end;
                 v_seq      := v_count+1;
                 v_numvcher := v_codcompy||v_year||v_month||lpad(v_seq,4,0);--001 21 0004
  END;


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
                    p_dtepay          in varchar2,
                    p_amtappr         in number,
                    p_dteyrepay       in number,
                    p_dtemthpay       in number,
                    p_numperiod       in number,
                    p_typpay          in varchar2,
                    p_dtecash         in varchar2,
                    p_codcomp         in varchar2
                    ) is

    rq_codempid  temploy1.codempid%type := p_codempid;
    rq_dtereq    date              := to_date(p_dtereq,'dd/mm/yyyy');
    v_dtereqr    date              := to_date(p_dtereqr,'dd/mm/yyyy');
    rq_numseq    number            := p_seqno;
    v_appseq     number            := p_appseq;
    rq_chk       varchar2(10 char) := p_chk;
    v_tobfreq    tobfreq%ROWTYPE;
    v_tobfcde    tobfcde%ROWTYPE;
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
    v_numlereq   varchar2(12 char);
    vv_dtereqr   date;
    vv_seqnor    number;
    v_row_id     varchar2(200 char);
    v_codcomp    tcenter.codcomp%type;
    v_numvcher   tobfreq.numvcher%type;
    v_qtyalw      tobfcftd.qtyalw%type;
    v_qtytalw     tobfcftd.qtytalw%type;
    v_syncond     tobfcdet.syncond%type;
    v_base_statement  varchar2(4000);
    v_found_syncond   number := 0;
    c1                sys_refcursor;
    temploy1_record   temploy1%rowtype;
    v_qtyappr  number;
    v_amtappr  tapobfrq.amtappr%type;

    --<<User37 14/05/2021
    v_typebf    tobfcde.typebf%type;
    v_amtvalue  number;
    -->>User37 14/05/2021

    cursor c_tobfcdet is
      select numobf,qtyalw,qtytalw,syncond
        from tobfcdet
       where codobf     = v_tobfreq.codobf
      order by numobf;
    begin
      v_staappr := p_status ;
      v_zyear   := pdk.check_year(global_v_lang);
      if v_staappr = 'A' then
        v_remark := p_remark_appr;
      elsif v_staappr = 'N' then
        v_remark := p_remark_not_appr;
      end if;
      v_remark  := replace(v_remark,'.',chr(13));
      v_remark  := replace(replace(v_remark,'^$','&'),'^@','#');
      --
      -- Step 1 => Check Data
      begin
          select *
            into v_tobfreq
            from tobfreq
           where codempid =  rq_codempid
             and dtereq   =  rq_dtereq
             and numseq   =  rq_numseq;
      exception when others then
           v_tobfreq := NULL ;
      end ;
      begin
        select *
          into v_tobfcde
          from tobfcde
         where codobf = v_tobfreq.codobf;
      exception when no_data_found then
          v_tobfreq  := null;
      end;
      begin
        select   approvno
          into   v_max_approv
          from   twkflowh
         where   routeno = v_tobfreq.routeno ;
      exception when no_data_found then
        v_max_approv := 0 ;
      end ;

      IF nvl(v_tobfreq.approvno,0) < v_appseq THEN
        ap_approvno := v_appseq ;
        begin
          select  count(*)
          into   v_count
          from   tapobfrq
          where  codempid = rq_codempid
          and    dtereq   = rq_dtereq
          and    numseq   = rq_numseq
          and    approvno = ap_approvno;
        exception when no_data_found then
          v_count := 0;
        end;
  --step 2 Upadte Data--
              if v_tobfcde.typebf = 'C' then
                v_qtyappr := p_amtappr;
                v_amtappr := p_amtappr;
              elsif v_tobfcde.typebf = 'T' then
                v_qtyappr := p_amtappr;
                begin
                    v_amtappr := v_tobfcde.amtvalue * p_amtappr;
                exception when others then
                    param_msg_error := get_error_msg_php('HR2020',global_v_lang);
                    return;
                end;
              end if;
             if v_count = 0  then
                insert into tapobfrq(codempid,dtereq,numseq,approvno,
                                qtyappr,amtappr,typepay,dtepay,
                                dteyrepay,dtemthpay,numperiod,codappr,
                                dteappr,staappr,remark,dtesnd,
                                dteapph,codcreate,coduser
                                )
                      values   ( rq_codempid, rq_dtereq, rq_numseq, ap_approvno,
                                v_qtyappr,v_amtappr,p_typpay,to_date(p_dtepay,'dd/mm/yyyy'),
                                p_dteyrepay,p_dtemthpay,p_numperiod,p_codappr,
                                to_date(p_dteappr,'dd/mm/yyyy'),v_staappr,v_remark,null,
                                sysdate,p_coduser,p_coduser
                                );
                 else
                        update    tapobfrq
                        set       qtyappr   =   v_qtyappr,
                                  amtappr   =   v_amtappr,
                                  typepay   =   p_typpay ,
                                  dtepay    =   to_date(p_dtepay,'dd/mm/yyyy'),
                                  dteyrepay =   p_dteyrepay,
                                  dtemthpay =   p_dtemthpay,
                                  numperiod =   p_numperiod,
                                  codappr   =   p_codappr,
                                  dteappr   =   to_date(p_dteappr,'dd/mm/yyyy'),
                                  staappr   =   v_staappr,
                                  remark    =   v_remark,
                                  dtesnd    =   null,
                                  dteapph   =   sysdate,
                                  coduser   =   p_coduser
                           where  codempid = rq_codempid
                           and    dtereq   = rq_dtereq
                           and    numseq   = rq_numseq
                           and    approvno = ap_approvno;
              end if;

     -- Step 3 => Check Next Step
        v_codeappr  :=  p_codappr ;
        v_approvno  :=  ap_approvno;

        chk_workflow.find_next_approve('HRES74E',v_tobfreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,ap_approvno,p_codappr);

        if  p_status = 'A' and rq_chk <> 'E'   then
          v_staappr := 'A';
          loop
            v_approv := chk_workflow.check_next_step('HRES74E',v_tobfreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);
            if  v_approv is not null then
              v_remark   := v_desc;
              v_approvno := v_approvno + 1 ;
              v_codeappr := v_approv ;

              begin
                select    count(*)
                  into    v_count
                  from    tapobfrq
                 where    codempid     =  rq_codempid
                   and    dtereq       =  rq_dtereq
                   and    numseq       =  rq_numseq
                   and    approvno     =  v_approvno;
              exception when no_data_found then  v_count := 0;
              end;

              if v_count = 0  then
                   insert into tapobfrq
                                (codempid,dtereq,numseq,approvno,
                                qtyappr,amtappr,typepay,dtepay,
                                dteyrepay,dtemthpay,numperiod,codappr,
                                dteappr,staappr,remark,dtesnd,
                                dteapph,codcreate,coduser
                                )
                      values   ( rq_codempid,rq_dtereq,rq_numseq,v_approvno,
                                v_qtyappr,v_amtappr,p_typpay,to_date(p_dtepay,'dd/mm/yyyy'),
                                p_dteyrepay,p_dtemthpay,p_numperiod,v_codeappr,
                                to_date(p_dteappr,'dd/mm/yyyy'),v_staappr,v_remark,null,
                                sysdate,p_coduser,p_coduser
                                );
                 else
                        update    tapobfrq
                        set       qtyappr   =   v_qtyappr,
                                  amtappr   =   v_amtappr,
                                  typepay   =   p_typpay ,
                                  dtepay    =   to_date(p_dtepay,'dd/mm/yyyy'),
                                  dteyrepay =   p_dteyrepay,
                                  dtemthpay =   p_dtemthpay,
                                  numperiod =   p_numperiod,
                                  codappr   =   v_codeappr,
                                  dteappr   =   to_date(p_dteappr,'dd/mm/yyyy'),
                                  staappr   =   v_staappr,
                                  remark    =   v_remark,
                                  dtesnd    =   null,
                                  dteapph   =   sysdate,
                                  coduser   =   p_coduser
                           where  codempid = rq_codempid
                           and    dtereq   = rq_dtereq
                           and    numseq   = rq_numseq
                           and    approvno = v_approvno;
              end if;
              chk_workflow.find_next_approve('HRES74E',v_tobfreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_numseq,v_approvno,p_codappr);-- user22 : 04/07/2016 : STA4590287 || v_approv := chk_workflow.Check_Next_Approve('HRES74E',v_tobfreq.routeno,rq_codempid,to_char(rq_dtereq,'dd/mm/yyyy'),rq_seqno,v_approvno,p_codappr);
            else
              exit ;
            end if;
          end loop ;

          update tobfreq
            set amtappr     = p_amtappr,
                typepay     = p_typpay,
                approvno    = v_approvno,
                staappr     = 'A',
                dteappr     = to_date(p_dteappr,'dd/mm/yyyy'),
                codappr     = v_codeappr,
                remarkap    = v_remark,
                coduser     = p_coduser,
                dteapph     = sysdate
          where codempid    = rq_codempid
            and dtereq      = rq_dtereq
            and numseq      = rq_numseq;
        end if;

        -- Step 4 => Update staappr
      --  v_staappr := p_status ;
        if v_max_approv = v_approvno then
          rq_chk := 'E' ;
        end if;

        if rq_chk = 'E' and p_status = 'A' then
          v_staappr := 'Y';

          begin
              select    codcomp
                into    v_codcomp
                from    temploy1
               where    codempid = rq_codempid;
            exception when no_data_found then
           v_codcomp := null;
          end;
          gen_numvcher(v_codcomp,p_lang,v_numvcher);

    -- tobfinf
          --<<User37 14/05/2021
          begin
              select typebf
                into v_typebf
                from tobfcde
               where codobf = v_tobfreq.codobf;
            exception when no_data_found then
                null;
          end;
          if v_typebf = 'T' then
            if v_tobfreq.amtwidrw <> 0 and v_tobfreq.qtywidrw <> 0 then
                v_amtvalue := v_tobfreq.amtwidrw / v_tobfreq.qtywidrw;
            end if;
          end if;
          -->>User37 14/05/2021

          insert into tobfinf
                      (numvcher,codempid,codcomp,dtereq,codobf,
                       typrelate,nameobf,numtsmit,qtywidrw,amtwidrw,
                       typepay,dtepay,
                       flgtranpy,dteyrepay,dtemthpay,numperiod,desnote,
                       codappr,dteappr,numvcomp,flgvoucher,
                       codcreate,coduser,amtvalue)
                values
                      (v_numvcher,v_tobfreq.codempid,v_codcomp,v_tobfreq.dtereq,v_tobfreq.codobf,
                       v_tobfreq.typrelate,v_tobfreq.nameobf,v_tobfreq.numtsmit,v_tobfreq.qtywidrw,v_tobfreq.amtwidrw,
                       v_tobfreq.typepay,to_date(p_dtepay,'dd/mm/yyyy'),
                       'N',p_dteyrepay,p_dtemthpay,p_numperiod,v_tobfreq.desnote,
                       v_codeappr,to_date(p_dteappr,'dd/mm/yyyy'),null,'N',
                       p_coduser,p_coduser,v_amtvalue);

       --tobfreqf
          begin
            --<<User37 #4827 21/04/2021
            /*insert into tobfattch(numvcher,numseq,filename,descattch,codcreate,coduser)
            select codempid,seqno,filename,descfile,p_coduser,p_coduser*/
            insert into tobfattch(numvcher,numseq,filename,descattch,codcreate,coduser)
            select v_numvcher,seqno,filename,descfile,p_coduser,p_coduser
            -->>User37 #4827 21/04/2021
              from tobfreqf
             where codempid   = v_tobfreq.codempid
               and dtereq     = v_tobfreq.dtereq
               and numseq     = v_tobfreq.numseq;
          exception when no_data_found then null;
                    when dup_val_on_index then null;
          end;

       --tobfsum
          begin

            begin
                select qtyalw,qtytalw
                  into v_qtyalw,v_qtytalw
                  from tobfcft t1,tobfcftd t2
                 where t1.codempid      = t2.codempid
                   and t1.dtestart      = t2.dtestart
                   and t2.codobf        = v_tobfreq.codobf
                   and t1.codempid      = v_tobfreq.codempid
                   and t1.dtestart = (select max(dtestart)
                                        from tobfcft
                                       where codempid   = v_tobfreq.codempid
                                         and dtestart   <= trunc(sysdate));
            exception when no_data_found then
              null;
            end;



            --<<User37 14/05/2021

            hrbf43e.save_tobfsum( v_tobfreq.codempid, v_tobfreq.dtereq, v_tobfreq.codobf,
                   v_codcomp, v_qtyalw, v_qtytalw);

            /*begin
              --<<User37 #4827 21/04/2021
              --insert into tobfsum(codempid,dteyre,dtemth,codobf,
              --            qtywidrw, qtytwidrw, amtwidrw, qtyalw, qtytalw,
              --            codcomp, dtelwidrw,
              --            codcreate,coduser)
              --values (v_tobfreq.codempid,p_dteyrepay,p_dtemthpay,v_tobfreq.codobf,
              --        v_tobfreq.qtywidrw, v_tobfreq.numtsmit, v_tobfreq.amtwidrw, v_qtyalw, v_qtytalw,
              --        v_codcomp, v_tobfreq.dtereq,
              --        p_coduser,p_coduser);
              insert into tobfsum(codempid,dteyre,dtemth,codobf,
                          qtywidrw, qtytwidrw, amtwidrw, qtyalw, qtytalw,
                          codcomp, dtelwidrw,
                          codcreate,coduser)
              values (v_tobfreq.codempid,to_number(to_char(to_date(p_dtereq,'dd/mm/yyyy'),'yyyy')),to_number(to_char(to_date(p_dtereq,'dd/mm/yyyy'),'mm')),v_tobfreq.codobf,
                      v_tobfreq.qtywidrw, v_tobfreq.numtsmit, v_tobfreq.amtwidrw, v_qtyalw, v_qtytalw,
                      v_codcomp, v_tobfreq.dtereq,
                      p_coduser,p_coduser);
              -->>User37 #4827 21/04/2021
            exception when dup_val_on_index then
              update tobfsum
                 set coduser      = p_coduser,
                     qtywidrw     = v_tobfreq.qtywidrw,
                     qtytwidrw    =  v_tobfreq.numtsmit,
                     amtwidrw     = amtwidrw + p_amtappr
               where codempid     = v_tobfreq.codempid
                 and dteyre       = to_number(to_char(to_date(p_dtereq,'dd/mm/yyyy'),'yyyy'))--User37 #4827 21/04/2021 p_dteyrepay
                 and dtemth       = to_number(to_char(to_date(p_dtereq,'dd/mm/yyyy'),'mm'))--User37 #4827 21/04/2021 p_dtemthpay
                 and codobf       = v_tobfreq.codobf;
            end;*/
            -->>User37 14/05/2021
          exception when no_data_found then
            null;
            begin

              for r_tobfcdet IN c_tobfcdet loop
                v_qtyalw      := r_tobfcdet.qtyalw;
                v_qtytalw     := r_tobfcdet.qtytalw;
                v_syncond     := r_tobfcdet.syncond;

                v_base_statement := 'select * from temploy1 where codempid like '''||v_tobfreq.codempid||''''||' and exists (SELECT CODEMPID FROM V_HRTR WHERE '||v_syncond|| ' and codempid =  '''||v_tobfreq.codempid||''')';
                begin
                  open c1 for v_base_statement;
                  loop
                    fetch c1 into temploy1_record;
                    exit when ( c1%notfound );
                    v_found_syncond := v_found_syncond + 1;
                  end loop;
                exception when others then
                  null;
                end;
                exit when v_found_syncond > 0;
              end loop;

              --<<User37 14/05/2021
              hrbf43e.save_tobfsum( v_tobfreq.codempid, v_tobfreq.dtereq, v_tobfreq.codobf,
                   v_codcomp, v_qtyalw, v_qtytalw);
              /*begin
                --<<User37 #4827 21/04/2021
                insert into tobfsum(codempid,dteyre,dtemth,codobf,
                            qtywidrw, qtytwidrw,amtwidrw,qtyalw,qtytalw,
                            codcomp, dtelwidrw,codcreate,coduser)
                values (v_tobfreq.codempid,to_number(to_char(to_date(p_dtereq,'dd/mm/yyyy'),'yyyy')),13,v_tobfreq.codobf,
                        v_tobfreq.qtyappr, v_tobfreq.numtsmit, v_tobfreq.amtwidrw, v_qtyalw, v_qtytalw,
                        v_codcomp, p_dtereqr,p_coduser,p_coduser);
                --insert into tobfsum(codempid,dteyre,dtemth,codobf,
                --            qtywidrw, qtytwidrw,amtwidrw,qtyalw,qtytalw,
                --            codcomp, dtelwidrw,codcreate,coduser)
                --values (v_tobfreq.codempid,to_char(sysdate,'yyyy'),13,v_tobfreq.codobf,
                --        v_tobfreq.qtyappr, v_tobfreq.numtsmit, v_tobfreq.amtwidrw, v_qtyalw, v_qtytalw,
                --        v_codcomp, p_dtereqr,p_coduser,p_coduser);
                -->>User37 #4827 21/04/2021
              exception when dup_val_on_index then
                update tobfsum
                   set coduser      = p_coduser,
                       qtywidrw     = v_tobfreq.qtyappr,
                       qtytwidrw    = v_tobfreq.numtsmit,
                       amtwidrw     = amtwidrw + p_amtappr
                 where codempid     = v_tobfreq.codempid
                   and dteyre       = to_number(to_char(to_date(p_dtereq,'dd/mm/yyyy'),'yyyy')) --User37 #4827 21/04/2021 to_char(sysdate,'yyyy')
                   and dtemth       = 13
                   and codobf       = v_tobfreq.codobf;
              end;*/
              -->>User37 14/05/2021
            exception when no_data_found then null;
            end;
          end;

       --tobfdep
          --<<User37 14/05/2021

          hrbf43e.save_tobfdep(rq_dtereq,v_tobfreq.codobf,v_codcomp);

          /*begin
            --<<User37 #4827 21/04/2021
            --insert into tobfdep(dteyre,dtemth,codcomp,codobf,qtyhuman,
            --                    qtywidrw,qtytwidrw,amtwidrw,codcreate,coduser)
            --values (to_char(sysdate,'yyyy'),to_char(sysdate,'mm'),v_codcomp,v_tobfreq.codobf,1,
            --       v_tobfreq.qtywidrw,v_tobfreq.numtsmit,v_amtappr,p_coduser,p_coduser);
            insert into tobfdep(dteyre,dtemth,codcomp,codobf,qtyhuman,
                                qtywidrw,qtytwidrw,amtwidrw,codcreate,coduser)
            values (to_number(to_char(to_date(p_dtereq,'dd/mm/yyyy'),'yyyy')),to_number(to_char(to_date(p_dtereq,'dd/mm/yyyy'),'mm')),v_codcomp,v_tobfreq.codobf,1,
                    v_tobfreq.qtywidrw,v_tobfreq.numtsmit,v_amtappr,p_coduser,p_coduser);
            -->>User37 #4827 21/04/2021
          exception when dup_val_on_index then
            update tobfdep
               set qtyhuman     = qtyhuman + 1,
                   qtywidrw     = v_tobfreq.qtywidrw,
                   qtytwidrw    = v_tobfreq.numtsmit,
                   amtwidrw     = amtwidrw + v_amtappr
             where dteyre       = to_number(to_char(to_date(p_dtereq,'dd/mm/yyyy'),'yyyy'))--User37 #4827 21/04/2021 to_char(sysdate,'yyyy')
               and dtemth       = to_number(to_char(to_date(p_dtereq,'dd/mm/yyyy'),'mm'))--User37 #4827 21/04/2021 to_char(sysdate,'mm')
               and codcomp      = v_codcomp
               and codobf       = v_tobfreq.codobf;
          end;*/
          -->>User37 14/05/2021


        end if;

          update tobfreq
            set qtyappr   =   v_qtyappr,
                amtappr   =   v_amtappr,
                approvno    = v_approvno,
                staappr     = v_staappr,
                numvcher    = v_numvcher,
                dteappr     = to_date(p_dteappr,'dd/mm/yyyy'),
                codappr     = v_codeappr,
                remarkap    = v_remark,
                coduser     = p_coduser,
                dteapph     = sysdate
          where codempid    = rq_codempid
            and dtereq      = rq_dtereq
            and numseq      = rq_numseq;

        commit;

  --Step 5 Send Mail--
        begin
            select  rowid
              into  v_row_id
              from  tobfreq
             where  codempid = rq_codempid
               and  numseq   = rq_numseq
               and  dtereq   = rq_dtereq ;
        exception when others then
            v_tobfreq := null ;
        end;

        -- Send mail
        begin
          chk_workflow.sendmail_to_approve( p_codapp        => 'HRES74E',
                                            p_codtable_req  => 'tobfreq',
                                            p_rowid_req     => v_row_id,
                                            p_codtable_appr => 'tapobfrq',
                                            p_codempid      => rq_codempid,
                                            p_dtereq        => rq_dtereq,
                                            p_seqno         => rq_numseq,
                                            p_staappr       => v_staappr,
                                            p_approvno      => v_approvno,
                                            p_subject_mail_codapp  => 'AUTOSENDMAIL',
                                            p_subject_mail_numseq  => '130',
                                            p_lang          => global_v_lang,
                                            p_coduser       => global_v_coduser);
        exception when others then
          param_msg_error_mail := get_error_msg_php('HR2403',global_v_lang);
        end;
      end if; --Check Approve

    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
     rollback;
    end;
  --

  procedure process_approve(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    json_obj2       json_object_t;
    v_rowcount      number:= 0;
    v_staappr       varchar2(100);
    v_appseq        number;
    v_chk           varchar2(10);
    v_numseq        number;
    v_codempid      varchar2(100);
    v_dtereq        varchar2(100);
    v_dteappr       varchar2(200);
    v_dtepay        varchar2(200);
    v_amtappr       number;
    v_amtwidrw      number;
    v_typpay        varchar2(100);
    v_dtecash       varchar2(100);
    v_dteyrepay     number;
    v_dtemthpay     number;
    v_numperiod     number;

  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input).get_object('param_json');
    v_staappr       := hcm_util.get_string_t(json_obj, 'p_staappr');
    v_appseq        := to_number(hcm_util.get_string_t(json_obj, 'p_approvno'));
    v_chk           := hcm_util.get_string_t(json_obj, 'p_chk_appr');
    v_codempid      := hcm_util.get_string_t(json_obj, 'p_codempid');
    v_dtereq        := hcm_util.get_string_t(json_obj, 'p_dtereq');
    v_numseq        := to_number(hcm_util.get_string_t(json_obj, 'p_numseq'));
    v_dteappr       := hcm_util.get_string_t(json_obj, 'p_dteappr');
    v_dtepay        := hcm_util.get_string_t(json_obj, 'p_dtepay');
--<<STT-SS-2101||redmine764
    --v_amtappr       := to_number(hcm_util.get_string_t(json_obj, 'p_amtappr'));
    v_amtappr       := to_number(replace(hcm_util.get_string_t(json_obj, 'p_amtappr'),','));
--<<STT-SS-2101||redmine764

    v_typpay        := hcm_util.get_string_t(json_obj, 'p_typepay');
    v_dtecash       := hcm_util.get_string_t(json_obj, 'p_dtecash');
    v_dteyrepay     := to_number(hcm_util.get_string_t(json_obj, 'p_dteyrepay'));
    v_dtemthpay     := to_number(hcm_util.get_string_t(json_obj, 'p_dtemthpay'));
    v_numperiod     := to_number(hcm_util.get_string_t(json_obj, 'p_numperiod'));

    v_staappr := nvl(v_staappr, 'A');
    approve( global_v_coduser, global_v_lang, '1', v_staappr,
                    p_remark_appr,p_remark_not_appr,to_char(sysdate,'dd/mm/yyyy'),
                    v_appseq,v_chk,v_codempid,v_numseq,v_dtereq,v_dtepay,
                    v_amtappr,v_dteyrepay,v_dtemthpay,v_numperiod,v_typpay,v_dtecash, '');

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
  procedure gen_detail(json_str_output out clob) as
    obj_data        json_object_t;
    v_tobfreq       tobfreq%rowtype;
    tobfinf_rec     tobfinf%rowtype;
    v_flag      varchar(50 char) := '';
    v_codcomp   temploy1.codcomp%type;
    v_codpos    temploy1.codpos%type;
    v_costcenter  tcenter.costcent%type;
    v_amtvalue    tobfcde.amtvalue%type;
    v_codunit     tobfcde.codunit%type;
    v_typebf     tobfcde.typebf%type;
  begin
    -- check numseq
    if p_seqno is null then
      begin
        select nvl(max(numseq),0) + 1 into p_seqno
          from tobfreq
         where codempid = p_codempid
           and dtereq = to_date(p_dtereq,'dd/mm/yyyy');
      exception when no_data_found then
        p_seqno := 1;
      end;
    end if;
--  get data from TOBFREQ
    begin
      select * into v_tobfreq
        from tobfreq
       where codempid = p_codempid
         and dtereq = to_date(p_dtereq,'dd/mm/yyyy')
         and numseq = p_seqno;
    exception when no_data_found then
      v_tobfreq := null;
    end;
    begin
      select codcomp,codpos into v_codcomp,v_codpos
      from temploy1
      where codempid = p_codempid;
    exception when no_data_found then null;
    end;
    begin
      select costcent into v_costcenter
      from tcenter
      where codcomp = v_codcomp;
    exception when no_data_found then null;
    end;
    begin
      select amtvalue, codunit, typebf into v_amtvalue, v_codunit, v_typebf
      from tobfcde
      where codobf = v_tobfreq.codobf;
    exception when no_data_found then null;
    end;
    begin
      select * into tobfinf_rec
        from tobfinf
       where numvcher = v_tobfreq.numvcher;
    exception when no_data_found then
      tobfinf_rec := null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror',200);
    obj_data.put('codempid', p_codempid );
    obj_data.put('desc_codempid', get_temploy_name(p_codempid, global_v_lang) );
    obj_data.put('codcomp', v_codcomp );
    obj_data.put('desc_codcomp', get_tcenter_name(v_codcomp, global_v_lang) );
    obj_data.put('codcenter', v_costcenter );
    obj_data.put('desc_codcenter', get_tcoscent_name(v_costcenter,global_v_lang) );
    obj_data.put('codobf', v_tobfreq.codobf ||' - '||get_tobfcde_name(v_tobfreq.codobf,global_v_lang));
    obj_data.put('codunit', v_codunit || ' - ' || get_tcodunit_name(v_codunit,global_v_lang) );
    obj_data.put('amtvalue', v_amtvalue );
    obj_data.put('typrelate', get_tlistval_name('TYPERELATE',v_tobfreq.typrelate,global_v_lang) );
    obj_data.put('nameobf', v_tobfreq.nameobf );
    obj_data.put('numtsmit', v_tobfreq.numtsmit );
    obj_data.put('qtywidrw', v_tobfreq.qtywidrw );
    obj_data.put('amtwidrw', v_tobfreq.amtwidrw );
    obj_data.put('typepay', get_tlistval_name('TYPPAYBF',v_tobfreq.typepay,global_v_lang) );
    obj_data.put('desnote', v_tobfreq.desnote );
    obj_data.put('dtereq', p_dtereq);
    obj_data.put('numseq', p_seqno );
    obj_data.put('typebf', get_tlistval_name('TYPPAYBNF',v_typebf,global_v_lang));
    obj_data.put('numvcher', v_tobfreq.numvcher );
    obj_data.put('dtepay', to_char(tobfinf_rec.dtepay,'dd/mm/yyyy') );
    obj_data.put('dteappr', to_char(v_tobfreq.dteappr,'dd/mm/yyyy') );
    obj_data.put('codappr', v_tobfreq.codappr );
    obj_data.put('desc_codappr', get_temploy_name(v_tobfreq.codappr, global_v_lang)  );

    json_str_output := obj_data.to_clob;

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_detail;

  procedure gen_detail_table(json_str_output out clob) as
    obj_rows    json_object_t;
    obj_data    json_object_t;
    v_row       number := 0;
    cursor c1 is
        select numseq,filename,descfile
        from tobfreqf
        where codempid = p_codempid
        and dtereq = to_date(p_dtereq,'dd/mm/yyyy')
        and numseq = p_seqno;
  begin
    -- check numseq
    if p_seqno is null then
      begin
        select nvl(max(numseq),0) + 1 into p_seqno
          from tobfreq
         where codempid = p_codempid
           and dtereq = to_date(p_dtereq,'dd/mm/yyyy');
      exception when no_data_found then
        p_seqno := 1;
      end;
    end if;
    obj_rows := json_object_t();
    for i in c1 loop
        v_row := v_row + 1;
        obj_data := json_object_t();
        obj_data.put('numseq',i.numseq);
        obj_data.put('filename',i.filename);
        obj_data.put('path_filename', get_tsetup_value('PATHWORKPHP')||get_tfolderd('HRES74E')||'/'||i.filename);
        obj_data.put('descfile',i.descfile);
        obj_data.put('coderror',200);
        obj_rows.put(to_char(v_row-1),obj_data);
    end loop;
    json_str_output := obj_rows.to_clob;
  end gen_detail_table;

  procedure get_detail(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_detail(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail;

  procedure get_detail_table(json_str_input in clob, json_str_output out clob) AS
  BEGIN
    initial_value(json_str_input);
    gen_detail_table(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  END get_detail_table;
end;

/
