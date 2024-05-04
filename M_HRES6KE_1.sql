--------------------------------------------------------
--  DDL for Package Body M_HRES6KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRES6KE" is
/* Cust-Modify: KOHU-HR2301 */ 
-- last update: 08/12/2023 16:40

  procedure select_ttotreq(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    v_columns       varchar2(4000);
    v_table         varchar2(4000);
    v_where         varchar2(4000);
    v_orderby       varchar2(4000);
    v_start         varchar2(4000);
    v_end           varchar2(4000);
    v_between       varchar2(4000);
    v_cursor        number;
    v_dummy         integer;
    v_stmt          varchar2(5000);
    v_row           number;
    v_date          date;
    v_number        number;
    v_varchar2      varchar2(1000);
    tcontrot_flgchglv   tcontrot.flgchglv%type;
    v_cost_center   tcenter.costcent%type;
    -- check null data --
    v_flg_exist     boolean := false;

    v_rcnt          number := 0;
    obj_row         json_object_t;
    obj_data        json_object_t;

    cursor c1 is
      select codempid,dtereq,numseq,numotreq,codcomp,dtestrt,dteend,timbstr,timbend,timdstr,timdend,timastr,
             timaend,codrem,staappr,codappr,dteappr,dteupd,coduser,remarkap,approvno,routeno
             ,remark,flgsend,dtesnd,codinput,numotgen,dtecancel,dteinput,dteapph,flgagency,
             flgchglv,codcompw,qtyminb,qtymind,qtymina
        from ttotreq
       where codempid like nvl(b_index_codempid,codempid)
         and codcomp like b_index_codcomp||'%'
         and numseq like nvl(b_index_numseq,numseq)
         and (
            (b_index_numseq is not null and dtereq between nvl(b_index_dtereq_st,dtereq) and nvl(b_index_dtereq_en,dtereq)) -- detail page
         or (b_index_numseq is null and ( -- index page
                dtestrt  between nvl(b_index_dtereq_st,dtestrt) and nvl(b_index_dtereq_en,dtestrt)
                    or
                dteend  between nvl(b_index_dtereq_st,dteend) and nvl(b_index_dtereq_en,dteend)
                    or
                b_index_dtereq_st between     dtestrt  and dteend
                    or
                b_index_dtereq_en between     dtestrt  and dteend
              ))
         )
      order by codempid, dtereq desc, numseq desc;

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    v_row := 0;
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    --
--    if not v_flg_exist then
--      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttotreq');
--      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--      return;
--    end if;
    --
    for i in c1 loop
      begin
        select costcent into v_cost_center
          from tcenter
         where codcomp = i.codcompw
           and rownum <= 1
      order by codcomp;
      exception when no_data_found then
        v_cost_center := null;
      end;
      --
      begin
        select flgchglv  
          into tcontrot_flgchglv
          from tcontrot
         where codcompy = hcm_util.get_codcomp_level(i.codcomp,1)
           and dteeffec = (select max(dteeffec) from tcontrot
                            where codcompy = hcm_util.get_codcomp_level(i.codcomp,1)
                              and dteeffec <= sysdate);
      exception when no_data_found then
        tcontrot_flgchglv   := null;
      end;
      --

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codempid',global_v_codempid);
      obj_data.put('codempid_query',i.codempid);
      obj_data.put('dtereq',nvl(to_char(i.dtereq,'dd/mm/yyyy'),''));
      obj_data.put('numseq',i.numseq);
      obj_data.put('numotreq',i.numotreq);
      obj_data.put('codcomp',i.codcomp);
      obj_data.put('dtestrt',nvl(to_char(i.dtestrt,'dd/mm/yyyy'),''));
      obj_data.put('dteend',nvl(to_char(i.dteend,'dd/mm/yyyy'),''));
      obj_data.put('timbstr',i.timbstr);
      obj_data.put('timbend',i.timbend);
      obj_data.put('timdstr',i.timdstr);
      obj_data.put('timdend',i.timdend);
      obj_data.put('timastr',i.timastr);
      obj_data.put('timaend',i.timaend);
      obj_data.put('codrem',i.codrem);
      obj_data.put('staappr',i.staappr);
      obj_data.put('codappr',i.codappr);
      obj_data.put('dteappr',nvl(to_char(i.dteappr,'dd/mm/yyyy'),''));
      obj_data.put('dteupd',nvl(to_char(i.dteupd,'dd/mm/yyyy'),''));
      obj_data.put('coduser',i.coduser);
      obj_data.put('remarkap',i.remarkap);
      obj_data.put('approvno',i.approvno);
      obj_data.put('routeno',i.routeno);
      obj_data.put('remark',i.remark);
      obj_data.put('flgsend',i.flgsend);
      obj_data.put('dtesnd',nvl(to_char(i.dtesnd,'dd/mm/yyyy'),''));
      obj_data.put('codinput',i.codinput);
      obj_data.put('numotgen',i.numotgen);
      obj_data.put('dtecancel',nvl(to_char(i.dtecancel,'dd/mm/yyyy'),''));
      obj_data.put('dteinput',nvl(to_char(i.dteinput,'dd/mm/yyyy'),''));
      obj_data.put('dteapph',nvl(to_char(i.dteapph,'dd/mm/yyyy'),''));
      obj_data.put('flgagency',nvl(i.flgagency,' '));
      obj_data.put('desc_codempid',nvl(get_temploy_name(trim(global_v_codempid),global_v_lang),''));
      obj_data.put('desc_codempid_query',nvl(get_temploy_name(trim(i.codempid),global_v_lang),''));
      obj_data.put('desc_codcomp',nvl(get_tcenter_name(trim(i.codcomp),global_v_lang),''));
      obj_data.put('desc_stareq',nvl(get_tlistval_name('ESSTAREQ',trim(i.staappr),global_v_lang),''));
      obj_data.put('desc_codappr',i.codappr || ' ' || nvl(get_temploy_name(trim(i.codappr),global_v_lang),''));
      obj_data.put('desc_codempap',nvl(chk_workflow.get_next_approve('HRES6KE',i.codempid,to_char(i.dtereq,'dd/mm/yyyy'),i.numseq,nvl(trim(i.approvno),'0'),global_v_lang),''));
      obj_data.put('dterange',to_char(i.dtestrt, 'dd/mm/yyyy')||' - '||to_char(i.dteend, 'dd/mm/yyyy'));
      obj_data.put('tcontrot_flgchglv',tcontrot_flgchglv);
      obj_data.put('flgchglv',i.flgchglv);
      obj_data.put('codcompw',i.codcompw);
      obj_data.put('qtyminb',hcm_util.convert_minute_to_time(i.qtyminb));
      obj_data.put('qtymind',hcm_util.convert_minute_to_time(i.qtymind));
      obj_data.put('qtymina',hcm_util.convert_minute_to_time(i.qtymina));
      if i.codcompw is not null then
        obj_data.put('costcent',v_cost_center);
      end if;

      obj_row.put(to_char(v_row),obj_data);
      v_row := v_row+1;
    end loop; -- end for
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end select_ttotreq;

  procedure get_detail(json_str_input in clob, json_str_output out clob) as
    json_obj            json_object_t;
    v_columns           varchar2(4000);
    v_table             varchar2(4000);
    v_where             varchar2(4000);
    v_orderby           varchar2(4000);
    v_start             varchar2(4000);
    v_end               varchar2(4000);
    v_between           varchar2(4000);
    v_cursor            number;
    v_dummy             integer;
    v_stmt              varchar2(5000);
    v_row               number;
    v_date              date;
    v_number            number;
    v_varchar2          varchar2(1000);
    tcontrot_flgchglv   tcontrot.flgchglv%type;
    v_cost_center       tcenter.costcent%type;
    -- check null data --
    v_flg_exist         boolean := false;

    v_rcnt              number := 0;
    obj_row             json_object_t;
    obj_data            json_object_t;
    obj_detail          json_object_t;
    obj_main            json_object_t;


    --<< user18 ST11 02/07/2021 detail cumulative overtime for week period
    v_codempid          ttotreq.codempid%type;
    v_dtereq            ttotreq.dtereq%type;
    v_numseq            ttotreq.numseq%type;
    v_numotreq          ttotreq.numotreq%type;

    v_dteot             date;
    v_typalert          tcontrot.typalert%type;
    -->> user18 ST11 02/07/2021 detail cumulative overtime for week period

    cursor c1 is
      select codempid,dtereq,numseq,numotreq,codcomp,dtestrt,dteend,timbstr,timbend,timdstr,timdend,timastr,
             timaend,codrem,staappr,codappr,dteappr,dteupd,coduser,remarkap,approvno,routeno
             ,remark,flgsend,dtesnd,codinput,numotgen,dtecancel,dteinput,dteapph,flgagency,
             flgchglv,codcompw,qtyminb,qtymind,qtymina
        from ttotreq
       where codempid = b_index_codempid
         and numseq = b_index_numseq
         and dtereq = b_index_dtereq;

  begin
    initial_value(json_str_input);
    obj_main    := json_object_t();
    obj_row     := json_object_t();
    v_row       := 0;

    --
    for i in c1 loop
      begin
        select costcent into v_cost_center
          from tcenter
         where codcomp = i.codcompw
           and rownum <= 1
      order by codcomp;
      exception when no_data_found then
        v_cost_center := null;
      end;
      --
      begin
        select flgchglv,nvl(typalert,'N')  
          into tcontrot_flgchglv, v_typalert
          from tcontrot
         where codcompy = hcm_util.get_codcomp_level(i.codcomp,1)
           and dteeffec = (select max(dteeffec) from tcontrot
                            where codcompy = hcm_util.get_codcomp_level(i.codcomp,1)
                              and dteeffec <= sysdate);
      exception when no_data_found then
        tcontrot_flgchglv   := null;
        v_typalert          := 'N';
      end;
      --      
      -->> user18 ST11 03/08/2021 change std detail
      v_codempid      := i.codempid;
      v_dtereq        := i.dtereq;
      v_numseq        := i.numseq;
      --<< user18 ST11 03/08/2021 change std detail

      obj_detail := json_object_t();
      obj_detail.put('codempid',global_v_codempid);
      obj_detail.put('codempid_query',i.codempid);
      obj_detail.put('dtereq',nvl(to_char(i.dtereq,'dd/mm/yyyy'),''));
      obj_detail.put('numseq',i.numseq);
      obj_detail.put('numotreq',i.numotreq);
      obj_detail.put('codcomp',i.codcomp);
      obj_detail.put('dtestrt',nvl(to_char(i.dtestrt,'dd/mm/yyyy'),''));
      obj_detail.put('dteend',nvl(to_char(i.dteend,'dd/mm/yyyy'),''));
      obj_detail.put('timbstr',i.timbstr);
      obj_detail.put('timbend',i.timbend);
      obj_detail.put('timdstr',i.timdstr);
      obj_detail.put('timdend',i.timdend);
      obj_detail.put('timastr',i.timastr);
      obj_detail.put('timaend',i.timaend);
      obj_detail.put('codrem',i.codrem);
      obj_detail.put('staappr',i.staappr);
      obj_detail.put('codappr',i.codappr);
      obj_detail.put('dteappr',nvl(to_char(i.dteappr,'dd/mm/yyyy'),''));
      obj_detail.put('dteupd',nvl(to_char(i.dteupd,'dd/mm/yyyy'),''));
      obj_detail.put('coduser',i.coduser);
      obj_detail.put('remarkap',i.remarkap);
      obj_detail.put('approvno',i.approvno);
      obj_detail.put('routeno',i.routeno);
      obj_detail.put('remark',i.remark);
      obj_detail.put('flgsend',i.flgsend);
      obj_detail.put('dtesnd',nvl(to_char(i.dtesnd,'dd/mm/yyyy'),''));
      obj_detail.put('codinput',i.codinput);
      obj_detail.put('numotgen',i.numotgen);
      obj_detail.put('dtecancel',nvl(to_char(i.dtecancel,'dd/mm/yyyy'),''));
      obj_detail.put('dteinput',nvl(to_char(i.dteinput,'dd/mm/yyyy'),''));
      obj_detail.put('dteapph',nvl(to_char(i.dteapph,'dd/mm/yyyy'),''));
      obj_detail.put('flgagency',nvl(i.flgagency,' '));
      obj_detail.put('desc_codempid',nvl(get_temploy_name(trim(global_v_codempid),global_v_lang),''));
      obj_detail.put('desc_codempid_query',nvl(get_temploy_name(trim(i.codempid),global_v_lang),''));
      obj_detail.put('desc_codcomp',nvl(get_tcenter_name(trim(i.codcomp),global_v_lang),''));
      obj_detail.put('desc_stareq',nvl(get_tlistval_name('ESSTAREQ',trim(i.staappr),global_v_lang),''));
      obj_detail.put('desc_codappr',i.codappr || ' ' || nvl(get_temploy_name(trim(i.codappr),global_v_lang),''));
      obj_detail.put('desc_codempap',nvl(chk_workflow.get_next_approve('HRES6KE',i.codempid,to_char(i.dtereq,'dd/mm/yyyy'),i.numseq,nvl(trim(i.approvno),'0'),global_v_lang),''));
      obj_detail.put('dterange',to_char(i.dtestrt, 'dd/mm/yyyy')||' - '||to_char(i.dteend, 'dd/mm/yyyy'));
      obj_detail.put('tcontrot_flgchglv',tcontrot_flgchglv);
      obj_detail.put('flgchglv',i.flgchglv);
      obj_detail.put('codcompw',i.codcompw);
      obj_detail.put('qtyminb',hcm_util.convert_minute_to_time(i.qtyminb));
      obj_detail.put('qtymind',hcm_util.convert_minute_to_time(i.qtymind));
      obj_detail.put('qtymina',hcm_util.convert_minute_to_time(i.qtymina));
      if i.codcompw is not null then
        obj_detail.put('costcent',v_cost_center);
      end if;
      -->> user18 ST11 31/08/2021 change std detail
      obj_detail.put('typalert',v_typalert);


      if v_typalert <> 'N' then
        std_ot.get_week_ot(i.codempid, i.numotreq,i.dtereq,i.numseq,i.dtestrt,i.dteend,
                           i.qtyminb, i.timbend, i.timbstr,
                           i.qtymind, i.timdend, i.timdstr,
                           i.qtymina, i.timaend, i.timastr,
                           global_v_codempid,
                           a_dtestweek,a_dteenweek,
                           a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
        for n in 1..v_qtyperiod loop
            obj_data          := json_object_t();
            obj_data.put('dtestrtwk',to_char(a_dtestweek(n),'dd/mm/yyyy'));
            obj_data.put('dteendwk',to_char(a_dteenweek(n),'dd/mm/yyyy'));
            obj_data.put('qtydaywk',hcm_util.convert_minute_to_hour(a_sumwork(n)));
            obj_data.put('qtyot_reqoth',hcm_util.convert_minute_to_hour(a_sumotreqoth(n)));
            obj_data.put('qtyot_req',hcm_util.convert_minute_to_hour(a_sumotreq(n)));
            obj_data.put('qtyot_total',hcm_util.convert_minute_to_hour(a_sumot(n)));
            obj_data.put('qtytotal',hcm_util.convert_minute_to_hour(a_totwork(n)));
            obj_row.put(to_char(n - 1),obj_data);
        end loop;
      end if;
      --<< user18 ST11 03/08/2021 change std detail
    end loop; -- end for

    obj_main.put('coderror',200);
    obj_main.put('detail',obj_detail);
    obj_main.put('table',obj_row);
    json_str_output := obj_main.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400',param_msg_error,global_v_lang);
  end get_detail;

  procedure ess_save_ttotreq(json_str in clob, resp_json_str out clob) is
    obj_data        json_object_t;
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    initial_value(json_str);

    p_obj_cumulative := hcm_util.get_json_t(hcm_util.get_json_t(json_obj,'table'),'rows');

    check_index;
    if param_msg_error is null then
      insert_next_step;
      if param_msg_error is null and v_msgerror is null then
        save_ttotreq;
        commit;
      else
        rollback;
      end if;
    end if;
--    if v_msgerror is not null then
--        obj_data := json_object_t();
--        obj_data.put('coderror', '201');
--        obj_data.put('response', v_msgerror);
--        obj_data.put('flg', 'warning');
--        resp_json_str := obj_data.to_clob;
--    else
--        resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
--    end if;

    if v_msgerror is not null then
        obj_data := json_object_t();
        obj_data.put('coderror', '201');
        obj_data.put('response', v_msgerror);
        obj_data.put('flg', 'warning');
        resp_json_str := obj_data.to_clob;
    elsif param_msg_error is not null then
        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('response', param_msg_error);
        obj_data.put('flg', 'error');
        resp_json_str := obj_data.to_clob;
    else
        param_msg_error := replace(get_error_msg_php('HR2401',global_v_lang),'@#$%201');
        resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := DBMS_UTILITY.format_error_stack||' '||DBMS_UTILITY.format_error_backtrace;
    resp_json_str := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end ess_save_ttotreq;

  procedure ess_cancel_ttotreq(json_str in clob, resp_json_str out clob) is
    json_obj    json_object_t;

    v_numperiod   tovrtime.numperiod%type;
    v_dtemthpay   tovrtime.dtemthpay%type;
    v_dteyrepay   tovrtime.dteyrepay%type;
    v_maillang      varchar2(100);
    flg_tovrtime    boolean;

    cursor c1 is
        select codempid, dtework, typot, 
               flgotcal, numperiod, dtemthpay, dteyrepay 
          from tovrtime  
         where codempid  = b_index_codempid
           and numotreq = p_numotreq
      order by dtework;

    cursor c2 is
        select flgtran 
          from tpaysum 
         where numperiod = v_numperiod
           and dtemthpay = v_dtemthpay
           and dteyrepay = v_dteyrepay
           and codempid = b_index_codempid
           and CODALW = 'OT' ;

    flg_cancel boolean;
    v_msg_to        clob;
    v_template_to   clob;
    v_error         VARCHAR2(20); 
    v_rowid         rowid;   
    v_rowid_ttotreq         rowid;   
    v_codempid_receive  temploy1.codempid%type;
  begin
    json_obj            := json_object_t(json_str);
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    ttotreq_dtereq      := to_date(trim(hcm_util.get_string_t(json_obj,'dtereq')),'dd/mm/yyyy');
    ttotreq_numseq      := to_number(hcm_util.get_string_t(json_obj,'numseq'));
    ttotreq_staappr     := hcm_util.get_string_t(json_obj,'staappr');
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');

    if ttotreq_dtereq is not null then
      if ttotreq_staappr = 'P' then
        begin
          update ttotreq set staappr   = 'C',
                             dtecancel = trunc(sysdate),
                             coduser   = global_v_coduser
                 where codempid = b_index_codempid
                   and dtereq   = ttotreq_dtereq
                   and numseq   = ttotreq_numseq;
          commit;
          param_msg_error := get_error_msg_php('HR2421',global_v_lang);
          commit;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
          resp_json_str   := get_response_message('400',param_msg_error,global_v_lang);
          rollback;
          return;
        end;
      elsif ttotreq_staappr in ('A','Y') then 
        begin
            select numotreq, rowid
              into p_numotreq,v_rowid_ttotreq
              from ttotreq
             where codempid = b_index_codempid
               and dtereq = ttotreq_dtereq
               and numseq = ttotreq_numseq;
        exception when no_data_found then
            p_numotreq := null;
            v_rowid_ttotreq := null;
        end;
        if ttotreq_staappr = 'Y' then
            flg_cancel  := true;
            for r1 in c1 loop
                if r1.flgotcal = 'Y' then
                    v_numperiod   := r1.numperiod;
                    v_dtemthpay   := r1.dtemthpay;
                    v_dteyrepay   := r1.dteyrepay;
                    for r2 in c2 loop
                        if r2.flgtran = 'Y' then
                            flg_cancel := false;
                        end if;
                    end loop;
                elsif r1.flgotcal = 'N' then
                    null;
                end if;
            end loop;

            if flg_cancel then
                flg_tovrtime := false;
                for r1 in c1 loop
                    flg_tovrtime := true;
                    begin
                        delete totpaydt  
                         where codempid  = r1.codempid
                           and dtework = r1.dtework
                           and typot = r1.typot;

                        delete totreqst  
                         where codempid  = r1.codempid
                           and numotreq = p_numotreq;

                        delete totreqd  
                         where codempid  = r1.codempid
                           and dtewkreq = r1.dtework
                           and typot = r1.typot
                           and numotreq = p_numotreq;

                        delete tovrtime  
                         where codempid  = r1.codempid
                           and dtework = r1.dtework
                           and typot = r1.typot;

                    exception when others then
                      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                      resp_json_str   := get_response_message('400',param_msg_error,global_v_lang);
                      rollback;
                      return;
                    end;   
                end loop;

                if not flg_tovrtime then
                    delete totreqst  
                     where codempid  = b_index_codempid
                       and numotreq = p_numotreq;

                    delete totreqd  
                     where codempid  = b_index_codempid
                       and numotreq = p_numotreq;
                end if;

                update ttotreq 
                   set staappr   = 'C',
                       dtecancel = trunc(sysdate),
                       coduser   = global_v_coduser
                 where codempid = b_index_codempid
                   and dtereq   = ttotreq_dtereq
                   and numseq   = ttotreq_numseq;
                param_msg_error := get_error_msg_php('HR2421',global_v_lang); 
                commit;     
            else
                param_msg_error := get_error_msg_php('ES0077',global_v_lang);
                resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
                return;
            end if;            
        elsif ttotreq_staappr = 'A' then
            begin
                update ttotreq 
                   set staappr   = 'C',
                       dtecancel = trunc(sysdate),
                       coduser   = global_v_coduser
                 where codempid = b_index_codempid
                   and dtereq   = ttotreq_dtereq
                   and numseq   = ttotreq_numseq;
                commit;
            exception when others then
              param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
              resp_json_str   := get_response_message('400',param_msg_error,global_v_lang);
              rollback;
              return;
            end;        
        end if;

        begin
            select rowid 
              into v_rowid
              from V_TEMPLOY
             where codempid = b_index_codempid;
        exception when others then
            v_rowid := null;
        end;

        begin
            select codappr 
              into v_codempid_receive
              from taptotrq
             where codempid = b_index_codempid
               and dtereq = ttotreq_dtereq
               and numseq = ttotreq_numseq
               and rownum = 1;
        exception when others then
            v_codempid_receive := null;
        end;

        v_maillang := chk_flowmail.get_emp_mail_lang(v_codempid_receive);

        chk_flowmail.get_message_result('HRES6KECN', v_maillang, v_msg_to, v_template_to);
        chk_flowmail.replace_text_frmmail(v_template_to, 'V_TEMPLOY', v_rowid, get_label_name('HRES6KE2',v_maillang,280), 'HRES6KECN', '1', null, global_v_coduser, v_maillang, v_msg_to, p_chkparam => 'N');
        chk_flowmail.replace_param('TTOTREQ',v_rowid_ttotreq,'HRES6KECN','1',v_maillang,v_msg_to,'N');
        begin
            v_error := chk_flowmail.send_mail_to_emp (v_codempid_receive, global_v_coduser, v_msg_to, NULL, get_label_name('HRES6KE2',v_maillang,280), 'E', v_maillang, null, null,null,null,null,'HRES6KE',v_codempid_receive);
        exception when others then
            v_error := '2403';
        end;

        if v_error != '2046' then
            param_msg_error := get_error_msg_php('HR2403', global_v_lang);
            resp_json_str := get_response_message('200', param_msg_error, global_v_lang);    
            return;
        end if;

      elsif ttotreq_staappr = 'C' then
        param_msg_error := get_error_msg_php('HR1506',global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR1490',global_v_lang);
      end if;
    end if;
    resp_json_str := get_response_message(null,param_msg_error,global_v_lang);
  end ess_cancel_ttotreq;

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_empid      := hcm_util.get_string_t(json_obj,'codinput');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_dtereq      := to_date(trim(hcm_util.get_string_t(json_obj,'dtereq')),'dd/mm/yyyy');
    b_index_numseq      := to_number(hcm_util.get_string_t(json_obj,'numseq'));
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dtereq_st   := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_st'),'dd/mm/yyyy');
    b_index_dtereq_en   := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_en'),'dd/mm/yyyy');

    --block tleaverq
    ttotreq_codempid    := hcm_util.get_string_t(json_obj,'codempid_query');
    ttotreq_dtereq      := to_date(trim(hcm_util.get_string_t(json_obj,'dtereq')),'dd/mm/yyyy');
    ttotreq_numseq      := to_number(hcm_util.get_string_t(json_obj,'numseq'));
    ttotreq_numotreq    := hcm_util.get_string_t(json_obj,'numotreq');
    ttotreq_codcomp     := hcm_util.get_string_t(json_obj,'codcomp');
    ttotreq_dtestrt     := to_date(trim(hcm_util.get_string_t(json_obj,'dtestrt')),'dd/mm/yyyy');
    ttotreq_dteend      := to_date(trim(hcm_util.get_string_t(json_obj,'dteend')),'dd/mm/yyyy');
    ttotreq_timbstr     := replace(trim(hcm_util.get_string_t(json_obj,'timbstr')),':','');
    ttotreq_timbend     := replace(trim(hcm_util.get_string_t(json_obj,'timbend')),':','');
    ttotreq_timdstr     := replace(trim(hcm_util.get_string_t(json_obj,'timdstr')),':','');
    ttotreq_timdend     := replace(trim(hcm_util.get_string_t(json_obj,'timdend')),':','');
    ttotreq_timastr     := replace(trim(hcm_util.get_string_t(json_obj,'timastr')),':','');
    ttotreq_timaend     := replace(trim(hcm_util.get_string_t(json_obj,'timaend')),':','');
    ttotreq_codrem      := hcm_util.get_string_t(json_obj,'codrem');
    ttotreq_staappr     := hcm_util.get_string_t(json_obj,'staappr');
    ttotreq_codappr     := hcm_util.get_string_t(json_obj,'codappr');
    ttotreq_dteappr     := to_date(trim(hcm_util.get_string_t(json_obj,'dteappr')),'dd/mm/yyyy');
    ttotreq_dteupd      := to_date(trim(hcm_util.get_string_t(json_obj,'dteupd')),'dd/mm/yyyy');
    ttotreq_coduser     := hcm_util.get_string_t(json_obj,'coduser');
    ttotreq_remarkap    := hcm_util.get_string_t(json_obj,'remarkap');
    ttotreq_approvno    := hcm_util.get_string_t(json_obj,'approvno');
    ttotreq_routeno     := hcm_util.get_string_t(json_obj,'routeno');
    ttotreq_remark      := hcm_util.get_string_t(json_obj,'remark');
    ttotreq_codinput    := hcm_util.get_string_t(json_obj,'codinput');
    ttotreq_dtecancel   := to_date(trim(hcm_util.get_string_t(json_obj,'dtecancel')),'dd/mm/yyyy');
    ttotreq_dteinput    := to_date(trim(hcm_util.get_string_t(json_obj,'dteinput')),'dd/mm/yyyy');
    -- /*user3*/ new requirement --
    ttotreq_flgchglv    := nvl(hcm_util.get_string_t(json_obj,'flgchglv'),'N');
    ttotreq_codcompw    := hcm_util.get_string_t(json_obj,'codcompw');
    ttotreq_qtyminb     := hcm_util.get_string_t(json_obj,'qtyminb');
    ttotreq_qtymind     := hcm_util.get_string_t(json_obj,'qtymind');
    ttotreq_qtymina     := hcm_util.get_string_t(json_obj,'qtymina');
    --param
    param_msg_error     := null;
    param_v_summin      := 0;
    param_qtyavgwk      := 0;
    if substr(to_char(sysdate,'yyyy'),1,2) = '25' then
      global_v_zyear    := 543;
    else
      global_v_zyear    := 0;
    end if;

    -- << user18 ST11 03/08/2021 change std
    p_dtestrt             := to_date(hcm_util.get_string_t(json_obj,'p_dtestrt'),'dd/mm/yyyy');
    p_dteend              := to_date(hcm_util.get_string_t(json_obj,'p_dteend'),'dd/mm/yyyy');
    p_codcomp             := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid_query      := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_timbstr             := replace(hcm_util.get_string_t(json_obj,'p_timbstr'),':');
    p_timbend             := replace(hcm_util.get_string_t(json_obj,'p_timbend'),':');
    p_qtyminb             := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_qtyminb'));

    p_timdstr             := replace(hcm_util.get_string_t(json_obj,'p_timdstr'),':');
    p_timdend             := replace(hcm_util.get_string_t(json_obj,'p_timdend'),':');
    p_qtymind             := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_qtymind'));

    p_timastr             := replace(hcm_util.get_string_t(json_obj,'p_timastr'),':');
    p_timaend             := replace(hcm_util.get_string_t(json_obj,'p_timaend'),':');
    p_qtymina             := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_qtymina'));
    p_numseq              := hcm_util.get_string_t(json_obj,'p_numseq');
    p_numotreq            := hcm_util.get_string_t(json_obj,'p_numotreq');
    p_dtereq              := to_date(hcm_util.get_string_t(json_obj,'p_dtereq'),'dd/mm/yyyy');

    p_dtestrtwk           := to_date(hcm_util.get_string_t(json_obj,'dtestrtwk'),'dd/mm/yyyy');
    p_dteendwk            := to_date(hcm_util.get_string_t(json_obj,'dteendwk'),'dd/mm/yyyy');
    p_qtydaywk            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'qtydaywk'));
    p_qtyot_reqoth        := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'qtyot_reqoth'));
    p_qtyot_req           := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'qtyot_req'));
    p_qtyot_total         := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'qtyot_total'));
    p_qtytotal            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'qtytotal'));
    p_flgconfirm          := hcm_util.get_string_t(json_obj,'p_flgconfirm');

    -- >> user18 ST11 03/08/2021 change std
    -- surachai
    p_dtework             := to_date(hcm_util.get_string_t(json_obj,'p_dtework'),'dd/mm/yyyy');
    p_codcompw            := hcm_util.get_string_t(json_obj,'p_codcompw');
    p_staappr_ot            := hcm_util.get_string_t(json_obj,'p_staappr');

    p_codcompbg            := hcm_util.get_string_t(json_obj,'codcompbg');   -- รหัส งบประมาณของหน่วยงาน
    p_departmentbudget     := hcm_util.get_string_t(json_obj,'departmentbudget');   -- งบประมาณของหน่วยงาน
    p_wkbudgetdate         := hcm_util.get_string_t(json_obj,'wkbudgetdate');   -- งบประมาณประจำสัปดาห์ วันที่
    p_wkbudget             := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'wkbudget')); -- งบประมาณประจำสัปดาห์ 
    p_requesthr            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'requesthr')); -- จำนวนชั่วโมงล่วงเวลาในใบคำขอนี้
    p_otherrequesthr       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'otherrequesthr')); -- จำนวนชั่วโมงล่วงเวลาในใบคำขออื่น
    p_totalhr              := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'totalhr')); -- รวมจำนวนชั่วโมงล่วงเวลา
    p_remainhr             := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'remainhr')); -- จำนวนชั่วโมงของงบประมาณคงเหลือ (ถ้าติดลบให้แสดง 0)
    p_percentused          := to_number(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'percentused'))); -- % ใช้ไป
    p_overbudgetstatus     := hcm_util.get_string_t(json_obj,'overbudgetstatus');
    p_reconfirm            := hcm_util.get_string_t(json_obj,'reconfirm');   -- รหัส งบประมาณของหน่วยงาน
    p_pageEdit             :=  hcm_util.get_string_t(json_obj,'p_pageEdit');
    p_flgPageEdit          :=  hcm_util.get_string_t(json_obj,'p_flgPageEdit');

  end initial_value;

  procedure check_index is
    v_codempid  temploy1.codempid%type;
    v_codrem    tcodotrq.codcodec%type;
    v_numlvl    temploy1.numlvl%type;
    v_staemp    temploy1.staemp%type;
    v_dteeffex  temploy1.dteeffex%type;

    v_qtyday    number(2);
    v_flgsecu   boolean;

    --<< user18 ST11 03/08/2021 change std
    v_qtymxotwk     tcontrot.qtymxotwk%type;
    v_qtymxallwk    tcontrot.qtymxallwk%type;

    v_dtestrtwk     date;
    v_dtestrtwk2    date;
    v_typalert      tcontrot.typalert%type;
    obj_row         json_object_t;

    -->> user18 ST11 03/08/2021 change std
    -- mo surachai 
    v_routeno       varchar2(15);
    vv_codapp       varchar2(40);
  begin
    if ttotreq_dtestrt > ttotreq_dteend then
       param_msg_error := get_error_msg_php('ES0026',global_v_lang);
       return;
    end if;
    --
    begin
      select codempid
      into   v_codempid
      from   tattence
      where  codempid = b_index_codempid
      and    dtework  between ttotreq_dtestrt and ttotreq_dteend
      and    rownum =1 ;
    exception when no_data_found then
      v_codempid := null;
    end;
    if v_codempid is null then
      param_msg_error := replace(get_error_msg_php('HR2010',global_v_lang,'tattence'),'@#$%400','');
      return;
    end if;
    --
    begin
      select codcomp,numlvl,staemp,dteeffex
      into   ttotreq_codcomp,v_numlvl,v_staemp,v_dteeffex
      from   temploy1
      where  codempid = b_index_codempid;
      if v_staemp = '0' or
        (v_staemp = '9' and v_dteeffex is not null and v_dteeffex <= ttotreq_dtestrt) then
        if v_staemp = '9' then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
          return;
        else
          param_msg_error := get_error_msg_php('HR2012',global_v_lang,'temploy1');
          return;
        end if;
      end if;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
    end;
    --
    if ttotreq_codrem is not null then
      begin
        select codcodec into v_codrem
        from   tcodotrq
        where  codcodec = ttotreq_codrem;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodotrq');
        return;
      end;
    end if;
    if ttotreq_remark is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang);
       return;
    end if;
    ---<<< weerayut 09/01/2018 Lock request during payroll
    if get_payroll_active('HRES6KE',nvl(ttotreq_codempid,b_index_codempid),ttotreq_dtestrt,ttotreq_dteend) = 'Y' then
      param_msg_error := get_error_msg_php('ES0057',global_v_lang);
      return;
    end if;
    --->>> weerayut 09/01/2018
    -- /*user3*/ new requirement --
    if ttotreq_codcompw is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, ttotreq_codcompw);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    -- /*user3*/ --

    -->> Site: mo-kohu-sm2301 Author: Nuii Kowit (000551) Date updated: 11 April 2024 15:21 Comment: redmine 4449#1850
    v_dtestrtwk     := std_ot.get_dtestrt_period (b_index_codempid ,ttotreq_dtestrt);
    v_dtestrtwk2    := std_ot.get_dtestrt_period (b_index_codempid ,ttotreq_dteend);
    --<< Site: mo-kohu-sm2301 Author: Nuii Kowit (000551) Date updated: 11 April 2024 15:21 Comment: redmine 4449#1850

    begin
        select nvl(qtymxotwk,0),nvl(qtymxallwk,0),nvl(typalert,'N')
          into v_qtymxotwk,v_qtymxallwk,v_typalert
          from tcontrot
         where codcompy = hcm_util.get_codcomp_level(ttotreq_codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = hcm_util.get_codcomp_level(ttotreq_codcomp,1)
                              and dteeffec <= sysdate);
    exception when others then
        v_qtymxotwk     := 0;
        v_qtymxallwk    := 0;
        v_typalert      := 'N';
    end; 

    ttotreq_qtyotreq := 0; --user36 ST11 16/09/2023
    if v_typalert <> 'N' then
        v_msgerror          := null;
        ttotreq_staovrot    := 'N';

        for i in 0..(p_obj_cumulative.get_size-1) loop
            obj_row         := hcm_util.get_json_t(p_obj_cumulative,to_char(i));
            p_qtyot_total   := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(obj_row,'qtyot_total'));
            p_qtytotal      := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(obj_row,'qtytotal'));
            ttotreq_qtyotreq := ttotreq_qtyotreq + hcm_util.convert_hour_to_minute(hcm_util.get_string_t(obj_row,'qtyot_req')); --user36 ST11 16/09/2023
            if (p_qtyot_total > v_qtymxotwk) then
                ttotreq_staovrot    := 'Y';
                if nvl(p_flgconfirm,'N') = 'N' then
                    if v_typalert = '1' then
                        v_msgerror          := replace(get_error_msg_php('ES0075',global_v_lang),'@#$%400');
                    elsif v_typalert = '2' then
                        param_msg_error := get_error_msg_php('ES0075',global_v_lang);
                    end if;
                /*else
                    ttotreq_staovrot    := 'Y';*/
                end if;
                return;
            end if;

            if (p_qtytotal > v_qtymxallwk) then
                ttotreq_staovrot    := 'Y';
                if nvl(p_flgconfirm,'N') = 'N' then
                    if v_typalert = '1' then
                        v_msgerror          := replace(get_error_msg_php('ES0076',global_v_lang),'@#$%400');
                    elsif v_typalert = '2' then
                        param_msg_error := get_error_msg_php('ES0076',global_v_lang);
                    end if;
                /*else
                    ttotreq_staovrot    := 'Y';*/
                end if;
                return;
            end if;
        end loop;

       /* if (p_qtyot_total > v_qtymxotwk) then
            if nvl(p_flgconfirm,'N') = 'N' then
                if v_typalert = '1' then
                    ttotreq_staovrot    := 'Y';
                    v_msgerror          := replace(get_error_msg_php('ES0075',global_v_lang),'@#$%400');
                elsif v_typalert = '2' then
                    param_msg_error := get_error_msg_php('ES0075',global_v_lang);
                end if;
            else
                ttotreq_staovrot    := 'Y';
            end if;
            return;
        end if;*/

        /*if (p_qtytotal > v_qtymxallwk) then
            if nvl(p_flgconfirm,'N') = 'N' then
                if v_typalert = '1' then
                    ttotreq_staovrot    := 'Y';
                    v_msgerror          := replace(get_error_msg_php('ES0076',global_v_lang),'@#$%400');
                elsif v_typalert = '2' then
                    param_msg_error := get_error_msg_php('ES0076',global_v_lang);
                end if;
            else
                ttotreq_staovrot    := 'Y';
            end if;
            return;
        end if;*/
    end if;
    --<< user18 ST11 03/08/2021 change std

    -- << mo surachai | 14/09/2023
        --	ตรวจสอบ Flow การอนุมัติ 
    begin 
        Select codapp
        into vv_codapp
        From  TEMPFLOW
        Where codapp = 'HRES6KE'
        and codempid = b_index_codempid;
    exception when no_data_found then  
      param_msg_error := replace(get_error_msg_php('ESZ004',global_v_lang),'@#$%400'); --KOHU-HR2301 19/10/2023
--        vv_codapp := '';
    end;
--    if vv_codapp is null then --KOHU-HR2301 19/10/2023 cancel
--        v_routeno   := chk_workflow.find_route('HRES6KE',b_index_codempid,'');
--        if v_routeno is null then
--            param_msg_error := replace(get_error_msg_php('ESZ004',global_v_lang),'@#$%400');
----            param_msg_error := get_error_msg_php('ES0057',global_v_lang);
--            return;
--        end if;
--    end if;
        -- รหัสหน่วยงานเจ้าของงบประมาณ
    if p_codcompbg is null 
    or nvl(p_wkbudget,0) <= 0 --user36 KOHU #1823 27/03/2024
    then
        param_msg_error := replace(get_error_msg_php('ESZ005',global_v_lang),'@#$%400');
        return;
    end if;
        -- % การใช้งบประมาณ

    if p_percentused > 100 and p_reconfirm <> 'true' then
        v_msgerror  := replace(get_error_msg_php('ESZ006',global_v_lang),'@#$%400');
        return;
    end if;
    -- >>
  end;

  procedure insert_next_step is
    v_codempid      temploy1.codempid%type;
    v_codapp        varchar2(10) := 'HRES6KE';
    v_count         number := 0;
    v_approvno      number := 0;
    v_codempid_next temploy1.codempid%type;
    v_codempap      temploy1.codempid%type;
    v_codcompap     temploy1.codcomp%type;
    v_codposap      varchar2(4);
    v_routeno       varchar2(15);
    v_remark        varchar2(200) := substr(get_label_name('HCM_APPRFLW',global_v_lang,10),1,200);
    v_numseq        number ;
    v_table	        varchar2(50 char);
    v_error		    varchar2(50 char);
  begin
    if  ttotreq_numseq  is null then
      begin
        select max(numseq) into v_numseq
        from   ttotreq
        where  codempid = b_index_codempid
        and    dtereq   = b_index_dtereq;
      exception  when others then
        v_numseq := 0;
      end;
      ttotreq_numseq      := nvl(v_numseq,0) + 1;
    end if;
    ttotreq_codempid   := b_index_codempid;
    ttotreq_dtereq     := to_date(to_char(b_index_dtereq,'dd/mm/yyyy'),'dd/mm/yyyy');

    v_approvno         :=  0 ;
    v_codempap         := b_index_codempid ;
    if ttotreq_staappr = 'C' then
      ttotreq_dteinput  := sysdate;
    end if;
    ttotreq_staappr   := 'P';
    ttotreq_dtecancel := null;

--    chk_workflow.find_next_approve(v_codapp  ,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_codempap);
    --Loop Check Next step--
    --<< user22 : 20/08/2016 : HRMS590307 ||
--    if v_routeno is null then
--      param_msg_error := v_codapp || get_error_msg_php('HR2055',global_v_lang,'twkflph');
--      return;
--    end if;
    --
--    chk_workflow.find_approval(v_codapp,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_table,v_error);
--    if v_error is not null then
--      param_msg_error := get_error_msg_php(v_error,global_v_lang,v_table);
--      return;
--    end if;
  -->> user22 : 20/08/2016 : HRMS590307 ||
    loop
      --v_codempid_next := chk_workflow.check_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_codempap);
      --Change to Chk_NextStep user13
--      v_codempid_next := chk_workflow.Chk_NextStep('HRES6KE',v_routeno,v_approvno,v_codempap,v_codcompap,v_codposap);
      v_codempid_next := chk_workflow.check_next_step(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_codempap);
    -- user22 : 18/07/2016 : HRMS590287 || v_codempid_next := chk_workflow.Check_Next_Approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_codempap);
      if  v_codempid_next is not null then
        v_approvno          := v_approvno + 1 ;
        ttotreq_codappr    := v_codempid_next ;
        ttotreq_staappr    := 'A' ;
        ttotreq_dteappr    := trunc(sysdate);
        ttotreq_remarkap   := v_remark;
        ttotreq_approvno   := v_approvno ;
        begin
          select count(*) into v_count
            from taptotrq
           where codempid = ttotreq_codempid
             and dtereq   = ttotreq_dtereq
             and numseq   = ttotreq_numseq
             and approvno = v_approvno;
        exception when no_data_found then  v_count := 0;
        end;
        if v_count = 0 then
          insert into taptotrq
                  (codempid,dtereq,numseq,approvno,codappr,dteappr,numotreq,staappr,remark,
                  dteupd,coduser,dteapph)
          values  (ttotreq_codempid,ttotreq_dtereq,ttotreq_numseq,v_approvno,
                   v_codempid_next,ttotreq_dteappr,ttotreq_numotreq,'A',v_remark,-- user22 : 04/07/2016 : HRMS590287 || v_codempid,ttotreq_dteappr,ttotreq_numotreq,'A',v_remark,
                   trunc(sysdate),global_v_coduser,sysdate
                   );
        else
          update taptotrq
             set codappr   = v_codempid_next,-- user22 : 18/07/2016 : HRMS590287 || set codappr   = v_codempid,
                 dteappr   = ttotreq_dteappr,
                 numotreq  = ttotreq_numotreq,
                 staappr   = 'A',
                 remark    = v_remark ,
                 coduser   = global_v_coduser,
                 dteapph   = sysdate
           where codempid = ttotreq_codempid
             and dtereq   = ttotreq_dtereq
             and numseq   = ttotreq_numseq
             and approvno = v_approvno;
        end if;
        chk_workflow.find_next_approve(v_codapp,v_routeno,b_index_codempid,to_char(b_index_dtereq,'dd/mm/yyyy'),b_index_numseq,v_approvno,v_codempid_next);
      else
        exit;
      end if;
    end loop ;
    ttotreq_approvno     := v_approvno ;
    ttotreq_routeno      := v_routeno ;
    --<<user36 ST11 16/09/2023
    if ttotreq_qtyotreq = 0 then
      ttotreq_qtyotreq := std_ot.get_qtyminot(ttotreq_codempid,ttotreq_dtestrt,ttotreq_dteend,
                                              hcm_util.convert_time_to_minute(ttotreq_qtyminb),ttotreq_timbend,ttotreq_timbstr,
                                              hcm_util.convert_time_to_minute(ttotreq_qtymind),ttotreq_timdend,ttotreq_timdstr,
                                              hcm_util.convert_time_to_minute(ttotreq_qtymina),ttotreq_timaend,ttotreq_timastr);
    end if;
    -->>user36 ST11 16/09/2023
    commit;
  end;

  procedure save_ttotreq is
    v_numseq    ttotreq.numseq%type := 0;
    v_codappr_arr   array_t;
    v_maxstep       number;
    v_pctotreq1     TEMPFLOW.pctotreq1%type;
    v_pctotreq2     TEMPFLOW.pctotreq2%type;
    v_pctotreq3     TEMPFLOW.pctotreq3%type;
    v_pctotreq4     TEMPFLOW.pctotreq4%type;
    v_codappr1      TEMPFLOW.codappr1%type;
    v_codappr2      TEMPFLOW.codappr2%type;
    v_codappr3      TEMPFLOW.codappr3%type;
    v_codappr4      TEMPFLOW.codappr4%type;
  begin
    begin
      ttotreq_codempid := b_index_codempid;
      ttotreq_dtereq   := to_date(to_char(b_index_dtereq,'dd/mm/yyyy'),'dd/mm/yyyy');
      ttotreq_coduser  := global_v_coduser;
      ttotreq_codinput := global_v_codempid;
      ttotreq_dteinput  := sysdate;
--      param_msg_error := replace(get_error_msg_php('HR2401',global_v_lang),'@#$%201');
      ttotreq_routeno := ''; -- mo ตาม swd | surachai | 22/09/2023 (แบบเดิมหา routeno มาให้อยู่แล้ว)
      insert into ttotreq 
      (numotreq,    numseq,       dtereq,       codempid,     dtestrt,
       dteend,      codrem,       remark,       codinput,     timbstr,
       timbend,     timdstr,      timdend,      timastr,      timaend,
       codappr,     routeno,      dteappr,
       codcomp,     staappr,      dteupd,       codcreate, coduser,
       approvno,    remarkap,     dteinput,     dtecancel,
       staovrot, -- user18 ST11 03/08/2021 change std
       -- /*user3*/ new requirement --
       flgchglv,    codcompw,     qtyminb,      qtymind,      qtymina,
       -- << mo surchai 
       codcompbg,qtybudget,qtyothot,pctbguse,
       -- >>
       qtyotreq) --user36 ST11 16/09/2023
      values
      (ttotreq_numotreq,    ttotreq_numseq,       ttotreq_dtereq,     ttotreq_codempid,    ttotreq_dtestrt,
       ttotreq_dteend,      ttotreq_codrem,       ttotreq_remark,     ttotreq_codinput,    ttotreq_timbstr,
       ttotreq_timbend,     ttotreq_timdstr,      ttotreq_timdend,    ttotreq_timastr,     ttotreq_timaend,
       ttotreq_codappr,     ttotreq_routeno,      ttotreq_dteappr,
       ttotreq_codcomp,     ttotreq_staappr,      ttotreq_dteupd,     ttotreq_coduser,     ttotreq_coduser,
       ttotreq_approvno,    ttotreq_remarkap,     ttotreq_dteinput,   ttotreq_dtecancel,
       ttotreq_staovrot,  -- user18 ST11 03/08/2021 change std
       -- /*user3*/ new requirement --
       ttotreq_flgchglv,    ttotreq_codcompw,
       hcm_util.convert_time_to_minute(ttotreq_qtyminb),
       hcm_util.convert_time_to_minute(ttotreq_qtymind),
       hcm_util.convert_time_to_minute(ttotreq_qtymina),
       -- << mo surchai 
       p_codcompbg,p_wkbudget,p_otherrequesthr,p_percentused,
       -- >>
       ttotreq_qtyotreq); --user36 ST11 16/09/2023
    exception when dup_val_on_index then
      ttotreq_dteupd   := to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy');
      ttotreq_coduser  := global_v_coduser;
      ttotreq_codinput := global_v_codempid;
--      param_msg_error := replace(get_error_msg_php('HR2401',global_v_lang),'@#$%201');
      begin
        update ttotreq
        set   numotreq    = ttotreq_numotreq,
              dtestrt     = ttotreq_dtestrt,
              dteend      = ttotreq_dteend,
              codrem      = ttotreq_codrem,
              remark      = ttotreq_remark,
              codinput    = ttotreq_codinput,
              timbstr     = ttotreq_timbstr,
              timbend     = ttotreq_timbend,
              timdstr     = ttotreq_timdstr,
              timdend     = ttotreq_timdend,
              timastr     = ttotreq_timastr,
              timaend     = ttotreq_timaend,
              codappr     = ttotreq_codappr,
              routeno     = ttotreq_routeno,
              dteappr     = ttotreq_dteappr,
              codcomp     = ttotreq_codcomp,
              staappr     = ttotreq_staappr,
              dteupd      = ttotreq_dteupd,
              coduser     = ttotreq_coduser,
              approvno    = ttotreq_approvno,
              remarkap    = ttotreq_remarkap,
              dtecancel   = ttotreq_dtecancel,
              staovrot    = ttotreq_staovrot, -- user18 ST11 03/08/2021 change std
              -- /*user3*/ new requirement --
              flgchglv    = ttotreq_flgchglv,
              codcompw    = ttotreq_codcompw,
              qtyminb     = hcm_util.convert_time_to_minute(ttotreq_qtyminb),
              qtymind     = hcm_util.convert_time_to_minute(ttotreq_qtymind),
              qtymina     = hcm_util.convert_time_to_minute(ttotreq_qtymina),
              -- << mo surchai 
              codcompbg = p_codcompbg,
              qtybudget = p_wkbudget,
              qtyothot  = p_otherrequesthr,
              pctbguse  = p_percentused,
              -- >>
              qtyotreq    = ttotreq_qtyotreq --user36 ST11 16/09/2023
        where numseq      = ttotreq_numseq
          and dtereq      = ttotreq_dtereq
          and codempid    = ttotreq_codempid;
        exception when others then
          param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      end;
    end;

    -- mo surachai | 21/09/2023
    begin
        select pctotreq1, pctotreq2, pctotreq3, pctotreq4, codappr1, codappr2, codappr3, codappr4
        into v_pctotreq1, v_pctotreq2, v_pctotreq3, v_pctotreq4, v_codappr1, v_codappr2, v_codappr3, v_codappr4
        From  TEMPFLOW
        Where codapp = 'HRES6KE'
            and  codempid = global_v_codempid;
    exception when no_data_found then
        v_pctotreq1 := null;
        v_pctotreq2 := null;
        v_pctotreq3 := null;
        v_pctotreq4 := null;
        v_codappr1 := null;
        v_codappr2 := null;
        v_codappr3 := null;
        v_codappr4 := null;
    end;
    -- หาจำนวนขั้นที่ต้องอนุมัติรายการขอครั้งนี้ 
    if p_percentused > v_pctotreq4 then
        v_maxstep := 4;
    elsif p_percentused > v_pctotreq3 then
        v_maxstep := 3;
    elsif p_percentused > v_pctotreq2 then
        v_maxstep := 2;
    else--if p_percentused > v_pctotreq1 then
        v_maxstep := 1;
    end if;

    -- หารหัสผู้อนุมัติ OT ของพนักงาน จากตาราง TEMPFLOW ตามจำนวนขั้นที่ต้องอนุมัติ
    If v_maxstep = 1 then
        v_codappr_arr(1) := v_codappr1;
    Elsif v_maxstep = 2 then
        v_codappr_arr(1) := v_codappr1;
        v_codappr_arr(2) := v_codappr2;
    Elsif v_maxstep = 3 then
        v_codappr_arr(1) := v_codappr1;
        v_codappr_arr(2) := v_codappr2;
        v_codappr_arr(3) := v_codappr3;
    Elsif v_maxstep = 4 then
        v_codappr_arr(1) := v_codappr1;
        v_codappr_arr(2) := v_codappr2;
        v_codappr_arr(3) := v_codappr3;
        v_codappr_arr(4) := v_codappr4;
    end if;

    -- เคลียร์ข้อมูลผู้อนุมัติเดิม ในตาราง TEMPAPRQ
    begin
        Delete TEMPAPRQ
        Where codempid = global_v_codempid
        And    dtereq  = ttotreq_dtereq
        And    numseq  = ttotreq_numseq;
    exception when others then
        null;
    end;
    for  i in 1..v_maxstep loop
        Insert into TEMPAPRQ(codapp,codempid,dtereq,numseq,approvno,codempap,seqno,
                            codcompap,codposap,routeno)
        values('HRES6KE',global_v_codempid,ttotreq_dtereq,ttotreq_numseq,i,v_codappr_arr(i),1,
                null,null,null);
    end loop; 

  end save_ttotreq;

  function get_resp_json_str return clob is
    json_obj              json_object_t;
  begin
    json_obj            :=  json_object_t();
    if param_msg_error is null then
      param_msg_error := 'Null';
    end if;
    json_obj.put('response',param_msg_error);
    --json_obj := var_dump_json_obj(json_obj);
    return json_obj.to_clob;
  end get_resp_json_str;

  function var_dump_json_obj(json_obj json_object_t) return json_object_t is
    json_obj2            json_object_t;
    ttotreq_obj          json_object_t;
  begin
    json_obj2           := json_obj;
    ttotreq_obj         := json_object_t();
    --obj tleaverq
    ttotreq_obj.put('codempid',ttotreq_codempid);
    ttotreq_obj.put('dtereq',ttotreq_dtereq);
    ttotreq_obj.put('numseq',ttotreq_numseq);
    ttotreq_obj.put('numotreq',ttotreq_numotreq);
    ttotreq_obj.put('codcomp',ttotreq_codcomp);
    ttotreq_obj.put('dtestrt',ttotreq_dtestrt);
    ttotreq_obj.put('dteend',ttotreq_dteend);
    ttotreq_obj.put('timbstr',ttotreq_timbstr);
    ttotreq_obj.put('timbend',ttotreq_timbend);
    ttotreq_obj.put('timdstr',ttotreq_timdstr);
    ttotreq_obj.put('timdend',ttotreq_timdend);
    ttotreq_obj.put('timastr',ttotreq_timastr);
    ttotreq_obj.put('timaend',ttotreq_timaend);
    ttotreq_obj.put('codrem',ttotreq_codrem);
    ttotreq_obj.put('staappr',ttotreq_staappr);
    ttotreq_obj.put('codappr',ttotreq_codappr);
    ttotreq_obj.put('dteappr',ttotreq_dteappr);
    ttotreq_obj.put('dteupd',ttotreq_dteupd);
    ttotreq_obj.put('coduser',ttotreq_coduser);
    ttotreq_obj.put('remarkap',ttotreq_remarkap);
    ttotreq_obj.put('approvno',ttotreq_approvno);
    ttotreq_obj.put('routeno',ttotreq_routeno);
    ttotreq_obj.put('remark',ttotreq_remark);
    ttotreq_obj.put('codinput',ttotreq_codinput);
    ttotreq_obj.put('dtecancel',ttotreq_dtecancel);
    ttotreq_obj.put('dteinput',ttotreq_dteinput);

    json_obj2.put('ttotreq',ttotreq_obj);
    return json_obj2;
  end var_dump_json_obj;

  procedure get_tcodotrq(json_str_input in clob, json_str_output out clob) as
    v_row           number := 0;
    obj_row         json_object_t;
    obj_data        json_object_t;
    cursor c1 is
      select codcodec, descode, descodt, descod3, descod4, descod5
        from tcodotrq
        order by codcodec;
  begin
    initial_value(json_str_input);
    obj_row   := json_object_t();
    v_row     := 0;
    for r1 in c1 loop
      v_row := v_row+1;
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codcodec',r1.codcodec);
      obj_data.put('desc_codcodec' ,get_tcodec_name('tcodotrq',r1.codcodec,global_v_lang));

      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end for
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_costcenter(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    json_obj        json_object_t;
    v_cost_center   tcenter.costcent%type;
    v_codcompw      ttotreq.codcompw%type;
  begin
    json_obj        := json_object_t(json_str_input);
    v_codcompw      := hcm_util.get_string_t(json_obj,'p_codcompw');
    --
    begin
      select costcent into v_cost_center
        from tcenter
       where codcomp = v_codcompw
         and rownum <= 1
    order by codcomp;
    exception when no_data_found then
      v_cost_center := null;
    end;
    --
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('costcent',v_cost_center);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_detail_create(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    json_obj        json_object_t;
    v_codcomp       temploy1.codcomp%type;
    v_codcompy      varchar(100 char);
    v_numseq        ttotreq.numseq%type;
    tcontrot_flgchglv   tcontrot.flgchglv%type;
    obj_row         json_object_t;
    obj_main        json_object_t;
    v_typalert          tcontrot.typalert%type;
    -- surachai | 13/09/2023
--    v_codcompw   temploy1.codcomp%type;

    -- Apisit | 05/03/2024codcomp
    v_codcompw   tattence.codcomp%type;
    v_dtereqst   tattence.dtework%type;
    v_codempid   tattence.codempid%type;
    v_cost_center   tcenter.codcomp%type;
  begin
    initial_value(json_str_input);

    -- << Apisit | 05/03/2024
    json_obj      := json_object_t(json_str_input);
    v_dtereqst    := to_date(hcm_util.get_string_t(json_obj,'p_dtereqst'), 'dd/mm/yyyy');
    v_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    -- >>

    begin
      select nvl(max(numseq),0) + 1 into v_numseq
        from ttotreq
       where codempid like nvl(b_index_codempid,codempid)
         and dtereq = trunc(sysdate);
    exception when no_data_found then
      v_numseq := null;
    end;

    select codcomp into v_codcomp from temploy1 where codempid = nvl(b_index_codempid,codempid);
    v_codcompy := get_codcompy(v_codcomp);
--    v_codcompy := get_codcompy(HCM_UTIL.GET_CODCOMP_LEVEL(v_codcomp,'','','Y'));
    begin
        select flgchglv,nvl(typalert,'N')  into tcontrot_flgchglv, v_typalert
          from tcontrot
         where codcompy = hcm_util.get_codcomp_level(v_codcompy,1)
           and dteeffec = (select max(dteeffec) from tcontrot
                            where codcompy = hcm_util.get_codcomp_level(v_codcompy,1)
                              and dteeffec <= sysdate);
      exception when no_data_found then
        tcontrot_flgchglv := null;
        v_typalert          := 'N';
      end;
    --
    -- << mo surachai 
--      begin 
--        select codcomp 
--        into v_codcompw
--        from   temploy1 
--        where codempid = b_index_codempid;
--
--      end;
    -- >>

    -- << Apisit | 05/03/2024
    select codcomp into v_codcompw
      from tattence
     where codempid = v_codempid
       and dtework = v_dtereqst;

    select costcent into v_cost_center
        from tcenter
       where codcomp = v_codcompw; 
    -- >>

    obj_data := json_object_t();
    obj_main    := json_object_t();
    obj_row     := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('numseq',v_numseq);
    obj_data.put('codcomp',v_codcomp);
    obj_data.put('staappr','');
    obj_data.put('tcontrot_flgchglv',tcontrot_flgchglv);
    obj_data.put('flgchglv', 'N');
    obj_data.put('typalert', v_typalert);
    -- << mo surachai | 13/09/2023
--    obj_data.put('dtestrt',nvl(to_char(sysdate,'dd/mm/yyyy'),''));
--    obj_data.put('dteend',nvl(to_char(sysdate,'dd/mm/yyyy'),''));
--    obj_data.put('codcompw',hcm_util.get_codcomp_level(v_codcompw,1));
    -- >>

    -- << Apisit || 05/03/2024
        obj_data.put('dtestrt',nvl(to_char(v_dtereqst,'dd/mm/yyyy'),to_char(sysdate,'dd/mm/yyyy')));
        obj_data.put('dteend',nvl(to_char(v_dtereqst,'dd/mm/yyyy'),to_char(sysdate,'dd/mm/yyyy')));
        obj_data.put('codcompw',v_codcompw);
        obj_data.put('costcent',nvl(v_cost_center,''));
    -- >>

    obj_main.put('coderror',200);
    obj_main.put('detail',obj_data);
    obj_main.put('table',obj_row);

    json_str_output := obj_main.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  function get_qtydaywk(v_codempid varchar2, v_dtestrtwk date, v_dteendwk date) return number is
    v_qtydaywk      number;
    v_qtymin        number;
  begin
      begin
          select sum(qtyhwork)
            into v_qtydaywk
            from tattence
           where codempid = v_codempid
             and dtework between v_dtestrtwk and v_dteendwk;
      exception when no_data_found then
        v_qtydaywk := null;
      end;

      begin
          select sum(qtymin)
            into v_qtymin
            from tleavetr
           where codempid = v_codempid
             and dtework between v_dtestrtwk and v_dteendwk;
      exception when no_data_found then
        v_qtymin := null;
      end;
      v_qtydaywk := nvl(v_qtydaywk,0) - nvl(v_qtymin,0);
    return v_qtydaywk;
  end get_qtydaywk;

  function get_qtyminotOth(v_codempid varchar2, v_dtestrtwk date, v_dteendwk date, v_dtereq date, v_numseq number, v_numotreq varchar2,v_addby varchar2 default null) return number is
    v_qtydaywk      number;
    v_qtymin        number;
    v_qtyminotOth   number;
    v_dteot         date;
    v_count         number;

    cursor c2 is
      select sum(qtyotreq) qtyotreq
        from ttotreq
       where codempid = v_codempid
         and dtestrt between v_dtestrtwk and v_dteendwk
         and staappr in ('P','A')
         and codempid||to_char(dtereq,'yyyymmdd')||numseq <>
             v_codempid||to_char(v_dtereq,'yyyymmdd')||v_numseq
         and  ((v_addby is not null and not exists(select item1
                          from ttemprpt
                         where to_date(item1,'dd/mm/yyyy') = ttotreq.dtestrt
                           and item2 = v_codempid
                           and nvl(item3,0) = ttotreq.numseq
                           and codempid = v_addby
                           and item9 in ('P','A')
                           and codapp = 'HRMS6KE3')    )
                or v_addby is null)
      order by dtereq desc, numseq desc;

    cursor c3 is
      select sum(qtyotreq) qtyotreq
        from totreqd
       where codempid = v_codempid
         and dtewkreq between v_dtestrtwk and v_dteendwk
         and numotreq <> nvl(v_numotreq,'xxxx')
         and dayeupd is null;

    cursor c4 is
      select sum(qtyminot) qtyminot
        from tovrtime
       where codempid = v_codempid
         and dtework between v_dtestrtwk and v_dteendwk
         and numotreq <> nvl(v_numotreq,'xxxx');
  begin
      v_qtyminotOth := 0;
      for r2 in c2 loop
        v_qtyminotOth := nvl(v_qtyminotOth,0) + nvl(r2.qtyotreq,0);
      end loop;

      for r3 in c3 loop
        v_qtyminotOth := nvl(v_qtyminotOth,0) + nvl(r3.qtyotreq,0);
      end loop;

      for r4 in c4 loop
        v_qtyminotOth := nvl(v_qtyminotOth,0) + nvl(r4.qtyminot,0);
      end loop;
    return v_qtyminotOth;
  end get_qtyminotOth;

  function get_qtyminot(p_codempid varchar2, v_dtestrt date, v_dteend date,
                        v_qtyminb number,v_timbend varchar2,v_timbstr varchar2,
                        v_qtymind number,v_timdend varchar2,v_timdstr varchar2,
                        v_qtymina number,v_timaend varchar2,v_timastr varchar2) return number is

    v_qtyminot      number;
    v_dteot         date;
    v_a_tovrtime    tovrtime%rowtype;
    v_a_rteotpay    hral85b_batch.a_rteotpay;
    v_a_qtyminot    hral85b_batch.a_qtyminot;
    v_codcompy      tcontrot.codcompy%type;
    v_dteeffec      tcontrot.dteeffec%TYPE;
    v_condot        tcontrot.condot%TYPE;
    v_condextr      tcontrot.condextr%TYPE;

    v_dtestrt2      date;
    v_timstrt2      varchar2(4);
    v_dteend2       date;
    v_timend2       varchar2(4);
    v_qtyminreq2    number;

    cursor c1 is
        select * 
          from tattence 
         where codempid = p_codempid
           and dtework between v_dtestrt and v_dteend;
  begin
    begin
      select  hcm_util.get_codcomp_level(codcomp,1)
        into  v_codcompy
        from  temploy1
       where  codempid = p_codempid;
    exception when no_data_found then
      v_codcompy := '';
    end;

    begin
      select  dteeffec,condot,condextr
        into  v_dteeffec,v_condot,v_condextr
        from  tcontrot
       where  codcompy = v_codcompy
         and  dteeffec = (select  max(dteeffec)
                            from  tcontrot
                           where  codcompy = v_codcompy
                             and  dteeffec <= sysdate)
         and  rownum <= 1;
    exception when no_data_found then null;
      v_dteeffec := null;
      v_condot   := '';
      v_condextr := '';
    end;

--    v_timbend := replace(v_timbend,':');
--    v_timbstr := replace(v_timbstr,':');
--    v_timdend := replace(v_timdend,':');
--    v_timdstr := replace(v_timdstr,':');
--    v_timaend := replace(v_timaend,':');
--    v_timastr := replace(v_timastr,':');

    for r1 in c1 loop
        if nvl(v_qtyminb,0) > 0 or (v_timbstr is not null and v_timbend is not null) then
            if nvl(v_qtyminb,0) > 0 then
                v_dtestrt2      := null;
                v_timstrt2      := null;
                v_dteend2       := null;
                v_timend2       := null;
                v_qtyminreq2    := v_qtyminb;
            else
                v_dtestrt2      := r1.dtework;
                v_timstrt2      := replace(v_timbstr,':');
                v_dteend2       := r1.dtework;
                v_timend2       := replace(v_timbend,':');
                v_qtyminreq2    := null;     
                if v_timend2 < v_timstrt2 then
                    v_dteend2   := r1.dtework + 1;
                end if;
            end if;

            hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                      null,r1.codempid,r1.dtework,'B',r1.codshift,
                                      nvl(r1.dtein,r1.dtestrtw),nvl(r1.timin,'0000'),nvl(r1.dteout,r1.dteendw+1),nvl(r1.timout,'2359'),
                                      v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                      null,null,null,null,'Y',
                                      v_a_tovrtime,v_a_rteotpay,v_a_qtyminot); 
            for i in 1..5 loop
                v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
            end loop;
        end if;
        if nvl(v_qtymind,0) > 0 or (v_timdstr is not null and v_timdend is not null) then
            if nvl(v_qtymind,0) > 0 then
                v_dtestrt2      := null;
                v_timstrt2      := null;
                v_dteend2       := null;
                v_timend2       := null;
                v_qtyminreq2    := v_qtymind;
            else
                v_dtestrt2      := r1.dtework;
                v_timstrt2      := replace(v_timdstr,':');
                v_dteend2       := r1.dtework;
                v_timend2       := replace(v_timdend,':');
                v_qtyminreq2    := null;     
                if v_timend2 < v_timstrt2 then
                    v_dteend2   := r1.dtework + 1;
                end if;
            end if;

            hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                      null,r1.codempid,r1.dtework,'D',r1.codshift,
                                      nvl(r1.dtein,r1.dtestrtw),nvl(r1.timin,'0000'),nvl(r1.dteout,r1.dteendw+1),nvl(r1.timout,'2359'),
                                      v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                      null,null,null,null,'Y',
                                      v_a_tovrtime,v_a_rteotpay,v_a_qtyminot); 
            for i in 1..5 loop
                v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
            end loop;
        end if;
        if nvl(v_qtymina,0) > 0 or (v_timastr is not null and v_timaend is not null) then
            if nvl(v_qtymina,0) > 0 then
                v_dtestrt2      := null;
                v_timstrt2      := null;
                v_dteend2       := null;
                v_timend2       := null;
                v_qtyminreq2    := v_qtymina;
            else
                v_dtestrt2      := r1.dtework;
                v_timstrt2      := replace(v_timastr,':');
                v_dteend2       := r1.dtework;
                v_timend2       := replace(v_timaend,':');
                v_qtyminreq2    := null;     
                if v_timend2 < v_timstrt2 then
                    v_dteend2   := r1.dtework + 1;
                end if;
            end if;

            hral85b_batch.cal_time_ot(v_codcompy,v_dteeffec,v_condot,v_condextr,
                                      null,r1.codempid,r1.dtework,'A',r1.codshift,
                                      nvl(r1.dtein,r1.dtestrtw),nvl(r1.timin,'0000'),nvl(r1.dteout,r1.dteendw+1),nvl(r1.timout,'2359'),
                                      v_dtestrt2,v_timstrt2,v_dteend2,v_timend2,v_qtyminreq2,
                                      null,null,null,null,'Y',
                                      v_a_tovrtime,v_a_rteotpay,v_a_qtyminot); 
            for i in 1..5 loop
                v_qtyminot := nvl(v_qtyminot,0) + nvl(v_a_qtyminot(i),0);
            end loop;
        end if;
    end loop;
    return v_qtyminot;
  end get_qtyminot;

  procedure get_cumulative_hours(json_str_input in clob, json_str_output out clob) as
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_dtestrtwk         date;
    v_dteendwk          date;
    v_dtestrtwk2        date;
    v_dteendwk2         date;
    v_qtydaywk          number;
    v_qtymin            number;
    v_qtyot_reqoth      number;
    v_qtyot_req         number;
    v_qtyot_total       number;
    v_qtytotal          number;
    v_qtyminot          number;
    v_qtyminotOth       number;
    v_msg_error         varchar2(2000);
    v_qtymxotwk         tcontrot.qtymxotwk%type;
    v_qtymxallwk        tcontrot.qtymxallwk%type;
    v_row               number := 0;
    obj_main            json_object_t;
    v_typalert          tcontrot.typalert%type;
  begin
    initial_value(json_str_input);
    obj_row         := json_object_t();
    obj_main        := json_object_t();

    if p_codcomp is null then
        begin
            select codcomp
              into p_codcomp
              from temploy1
             where codempid = p_codempid_query;
        exception when others then
            p_codcomp     := null;
        end;
    end if;

    begin
        select nvl(qtymxotwk,0), nvl(qtymxallwk,0),nvl(typalert,'N')
          into v_qtymxotwk, v_qtymxallwk, v_typalert
          from tcontrot
         where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                              and dteeffec <= sysdate);
    exception when others then
        v_qtymxotwk     := 0;
        v_qtymxallwk    := 0;
        v_typalert      := 'N';
    end;
    if v_typalert <> 'N' then
        std_ot.get_week_ot(p_codempid_query, p_numotreq,p_dtereq,p_numseq,p_dtestrt,p_dteend,
                           p_qtyminb, p_timbend, p_timbstr,
                           p_qtymind, p_timdend, p_timdstr,
                           p_qtymina, p_timaend, p_timastr,
                           global_v_codempid,
                           a_dtestweek,a_dteenweek,
                           a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);

        for n in 1..v_qtyperiod loop
            obj_data        := json_object_t();
            obj_data.put('dtestrtwk',to_char(a_dtestweek(n),'dd/mm/yyyy'));
            obj_data.put('dteendwk',to_char(a_dteenweek(n),'dd/mm/yyyy'));
            obj_data.put('qtydaywk',hcm_util.convert_minute_to_hour(a_sumwork(n)));
            obj_data.put('qtyot_reqoth',hcm_util.convert_minute_to_hour(a_sumotreqoth(n)));
            obj_data.put('qtyot_req',hcm_util.convert_minute_to_hour(a_sumotreq(n)));
            obj_data.put('qtyot_total',hcm_util.convert_minute_to_hour(a_sumot(n)));
            obj_data.put('qtytotal',hcm_util.convert_minute_to_hour(a_totwork(n)));
            obj_row.put(to_char(n - 1),obj_data);

            if v_msg_error is null then
                v_qtyot_total   := a_sumot(n);
                v_qtytotal      := a_totwork(n);

                if (v_qtyot_total > v_qtymxotwk) then
                    v_msg_error := replace(get_error_msg_php('ES0075',global_v_lang),'@#$%400');
                elsif (v_qtytotal > v_qtymxallwk) then
                    v_msg_error := replace(get_error_msg_php('ES0076',global_v_lang),'@#$%400');
                end if;
            end if;
        end loop;
    end if;

    obj_main.put('coderror', '200');
    obj_main.put('msgerror',v_msg_error);
    obj_main.put('table',obj_row);
    json_str_output := obj_main.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_cumulative_hours;
  -->> user18 ST11 03/08/2021 change std detail cumulative overtime for week period

  -- << mo surachai | 13/09/2023
   procedure ot_budget(json_str_input in clob, json_str_output out clob) as
    p_codcompbg     ttotreq.codcomp%type;
    p_qtybudget     number;
    p_qtyothot      number;
    v_dtestrt       date;
    v_dteend        date;
    --
    v_departmentbudget varchar2(100);
    v_wkbudgetdate     varchar2(100);
    v_wkbudget         varchar2(100);
--    v_requesthr
--    v_otherrequesthr
--    v_totalhr
--    v_remainhr
--    v_percentused
--    v_overbudgetstatus

    --
    obj_data            json_object_t;
    v_sumotreqoth        number;
    v_sumotreq          number;
    v_percentused       number;
    v_remainhr          number;
    --
    vv_codcompbg        ttotreq.codcompbg%type;
    vv_qtybudget        ttotreq.qtybudget%type;
    vv_qtyotreq         ttotreq.qtyotreq%type;
    vv_qtyothot         ttotreq.qtyothot%type;
    vv_pctbguse         ttotreq.pctbguse%type;
   begin
    initial_value(json_str_input);
    -- หาวันที่ เริ่มต้นขสิ่นสุด ของอาทิต
    std_ot.get_week_ot(p_codempid_query, p_numotreq,p_dtereq,p_numseq,p_dtestrt,p_dteend,
                           p_qtyminb, p_timbend, p_timbstr,
                           p_qtymind, p_timdend, p_timdstr,
                           p_qtymina, p_timaend, p_timastr,
                           global_v_codempid,
                           a_dtestweek,a_dteenweek,
                           a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
    for n in 1..v_qtyperiod loop
--        v_dtestrt       := greatest(a_dtestweek(n), trunc(p_dtework,'mm'));
--        v_dteend        := least(a_dteenweek(n), p_dtework);
        v_dtestrt       := least(a_dtestweek(n), p_dtework);
        IF TO_CHAR(p_dtework, 'MM') != TO_CHAR(v_dtestrt, 'MM') THEN
            v_dtestrt := TRUNC(p_dtework, 'MM');
        END IF;
        v_dteend        := greatest(a_dteenweek(n), trunc(p_dtework,'mm'));
        IF TO_CHAR(p_dtework, 'MM') != TO_CHAR(v_dteend, 'MM') THEN
            v_dteend := LAST_DAY(p_dtework);
        END IF;
        v_sumotreqoth   := a_sumotreqoth(n);
        v_sumotreq      := a_sumotreq(n);
        exit;
    end loop;

    if p_staappr_ot = 'P' or p_staappr_ot is null then
--    param_msg_error := b_index_codempid || p_dtework || p_codcompw || p_dtereq || p_numseq || v_dtestrt || v_dteend;
--    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
--    return;
        otbudget.get_bugget_data(b_index_codempid,p_dtework,p_codcompw,
                                p_dtereq,p_numseq,v_dtestrt,v_dteend,
                                p_codcompbg,p_qtybudget,p_qtyothot);
          -- ***** use give open | surachai | 22/09/2023
        if nvl(p_qtybudget,0) > 0 then --user36 KOHU #1823 27/03/2024
        v_percentused := nvl((nvl(v_sumotreq,0) + nvl(p_qtyothot,0))/round(p_qtybudget, 0)*100,0); -- % ใช้ไป (ใช้จริงให้เปิด)
        else
        v_percentused := 0;
        end if;
        v_remainhr    := nvl(p_qtybudget,0) - (nvl(v_sumotreq,0) + nvl(p_qtyothot,0)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('response','');
        obj_data.put('codcompbg',p_codcompbg); -- รหัส งบประมาณของหน่วยงาน
        obj_data.put('departmentbudget',get_tcenter_name(p_codcompbg, global_v_lang));                                          -- งบประมาณของหน่วยงาน
        obj_data.put('wkbudgetdate',to_char(v_dtestrt,'dd/mm/yyyy')||' - '||to_char(v_dteend,'dd/mm/yyyy'));                    -- งบประมาณประจำสัปดาห์ วันที่
        obj_data.put('wkbudget',hcm_util.convert_minute_to_hour(round(nvl(p_qtybudget,0))));                                           -- งบประมาณประจำสัปดาห์ 
        obj_data.put('requesthr',hcm_util.convert_minute_to_hour(round(nvl(v_sumotreq,0))));                                           -- จำนวนชั่วโมงล่วงเวลาในใบคำขอนี้
        obj_data.put('otherrequesthr',hcm_util.convert_minute_to_hour(round(nvl(p_qtyothot,0))));                                      -- จำนวนชั่วโมงล่วงเวลาในใบคำขออื่น
        obj_data.put('totalhr',hcm_util.convert_minute_to_hour(round(nvl(v_sumotreq,0) + nvl(p_qtyothot,0))));                         -- รวมจำนวนชั่วโมงล่วงเวลา
        if v_remainhr < 0 then
                obj_data.put('remainhr',hcm_util.convert_minute_to_hour(0)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ (ถ้าติดลบให้แสดง 0)
        else
            obj_data.put('remainhr',hcm_util.convert_minute_to_hour(round(v_remainhr))); -- จำนวนชั่วโมงของงบประมาณคงเหลือ
        end if;
         obj_data.put('percentused',round(v_percentused)); -- % ใช้ไป -- bk อย่าลืมเปิด
        if v_percentused <= 100 or v_percentused is null then
            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'240'));
        elsif v_percentused > 100 then
            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'230'));
        else
            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'9999'));
        end if;

        -- **** test only | surachai | 22/09/2023
--        v_percentused := 99; -- % ใช้ไป (ใช้จริงให้เปิด)
--        v_remainhr    := 500; -- จำนวนชั่วโมงของงบประมาณคงเหลือ
--        obj_data := json_object_t();
--        obj_data.put('coderror','200');
--        obj_data.put('response','');
--        obj_data.put('codcompbg','TJS000000000000000000'); -- รหัส งบประมาณของหน่วยงาน
--        obj_data.put('departmentbudget',get_tcenter_name('TJS000000000000000000', global_v_lang));                                          -- งบประมาณของหน่วยงาน
--        obj_data.put('wkbudgetdate',to_char(v_dtestrt,'dd/mm/yyyy')||' - '||to_char(v_dteend,'dd/mm/yyyy'));                    -- งบประมาณประจำสัปดาห์ วันที่
--        obj_data.put('wkbudget',hcm_util.convert_minute_to_hour(nvl(800,0)));                                           -- งบประมาณประจำสัปดาห์ 
--        obj_data.put('requesthr',hcm_util.convert_minute_to_hour(nvl(240,0)));                                           -- จำนวนชั่วโมงล่วงเวลาในใบคำขอนี้
--        obj_data.put('otherrequesthr',hcm_util.convert_minute_to_hour(nvl(300,0)));                                      -- จำนวนชั่วโมงล่วงเวลาในใบคำขออื่น
--        obj_data.put('totalhr',hcm_util.convert_minute_to_hour(nvl(240,0) + nvl(300,0)));                         -- รวมจำนวนชั่วโมงล่วงเวลา
--        if v_remainhr < 0 then
--                obj_data.put('remainhr',hcm_util.convert_minute_to_hour(0)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ (ถ้าติดลบให้แสดง 0)
--        else
--            obj_data.put('remainhr',hcm_util.convert_minute_to_hour(v_remainhr)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ
--        end if;
--         obj_data.put('percentused',v_percentused); -- % ใช้ไป -- bk อย่าลืมเปิด
--        if v_percentused <= 100 or v_percentused is null then
--            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'240'));
--        elsif v_percentused > 100 then
--            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'230'));
--        else
--            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'9999'));
--        end if;

    else
        begin 
            select  codcompbg,qtybudget,qtyotreq,qtyothot,pctbguse
            into vv_codcompbg,vv_qtybudget,vv_qtyotreq,vv_qtyothot,vv_pctbguse
            from   ttotreq
            where codempid = p_codempid_query
                and  dtereq   = p_dtereq
                and  numseq   = p_numseq;
        exception when no_data_found then
            vv_codcompbg    := '';
            vv_qtybudget    := 0;
            vv_qtyotreq     := 0;
            vv_qtyothot     := 0;
            vv_pctbguse     := 0;
        end;
        v_remainhr    := nvl(vv_qtybudget,0) - (nvl(vv_qtyotreq,0) + nvl(vv_qtyothot,0)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ
        obj_data := json_object_t();
        obj_data.put('coderror','200');
        obj_data.put('response','');
        obj_data.put('codcompbg',vv_codcompbg); -- รหัส งบประมาณของหน่วยงาน
        -- obj_data.put('codcompbg','1-xxxx'); -- รหัส งบประมาณของหน่วยงาน
        obj_data.put('departmentbudget',get_tcenter_name(vv_codcompbg, global_v_lang));                                          -- งบประมาณของหน่วยงาน
        obj_data.put('wkbudgetdate',to_char(v_dtestrt,'dd/mm/yyyy')||' - '||to_char(v_dteend,'dd/mm/yyyy'));                    -- งบประมาณประจำสัปดาห์ วันที่
        obj_data.put('wkbudget',hcm_util.convert_minute_to_hour(nvl(vv_qtybudget,0)));                                           -- งบประมาณประจำสัปดาห์ 
        obj_data.put('requesthr',hcm_util.convert_minute_to_hour(nvl(vv_qtyotreq,0)));                                           -- จำนวนชั่วโมงล่วงเวลาในใบคำขอนี้
        obj_data.put('otherrequesthr',hcm_util.convert_minute_to_hour(nvl(vv_qtyothot,0)));                                      -- จำนวนชั่วโมงล่วงเวลาในใบคำขออื่น
        obj_data.put('totalhr',hcm_util.convert_minute_to_hour(nvl(vv_qtyotreq,0) + nvl(vv_qtyothot,0)));                         -- รวมจำนวนชั่วโมงล่วงเวลา
        if v_remainhr < 0 then
                obj_data.put('remainhr',hcm_util.convert_minute_to_hour(0)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ (ถ้าติดลบให้แสดง 0)
        else
            obj_data.put('remainhr',hcm_util.convert_minute_to_hour(v_remainhr)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ
        end if;
         obj_data.put('percentused',vv_pctbguse); -- % ใช้ไป -- bk อย่าลืมเปิด
--        obj_data.put('percentused',101); -- % ใช้ไป
        if vv_pctbguse <= 100 or vv_pctbguse is null then
            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'240'));
        elsif vv_pctbguse > 100 then
            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'230'));
        else
            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'9999'));
        end if;
    end if;
    json_str_output := obj_data.to_clob;

   exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
   end ot_budget;

   procedure list_of_app(json_str_input in clob, json_srt_output out clob) as
   obj_data_row            json_object_t;
   obj_data                 json_object_t;
   v_codapp varchar2(8 char) := 'HRES6KE';
   v_check varchar2(1 char);
   v_maxstep number;
   v_codappr array_t;
   v_codpos    temploy1.codpos%type;
   v_codcomp   temploy1.codcomp%type;
   v_count  number;

   cursor c_tempflow is 
    select *
    from tempflow
    where codempid = p_codempid_query
       and codapp  = v_codapp;

    cursor c_tempaprq is
        select * 
        from   tempaprq
        where codempid = p_codempid_query
            and    dtereq  = p_dtereq
            and    numseq  = p_numseq
            and    codapp  = v_codapp
        order by approvno asc;

   begin

    initial_value(json_str_input);
     -- p_percentused := 61;
    v_check := '';
    if p_staappr_ot = 'P' or p_staappr_ot is null then
        for r in c_tempflow loop    
            v_check := 'Y';
-->> Site: mo-kohu-sm2301 Author: Nuii Kowit (000551) Date updated: 11 April 2024 15:21 Comment: redmine 4449#1865
--            if p_percentused > r.pctotreq4 then
                v_maxstep := 4;
--            elsif p_percentused > r.pctotreq3 then
--                v_maxstep := 3;
--            elsif p_percentused > r.pctotreq2 then
--                v_maxstep := 2;
--            else   
--                v_maxstep := 1;
--            end if;
            v_codappr := array_t();
--            v_codappr(1) := null;
--            v_codappr(2) := null;
--            v_codappr(3) := null;
--            v_codappr(4) := null;
--            If v_maxstep = 1 then
--                v_codappr(1) := r.codappr1;	
--            Elsif v_maxstep = 2 then
--                v_codappr(1) := r.codappr1;
--                v_codappr(2) := r.codappr2;
--            Elsif v_maxstep = 3 then
--                v_codappr(1) := r.codappr1;
--                v_codappr(2) := r.codappr2;
--                v_codappr(3) := r.codappr3;
--            Elsif v_maxstep = 4 then
                v_codappr(1) := r.codappr1;
                v_codappr(2) := r.codappr2;
                v_codappr(3) := r.codappr3;
                v_codappr(4) := r.codappr4;
--            end if;	
--<< Site: mo-kohu-sm2301 Author: Nuii Kowit (000551) Date updated: 11 April 2024 15:21 Comment: redmine 4449#1865
        end loop;
        if v_check is null then
            obj_data_row := json_object_t();
            obj_data := json_object_t();

            obj_data.put('coderror','200');
            obj_data.put('response',replace(get_error_msg_php('ESZ004',global_v_lang),'@#$%400'));
            obj_data.put('type_error','warning');
            obj_data_row.put(to_char(0),obj_data);
            json_srt_output := obj_data_row.to_clob;
            return;
        end if;
        obj_data_row := json_object_t();
        for  i in 1..v_maxstep loop

            obj_data := json_object_t();
            if v_codappr(i) is not null then
                begin
                    select codpos,codcomp
                    into v_codpos,v_codcomp
                    from temploy1 
                    where codempid = v_codappr(i);
                exception when no_data_found then
                    v_codpos := '';
                    v_codcomp := '';
                end;
                obj_data.put('coderror','200');
                obj_data.put('response','');
                obj_data.put('no', i);
                obj_data.put('codempap', v_codappr(i));
                obj_data.put('desc_codempap',get_temploy_name(v_codappr(i), global_v_lang));
                obj_data.put('codpos',v_codpos);
                obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
                obj_data.put('codcomp',v_codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
                obj_data_row.put(to_char(i-1),obj_data);
            end if;
        end loop;
    else
        obj_data_row := json_object_t();
        v_count := 0;
         v_check := '';
        for r2 in c_tempaprq loop
            v_check := 'Y';
            v_count := v_count+1;
                 begin
                    select codpos,codcomp
                    into v_codpos,v_codcomp
                    from temploy1 
                    where codempid = r2.codempap;
                exception when no_data_found then
                    v_codpos := '';
                    v_codcomp := '';
                end;
                obj_data := json_object_t();
                obj_data.put('coderror','200');
                obj_data.put('response','');
                obj_data.put('no', v_count);
                obj_data.put('codempap', r2.codempap);
                obj_data.put('desc_codempap',get_temploy_name(r2.codempap, global_v_lang));
                obj_data.put('codpos',v_codpos);
                obj_data.put('desc_codpos',get_tpostn_name(v_codpos,global_v_lang));
                obj_data.put('codcomp',v_codcomp);
                obj_data.put('desc_codcomp',get_tcenter_name(v_codcomp,global_v_lang));
                obj_data_row.put(to_char(v_count-1),obj_data);
                v_count := v_count+1;
        end loop;
        if v_check is null then
            obj_data_row := json_object_t();
            obj_data := json_object_t();

            obj_data.put('coderror','200');
            obj_data.put('response',replace(get_error_msg_php('ESZ004',global_v_lang),'@#$%400'));
            obj_data.put('type_error','warning');
            obj_data_row.put(to_char(0),obj_data);
            json_srt_output := obj_data_row.to_clob;
            return;
            return;
        end if;
    end if;
    json_srt_output := obj_data_row.to_clob;

    exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_srt_output   := get_response_message('400',param_msg_error,global_v_lang);
   end;
   -- >>
end M_HRES6KE;

/
