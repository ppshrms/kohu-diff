--------------------------------------------------------
--  DDL for Package Body M_HRMS6KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "M_HRMS6KE" is
/* Cust-Modify: KOHU-HE2301 */ 
-- last update: 09/12/2023 15:43  
  function check_date (p_date in varchar2, p_zyear in number) return boolean is
    v_date		date;
    v_error		boolean := false;
  begin
    if p_date is not null then
      begin
        v_date := to_date(p_date,'dd/mm/yyyy');
      exception when others then
        v_error := true;
        return(v_error);
      end;
    end if;
    return(v_error);
  end;

  function check_dteyre (p_date in varchar2)
  return date is
    v_date		date;
    v_error		boolean := false;
    v_year    number;
    v_daymon	varchar2(30);
    v_text		varchar2(30);
    p_zyear		number;
    chkreg 		varchar2(30);
  begin
     begin
      select value into chkreg
      from v$nls_parameters where parameter = 'NLS_CALENDAR';
      if chkreg = 'Thai Buddha' then
        if to_number(substr(p_date,-4,4)) > 2500 then
          p_zyear := 0;
        else
          p_zyear := 543;
       end if;
      else
       if to_number(substr(p_date,-4,4)) > 2500 then
          p_zyear := -543;
       else
          p_zyear := 0;
       end if;
      end if;
    end;

    if p_date is not null then
      -- plus year --
      v_year			:= substr(p_date,-4,4);
      v_year			:= v_year + p_zyear;
      v_daymon		:= substr(p_date,1,length(p_date)-4);
      v_text			:= v_daymon||to_char(v_year);
      v_year      := null;
      v_daymon    := null;
      -- plus year --
      v_date := to_date(v_text,'dd/mm/yyyy');
    end if;

    return(v_date);
  end;

  function check_times (p_time in varchar2) return boolean is
    v_stmt			varchar2(500);
    v_time			varchar2(4);
  begin
    v_stmt := 'select to_char(to_date('''||p_time||
              ''',''hh24mi''),''hh24mi'') from dual';
    v_time := execute_desc(v_stmt);
    if v_time is null then
      return(false);
    else
      return(true);
    end if;
  end;


  procedure check_index is
  begin
    if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;

    if b_index_codempid is not null then
      param_msg_error := hcm_secur.secur_codempid(global_v_coduser, global_v_lang, b_index_codempid);
      if param_msg_error is not null then
        return;
      end if;
    end if;

-- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 03/04/2024 | Update Code For Review
    if b_index_dtestrt	is	not null or b_index_dteend is not null then
        if b_index_dtestrt	is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if b_index_dteend	is null then
          param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        end if;
        if b_index_dtestrt > b_index_dteend then
          param_msg_error := get_error_msg_php('HR2021',global_v_lang);
        end if;
    end if;
-- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 03/04/2024 | Update Code For Review
  end;
  --

  procedure get_index(json_str_input in clob, json_str_output out clob) as
    json_obj        json_object_t;
    v_codempid      temploy1.codempid%type;
    v_dtereq        varchar2(100);
    v_timbstr       varchar2(100);
    v_timdstr       varchar2(100);
    v_timastr       varchar2(100);
    v_row           number;
    v_total         number;
    flgpass         boolean;
    flg_secur       boolean ;
    v_zupdsal       varchar2(1);
	v_flgsal		boolean;

    obj_row         json_object_t;
    obj_data        json_object_t;
    -- check null data --
    v_flg_exist     boolean := false;

    cursor c1 is
      select 	numotgen,dtereq,dtestrt,dteend,codcomp,timbstr,timbend,timdstr,timdend,timastr,timaend,qtymina,qtyminb,qtymind
  	  from   	ttotreqst a
--      where   ((codcomp is not null and codcomp like b_index_codcomp||'%') or (codcomp is null))
--  	  and    	numotgen in	(select	numotgen	from	ttotreq	where	codempid	like	nvl(b_index_codempid||'%',codempid))
--  	  and			((dtereq	between b_index_dtestrt	and b_index_dteend) or b_index_dtestrt is null)
      where   ((codcomp is not null and codcomp like b_index_codcomp||'%') or (codcomp is null))
  	  and    	((numotgen in	(select	numotgen	from	ttotreq	where	codempid	like	b_index_codempid))  or (b_index_codempid is null))
--  	  and			((dtereq	between b_index_dtestrt	and b_index_dteend) or b_index_dtestrt is null)
      and (
              dtestrt  between nvl(b_index_dtestrt,dtestrt) and nvl(b_index_dteend,dtestrt)
                  or
              dteend  between nvl(b_index_dtestrt,dteend) and nvl(b_index_dteend,dteend)
                  or
              b_index_dtestrt between     dtestrt  and dteend
                  or
             b_index_dteend between     dtestrt  and dteend
            )
  	  and      exists (select  numotgen
                       from    ttotreq b ,temploy1 c
                       where   a.numotgen = b.numotgen
                       and     b.codempid = c.codempid
                       and     c.numlvl between global_v_zminlvl and global_v_zwrklvl
                       and    (b.codempid = global_v_codempid or
                              (b.codempid <> global_v_codempid
                               and     0 <> (select count(ts.codcomp)
                                             from  tusrcom ts
                                             where ts.coduser = global_v_coduser
                                             and   b.codcomp like ts.codcomp||'%'
                                             and rownum <= 1 ) ))
  	                        )
  	  order by numotgen;

  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
    check_index;
    if param_msg_error is null then
      if b_index_codempid is not null then
        begin
          select codempid
          into v_codempid
          from temploy1
          where codempid like b_index_codempid
            and rownum = 1;
        exception when no_data_found then
          param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        end;
        -- user19
        flg_secur := secur_main.secur2(b_index_codempid, global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        if not flg_secur then
           param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        end if;

      end if;

      --
--      for r1 in c1 loop
--        v_flg_exist := true;
--        exit;
--      end loop;
      --
--      if not v_flg_exist then
--        param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttotreqst');
--        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--        return;
--      end if;
      --
      if param_msg_error is null then
        v_row := 0;
        for i in c1 loop
          flgpass := secur_main.secur7(i.codcomp,global_v_coduser);
          if flgpass = true then
            v_row := v_row+1;

            v_dtereq		:= to_char(i.dtestrt,'dd/mm/yyyy') || '  -  '||to_char(i.dteend,'dd/mm/yyyy');
            if i.timbstr	is	not null then
              v_timbstr	:= substr(i.timbstr,1,2)||':'||substr(i.timbstr,3,2)||'  -  '||substr(i.timbend,1,2)||':'||substr(i.timbend,3,2);
            else
              v_timbstr	:= hcm_util.convert_minute_to_time(i.qtyminb);
              if v_timbstr is not null then
                v_timbstr := v_timbstr || ' ' || get_label_name('HRMS6KE1',global_v_lang,100);
              end if;
            end if;
            if i.timdstr	is	not null then
              v_timdstr	:= substr(i.timdstr,1,2)||':'||substr(i.timdstr,3,2)||'  -  '||substr(i.timdend,1,2)||':'||substr(i.timdend,3,2);
            else
              v_timdstr	:= hcm_util.convert_minute_to_time(i.qtymind);
              if v_timdstr is not null then
                v_timdstr := v_timdstr || ' ' || get_label_name('HRMS6KE1',global_v_lang,100);
              end if;
            end if;
            if i.timastr	is	not null then
              v_timastr	:= substr(i.timastr,1,2)||':'||substr(i.timastr,3,2)||'  -  '||substr(i.timaend,1,2)||':'||substr(i.timaend,3,2);
            else
              v_timastr	:= hcm_util.convert_minute_to_time(i.qtymina);
              if v_timastr is not null then
                v_timastr := v_timastr || ' ' || get_label_name('HRMS6KE1',global_v_lang,100);
              end if;
            end if;

            obj_data := json_object_t();
            obj_data.put('coderror','200');
            obj_data.put('numotgen',i.numotgen);
            obj_data.put('dtereq',v_dtereq);
            obj_data.put('timbstr',v_timbstr);
            obj_data.put('timdstr',v_timdstr);
            obj_data.put('timastr',v_timastr);
            obj_data.put('desc_codcomp',get_tcenter_name(i.codcomp,global_v_lang));
            obj_data.put('codcomp',i.codcomp);
            obj_row.put(to_char(v_row-1),obj_data);
          end if;
        end loop; -- end for
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
      end if;
      json_str_output := obj_row.to_clob;
      return;
    end if;	--param_msg_error
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure check_detail_tab1 is
  begin
     if b_index_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,b_index_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end;

  procedure get_tab1(json_str_input in clob, json_str_output out clob) is
    obj_data          json_object_t;
    obj_data2         json_object_t;
    v_cost_center     varchar2(100 char);
    v_staappr         varchar2(10 char);
    tcontrot_flgchglv varchar2(100 char);
  begin
    initial_value(json_str_input);

    check_detail_tab1;
    if param_msg_error is null then
      begin
        select dtereq,codcomp,codcalen,codshift,dtestrt,dteend,timbstr,timbend,
               timdstr,timdend,timastr,timaend,codrem,remark,codinput,codempid,
               flgchglv, codcompw, qtyminb, qtymind, qtymina
          into v_dtereq,v_codcomp,v_codcalen,v_codshift,v_dtestrt,v_dteend,v_timbstr,v_timbend,
               v_timdstr,v_timdend,v_timastr,v_timaend,v_codrem,v_remark,v_codinput,v_codempid,
               v_flgchglv, v_codcompw, v_qtyminb, v_qtymind, v_qtymina
          from ttotreqst
         where numotgen = b_index_numotgen;
      end;
      --

      -- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | Fix issue 4449#1746 and fix change date effect or codempid is get data in table tattence
      begin
        select 'Y'
          into v_staappr
          from ttotreq
         where numotgen = b_index_numotgen
           and staappr in ('A', 'Y' , 'N')
         fetch first 1 row only;
      exception when no_data_found then
        v_staappr := 'N';
      end;
      -- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | Fix issue 4449#1746 and fix change date effect or codempid is get data in table tattence

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
      begin
        select flgchglv  into tcontrot_flgchglv
          from tcontrot
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteeffec = (select max(dteeffec) from tcontrot
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                              and dteeffec <= sysdate);
      exception when no_data_found then
        tcontrot_flgchglv := null;
      end;
      --
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numotgen',b_index_numotgen);
      obj_data.put('dtereq',nvl(to_char(v_dtereq,'dd/mm/yyyy'),''));
      obj_data.put('codcomp',v_codcomp);
      obj_data.put('codcalen',v_codcalen);
      obj_data.put('codshift',v_codshift);
      obj_data.put('dtestrt',to_char(v_dtestrt,'dd/mm/yyyy'));
      obj_data.put('dteend',to_char(v_dteend,'dd/mm/yyyy'));
      obj_data.put('timbstr',CASE WHEN v_timbstr is not null then substr(v_timbstr,1,2)||':'||substr(v_timbstr,3,2) else '' end);
      obj_data.put('timbend',CASE WHEN v_timbend is not null then substr(v_timbend,1,2)||':'||substr(v_timbend,3,2) else '' end);
      obj_data.put('timdstr',CASE WHEN v_timdstr is not null then substr(v_timdstr,1,2)||':'||substr(v_timdstr,3,2) else '' end);
      obj_data.put('timdend',CASE WHEN v_timdend is not null then substr(v_timdend,1,2)||':'||substr(v_timdend,3,2) else '' end);
      obj_data.put('timastr',CASE WHEN v_timastr is not null then substr(v_timastr,1,2)||':'||substr(v_timastr,3,2) else '' end);
      obj_data.put('timaend',CASE WHEN v_timaend is not null then substr(v_timaend,1,2)||':'||substr(v_timaend,3,2) else '' end);
      obj_data.put('codrem',v_codrem);
      obj_data.put('remark',v_remark);
      -- /*user3*/ new requirement --
--      obj_data.put('codempid',v_codempid);
      obj_data.put('codempid',v_codempid); -- user18 13/08/2021 fix issue #6319
      obj_data.put('codinput',v_codinput||' '||get_temploy_name(v_codinput,global_v_lang));
      obj_data.put('name_codinput',nvl(get_temploy_name(v_codinput,global_v_lang),''));
      obj_data.put('tcontrot_flgchglv',tcontrot_flgchglv);
      obj_data.put('flgchglv',v_flgchglv);
      obj_data.put('codcompw',v_codcompw);
      obj_data.put('qtyminb',hcm_util.convert_minute_to_time(v_qtyminb));
      obj_data.put('qtymind',hcm_util.convert_minute_to_time(v_qtymind));
      obj_data.put('qtymina',hcm_util.convert_minute_to_time(v_qtymina));
      if v_codcompw is not null then
        obj_data.put('costcent',v_cost_center);
      end if;
      obj_data.put('staappr',v_staappr);

      json_str_output := obj_data.to_clob;
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
     end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_tab2(json_str_input in clob, json_str_output out clob) as
    obj_row       json_object_t;
    obj_data      json_object_t;
    v_typot       varchar2(1 char);
    v_timstrt     varchar2(10 char);
    v_timend      varchar2(10 char);
    flg_secur     boolean ;
    v_zupdsal     varchar2(1);
	v_flgsal	  boolean;
    v_row         number;
    v_total       number;
    v_qtymin      varchar2(10 char);
    v_cost_center varchar2(100 char);

    -->> user18 ST11 03/08/2021 change std
    v_dtestrtwk     date;
    v_dteendwk      date;

    v_dtestrtwk2    date;
    v_dteendwk2     date;

    v_qtydaywk      number;
    v_qtyot_reqoth  number;
    v_qtyot_req     number;
    v_qtyot_total   number;
    v_qtytotal      number;

    v_qtyminot      number;
    v_qtyminotOth   number;

    v_qtyminotb     number;
    v_qtyminotd     number;
    v_qtyminota     number;
    v_tmp_qtyot_req number;
    v_numotreq      ttotreq.numotreq%type;
    flg_cancel          boolean;
    v_numperiod   tovrtime.numperiod%type;
    v_dtemthpay   tovrtime.dtemthpay%type;
    v_dteyrepay   tovrtime.dteyrepay%type;
    v_flgDeleteDisabled varchar2(1);
    v_typalert      tcontrot.typalert%type;
    --<< user18 ST11 03/08/2021 change std

    cursor c1 is
      select a.dtestrt,a.codempid,a.numseq,a.timbstr,a.timbend,a.timdstr,a.timdend,a.timastr,a.timaend,a.staappr,
             a.flgchglv, a.codcompw, a.qtymina, a.qtyminb, a.qtymind,
             a.codcomp, a.dtereq, a.numotgen,a.staovrot, a.numotreq -- user18 ST11 03/08/2021 change std
        from ttotreq a, temploy1 c
       where a.numotgen = b_index_numotgen
         and a.codempid = c.codempid
  	     and c.numlvl between global_v_zminlvl and global_v_zwrklvl
         and 0 <> (select count(ts.codcomp)
                    from tusrcom ts
                   where ts.coduser = global_v_coduser
                     and c.codcomp like ts.codcomp||'%'
                     and rownum <= 1 );
    cursor c2 is
        select codempid, dtework, typot,
               flgotcal, numperiod, dtemthpay, dteyrepay
          from tovrtime
         where codempid  = ttotreq_codempid
           and numotreq = v_numotreq
      order by dtework;

    cursor c3 is
        select flgtran
          from tpaysum
         where numperiod = v_numperiod
           and dtemthpay = v_dtemthpay
           and dteyrepay = v_dteyrepay
           and codempid = ttotreq_codempid
           and CODALW = 'OT' ;

  begin
    initial_value(json_str_input);
    obj_row  := json_object_t();
    v_row := 0;

    -->> user18 ST11 03/08/2021 change std
    begin
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRMS6KE3';
    exception when others then
        null;
    end;
    v_report_numseq := 0;
    --<< user18 ST11 03/08/2021 change std

    for i in c1 loop
      ttotreq_codempid  := i.codempid;
      v_row := v_row+1;
      --
      begin
        select  codshift
          into  v_codshift
          from  tattence
          where codempid = i.codempid
          and   dtework  = i.dtestrt
          order by dtework;
      exception when no_data_found then
        v_codshift := null;
      end;

      if i.timastr is not null or nvl(i.qtymina,0) > 0 then
        v_typot   := 'A';
        v_timstrt := to_char(to_date(i.timastr,'hh24:mi'), 'hh24:mi');
        v_timend  := to_char(to_date(i.timaend,'hh24:mi'), 'hh24:mi');
        v_qtymin  := hcm_util.convert_minute_to_hour(i.qtymina);
      end if;
      if i.timbstr is not null or nvl(i.qtyminb,0) > 0 then
        v_typot   := 'B';
        v_timstrt := to_char(to_date(i.timbstr,'hh24:mi'), 'hh24:mi');
        v_timend  := to_char(to_date(i.timbend,'hh24:mi'), 'hh24:mi');
        v_qtymin  := hcm_util.convert_minute_to_hour(i.qtyminb);
      end if;
      if i.timdstr is not null or nvl(i.qtymind,0) > 0 then
        v_typot   := 'D';
        v_timstrt := to_char(to_date(i.timdstr,'hh24:mi'), 'hh24:mi');
        v_timend  := to_char(to_date(i.timdend,'hh24:mi'), 'hh24:mi');
        v_qtymin  := hcm_util.convert_minute_to_hour(i.qtymind);
      end if;
      --
      begin
        select costcent into v_cost_center
          from tcenter
         where codcomp = i.codcompw
           and rownum <= 1
      order by codcomp;
      exception when no_data_found then
        v_cost_center := null;
      end;

      begin
        select nvl(typalert,'N')
          into v_typalert
          from tcontrot
         where codcompy = hcm_util.get_codcomp_level(i.codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = hcm_util.get_codcomp_level(i.codcomp,1)
                              and dteeffec <= sysdate);
      exception when others then
        v_typalert  := 'N';
      end;

      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtestrt',nvl(to_char(i.dtestrt,'dd/mm/yyyy'),''));
      obj_data.put('codempid',i.codempid);
      obj_data.put('numseq',i.numseq);
      obj_data.put('desc_codempid',get_temploy_name(i.codempid,global_v_lang));
      obj_data.put('typot',v_typot);
      obj_data.put('codshift',v_codshift);
      obj_data.put('v_timstrt',v_timstrt);
      obj_data.put('v_timend',v_timend);
      obj_data.put('staappr',i.staappr);
      obj_data.put('v_staappr',get_tlistval_name('ESSTAREQ',i.staappr,global_v_lang));
      --
      if nvl(i.flgchglv,'N') = 'Y' then
        obj_data.put('flgchglv_',false);
      else
        obj_data.put('flgchglv_',true);
      end if;
      obj_data.put('flgchglv',i.flgchglv);
      obj_data.put('codcompw',i.codcompw);
      obj_data.put('qtyminr',v_qtymin);
      obj_data.put('timstrt',v_timstrt);
      obj_data.put('timend',v_timend);

      if i.codcompw is not null then
        obj_data.put('costcent',v_cost_center);
      end if;

      if i.staappr = 'P' then
        v_flgDeleteDisabled := 'N';
      elsif i.staappr in ('N')  then
        v_flgDeleteDisabled := 'Y';
      elsif i.staappr in ('A','Y')  then
        if ttotreq_staappr = 'Y' then
            v_flgDeleteDisabled := 'N';
            flg_cancel  := true;
            for r2 in c2 loop
                if r2.flgotcal = 'Y' then
                    v_numperiod   := r2.numperiod;
                    v_dtemthpay   := r2.dtemthpay;
                    v_dteyrepay   := r2.dteyrepay;
                    for r3 in c3 loop
                        if r3.flgtran = 'Y' then
                            flg_cancel := false;
                        end if;
                    end loop;
                end if;

                if flg_cancel then
                    v_flgDeleteDisabled := 'N';
                else
                    v_flgDeleteDisabled := 'Y';
                end if;
            end loop;
        elsif i.staappr = 'A' then
            v_flgDeleteDisabled := 'Y';
        end if;
      end if;
      obj_data.put('flgDeleteDisabled',v_flgDeleteDisabled);

      -->> user18 ST11 03/08/2021 change std
      std_ot.get_week_ot(i.codempid, i.numotreq,i.dtereq,i.numseq,i.dtestrt,i.dtestrt,
                         i.qtyminb, i.timbend, i.timbstr,
                         i.qtymind, i.timdend, i.timdstr,
                         i.qtymina, i.timaend, i.timastr,
                         global_v_codempid,
                         a_dtestweek,a_dteenweek,
                         a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
      v_dtestrtwk   := a_dtestweek(1);
      v_dteendwk    := a_dteenweek(1);
      v_qtydaywk    := a_sumwork(1);
      v_qtyminotOth := a_sumotreqoth(1);
      v_qtyminot    := a_sumotreq(1);
      v_qtytotal    := a_totwork(1);
      v_qtyot_total := a_sumot(1);

      obj_data.put('qtytotal',hcm_util.convert_minute_to_hour(v_qtytotal));
      obj_data.put('dtestrtwk',to_char(v_dtestrtwk,'dd/mm/yyyy'));
      obj_data.put('dteendwk',to_char(v_dteendwk,'dd/mm/yyyy'));
      obj_data.put('qtydaywk',hcm_util.convert_minute_to_hour(v_qtydaywk));
      obj_data.put('qtyot_reqoth',hcm_util.convert_minute_to_hour(v_qtyminotOth));
      obj_data.put('qtyot_req',hcm_util.convert_minute_to_hour(v_qtyminot));
      obj_data.put('qtyot_total',hcm_util.convert_minute_to_hour(v_qtyot_total));

      v_report_numseq := v_report_numseq + 1;
      obj_data.put('seqno',v_report_numseq);
      obj_data.put('staovrot',nvl(i.staovrot,'N'));
      obj_data.put('numotreq',i.numotreq);
      obj_data.put('typalert',v_typalert);
      insert into ttemprpt (codempid,codapp,numseq,
                            item1,item2,item3,item4,item5,
                            item6,item7,item8,item9,item10,
                            item11,item12,item13,item14,item15,
                            item16,item17,item18,item19,item20,
                            item21,item22,item23,item24,
                            item25,item26,item27,item28,item29,item30,item31)
      values(global_v_codempid,'HRMS6KE3',v_report_numseq,
                            nvl(to_char(i.dtestrt,'dd/mm/yyyy'),''),i.codempid,
                            i.numseq,get_temploy_name(i.codempid,global_v_lang),
                            v_typot,v_codshift,v_timstrt,v_timend,i.staappr,get_tlistval_name('ESSTAREQ',i.staappr,global_v_lang),
                            i.flgchglv,i.flgchglv,i.codcompw,v_qtymin,v_timstrt,
                            v_timend,v_cost_center,
                            hcm_util.convert_minute_to_hour(v_qtydaywk + v_qtyminotOth + v_qtyminot), --item18
                            to_char(v_dtestrtwk,'dd/mm/yyyy'),to_char(v_dteendwk,'dd/mm/yyyy'), --item19,item20
                            hcm_util.convert_minute_to_hour(v_qtydaywk),hcm_util.convert_minute_to_hour(v_qtyminotOth), --item21,item22
                            hcm_util.convert_minute_to_hour(v_qtyminot),hcm_util.convert_minute_to_hour(v_qtyminotOth + v_qtyminot), --item23,item24
                            0,0,0,nvl(i.staovrot,'N'),i.numotreq, v_flgDeleteDisabled,v_typalert);
                            commit;
      --<< user18 ST11 03/08/2021 change std
      obj_data.put('listofapp','<i class="fa fa-info-circle " data-toggle="modal" href="#hrms6ke-list-of-app"></i>');

      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end for
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_ttotreq (p_codempid	in temploy1.codempid%type,--User37 STA4590329 26/12/2016
						 p_staemp   in temploy1.staemp%type,
						 p_dteeffex in temploy1.dteeffex%type) is
    obj_row         json_object_t;
    obj_data        json_object_t;
    json_str_output clob;
    v_row           number := 0;
    v_timstotb      varchar2(4);
    v_timenotb      varchar2(4);
    v_timstotd      varchar2(4);
    v_timenotd      varchar2(4);
    v_timstota      varchar2(4);
    v_timenota      varchar2(4);
    v_gentime       varchar2(1);
    v_namemp		temploy1.namempt%type;

    v_condot		varchar2(500);
    v_condextr		varchar2(500);
    v_dtewkreq		date;
    v_dteeffec		date;
    v_totmeal		varchar2(1);

    v_codcomp       temploy1.codcomp%type;
    v_codpos        temploy1.codpos%type;
    v_numlvl        temploy1.numlvl%type;
    v_typemp        temploy1.typemp%type;
    v_codempmt      temploy1.codempmt%type;
    v_codcalen      temploy1.codempmt%type;
    v_jobgrade      temploy1.jobgrade%type;
    v_amtincom1     temploy3.amtincom1%type;
    v_codcurr		temploy3.codcurr%type;

    v_cond			tcontrot.condot%type;
    v_stmt      	varchar2(1000);
    v_ratechge		tratechg.ratechge%type;
    v_chkreg 		varchar2(100);
    v_zyear			number;
    v_flgcondot		boolean;
    v_flgcondextr	boolean;
    v_seqno			number;--User37 STA4590329 27/12/2016

    -->> user18 ST11 03/08/2021 change std
    v_qtydaywk      number;
    v_qtyot_reqoth  number;
    v_qtyot_req     number;
    v_qtyot_total   number;
    v_qtytotal      number;

    v_qtyminot      number;
    v_qtyminotOth   number;

    v_qtyminotb     number;
    v_qtyminotd     number;
    v_qtyminota     number;
    v_tmp_qtyot_req number;
    v_qtyday_req    number;
    v_qtymxotwk     tcontrot.qtymxotwk%type;
    v_qtymxallwk    tcontrot.qtymxallwk%type;
    v_typalert      tcontrot.typalert%type;
    v_qtyminotOth_cumulative number;
    v_codempid_tmp          tattence.codempid%type;
    v_ttemprpt          ttemprpt%rowtype;
    v_numseq_tmp        number;
    --<< user18 ST11 03/08/2021 change std


    cursor c_tattence is
      select codempid,dtework,typwork,codshift
      from   tattence
      where  codempid = p_codempid
      and    dtework  between ttotreqst_dtestrt  and ttotreqst_dteend
      order by dtework;

    cursor c_ttmovemt is
      select codempid,dteeffec,numseq,
             codcomp,codpos,numlvl,typemp,codempmt,codcalen,jobgrade,
             nvl(stddec(amtincom1,codempid,global_v_chken),0) amtincom1
        from ttmovemt
       where codempid  = p_codempid
         and dteeffec <= v_dtewkreq
         and staupd in('C','U')
    order by dteeffec desc ,numseq desc;

    cursor c_ttmovemt2 is
      select codempid,dteeffec,numseq,
             codcompt,codposnow,numlvlt,typempt,codempmtt,codcalet,jobgradet,
             nvl(stddec(amtincom1,codempid,global_v_chken),0) - nvl(stddec(amtincadj1,codempid,global_v_chken),0) amtincom1
        from ttmovemt
       where codempid = p_codempid
         and dteeffec > v_dtewkreq
         and staupd in('C','U')
    order by dteeffec,numseq;

    cursor c_temp is
      SELECT distinct item2 codempid,
             to_date(item19,'dd/mm/yyyy') dtestrtwk,
             to_date(item20,'dd/mm/yyyy') dteendwk
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
      ORDER BY item2, dtestrtwk;

    CURSOR c_temp2 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
         and item2 = v_codempid_tmp
         and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
      ORDER BY numseq;

    CURSOR c1 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
      ORDER BY numseq;


  BEGIN

    obj_row  := json_object_t();
    obj_data := json_object_t();
    --<<user36 19/2/2014
    begin
      select a.codcomp,a.codpos,a.numlvl,a.typemp,a.codempmt,a.codcalen,
             nvl(stddec(b.amtincom1,p_codempid,global_v_chken),0),b.codcurr,a.jobgrade
        into v_codcomp,v_codpos,v_numlvl,v_typemp,v_codempmt,v_codcalen,
             v_amtincom1,v_codcurr,v_jobgrade
        from temploy1 a, temploy3 b
       where a.codempid = b.codempid
         and a.codempid = p_codempid;
    exception when no_data_found then null;
    end;



    begin
      select condot,condextr,dteeffec into v_condot,v_condextr,v_dteeffec
      from   tcontrot
      where  codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
      and    dteeffec = (select max(dteeffec)
                         from   tcontrot
                         where  codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
                         and    dteeffec <= to_date(to_char(sysdate,'dd/mm/yyyy'),'dd/mm/yyyy'))
      and    rownum <= 1;
    exception when no_data_found then return;
    end;





    -->>user36 19/2/2014

    --<<User37 STA4590329 27/12/2016
    begin
      select max(numseq) into v_seqno
        from   ttotreq
        where	 codempid = p_codempid
        and    dtereq   = ttotreqst_dtereq;
    exception  when others then
      v_seqno := 0;
    end;
    -->>User37 STA4590329 27/12/2016

      begin
        select qtymxotwk,qtymxallwk, nvl(typalert,'N')
          into v_qtymxotwk,v_qtymxallwk,v_typalert
          from tcontrot
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                              and dteeffec <= sysdate);
      exception when others then
        v_qtymxotwk := 0;
        v_qtymxallwk := 0;
        v_typalert  := 'N';
      end;

    << main_loop >>
    loop
      if p_staemp = '0' or
        (p_staemp = '9' and p_dteeffex <= ttotreqst_dtestrt) then
        exit main_loop;
      end if;
      v_namemp := get_temploy_name(p_codempid,global_v_chken);
      std_ot.get_week_ot(p_codempid, '',v_dtewkreq,'',ttotreqst_dtestrt,ttotreqst_dteend,
                         null, null, null,
                         null, null, null,
                         null, null, null,
                         global_v_codempid,
                         a_dtestweek,a_dteenweek,
                         a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);

      for r_tattence in c_tattence loop
        if (p_staemp = '9' and p_dteeffex <= r_tattence.dtework) then
          exit main_loop;
        end if;
        v_dtestrtwk   := std_ot.get_dtestrt_period (r_tattence.codempid, r_tattence.dtework);
        v_dteendwk    := v_dtestrtwk + 6;
        --<<user36 19/2/2014
        if v_condot is null then
          goto cal_loop;
        else
          v_dtewkreq := r_tattence.dtework;

          for r_ttmovemt in c_ttmovemt loop
            v_codcomp   := r_ttmovemt.codcomp;
            v_codpos    := r_ttmovemt.codpos;
            v_numlvl    := r_ttmovemt.numlvl;
            v_typemp    := r_ttmovemt.typemp;
            v_codempmt  := r_ttmovemt.codempmt;
            v_codcalen  := r_ttmovemt.codcalen;
            v_amtincom1 := r_ttmovemt.amtincom1;
            v_jobgrade  := r_ttmovemt.jobgrade;
            exit;
          end loop;

          for r_ttmovemt in c_ttmovemt2 loop
            v_codcomp   := r_ttmovemt.codcompt;
            v_codpos    := r_ttmovemt.codposnow;
            v_numlvl    := r_ttmovemt.numlvlt;
            v_typemp    := r_ttmovemt.typempt;
            v_codempmt  := r_ttmovemt.codempmtt;
            v_codcalen  := r_ttmovemt.codcalet;
            v_amtincom1 := r_ttmovemt.amtincom1;
            v_jobgrade  := r_ttmovemt.jobgradet;
            exit;
          end loop;

          --
          begin
            select value into v_chkreg
            from v$nls_parameters
            where parameter = 'NLS_CALENDAR';
            if v_chkreg = 'Thai Buddha' then
              v_zyear := 543;
            else
              v_zyear := 0;
            end if;
          exception when others then v_zyear := 0;
          end;

          v_ratechge := get_exchange_rate(to_number(to_char(v_dtewkreq,'yyyy')) - v_zyear,to_number(to_char(v_dtewkreq,'mm')),v_codcurr,v_codcurr);--,:global.v_codcurr,v_codcurr);
          v_amtincom1 := v_amtincom1 * v_ratechge;
          --
          v_flgcondot := false;
          if v_condot is not null then
            v_cond := v_condot;
            v_cond := replace(v_cond,'V_HRAL92M1.CODCOMP',''''||v_codcomp||'''');
            v_cond := replace(v_cond,'V_HRAL92M1.CODPOS',''''||v_codpos||'''');
            v_cond := replace(v_cond,'V_HRAL92M1.NUMLVL',v_numlvl);
            v_cond := replace(v_cond,'V_HRAL92M1.JOBGRADE',''''||v_jobgrade||'''');
            v_cond := replace(v_cond,'V_HRAL92M1.TYPEMP',''''||v_typemp||'''');
            v_cond := replace(v_cond,'V_HRAL92M1.CODEMPMT',''''||v_codempmt||'''');
            v_cond := replace(v_cond,'V_HRAL92M1.AMTINCOM1',v_amtincom1);

            v_stmt := 'select count(*) from dual where '||v_cond;
            v_flgcondot := execute_stmt(v_stmt);
          end if;




          if v_flgcondot then
            goto cal_loop;
          else
            begin
              select 'Y' into v_totmeal
              from 	 totmeal
              where  codcompy = hcm_util.get_codcomp_level(v_codcomp,'1')
              and    dteeffec = v_dteeffec
              and		 rownum = 1;
            exception when no_data_found then v_totmeal := 'N';
            end;

            if v_totmeal = 'Y' then
              if v_condextr is null then
                goto cal_loop;
              else
                v_flgcondextr := false;
                v_cond := v_condextr;
                v_cond := replace(v_cond,'V_HRAL92M1.CODCOMP',''''||v_codcomp||'''');
                v_cond := replace(v_cond,'V_HRAL92M1.CODPOS',''''||v_codpos||'''');
                v_cond := replace(v_cond,'V_HRAL92M1.NUMLVL',v_numlvl);
                v_cond := replace(v_cond,'V_HRAL92M1.JOBGRADE',''''||v_jobgrade||'''');
                v_cond := replace(v_cond,'V_HRAL92M1.TYPEMP',''''||v_typemp||'''');
                v_cond := replace(v_cond,'V_HRAL92M1.CODEMPMT',''''||v_codempmt||'''');
                v_cond := replace(v_cond,'V_HRAL92M1.AMTINCOM1',v_amtincom1);

                v_stmt := 'select count(*) from dual where '||v_cond;
                v_flgcondextr := execute_stmt(v_stmt);

                if v_flgcondextr then
                  goto cal_loop;
                else
                  goto next_day;
                end if;
              end if; --v_condextr is null

            else
              goto next_day;
            end if; --v_totmeal = 'Y'
          end if; --v_flgcondot
        end if; --v_condot is null
        -->>user36 19/2/2014


        <<cal_loop>>
        loop
          if ttotreqst_codshift is not null and ttotreqst_codshift <> r_tattence.codshift then
            exit cal_loop;
          end if;
          /*
          if (:totreqst.typwork = 'W' and r_tattence.typwork <> 'W') or
             (:totreqst.typwork = 'H' and r_tattence.typwork <> 'H') or
             (:totreqst.typwork = 'S' and r_tattence.typwork <> 'S') or
             (:totreqst.typwork = 'T' and r_tattence.typwork <> 'T') then
            exit cal_loop;
          end if;*/
          begin
            select timstotb,timenotb,timstota,timenota,timstotd,timenotd
            into   v_timstotb,v_timenotb,v_timstota,v_timenota,v_timstotd,v_timenotd
            from   tshiftcd
            where  codshift = r_tattence.codshift;
          exception when no_data_found then
            v_timstotb := null; v_timenotb := null; v_timenotd := null;
            v_timstota := null; v_timenota := null; v_timenotd := null;
          end;

          -->> user18 ST11 03/08/2021 change std

          v_qtydaywk    := std_ot.get_qtyminwk(r_tattence.codempid, v_dtestrtwk, v_dteendwk);

          v_qtyminot    := std_ot.get_qtyminot(r_tattence.codempid, r_tattence.dtework, r_tattence.dtework,
                                                hcm_util.convert_time_to_minute(ttotreqst_qtyminb), ttotreqst_timbend, ttotreqst_timbstr,
                                                hcm_util.convert_time_to_minute(ttotreqst_qtymind), ttotreqst_timdend, ttotreqst_timdstr,
                                                hcm_util.convert_time_to_minute(ttotreqst_qtymina), ttotreqst_timaend, ttotreqst_timastr);


--          param_msg_error := v_qtyminot || ' ' || r_tattence.codempid || '' || r_tattence.dtework  || get_error_msg_php('HR2508',global_v_lang);
--          return;

          v_qtyminotb   := std_ot.get_qtyminot(r_tattence.codempid, r_tattence.dtework, r_tattence.dtework,
                                                hcm_util.convert_time_to_minute(ttotreqst_qtyminb), ttotreqst_timbend, ttotreqst_timbstr,
                                                null, null, null,
                                                null, null, null);
          v_qtyminotd   := std_ot.get_qtyminot(r_tattence.codempid, r_tattence.dtework, r_tattence.dtework,
                                                null, null, null,
                                                hcm_util.convert_time_to_minute(ttotreqst_qtymind), ttotreqst_timdend, ttotreqst_timdstr,
                                                null, null, null);
          v_qtyminota   := std_ot.get_qtyminot(r_tattence.codempid, r_tattence.dtework, r_tattence.dtework,
                                                null, null, null,
                                                null, null, null,
                                                hcm_util.convert_time_to_minute(ttotreqst_qtymina), ttotreqst_timaend, ttotreqst_timastr);
          --<< user18 ST11 03/08/2021 change std

          -- Before Work
          if ttotreqst_qtyminb is not null or ttotreqst_timbstr is not null or ttotreqst_timbend is not null then-- user22 : 29/06/2016 : STA4590280 || if :totreqst.typotreq = 'B' then
            -->> user18 ST11 03/08/2021 change std
              v_report_numseq := v_report_numseq + 1;
              global_ttotreq_data.put('staovrot',v_staovrot);
              insert into ttemprpt (codempid,codapp,numseq,
                                    item1,item2,item3,item4,item5,
                                    item6,item7,item8,item9,item10,
                                    item11,item12,item13,item14,item15,
                                    item16,item17,item18,item19,item20,
                                    item21,item22,item23,item24,
                                    item25,item26,item27,item28)
              values(global_v_codempid,'HRMS6KE3',v_report_numseq,
                                    to_char(r_tattence.dtework,'dd/mm/yyyy'),r_tattence.codempid,
                                    '',get_temploy_name(r_tattence.codempid,global_v_lang),
                                    'B',r_tattence.codshift,nvl(to_char(to_date(ttotreqst_timbstr,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timstota,'hh24:mi'),'hh24:mi')),nvl(to_char(to_date(ttotreqst_timbend,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timenota,'hh24:mi'),'hh24:mi')),
                                    'P',get_tlistval_name('ESSTAREQ','P',global_v_lang),
                                    ttotreqst_flgchglv,ttotreqst_flgchglv,ttotreqst_codcompw,ttotreqst_qtyminb,
                                    nvl(to_char(to_date(ttotreqst_timbstr,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timstota,'hh24:mi'),'hh24:mi')),
                                    nvl(to_char(to_date(ttotreqst_timbend,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timenota,'hh24:mi'),'hh24:mi')),
                                    ttotreqst_costcent,
                                    hcm_util.convert_minute_to_hour(v_qtydaywk + v_qtyminotOth + v_qtyminot), --item18
                                    to_char(v_dtestrtwk,'dd/mm/yyyy'),to_char(v_dteendwk,'dd/mm/yyyy'), --item19,item20
                                    hcm_util.convert_minute_to_hour(v_qtydaywk),hcm_util.convert_minute_to_hour(v_qtyminotOth + (v_qtyminot - v_qtyminotb)), --item21,item22
                                    hcm_util.convert_minute_to_hour(v_qtyminotb),hcm_util.convert_minute_to_hour(v_qtyminotOth + v_qtyminot), --item23,item24
                                    1,0,0,v_staovrot);

              if not std_ot.chk_duptemp(r_tattence.codempid, r_tattence.dtework, 'B', global_v_codempid) then
                -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                -- v_numseq_tmp := std_ot.get_max_numseq(global_v_codempid); -- bk
                v_numseq_tmp := std_ot.get_max_numseq(global_v_codempid,r_tattence.codempid); -- add
                -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                insert into ttemprpt (codempid,codapp,numseq,
                                      item1,item2,item3,item4,item5,
                                      item6,item7,item8,item10,temp31)
                -- values(global_v_codempid, 'CALOT36',v_numseq_tmp, -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (bk)              
                values(global_v_codempid, 'CALOT36'||r_tattence.codempid,v_numseq_tmp, -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (add)
                       r_tattence.codempid, to_char(r_tattence.dtework,'dd/mm/yyyy'), 'B', '',
                       to_char(r_tattence.dtework,'dd/mm/yyyy'), ttotreqst_timbstr,
                       to_char(r_tattence.dtework,'dd/mm/yyyy'), ttotreqst_timbend,
                       '5', v_qtyminotb);
              else
                update ttemprpt
                   set temp31 = v_qtyminotb,
                       item10 = '5'
                 where codempid = global_v_codempid
                   -- and codapp = 'CALOT36' -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (add)
                   and codapp = 'CALOT36'||r_tattence.codempid
                   and item1 = r_tattence.codempid
                   and to_date(item2,'dd/mm/yyyy') = r_tattence.dtework
                   and item3 = 'B';
              end if;
              --<< user18 ST11 03/08/2021 change std
          end if;
          -- During Work
          if ttotreqst_qtymind is not null or ttotreqst_timdstr is not null or ttotreqst_timdend is not null then-- user22 : 29/06/2016 : STA4590280 || if :totreqst.typotreq = 'D' then
            if /*nut (:totreqst.typwork in ('A','H','T','S') and*/ r_tattence.typwork in ('H','T','S') then
                -->> user18 ST11 03/08/2021 change std
                v_report_numseq := v_report_numseq + 1;
                insert into ttemprpt (codempid,codapp,numseq,
                                    item1,item2,item3,item4,item5,
                                    item6,item7,item8,item9,item10,
                                    item11,item12,item13,item14,item15,
                                    item16,item17,item18,item19,item20,
                                    item21,item22,item23,item24,
                                    item25,item26,item27,item28)
                values(global_v_codempid,'HRMS6KE3',v_report_numseq,
                                    to_char(r_tattence.dtework,'dd/mm/yyyy'),r_tattence.codempid,
                                    '',get_temploy_name(r_tattence.codempid,global_v_lang),
                                    'D',r_tattence.codshift,
                                    nvl(to_char(to_date(ttotreqst_timdstr,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timstota,'hh24:mi'),'hh24:mi')),
                                    nvl(to_char(to_date(ttotreqst_timdend,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timenota,'hh24:mi'),'hh24:mi')),
                                    'P',get_tlistval_name('ESSTAREQ','P',global_v_lang),
                                    ttotreqst_flgchglv,ttotreqst_flgchglv,ttotreqst_codcompw,ttotreqst_qtymind,
                                    nvl(to_char(to_date(ttotreqst_timdstr,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timstota,'hh24:mi'),'hh24:mi')),
                                    nvl(to_char(to_date(ttotreqst_timdend,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timenota,'hh24:mi'),'hh24:mi')),
                                    ttotreqst_costcent,
                                    hcm_util.convert_minute_to_hour(v_qtydaywk + v_qtyminotOth + v_qtyminot), --item18
                                    to_char(v_dtestrtwk,'dd/mm/yyyy'),to_char(v_dteendwk,'dd/mm/yyyy'), --item19,item20
                                    hcm_util.convert_minute_to_hour(v_qtydaywk),
                                    hcm_util.convert_minute_to_hour(v_qtyminotOth + (v_qtyminot - v_qtyminotd)), --item21,item22
                                    hcm_util.convert_minute_to_hour(v_qtyminotd),
                                    hcm_util.convert_minute_to_hour(v_qtyminotOth + v_qtyminot), --item23,item24
                                    1,0,0,v_staovrot);

                if not std_ot.chk_duptemp(r_tattence.codempid, r_tattence.dtework, 'D', global_v_codempid) then
                    -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                    -- vv_numseq_tmp := std_ot.get_max_numseq(global_v_codempid); -- bk
                    v_numseq_tmp := std_ot.get_max_numseq(global_v_codempid,r_tattence.codempid); -- add
                    -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                    insert into ttemprpt (codempid,codapp,numseq,
                                          item1,item2,item3,item4,item5,
                                          item6,item7,item8,item10,temp31)
                    -- values(global_v_codempid, 'CALOT36',v_numseq_tmp, -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (bk)
                    values(global_v_codempid, 'CALOT36'||r_tattence.codempid,v_numseq_tmp, -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (add)
                           r_tattence.codempid, to_char(r_tattence.dtework,'dd/mm/yyyy'), 'D', '',
                           to_char(r_tattence.dtework,'dd/mm/yyyy'), ttotreqst_timdstr,
                           to_char(r_tattence.dtework,'dd/mm/yyyy'), ttotreqst_timdend,
                           '5', v_qtyminotd);
                else
                    update ttemprpt
                       set temp31 = v_qtyminotd,
                           item10 = '5'
                     where codempid = global_v_codempid
                       -- and codapp = 'CALOT36' -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (bk)
                       and codapp = 'CALOT36'||r_tattence.codempid -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (add)
                       and item1 = r_tattence.codempid
                       and to_date(item2,'dd/mm/yyyy') = r_tattence.dtework
                       and item3 = 'D';
                end if;
                --<< user18 ST11 03/08/2021 change std
            end if;
          end if;
          -- After Work
          if ttotreqst_qtymina is not null or ttotreqst_timastr is not null or ttotreqst_timaend is not null then-- user22 : 29/06/2016 : STA4590280 || if :totreqst.typotreq = 'A' then
            -->> user18 ST11 03/08/2021 change std
              v_report_numseq := v_report_numseq + 1;
              insert into ttemprpt (codempid,codapp,numseq,
                                    item1,item2,item3,item4,item5,
                                    item6,item7,item8,item9,item10,
                                    item11,item12,item13,item14,item15,
                                    item16,item17,item18,item19,item20,
                                    item21,item22,item23,item24,
                                    item25,item26,item27,item28)
              values(global_v_codempid,'HRMS6KE3',v_report_numseq,
                                    to_char(r_tattence.dtework,'dd/mm/yyyy'),r_tattence.codempid,
                                    '',get_temploy_name(r_tattence.codempid,global_v_lang),
                                    'A',r_tattence.codshift,
                                    nvl(to_char(to_date(ttotreqst_timastr,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timstota,'hh24:mi'),'hh24:mi')),
                                    nvl(to_char(to_date(ttotreqst_timaend,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timenota,'hh24:mi'),'hh24:mi')),
                                    'P',get_tlistval_name('ESSTAREQ','P',global_v_lang),
                                    ttotreqst_flgchglv,ttotreqst_flgchglv,ttotreqst_codcompw,ttotreqst_qtymina,
                                    nvl(to_char(to_date(ttotreqst_timastr,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timstota,'hh24:mi'),'hh24:mi')),
                                    nvl(to_char(to_date(ttotreqst_timaend,'hh24:mi'),'hh24:mi'),to_char(to_date(v_timenota,'hh24:mi'),'hh24:mi')),
                                    ttotreqst_costcent,
                                    hcm_util.convert_minute_to_hour(v_qtydaywk + v_qtyminotOth + v_qtyminot), --item18
                                    to_char(v_dtestrtwk,'dd/mm/yyyy'),to_char(v_dteendwk,'dd/mm/yyyy'), --item19,item20
                                    hcm_util.convert_minute_to_hour(v_qtydaywk),
                                    hcm_util.convert_minute_to_hour(v_qtyminotOth + (v_qtyminot - v_qtyminota)), --item21,item22
                                    hcm_util.convert_minute_to_hour(v_qtyminota),
                                    hcm_util.convert_minute_to_hour(v_qtyminotOth + v_qtyminot), --item23,item24
                                    1,0,0,v_staovrot);

              if not std_ot.chk_duptemp(r_tattence.codempid, r_tattence.dtework, 'A', global_v_codempid) then
                -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                -- v_numseq_tmp := std_ot.get_max_numseq(global_v_codempid); -- bk
                v_numseq_tmp := std_ot.get_max_numseq(global_v_codempid,r_tattence.codempid); -- add
                -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
                insert into ttemprpt (codempid,codapp,numseq,
                                      item1,item2,item3,item4,item5,
                                      item6,item7,item8,item10,temp31)
                -- values(global_v_codempid, 'CALOT36',v_numseq_tmp, -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (bk)
                values(global_v_codempid, 'CALOT36'||r_tattence.codempid,v_numseq_tmp, -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (add)
                       r_tattence.codempid, to_char(r_tattence.dtework,'dd/mm/yyyy'), 'A', '',
                       to_char(r_tattence.dtework,'dd/mm/yyyy'), ttotreqst_timastr,
                       to_char(r_tattence.dtework,'dd/mm/yyyy'), ttotreqst_timaend,
                       '5', v_qtyminota);
              else
                update ttemprpt
                   set temp31 = v_qtyminota,
                       item10 = '5'
                 where codempid = global_v_codempid
                  -- and codapp = 'CALOT36' -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (bk)
                   and codapp = 'CALOT36'||r_tattence.codempid -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (add)
                   and item1 = r_tattence.codempid
                   and to_date(item2,'dd/mm/yyyy') = r_tattence.dtework
                   and item3 = 'A';
              end if;
              --<< user18 ST11 03/08/2021 change std
          end if;
          exit cal_loop;
        end loop;

        <<next_day>>
        null;
      end loop; -- for r_tattence
      exit main_loop;
    end loop;

    if v_typalert <> 'N' then
        for r_temp in c_temp loop
            v_codempid_tmp              := r_temp.codempid;
            v_dtestrtwk                 := r_temp.dtestrtwk;
            v_dteendwk                  := r_temp.dteendwk;
            v_qtydaywk                  := std_ot.get_qtyminwk(v_codempid_tmp, v_dtestrtwk, v_dteendwk);
            v_qtyminotOth_cumulative    := std_ot.get_qtyminotOth_notTmp (v_codempid_tmp ,v_dtestrtwk, v_dteendwk, 'HRMS6KE3', global_v_codempid);

            for r2 in c_temp2 loop
              v_qtyot_total     := v_qtyminotOth_cumulative + hcm_util.convert_time_to_minute(r2.item23);
              v_qtytotal        := v_qtydaywk + v_qtyot_total;
              if (v_qtyot_total > v_qtymxotwk or v_qtytotal > v_qtymxallwk) then
                  if v_typalert = '1' then
                    v_staovrot   := 'Y';
                  elsif v_typalert = '2' then
                    delete ttemprpt
                     where codempid = r2.codempid
                       and codapp = r2.codapp
                       and numseq = r2.numseq;
                  end if;
              else
                  v_staovrot   := 'N';
              end if;
              v_qtyminotOth_cumulative := v_qtyot_total;
            end loop;

            v_qtyminotOth_cumulative    := std_ot.get_qtyminotOth_notTmp (v_codempid_tmp ,v_dtestrtwk, v_dteendwk, 'HRMS6KE3', global_v_codempid);
            for r2 in c_temp2 loop
              v_qtyminotOth := std_ot.get_qtyminotOth_notTmp (r2.item2 ,v_dtestrtwk, v_dteendwk, 'HRMS6KE3', global_v_codempid);
              begin
              SELECT sum(hcm_util.convert_time_to_minute(item23))
                into v_tmp_qtyot_req
                FROM ttemprpt
               WHERE codempid = r2.codempid
                 AND codapp = r2.codapp
                 and item2 = r2.item2
                 and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
                 and numseq <> r2.numseq;
              end;

              v_qtyminotOth     := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
              v_ttemprpt.item22 := hcm_util.convert_minute_to_hour(v_qtyminotOth);
              v_ttemprpt.item24 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r2.item23) + v_qtyminotOth);
              v_ttemprpt.item18 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r2.item21) + hcm_util.convert_time_to_minute(r2.item23) + v_qtyminotOth);
              v_qtyot_total     := v_qtyminotOth_cumulative + hcm_util.convert_time_to_minute(r2.item23);
              v_qtytotal        := v_qtydaywk + v_qtyot_total;
              if (v_qtyot_total > v_qtymxotwk or v_qtytotal > v_qtymxallwk) then
                  if v_typalert = '1' then
                    v_staovrot   := 'Y';
                  elsif v_typalert = '2' then
                    delete ttemprpt
                     where codempid = r2.codempid
                       and codapp = r2.codapp
                       and numseq = r2.numseq;
                  end if;
              else
                  v_staovrot   := 'N';
              end if;
              v_qtyminotOth_cumulative := v_qtyot_total;

              update ttemprpt
                 set item22 = v_ttemprpt.item22,
                     item24 = v_ttemprpt.item24,
                     item18 = v_ttemprpt.item18,
                     item28 = v_staovrot
               where codempid = r2.codempid
                 and codapp = r2.codapp
                 and numseq = r2.numseq;
            end loop;
        end loop;
    end if;

    global_ttotreq_count := 0;
    for r1 in c1 loop
        global_ttotreq_count    := global_ttotreq_count+1;
        global_ttotreq_data     := json_object_t();
        global_ttotreq_data.put('coderror', '200');
        global_ttotreq_data.put('seqno',r1.numseq); --dtestrt
        global_ttotreq_data.put('dtestrt',r1.item1); --dtestrt
        global_ttotreq_data.put('dtestrtOld',r1.item1); --dtestrt
        global_ttotreq_data.put('codempid',r1.item2); -- codempid
        global_ttotreq_data.put('codempidOld',r1.item2); -- codempid
        global_ttotreq_data.put('numseq',r1.item3); -- numseq
        global_ttotreq_data.put('desc_codempid',r1.item4); --desc_codempid
        global_ttotreq_data.put('typot',r1.item5); --typot
        global_ttotreq_data.put('codshift',r1.item6); --codshift
        global_ttotreq_data.put('v_timstrt',r1.item7); --v_timstrt
        global_ttotreq_data.put('v_timend',r1.item8); --v_timend
        global_ttotreq_data.put('staappr',r1.item9); --staappr
        global_ttotreq_data.put('v_staappr',r1.item10); --v_staappr
        global_ttotreq_data.put('flgchglv_',r1.item11); --flgchglv_
        global_ttotreq_data.put('flgchglv',r1.item12); --flgchglv
        global_ttotreq_data.put('codcompw',r1.item13); --codcompw
        global_ttotreq_data.put('qtyminr',r1.item14); --qtyminr
        global_ttotreq_data.put('timstrt',r1.item15); --timstrt
        global_ttotreq_data.put('timend',r1.item16); --timend
        global_ttotreq_data.put('costcent',r1.item17); --costcent
        global_ttotreq_data.put('qtytotal',r1.item18); --qtytotal
        global_ttotreq_data.put('dtestrtwk',r1.item19);--dtestrtwk
        global_ttotreq_data.put('dteendwk',r1.item20);--,dteendwk
        global_ttotreq_data.put('qtydaywk',r1.item21); --qtydaywk
        global_ttotreq_data.put('qtyot_reqoth',r1.item22); --qtyot_reqoth
        global_ttotreq_data.put('qtyot_req',r1.item23); --qtyot_req
        global_ttotreq_data.put('qtyot_total',r1.item24); --qtyot_total
        if r1.item25 = 1 then
            global_ttotreq_data.put('flgAdd',true);
        else
            global_ttotreq_data.put('flgAdd',false);
        end if;
        if r1.item26 = 1 then
            global_ttotreq_data.put('flgEdit',true);
        else
            global_ttotreq_data.put('flgEdit',false);
        end if;
        if r1.item27 = 1 then
            global_ttotreq_data.put('flgDelete',true);
        else
            global_ttotreq_data.put('flgDelete',false);
        end if;
        global_ttotreq_data.put('staovrot',r1.item28);
        global_ttotreq_data.put('typalert',v_typalert);
        global_ttotreq_data.put('listofapp','<i class="fa fa-info-circle " data-toggle="modal" href="#hrms6ke-list-of-app"></i>'); --< bow.sarunya | fix issue4449#1766
        global_ttotreq_row.put(to_char(global_ttotreq_count-1),global_ttotreq_data);

    end loop;
  END;

  procedure get_tab2_process(json_str_input in clob, json_str_output out clob) is
    obj_row       json_object_t;
    flg_secur     boolean;
    v_zupdsal     varchar2(15 char);

    cursor c1 is
      select	codempid,codcomp,codpos,
              staemp,dteeffex--User37 STA4590329 26/12/2016
      from		temploy1 a
      where		codcomp		like	ttotreqst_codcomp||'%'
      and			(codcalen	=	ttotreqst_codcalen or ttotreqst_codcalen is null)
      and     staemp in ('1','3')
      and     exists (select codempid from tattence b
                      where a.codempid = b.codempid
                      and   dtework between ttotreqst_dtestrt  and ttotreqst_dteend )

      order by codempid;

    cursor c2 is
      select codempid,codcomp,codpos,
             staemp,dteeffex--User37 STA4590329 26/12/2016
      from temploy1
      where codcomp		like	ttotreqst_codcomp||'%'
      and	(codcalen	=	ttotreqst_codcalen or ttotreqst_codcalen is null)
      and staemp in ('1','3')
      and codempid in (select codempid from tattence
                        where	codcomp		like	ttotreqst_codcomp||'%'
                        and dtework between ttotreqst_dtestrt  and ttotreqst_dteend
                        and codshift = ttotreqst_codshift
                        group by codempid)
      order by codempid;

    --<<User37 STA4590329 26/12/2016
    v_codempid		temploy1.codempid%type;
    cursor c_tattence is
      select codempid,dtework,typwork,codshift
      from   tattence
      where  codempid = v_codempid		and    dtework  between ttotreqst_dtestrt  and ttotreqst_dteend
      order by dtework;
    -->>User37 STA4590329 26/12/2016

    --<<user4 || 15/08/2018 || for add codempid only [requirement from NEO]
    cursor c_temploy1 is
      select codempid,codcomp,codpos,
              staemp,dteeffex
      from		temploy1 a
      where		codempid = ttotreqst_codempid
      and     staemp in ('1','3')
      and     exists (select codempid from tattence b
                      where a.codempid = b.codempid
                      and   dtework between ttotreqst_dtestrt  and ttotreqst_dteend );
    -->>user4 || 15/08/2018 || for add codempid only [requirement from NEO]

  begin
    obj_row     := json_object_t();
    initial_value(json_str_input);
    check_index_save;


    -->> user18 ST11 03/08/2021 change std
    if p_flgclear = 1 then
        begin
            delete ttemprpt
             where codempid = global_v_codempid
               and codapp = 'HRMS6KE3';
        exception when others then
            null;
        end;
        v_report_numseq := 0;
        commit;
    else
      begin
          select max(numseq)
            into v_report_numseq
            from ttemprpt
           where codempid = global_v_codempid
             and codapp = 'HRMS6KE3';
      exception when others then
        v_report_numseq := 0;
      end;
      v_report_numseq := nvl(v_report_numseq,0);
    end if;
    --<< user18 ST11 03/08/2021 change std


    if param_msg_error is null then
      if ttotreqst_codempid is not null then -- user4 || 15/08/2018 || for add codempid only [requirement from NEO]
        for i in c_temploy1 loop
          flg_secur := secur_main.secur2(i.codempid, global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
          if flg_secur then
            gen_ttotreq(i.codempid,i.staemp,i.dteeffex);
          end if;
        end loop;
      else
        if ttotreqst_codshift is null then
          for i in c1 loop
            flg_secur := secur_main.secur2(i.codempid, global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

            if flg_secur then
              --<<User37 STA4590329 26/12/2016
--              :ttotreq.codempid	:=	i.codempid;
--              :ttotreq.empname	:=	get_temploy_name(i.codempid,:global.v_lang);
--              :ttotreq.compname	:=	get_tcenter_name(i.codcomp,:global.v_lang);
--              :ttotreq.posname	:=	get_tpostn_name(i.codpos,:global.v_lang);
--              :ttotreq.staappr	:=	'P';
--              :ttotreq.v_staappr:=	get_tlistval_name('ESSTAREQ',:ttotreq.staappr,:global.v_lang);
              gen_ttotreq(i.codempid,i.staemp,i.dteeffex);
              -->>User37 STA4590329 26/12/2016
            end if;
            --User37 STA4590329 26/12/2016 next_record;
          end loop;
        else
          for i in c2 loop
            flg_secur := secur_main.secur2(i.codempid, global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);

            if flg_secur then
              --<<User37 STA4590329 26/12/2016
--              :ttotreq.codempid	:=	i.codempid;
--              :ttotreq.empname	:=	get_temploy_name(i.codempid,:global.v_lang);
--              :ttotreq.compname	:=	get_tcenter_name(i.codcomp,:global.v_lang);
--              :ttotreq.posname	:=	get_tpostn_name(i.codpos,:global.v_lang);
--              :ttotreq.staappr	:=	'P';
--              :ttotreq.v_staappr:=	get_tlistval_name('ESSTAREQ',:ttotreq.staappr,:global.v_lang);
              gen_ttotreq(i.codempid,i.staemp,i.dteeffex);
              -->>User37 STA4590329 26/12/2016
            end if;
            --User37 STA4590329 26/12/2016 next_record;
          end loop;
        end if;	--if ttotreqst_codshift is null then
      end if; -- user4 || 15/08/2018 || for add codempid only [requirement from NEO]
-- user3 20190711
--      if global_ttotreq_row.get_size > 0 then
--        json_ext.put(global_ttotreq_row, '0.total', global_ttotreq_count);
--      end if;
--      if global_ttotreq_row.get_size > 0 then
--        global_ttotreq_row.put('0.total', global_ttotreq_count);
--      end if;

      if param_msg_error is not null then
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
      end if;
      -- get row json
      obj_row.put('coderror', '200');
      obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
      obj_row.put('details', global_ttotreq_row.to_clob);

      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if; --if param_msg_error is null then
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure get_tab2_add_inline(json_str_input in clob, json_str_output out clob) is
    obj_row json_object_t;
    cursor c1 is
      select codempid,codshift
        from tattence
       where codempid = b_index_codempid
         and dtework  = v_dtework;
  begin
    obj_row := json_object_t();
    initial_value(json_str_input);
    obj_row.put('coderror', '200');
    obj_row.put('desc_coderror', ' ');
    obj_row.put('httpcode', '');
    obj_row.put('flg', '');
    obj_row.put('codshift','');
    obj_row.put('codempid',b_index_codempid);
    obj_row.put('desc_codempid',get_temploy_name(b_index_codempid,global_v_lang));
    obj_row.put('staappr','P');
    obj_row.put('v_staappr',get_tlistval_name('ESSTAREQ','P',global_v_lang));
    for r1 in c1 loop
      obj_row.put('codshift',r1.codshift);
    end loop;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure save_detail(json_str_input in clob, json_str_output out clob) is
    param_tab2        clob;
    global_json_str   clob;
    json_param_obj    json_object_t;
    obj_row           json_object_t;
    qtybudget           number;
    qtyothot            number;
    percentused         number;
    codcompbg           number;
    v_error_code        varchar2(100 char) := '400';
    v_codcompy          temploy1.codcomp%type;
    v_loop              number;
    v_count             number;

  begin
    v_msgerror  := null;
    initial_value(json_str_input);
    check_index_save;
    json_param_obj      := json_object_t(json_str_input).get_object('param_tab2');
    ot_budget_check(json_param_obj.to_clob, qtybudget, qtyothot, percentused, codcompbg);
--    param_msg_error := p_flgconfirm || get_error_msg_php('HR2508',global_v_lang);
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--    return;
    if percentused > 100 and nvl(p_flgconfirm,'N') = 'N' then
       v_msgerror      := replace(get_error_msg_php('MSZ002',global_v_lang),'@#$%400');
    end if;
    if param_msg_error is null and v_msgerror is null then
      -- gen_docno ---
      if ttotreqst_numotgen is null then
        -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 16/04/2024 | 4449#1887 (add)
            -- v_numotgen 	:= std_al.gen_req ('TTOT','TTOTREQST','NUMOTGEN',global_v_zyear,global_v_coduser) ;
            -- ttotreqst_numotgen := replace(v_numotgen,'-',null) ;
            -- std_al.upd_req('TTOT',v_numotgen,global_v_coduser,global_v_zyear,'');
        -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 16/04/2024 | 4449#1887 (add)

         -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 16/04/2024 | 4449#1887 (add)
        if ttotreqst_codcomp is null then
            begin
                select get_codcompy(codcomp)
                into v_codcompy
                from temploy1
                where codempid = ttotreqst_codempid;
            exception when no_data_found then 
                v_codcompy := null;
            end;
        else
            v_codcompy := hcm_util.get_codcompy(ttotreqst_codcomp);
        end if;

        v_loop := 0;
        loop
            v_loop := v_loop + 1;

            v_numotgen 	:= std_al.gen_req ('TTOT','TTOTREQST','NUMOTGEN',global_v_zyear,v_codcompy,'') ;
            ttotreqst_numotgen := replace(v_numotgen,'-',null) ;
            std_al.upd_req('TTOT',v_numotgen,global_v_coduser,global_v_zyear,v_codcompy,'');

            begin
                select count(*)
                into v_count
                from ttotreqst
                where numotgen = v_numotgen;
            exception when no_data_found then
                null;
            end;

            exit when (v_count = 0 or v_loop = 100);
        end loop;
        -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 16/04/2024 | 4449#1887 (add)
      end if;
      insert_next_step(json_param_obj.to_clob, json_str_output);
      if param_msg_error is null and v_msgerror is null then
        save_ttotreqst;
        if param_msg_error is null then
          commit;
          v_error_code := '201';
          param_msg_error := get_error_msg_php('HR2401',global_v_lang);
        else
          rollback;
        end if;
      else
        rollback;
      end if;
    end if;

    obj_row := json_object_t();
    obj_row.put('numotreq', ttotreqst_numotgen);
    if v_msgerror is not null then
        obj_row.put('coderror', '201');
        obj_row.put('response', v_msgerror);
        obj_row.put('flg', 'warning');
    else
        obj_row.put('coderror', v_error_code);
        obj_row.put('response', replace(param_msg_error,'@#$%'||v_error_code,''));
    end if;

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    rollback;
  end;

  procedure delete_index(json_str_input in clob, json_str_output out clob) is
    v_chk	        number;
    json_obj      json_object_t;
    json_obj2     json_object_t;
    v_flgrecord   varchar2(100 char);
  begin
    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input).get_object('param_index');
    for i in 0..json_obj.get_size-1 loop
      json_obj2         := hcm_util.get_json_t(json_obj,to_char(i));
      b_index_numotgen  := hcm_util.get_string_t(json_obj2,'numotgen');
      v_flgrecord       := hcm_util.get_string_t(json_obj2,'flg');

      if v_flgrecord = 'delete' then
        begin
          select count(*) into v_chk
          from	 ttotreq
          where	 numotgen = b_index_numotgen
          and		 staappr not in ('P','C');
        exception when no_data_found then
          v_chk	:=	0;
        end;
        if v_chk = 0 then
          if param_msg_error is null then
            delete ttotreq where numotgen = b_index_numotgen;
            delete ttotreqst where numotgen = b_index_numotgen;
          end if;
        else
          param_msg_error := get_error_msg_php('HR8011',global_v_lang);
          rollback;
          json_str_output := get_response_message(null,param_msg_error,global_v_lang);
          return;
        end if;
      end if;
    end loop;
    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    commit;
    --
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  end;

  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    global_ttotreq_count := 0;
    global_ttotreq_row   := json_object_t();
    global_ttotreq_data  := json_object_t();

    json_obj            := json_object_t(json_str);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    global_v_empid      := hcm_util.get_string_t(json_obj,'codinput');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    --block b_index
    b_index_numotgen    := hcm_util.get_string_t(json_obj,'p_numotgen');
    b_index_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    b_index_dtereq      := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereq')),'dd/mm/yyyy');
    b_index_numseq      := to_number(hcm_util.get_string_t(json_obj,'p_numseq'));
    b_index_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    b_index_dtestrt     := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_st'),'dd/mm/yyyy');
    b_index_dteend      := to_date(hcm_util.get_string_t(json_obj,'p_dtereq_en'),'dd/mm/yyyy');

    --block ttotreqst
    ttotreqst_numotgen    := hcm_util.get_string_t(json_obj,'p_numotgen');
    ttotreqst_dtereq      := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtereq')),'dd/mm/yyyy');
    ttotreqst_codempid    := hcm_util.get_string_t(json_obj,'p_codempid_query');
    ttotreqst_codcomp     := hcm_util.get_string_t(json_obj,'p_codcomp');
    ttotreqst_codcalen    := hcm_util.get_string_t(json_obj,'p_codcalen');
    ttotreqst_codshift    := hcm_util.get_string_t(json_obj,'p_codshift');
    ttotreqst_dtestrt     := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtestrt')),'dd/mm/yyyy');
    ttotreqst_dteend      := to_date(trim(hcm_util.get_string_t(json_obj,'p_dteend')),'dd/mm/yyyy');
    ttotreqst_timbstr     := replace(trim(hcm_util.get_string_t(json_obj,'p_timbstr')),':','');
    ttotreqst_timbend     := replace(trim(hcm_util.get_string_t(json_obj,'p_timbend')),':','');
    ttotreqst_timdstr     := replace(trim(hcm_util.get_string_t(json_obj,'p_timdstr')),':','');
    ttotreqst_timdend     := replace(trim(hcm_util.get_string_t(json_obj,'p_timdend')),':','');
    ttotreqst_timastr     := replace(trim(hcm_util.get_string_t(json_obj,'p_timastr')),':','');
    ttotreqst_timaend     := replace(trim(hcm_util.get_string_t(json_obj,'p_timaend')),':','');
    ttotreqst_codrem      := hcm_util.get_string_t(json_obj,'p_codrem');
    ttotreqst_remark      := hcm_util.get_string_t(json_obj,'p_remark');
    ttotreqst_codinput    := hcm_util.get_string_t(json_obj,'p_codinput');
    -- new requirement user03 02/08/2019--
    ttotreqst_codcompw      := hcm_util.get_string_t(json_obj,'p_codcompw');
    ttotreqst_flgchglv      := hcm_util.get_string_t(json_obj,'p_flgchglv');
    ttotreqst_qtyminb       := hcm_util.get_string_t(json_obj,'p_qtyminb');
    ttotreqst_qtymind       := hcm_util.get_string_t(json_obj,'p_qtymind');
    ttotreqst_qtymina       := hcm_util.get_string_t(json_obj,'p_qtymina');
    ttotreqst_costcent      := hcm_util.get_string_t(json_obj,'p_costcent');
    ttotreqst_costcent      := hcm_util.get_string_t(json_obj,'p_costcent');


    ttotreqst_codcompbg            := hcm_util.get_string_t(json_obj,'p_codcompbg');   -- รหัส งบประมาณของหน่วยงาน
    ttotreqst_departmentbudget     := hcm_util.get_string_t(json_obj,'p_departmentbudget');   -- งบประมาณของหน่วยงาน
    ttotreqst_wkbudgetdate         := hcm_util.get_string_t(json_obj,'p_wkbudgetdate');   -- งบประมาณประจำสัปดาห์ วันที่
    ttotreqst_wkbudget             := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_wkbudget')); -- งบประมาณประจำสัปดาห์ 
    ttotreqst_requesthr            := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_requesthr')); -- จำนวนชั่วโมงล่วงเวลาในใบคำขอนี้
    ttotreqst_otherrequesthr       := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_otherrequesthr')); -- จำนวนชั่วโมงล่วงเวลาในใบคำขออื่น
    ttotreqst_totalhr              := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_totalhr')); -- รวมจำนวนชั่วโมงล่วงเวลา
    ttotreqst_remainhr             := hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_remainhr')); -- จำนวนชั่วโมงของงบประมาณคงเหลือ (ถ้าติดลบให้แสดง 0)
    ttotreqst_percentused          := to_number(hcm_util.convert_hour_to_minute(hcm_util.get_string_t(json_obj,'p_percentused'))); -- % ใช้ไป

    ttotreqst_numseq        := hcm_util.get_string_t(json_obj,'p_numseq');
    p_flgclear              := hcm_util.get_string_t(json_obj,'p_flgclear'); -- user18 ST11 03/08/2021 change std
    p_error_numseq          := nvl(hcm_util.get_string_t(json_obj,'p_error_numseq'),-1); -- user18 ST11 05/08/2021 change std
    p_flgconfirm            := hcm_util.get_string_t(json_obj,'p_flgconfirm');
--    p_error_numseq          := 4; -- debug
    --tab2 inline
    v_dtework             := to_date(trim(hcm_util.get_string_t(json_obj,'p_dtework')),'dd/mm/yyyy');
    if substr(to_char(sysdate,'yyyy'),1,2) = '25' then
      global_v_zyear    := 543;
    else
      global_v_zyear    := 0;
    end if;
    -- mo surachai 09/12/2023
    p_staappr   := hcm_util.get_string_t(json_obj,'p_staappr');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index_save is
    v_codempid      temploy1.codempid%type;
    v_codrem        tcodotrq.codcodec%type;
    v_codwork  	    tcodwork.codcodec%type;
    v_numlvl        temploy1.numlvl%type;
    v_staemp        temploy1.staemp%type;
    v_dteeffex      temploy1.dteeffex%type;

    v_codcomp	    temploy1.codcomp%type;
    v_qtyday        number(2);
    v_flgsecu       boolean;
    v_set_qtybudget number;
    para_codcompbg  varchar2(100);

  begin
    /*if ttotreqst_dtereq is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if ttotreqst_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if ttotreqst_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if ttotreqst_dtestrt > ttotreqst_dteend then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if ttotreqst_timbend is null and ttotreqst_timbstr is null and
      ttotreqst_timdend is null and ttotreqst_timdstr is null and
      ttotreqst_timaend is null and ttotreqst_timastr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if ttotreqst_timbend is not null and ttotreqst_timbstr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if ttotreqst_timastr is not null and ttotreqst_timaend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if ttotreqst_codrem is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang);
       return;
    end if;	*/
    if ttotreqst_codrem is not null then
      begin
        select codcodec	into v_codrem
        from   tcodotrq
        where  codcodec = ttotreqst_codrem;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
      end;
    end if;
    if ttotreqst_codcalen is not null then
      begin
        select codcodec	into v_codwork
        from   tcodwork
        where  codcodec = ttotreqst_codcalen;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodwork');
        return;
      end;
    end if;
    /*if ttotreqst_remark is null then
       param_msg_error := get_error_msg_php('HR2045',global_v_lang);
       return;
    end if;*/

    --<<user4 || 15/08/2018 || for add codempid only [requirement from NEO]
    if ttotreqst_codempid is not null then
      begin
        select codempid into v_codempid
        from temploy1
        where codempid = ttotreqst_codempid;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'temploy1');
        return;
      end;
    end if;

        -->>user4 || 15/08/2018 || for add codempid only [requirement from NEO]

    if ttotreqst_codcompw is not null then
         begin
                select codcomp, qtybudget into para_codcompbg, v_set_qtybudget
                from TBUDGETOT
                where dteyear = to_number(to_char(ttotreqst_dtestrt, 'yyyy'))
                and dtemonth = to_number(to_char(ttotreqst_dtestrt, 'mm'))
                and ttotreqst_codcompw like codcomp || '%'
                order by codcomp desc -- user22 : 28/03/2024 : KOHU-HR2301 ||
                FETCH FIRST 1 ROW ONLY;
            exception when no_data_found then
              param_msg_error :=  get_error_msg_php('MSZ001',global_v_lang);
              return;
         end;

          if nvl(v_set_qtybudget,0) <= 0 then --user36 KOHU #1823 27/03/2024 ||if para_codcompbg is null then          
            param_msg_error := get_error_msg_php('MSZ001',global_v_lang);
            return;
          end if;
      end if;
  end;

  procedure check_data is
    v_check_emp         number:=0;
    v_codempid          temploy1.codempid%type;
    v_codapp            varchar2(10) := 'HRES6KE';--'HRMS6KE';
    v_count             number := 0;
    v_approvno          number := 0;
    v_codempid_next     temploy1.codempid%type;
    v_codempap          temploy1.codempid%type;
    v_codcompap         temploy1.codcomp%type;
    v_codposap          varchar2(4);
    v_routeno           varchar2(15);
    v_remark            varchar2(200);-- := ctrl.get_label('HRMS6KEC2',global_v_lang,100);
    v_seqno             number ;
    v_numlvl            number ;
    v_staemp            varchar2(15);
    v_dteeffex          date ;
    flg_secur           boolean ;
    v_zupdsal           varchar2(15);
    v_dup			    number:=0;

    -->> user18 ST11 03/08/2021 change std
    v_qtymxotwk         tcontrot.qtymxotwk%type;
    v_qtymxallwk        tcontrot.qtymxallwk%type;
    v_qtydaywk          number;
    --<< user18 ST11 03/08/2021 change std

-- << KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
    vv_codapp       varchar2(40);
-- >> KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
  begin
    if ttotreq_codempid	is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
	end if;
	begin
        select numlvl,staemp,dteeffex
          into v_numlvl,v_staemp,v_dteeffex
          from temploy1
         where codempid = ttotreq_codempid;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
    end;
    begin
        select codempid	into v_codempid
          from tattence
         where codempid = ttotreq_codempid
           and dtework  between ttotreqst_dtestrt and ttotreqst_dteend
           and rownum =1 ;
    exception when no_data_found then
        v_codempid := null;
    end;
    if v_codempid is null then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tattence');
        return;
	end if;

    flg_secur := secur_main.secur2(ttotreq_codempid, global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
	if not flg_secur then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        return;
	end if;

    if ttotreq_codshift is not null then
        v_check_emp  :=0;
        begin
            select count(*) into v_check_emp
              from tattence
             where	codempid = ttotreq_codempid
               and dtework    = ttotreq_dtestrt
               and codshift   = ttotreq_codshift;
            if v_check_emp = 0 then
                param_msg_error := get_error_msg_php('AL0032',global_v_lang);
                return;
            end if;
        end;
    end if;

    if ttotreq_dtestrt is	null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
--      if ttotreq_timstrt is null then
--        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--        return;
--      end if;
--      if ttotreq_timend	is	null	then
--        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
--        return;
--      end if;
--      begin
--        select count(*) into v_dup
--        from	ttotreq
--        where	codempid = ttotreq_codempid
--        and		dtereq	 = ttotreqst_dtereq
--        and		numseq	 = ttotreq_seqno;
--      exception when no_data_found then
--        v_dup	:=	0;
--      end;
--      if v_dup > 0 then
--        param_msg_error := get_error_msg_php('HR2005',global_v_lang);
--        return;
--      end if;
    begin
        select codcomp
          into ttotreq_codcomp
          from temploy1
         where codempid = ttotreq_codempid;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
    end;


    -- << KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 23/09/2023 | Modify
        --	ตรวจสอบ Flow การอนุมัติ 
    begin 
        Select codapp
        into vv_codapp
        From  TEMPFLOW
        Where codapp = 'HRES6KE'
        and codempid = ttotreq_codempid;
    exception when no_data_found then   
      param_msg_error := replace(get_error_msg_php('MSZ003',global_v_lang),'@#$%400') || ' ('|| ttotreq_codempid ||')'; --KOHU-HR2301 19/10/2023
--        vv_codapp := '';
    end;
    -- >> KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 23/09/2023 | Modify
--    if vv_codapp is null then
--        v_routeno   := chk_workflow.find_route('HRES6KE',ttotreq_codempid,'');
--        if v_routeno is null then
--            param_msg_error := replace(get_error_msg_php('MSZ003',global_v_lang),'@#$%400');
--            return;
--        end if;
--    end if;
  end;

  procedure check_after_save is
    v_qtymxotwk             tcontrot.qtymxotwk%type;
    v_qtymxallwk            tcontrot.qtymxallwk%type;
    v_typalert              tcontrot.typalert%type;
    v_tmp_qtyot_req         number;
  begin
    begin
        select codcomp
          into ttotreq_codcomp
          from temploy1
         where codempid = ttotreq_codempid;
    exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang);
        return;
    end;

    if ttotreq_dtestrt not between ttotreqst_dtestrt and ttotreqst_dteend then
        param_msg_error := get_error_msg_php('AL0021',global_v_lang);
        return;
    end if;

    begin
        select qtymxotwk, qtymxallwk, nvl(typalert,'N')
          into v_qtymxotwk, v_qtymxallwk, v_typalert
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

    v_qtymxotwk     := nvl(v_qtymxotwk,0);

    --<<user36 ST11 16/09/2023
    v_qtyminot      := std_ot.get_qtyminot(ttotreq_codempid, ttotreq_dtestrt, ttotreq_dtestrt,
                                            hcm_util.convert_time_to_minute(ttotreq_qtyminb), ttotreq_timbend, ttotreq_timbstr,
                                            hcm_util.convert_time_to_minute(ttotreq_qtymind), ttotreq_timdend, ttotreq_timdstr,
                                            hcm_util.convert_time_to_minute(ttotreq_qtymina), ttotreq_timaend, ttotreq_timastr);
    ttotreq_qtyotreq := v_qtyminot; 
    -->>user36 ST11 16/09/2023

    if v_typalert <> 'N' then
        std_ot.get_week_ot(ttotreq_codempid, ttotreq_numotreq,ttotreq_dtereq,ttotreq_numseq,v_dtestrtwk,v_dteendwk,
                           null, null, null,
                           null, null, null,
                           null, null, null,
                           global_v_codempid,
                           a_dtestweek,a_dteenweek,
                           a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
        v_qtydaywk      := a_sumwork(1);

        v_qtyminotOth := std_ot.get_qtyminotOth_notTmp (ttotreq_codempid ,v_dtestrtwk, v_dteendwk, 'HRMS6KE3', global_v_codempid);

        begin
          SELECT sum(hcm_util.convert_time_to_minute(item23))
            into v_tmp_qtyot_req
            FROM ttemprpt
           WHERE codempid = global_v_codempid
             AND codapp = 'HRMS6KE3'
             and item2 = ttotreq_codempid
             and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
             and numseq < v_report_numseq;
        exception when others then
            v_tmp_qtyot_req := 0;
        end;
        v_qtyminotOth := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
        --user36 ST11 16/09/2023||
--        v_qtyminot      := std_ot.get_qtyminot(ttotreq_codempid, ttotreq_dtestrt, ttotreq_dtestrt,
--                                                hcm_util.convert_time_to_minute(ttotreq_qtyminb), ttotreq_timbend, ttotreq_timbstr,
--                                                hcm_util.convert_time_to_minute(ttotreq_qtymind), ttotreq_timdend, ttotreq_timdstr,
--                                                hcm_util.convert_time_to_minute(ttotreq_qtymina), ttotreq_timaend, ttotreq_timastr);

        v_qtyot_total   := v_qtyminotOth + v_qtyminot;
        v_qtytotal      := v_qtydaywk + v_qtyminotOth + v_qtyminot;
        ttotreq_staovrot    := 'N';
        if (v_qtyot_total > v_qtymxotwk) then
            if v_typalert = '1' then
                ttotreq_staovrot    := 'Y';
                if v_msgerror is null and nvl(p_flgconfirm,'N') = 'N' then
                    v_msgerror      := replace(get_error_msg_php('ES0075',global_v_lang),'@#$%400');
                end if;
            elsif v_typalert = '2' then
                param_msg_error := get_error_msg_php('ES0075',global_v_lang);
            end if;
            return;
        end if;

        if (v_qtytotal > v_qtymxallwk) then
            if v_typalert = '1' then
                ttotreq_staovrot    := 'Y';
                if v_msgerror is null and nvl(p_flgconfirm,'N') = 'N' then
                    v_msgerror      := replace(get_error_msg_php('ES0076',global_v_lang),'@#$%400');
                end if;
            elsif v_typalert = '2' then
                param_msg_error := get_error_msg_php('ES0076',global_v_lang);
            end if;
            return;
        end if;
    else
        ttotreq_staovrot    := 'N';
    end if;
  end;

  procedure insert_next_step(json_str in clob, p_result out clob) is
    json_obj        json_object_t := json_object_t(json_str);
    json_obj2       json_object_t;
    json_obj3       json_object_t;
    v_codempid      temploy1.codempid%type;
    t_codempid      temploy1.codempid%type;
    t_seqno         number;
    t_flgrecord     varchar2(10 char);
    v_codapp        varchar2(10 char) := 'HRES6KE';
    v_count         number := 0;
    v_approvno      number := 0;
    v_codempid_next temploy1.codempid%type;
    v_codempap      temploy1.codempid%type;
    v_codcompap     temploy1.codcomp%type;
    v_codposap      varchar2(4 char);
    v_routeno       varchar2(15 char);
    v_remark        varchar2(200 char) := substr(get_label_name('HCM_APPRFLW',global_v_lang,10),1,200);
    v_numseq        number ;
    v_table			varchar2(50 char);
    v_error			varchar2(50 char);
    v_error_mail	varchar2(50 char);
    v_seqno			number:=0;
    --
    v_numlvl		temploy1.numlvl%type;
    v_staemp		temploy1.staemp%type;
    v_dteeffex		temploy1.dteeffex%type;
    flg_secur       boolean;
    v_zupdsal       varchar2(1 char);
    --
    v_ocodempid	 	temploy1.codempid%type:='!@#$';--User37 STA4590329 27/12/2016
    v_maxseq		number;--User37 STA4590329 28/12/2016
    v_flgrecord     varchar2(10 char);
    --
    v_codempid_noworkflow   varchar2(4000 char);
    v_concat                varchar2(10 char);
    v_count_codempid        number := 0;    -- 27/01/2020 redmine #7810
    v_chk_codempid          number := 0;    -- 27/01/2020 redmine #7810
    v_staappr       ttotreq.staappr%type;
    v_rowid_ttotreq     rowid;
    v_rowid             rowid;
    flg_cancel          boolean;
    flg_tovrtime        boolean;
    v_numperiod   tovrtime.numperiod%type;
    v_dtemthpay   tovrtime.dtemthpay%type;
    v_dteyrepay   tovrtime.dteyrepay%type;
    v_maillang      varchar2(100);
    v_numotreq      ttotreq.numotreq%type;
    v_codempid_receive  temploy1.codempid%type;
    v_msg_to        clob;
    v_template_to   clob;
    cursor c1 is
        select codempid, dtework, typot,
               flgotcal, numperiod, dtemthpay, dteyrepay
          from tovrtime
         where codempid  = ttotreq_codempid
           and numotreq = v_numotreq
      order by dtework;

    cursor c2 is
        select flgtran
          from tpaysum
         where numperiod = v_numperiod
           and dtemthpay = v_dtemthpay
           and dteyrepay = v_dteyrepay
           and codempid = ttotreq_codempid
           and CODALW = 'OT' ;

  begin
    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRMS6KE'; -- 27/01/2020 redmine #7810
--    delete from ttemprpt where codempid = global_v_codempid and codapp = 'HRMS6KE3';

    for i in 0..json_obj.get_size-1 loop
      json_obj2         := json_object_t(json_obj.get(to_char(i)));
      ttotreq_dtestrt   := to_date(hcm_util.get_string_t(json_obj2,'dtestrt'),'dd/mm/yyyy');
      ttotreq_codempid  := hcm_util.get_string_t(json_obj2,'codempid');
      ttotreq_typot     := hcm_util.get_string_t(json_obj2, 'typot');
      ttotreq_codshift  := hcm_util.get_string_t(json_obj2,'codshift');
      ttotreq_timstrt   := replace(trim(hcm_util.get_string_t(json_obj2,'timstrt')),':','');
      ttotreq_timend    := replace(trim(hcm_util.get_string_t(json_obj2,'timend')),':','');
      ttotreq_staappr   := hcm_util.get_string_t(json_obj2,'staappr');
      ttotreq_seqno     := to_number(hcm_util.get_string_t(json_obj2,'numseq'));
      v_flgrecord       := hcm_util.get_string_t(json_obj2,'flg');
      --
      ttotreq_qtyminr   := hcm_util.get_string_t(json_obj2,'qtyminr');
      ttotreq_codcompw  := hcm_util.get_string_t(json_obj2,'codcompw');
      ttotreq_flgchglv  := hcm_util.get_string_t(json_obj2,'flgchglv');
      -->> user18 ST11 04/08/2021 change std
      v_qtyot_total     := hcm_util.convert_time_to_minute(hcm_util.get_string_t(json_obj2,'qtyot_total'));
      v_qtytotal        := hcm_util.convert_time_to_minute(hcm_util.get_string_t(json_obj2,'qtytotal'));
      p_qtyot_req       := hcm_util.convert_time_to_minute(hcm_util.get_string_t(json_obj2,'qtyot_req'));

      v_dtestrtwk       := to_date(hcm_util.get_string_t(json_obj2,'dtestrtwk'),'dd/mm/yyyy');
      v_dteendwk        := to_date(hcm_util.get_string_t(json_obj2,'dteendwk'),'dd/mm/yyyy');
      v_report_numseq   := hcm_util.get_string_t(json_obj2,'seqno');
      --<< user18 ST11 04/08/2021 change std

      if v_flgrecord = 'delete' then
        if ttotreq_staappr = 'P' then
            begin
              delete from ttotreq
              where codempid = ttotreq_codempid
                and dtereq   = ttotreqst_dtereq
                and numseq   = ttotreq_seqno;
            exception when others then
              null;
            end;
        elsif ttotreq_staappr in ('A','Y') then
            begin
                select rowid
                  into v_rowid_ttotreq
                  from ttotreq
                 where codempid = ttotreq_codempid
                   and dtereq = ttotreq_dtereq
                   and numseq = ttotreq_seqno;
            exception when no_data_found then
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
                            delete tovrtime
                             where codempid  = r1.codempid
                               and dtework = r1.dtework
                               and typot = r1.typot;

                            delete totpaydt
                             where codempid  = r1.codempid
                               and dtework = r1.dtework
                               and typot = r1.typot;

                            delete totreqst
                             where codempid  = r1.codempid
                               and numotreq = v_numotreq;

                            delete totreqd
                             where codempid  = r1.codempid
                               and dtewkreq = r1.dtework
                               and typot = r1.typot
                               and numotreq = v_numotreq;
                        exception when others then
                          null;
                        end;
                    end loop;

                    if not flg_tovrtime then
                        delete totreqst
                         where codempid  = b_index_codempid
                           and numotreq = v_numotreq;

                        delete totreqd
                         where codempid  = b_index_codempid
                           and numotreq = v_numotreq;
                    end if;

                    update ttotreq
                       set staappr   = 'C',
                           dtecancel = trunc(sysdate),
                           coduser   = global_v_coduser,
                           dteupd = sysdate
                     where codempid = b_index_codempid
                       and dtereq   = ttotreq_dtereq
                       and numseq   = ttotreq_numseq;
                    commit;
                else
                    null;
                end if;
            elsif ttotreq_staappr = 'A' then
                begin
                    update ttotreq
                       set staappr   = 'C',
                           dtecancel = trunc(sysdate),
                           coduser   = global_v_coduser,
                           dteupd = sysdate
                     where codempid = ttotreq_codempid
                       and dtereq   = ttotreq_dtereq
                       and numseq   = ttotreq_seqno;
                    commit;
                exception when others then
                  param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                  rollback;
                  return;
                end;
            end if;
            begin
                select rowid
                  into v_rowid
                  from V_TEMPLOY
                 where codempid = ttotreq_codempid;
            exception when others then
                v_rowid := null;
            end;
            begin
                select codappr
                  into v_codempid_receive
                  from taptotrq
                 where codempid = ttotreq_codempid
                   and dtereq = ttotreq_dtereq
                   and numseq = ttotreq_seqno
                   and rownum = 1;
            exception when others then
                v_codempid_receive := null;
            end;

            v_maillang := chk_flowmail.get_emp_mail_lang(v_codempid_receive);

            chk_flowmail.get_message_result('HRES6KECN', v_maillang, v_msg_to, v_template_to);
            chk_flowmail.replace_text_frmmail(v_template_to, 'V_TEMPLOY', v_rowid, get_label_name('HRES6KE2',v_maillang,280), 'HRES6KECN', '1', null, global_v_coduser, v_maillang, v_msg_to, p_chkparam => 'N');
            chk_flowmail.replace_param('TTOTREQ',v_rowid_ttotreq,'HRES6KECN','1',v_maillang,v_msg_to,'N');
            begin
                v_error_mail := chk_flowmail.send_mail_to_emp (v_codempid_receive, global_v_coduser, v_msg_to, NULL, get_label_name('HRES6KE2',v_maillang,280), 'E', v_maillang, null, null,null,null,null,'HRES6KE',v_codempid_receive);
            exception when others then
                v_error_mail := '2403';
            end;
        end if;
      elsif  v_flgrecord = 'add' or  v_flgrecord = 'edit' then
        check_data;
        if param_msg_error is null or v_codempid_noworkflow is not null then  -- user4 || 01/02/2018 || skip codempid that has not setup workflow
          if ttotreq_staappr is null then
            ttotreq_staappr := 'P';
          end if;
          if ttotreq_seqno is null then --user4 || 28/08/2017
            v_ocodempid	:= ttotreq_codempid;
            v_maxseq	:= 0;
            for j in 0..json_obj.get_size-1 loop
              json_obj3   := hcm_util.get_json_t(json_obj,to_char(j));
              t_codempid  := hcm_util.get_string_t(json_obj3,'codempid');
              t_seqno     := hcm_util.get_string_t(json_obj3,'numseq');
              t_flgrecord := hcm_util.get_string_t(json_obj3,'flg');
              if t_codempid = v_ocodempid then
                if t_seqno is not null and t_seqno > v_maxseq and t_flgrecord <> 'delete' then
                  v_maxseq := t_seqno;
                end if;
              end if;
            end loop;
            if v_maxseq = 0 then
              begin
                select max(numseq) into v_seqno
                from   ttotreq
                where	 codempid = ttotreq_codempid
                and    dtereq   = ttotreqst_dtereq;
              exception  when others then
                v_seqno := 0;
              end;
              ttotreq_seqno  := nvl(v_seqno,0) + 1;
            else
              ttotreq_seqno  := nvl(v_maxseq,0) + 1;
            end if;
          end if; --if ttotreq_seqno is not null then --user4 || 28/08/2017
          ttotreq_timbstr  	:= 	null;
          ttotreq_timbend  	:= 	null;
          ttotreq_timdstr  	:= 	null;
          ttotreq_timdend  	:= 	null;
          ttotreq_timastr  	:= 	null;
          ttotreq_timaend  	:= 	null;
          ttotreq_qtymina   :=  null;
          ttotreq_qtyminb   :=  null;
          ttotreq_qtymind   :=  null;
          if ttotreq_typot = 'A' then
            ttotreq_timastr := ttotreq_timstrt;
            ttotreq_timaend := ttotreq_timend;
            ttotreq_qtymina := ttotreq_qtyminr;
          elsif ttotreq_typot = 'B' then
            ttotreq_timbstr := ttotreq_timstrt;
            ttotreq_timbend := ttotreq_timend;
            ttotreq_qtyminb := ttotreq_qtyminr;
          elsif ttotreq_typot = 'D' then
            ttotreq_timdstr := ttotreq_timstrt;
            ttotreq_timdend := ttotreq_timend;
            ttotreq_qtymind := ttotreq_qtyminr;
          end if;
          ttotreq_dteend   :=	ttotreq_dtestrt;
          ttotreq_dtereq   := ttotreqst_dtereq;
          ttotreq_numotgen := ttotreqst_numotgen;
          ttotreq_codrem   := ttotreqst_codrem;
          ttotreq_remark   := ttotreqst_remark;
          ttotreq_codinput := ttotreqst_codinput;
          begin
            select	codcomp
            into		ttotreq_codcomp
            from		temploy1
            where		codempid	=	ttotreq_codempid;
          exception when others then null;
          end;
          ttotreq_coduser := global_v_coduser;
          v_approvno      := 0;
          v_codempap      := ttotreq_codempid;
          v_routeno := null;

--          chk_workflow.find_next_approve(v_codapp,v_routeno,ttotreq_codempid,to_char(ttotreq_dtereq,'dd/mm/yyyy'),ttotreq_seqno,v_approvno,v_codempap);
--          if v_routeno is null then
--            param_msg_error := get_error_msg_php('HR2055',global_v_lang,'twkflph');
--            return;
--          end if;

--          chk_workflow.find_approval(v_codapp,ttotreq_codempid,to_char(ttotreq_dtereq,'dd/mm/yyyy'),ttotreq_seqno,v_approvno,v_table,v_error);
--          if v_error is not null then
--            v_count_codempid := v_count_codempid + 1;
--
--            --<< 27/01/2020 redmine #7810
--            begin
--                select count(*)
--                  into v_chk_codempid
--                  from ttemprpt
--                 where codempid = global_v_codempid
--                   and codapp = 'HRMS6KE'
--                   and item1 = ttotreq_codempid;
--            exception when others then
--                v_chk_codempid := 0;
--            end;
--
--            if v_chk_codempid = 0 then
--                begin
--                    insert into ttemprpt(codempid,codapp,numseq,item1)
--                        values(global_v_codempid,'HRMS6KE',v_count_codempid,ttotreq_codempid);
--                exception when dup_val_on_index then null;
--                end;
--                v_codempid_noworkflow := substr(v_codempid_noworkflow||v_concat||ttotreq_codempid,1,3000);
--                v_concat := ', ';
--            end if;
--            -->> 27/01/2020 redmine #7810
--
--            param_msg_error := 'List of employees that not found approvers <br><span style="color:red;">'||v_codempid_noworkflow||'</span><br><br> '||get_error_msg_php(v_error,global_v_lang,v_table);
----            return;
--          end if;
--
          if param_msg_error is null then
--            loop
--              v_codempid_next := chk_workflow.check_next_step(v_codapp,v_routeno,ttotreq_codempid,to_char(ttotreq_dtereq,'dd/mm/yyyy'),ttotreq_seqno,v_approvno,v_codempap);
--              if v_codempid_next is not null then
--                v_approvno        := v_approvno + 1;
--                ttotreq_codappr   := v_codempid_next;
--                ttotreq_staappr   := 'A';
--                ttotreq_dteappr   := trunc(sysdate);
--                ttotreq_remarkap  := v_remark;
--                ttotreq_approvno  := v_approvno;
--                begin
--                    select  count(*) into v_count
--                    from   taptotrq
--                    where  codempid = ttotreq_codempid
--                    and    dtereq   = ttotreq_dtereq
--                    and    numseq   = ttotreq_seqno
--                    and    approvno = v_approvno;
--                exception when no_data_found then  v_count := 0;
--                end;
--                if v_count = 0 then
--                  insert into taptotrq
--                          (codempid,dtereq,numseq,approvno,codappr,dteappr,numotreq,staappr,remark,
--                          dteupd,coduser,dteapph)
--                  values  (ttotreq_codempid,ttotreq_dtereq,ttotreq_seqno,v_approvno,
--                          v_codempid_next,ttotreq_dteappr,ttotreq_numotreq,'A',v_remark,
--                          trunc(sysdate),global_v_coduser,sysdate);
--                else
--                    update taptotrq   set codappr   = v_codempid_next,
--                                          dteappr   = ttotreq_dteappr,
--                                          numotreq  = ttotreq_numotreq,
--                                          staappr   = 'A',
--                                          remark    = v_remark ,
--                                          coduser   = global_v_coduser,
--                                          dteupd =  sysdate,
--                                          dteapph   = sysdate
--                      where	codempid = ttotreq_codempid
--                      and   dtereq   = ttotreq_dtereq
--                      and   numseq	 = ttotreq_seqno
--                      and   approvno = v_approvno;
--                end if;
--                chk_workflow.find_next_approve(v_codapp,v_routeno,ttotreq_codempid,to_char(ttotreq_dtereq,'dd/mm/yyyy'),ttotreq_seqno,v_approvno,v_codempap);
--              else
--                exit;
--              end if;
--            end loop ;
            ttotreq_approvno   := v_approvno;
            ttotreq_routeno    := v_routeno;
            ttotreq_codempap   := v_codempap;
            ttotreq_codcompap  := v_codcompap;
            ttotreq_codposap   := v_codposap;
            ---<<< weerayut 09/01/2018 Lock request during payroll
            if get_payroll_active('HRMS6KE',ttotreq_codempid,ttotreq_dtestrt,ttotreq_dteend) = 'Y' then
              param_msg_error := get_error_msg_php('ES0057',global_v_lang);
              return;
            end if;
            --->>> weerayut 09/01/2018
            -- insert ttotreq
            if param_msg_error is null then
              ttotreq_staovrot  := 'N';
              save_ttotreq;
              -->> user18 ST11 04/08/2021 change std
              check_after_save;
              if v_msgerror is not null then
                rollback;
                return;
              end if;
              begin
                  update ttotreq
                     set staovrot    = ttotreq_staovrot,
                         qtyotreq   = ttotreq_qtyotreq --user36 ST11 16/09/2023
                   where /*numotgen    = ttotreqst_numotgen
                     and*/ dtereq      = ttotreq_dtereq
                     and numseq      = ttotreq_seqno
                     and codempid    = ttotreq_codempid;
              end;
              if param_msg_error is not null then
                rollback;
                return;
              end if;
              --<< user18 ST11 04/08/2021 change std
            end if;
          else
--            return;
            null;
          end if;
        end if;
      end if; -- if v_flgrecord
    end loop; --end for
  end ; 

  procedure save_ttotreq is
    v_numseq    ttotreq.numseq%type := 0;
    v_rowcount  number := 0;
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
    ttotreq_coduser  := global_v_coduser;
    ttotreq_codinput := global_v_codempid;
    ttotreq_routeno := ''; 
    begin
      update ttotreq
      set   dtereq      = ttotreq_dtereq,
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
            dteinput    = ttotreq_dteinput,
            dtecancel   = ttotreq_dtecancel,
            --
            codcompw    = ttotreq_codcompw,
            flgchglv    = ttotreq_flgchglv,
            qtymina     = hcm_util.convert_time_to_minute(ttotreq_qtymina),
            qtyminb     = hcm_util.convert_time_to_minute(ttotreq_qtyminb),
            qtymind     = hcm_util.convert_time_to_minute(ttotreq_qtymind),
            staovrot    = ttotreq_staovrot, -- user18 ST11 04/08/2021 change std

          -- << KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
              codcompbg = ttotreqst_codcompbg,
              qtybudget = ttotreqst_wkbudget,
              qtyothot  = ttotreqst_otherrequesthr,
              pctbguse  = ttotreqst_percentused
          -- >> KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
      where numotgen    = ttotreqst_numotgen
        and numseq      = ttotreq_seqno
        and codempid    = ttotreq_codempid;
    end;

    v_rowcount := sql%rowcount;

    if v_rowcount <= 0 then
      begin
        insert into ttotreq
        (numotgen,    numseq,       dtereq,       codempid,     dtestrt,
         dteend,      codrem,       remark,       codinput,     timbstr,
         timbend,     timdstr,      timdend,      timastr,      timaend,
         codappr,     routeno,      dteappr,
         codcomp,     staappr,      dteupd,       coduser,
         approvno,    remarkap,     dteinput,     dtecancel,
         codcompw,    flgchglv,
         staovrot,  codcreate, dtecreate,-- user18 ST11 04/08/2021 change std
         qtyminb,
         qtymind,
         qtymina,
         codcompbg, qtybudget, qtyothot, pctbguse)
        values
        (ttotreqst_numotgen,  ttotreq_seqno,        ttotreq_dtereq,     ttotreq_codempid,    ttotreq_dtestrt,
         ttotreq_dteend,      ttotreq_codrem,       ttotreq_remark,     ttotreq_codinput,    ttotreq_timbstr,
         ttotreq_timbend,     ttotreq_timdstr,      ttotreq_timdend,    ttotreq_timastr,     ttotreq_timaend,
         ttotreq_codappr,     ttotreq_routeno,     ttotreq_dteappr,
         ttotreq_codcomp,     ttotreq_staappr,      ttotreq_dteupd,     ttotreq_coduser,
         ttotreq_approvno,     ttotreq_remarkap,     sysdate,   ttotreq_dtecancel,
         ttotreq_codcompw,    ttotreq_flgchglv,
         ttotreq_staovrot, ttotreq_coduser, sysdate, -- user18 ST11 04/08/2021 change std
         hcm_util.convert_time_to_minute(ttotreq_qtyminb),
         hcm_util.convert_time_to_minute(ttotreq_qtymind),
         hcm_util.convert_time_to_minute(ttotreq_qtymina),
         -- << KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
         ttotreqst_codcompbg,
         ttotreqst_wkbudget,
         ttotreqst_otherrequesthr,
         ttotreqst_percentused);
         -- >> KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
      exception when dup_val_on_index then
        null;
      end;
    end if;

    update ttemprpt
       set item3 = ttotreq_seqno
     where codapp = 'HRMS6KE3'
       and codempid = global_v_codempid
       and numseq = v_report_numseq;



    -- << KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
    begin
        select pctotreq1, pctotreq2, pctotreq3, pctotreq4, codappr1, codappr2, codappr3, codappr4
        into v_pctotreq1, v_pctotreq2, v_pctotreq3, v_pctotreq4, v_codappr1, v_codappr2, v_codappr3, v_codappr4
        From  TEMPFLOW
        Where codapp = 'HRES6KE'
            and  codempid = ttotreq_codempid;
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

    if ttotreqst_percentused > v_pctotreq4 then
        v_maxstep := 4;
    elsif ttotreqst_percentused > v_pctotreq3 then
        v_maxstep := 3;
    elsif ttotreqst_percentused > v_pctotreq2 then
        v_maxstep := 2;
    else --ttotreqst_percentused > v_pctotreq1 then
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
        Where codempid = ttotreq_codempid
        And    dtereq  = ttotreq_dtereq
        And    numseq  = ttotreq_seqno;
    exception when others then
        null;
    end;




    for  i in 1..v_maxstep loop
        Insert into TEMPAPRQ(codapp,codempid,dtereq,numseq,approvno,codempap,seqno,
                            codcompap,codposap,routeno)
        values('HRES6KE',ttotreq_codempid,ttotreq_dtereq,ttotreq_seqno,i,v_codappr_arr(i),1,
                null,null,null);
    end loop; 

    -- >> KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
  end save_ttotreq;

  procedure save_ttotreqst is
    v_numseq  number := 0;
  begin
    begin
      insert into ttotreqst
      (numotgen,dtereq,codinput,codcomp,codcalen,dtestrt,dteend,
       timbstr,timbend,timdstr,timdend,timastr,timaend,codrem,
       remark,coduser,dteupd,codshift,
       -- /*user3*/ new requirement --
       codempid,codcompw,flgchglv,qtyminb,qtymind,qtymina,
       -- << KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
       codcompbg, qtybudget, qtyothot, pctbguse, qtyotreq)
       -- >> KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify

      values
      (ttotreqst_numotgen, ttotreqst_dtereq,  ttotreqst_codinput,  ttotreqst_codcomp,  ttotreqst_codcalen,  ttotreqst_dtestrt,  ttotreqst_dteend,
       ttotreqst_timbstr,  ttotreqst_timbend, ttotreqst_timdstr,   ttotreqst_timdend,  ttotreqst_timastr,   ttotreqst_timaend,  ttotreq_codrem,
       ttotreqst_remark,   global_v_coduser,  sysdate,  ttotreqst_codshift,
       -- /*user3*/ new requirement --
       ttotreqst_codempid,ttotreqst_codcompw, ttotreqst_flgchglv,
       hcm_util.convert_time_to_minute(ttotreqst_qtyminb),
       hcm_util.convert_time_to_minute(ttotreqst_qtymind),
       hcm_util.convert_time_to_minute(ttotreqst_qtymina),
      -- << KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
      ttotreqst_codcompbg,ttotreqst_wkbudget,ttotreqst_otherrequesthr,ttotreqst_percentused, ttotreqst_requesthr
      -- >> KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
       );
    exception when dup_val_on_index then
      begin
        update ttotreqst
        set   dtereq     = ttotreqst_dtereq,
              codinput   = ttotreqst_codinput,
              codcomp    = ttotreqst_codcomp,
              codcalen   = ttotreqst_codcalen,
              dtestrt    = ttotreqst_dtestrt,
              dteend     = ttotreqst_dteend,
              timbstr    = ttotreqst_timbstr,
              timbend    = ttotreqst_timbend,
              timdstr    = ttotreqst_timdstr,
              timdend    = ttotreqst_timdend,
              timastr    = ttotreqst_timastr,
              timaend    = ttotreqst_timaend,
              codrem     = ttotreqst_codrem,
              remark     = ttotreqst_remark,
              coduser    = global_v_coduser,
              dteupd     = sysdate,
              codshift   = ttotreqst_codshift,
              -- /*user3*/ new requirement --
              codempid   = ttotreqst_codempid,
              codcompw   = ttotreqst_codcompw,
              flgchglv   = ttotreqst_flgchglv,
              qtyminb    = hcm_util.convert_time_to_minute(ttotreqst_qtyminb),
              qtymind    = hcm_util.convert_time_to_minute(ttotreqst_qtymind),
              qtymina    = hcm_util.convert_time_to_minute(ttotreqst_qtymina),
            -- << KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
              codcompbg = ttotreqst_codcompbg,
              qtybudget = ttotreqst_wkbudget,
              qtyothot  = ttotreqst_otherrequesthr,
              pctbguse  = ttotreqst_percentused,
              qtyotreq = ttotreqst_requesthr
           -- >> KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 09/12/2023 | Modify
        where numotgen   = ttotreqst_numotgen;
        update ttotreq
          set dtereq = ttotreqst_dtereq
        where numotgen   = ttotreqst_numotgen;
      end;
    end;
  end save_ttotreqst;

  procedure get_tcodotrq (json_str_input in clob, json_str_output out clob) as
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
      obj_data.put('rcnt', v_rcnt);
      obj_data.put('codcodec',r1.codcodec);
      obj_data.put('desc_codcodec' ,get_tcodec_name('tcodotrq',r1.codcodec,global_v_lang));

      obj_row.put(to_char(v_row-1),obj_data);
    end loop; -- end for
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_tcodotrq;


  procedure get_costcenter(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    json_obj        json_object_t;
    v_cost_center   tcenter.costcent%type;
    v_codcompw      ttotreq.codcompw%type;
  begin
    initial_value(json_str_input);
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

  procedure get_ot_change (json_str_input in clob, json_str_output out clob) is
    obj_input       json_object_t;
    obj_data        json_object_t;
    v_flgchglv      tcontrot.flgchglv%type;
    v_codcompy      tcenter.codcompy%type;
    v_codempid      temploy1.codempid%type;
    v_codcomp       temploy1.codcomp%type;
  begin
    obj_input       := json_object_t(json_str_input);
    v_codempid      := hcm_util.get_string_t(obj_input,'p_codempid_query');
    v_codcomp       := replace(hcm_util.get_string_t(obj_input,'p_codcomp'), '-', null);
    v_flgchglv      := 'N';
    if v_codempid is not null then
      begin
        select hcm_util.get_codcomp_level(codcomp, 1)
          into v_codcompy
          from temploy1
         where codempid like v_codempid;
      exception when no_data_found then
        v_codcompy  := null;
      end;
    else
      v_codcompy    := hcm_util.get_codcomp_level(v_codcomp, 1);
    end if;
    --
    begin
      select flgchglv
        into v_flgchglv
        from tcontrot
       where codcompy = v_codcompy
         and dteeffec = (select max(dteeffec)
                           from tcontrot
                          where dteeffec <= sysdate
                            and codcompy = v_codcompy)
         and rownum <= 1;
    exception when no_data_found then
      v_flgchglv      := 'N';
    end;
    obj_data       := json_object_t();
    obj_data.put('coderror', 200);
    obj_data.put('flgchglv_', v_flgchglv);

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_ot_change;

  procedure get_codshift_ot (json_str_input in clob, json_str_output out clob) is
    obj_input       json_object_t;
    obj_data        json_object_t;
    v_codshift      tattence.codshift%type;
    v_dtestrtw      tattence.dtestrtw%type;
    v_timstrtw      tattence.timstrtw%type;
    v_dteendw       tattence.dteendw%type;
    v_timendw       tattence.timendw%type;
    --
    v_codempid      tattence.codempid%type;
    v_dtewkreq      tattence.dtework%type;
    v_typalert      tcontrot.typalert%type;
    v_codcomp       temploy1.codcomp%type;
  begin
    initial_value(json_str_input);
    obj_input       := json_object_t(json_str_input);
    v_codempid      := hcm_util.get_string_t(obj_input,'p_codempid_query');
    v_dtewkreq      := to_date(hcm_util.get_string_t(obj_input,'p_dtewkreq'),'dd/mm/yyyy');
    begin
      select codshift,dtestrtw,timstrtw,dteendw,timendw,codcomp
        into v_codshift,v_dtestrtw,v_timstrtw,v_dteendw,v_timendw,v_codcomp
        from tattence
       where codempid = v_codempid
         and dtework  = v_dtewkreq;
    exception when no_data_found then
      v_codshift        := null;
    end;

    begin
        select nvl(typalert,'N')
          into v_typalert
          from tcontrot
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                              and dteeffec <= sysdate);
    exception when others then
        v_typalert      := 'N';
    end;

    obj_data       := json_object_t();
    obj_data.put('coderror', 200);
    obj_data.put('codshift', v_codshift);
    obj_data.put('dtestrtw', to_char(v_dtestrtw,'dd/mm/yyyy'));
    obj_data.put('timstrtw', v_timstrtw);
    obj_data.put('dteendw', to_char(v_dteendw,'dd/mm/yyyy'));
    obj_data.put('timendw', v_timendw);
    obj_data.put('typalert', nvl(v_typalert,'N'));

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_codshift_ot;

  --<< user18 ST11 03/08/2021 change std
  procedure get_ChkDtereq (json_str_input in clob, json_str_output out clob) is
    obj_input       json_object_t;
    obj_data        json_object_t;
    v_codshift      tattence.codshift%type;
    v_dtestrtw      tattence.dtestrtw%type;
    v_timstrtw      tattence.timstrtw%type;
    v_dteendw       tattence.dteendw%type;
    v_timendw       tattence.timendw%type;
    --
    v_codempid      tattence.codempid%type;
    v_dtewkreq      tattence.dtework%type;
  begin
    initial_value(json_str_input);
    obj_input       := json_object_t(json_str_input);
    v_codempid      := hcm_util.get_string_t(obj_input,'p_codempid_query');
    ttotreq_dtestrt := to_date(hcm_util.get_string_t(obj_input,'p_dtestrt'),'dd/mm/yyyy');
    v_dtestrt       := to_date(hcm_util.get_string_t(obj_input,'p_dtestrtwk'),'dd/mm/yyyy');
    v_dteend        := to_date(hcm_util.get_string_t(obj_input,'p_dteendwk'),'dd/mm/yyyy');

    obj_data       := json_object_t();
    obj_data.put('coderror', 200);

    if ttotreq_dtestrt not between v_dtestrt and v_dteend then
        obj_data.put('msgerror', replace(get_error_msg_php('AL0021',global_v_lang),'@#$%400'));
    end if;

    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_ChkDtereq;

  procedure get_cumulative_hours(json_str_input in clob, json_str_output out clob) as
    obj_input           json_object_t;
    obj_main            json_object_t;

    json_obj            json_object_t;
    v_row               number;
    -- check null data --
    v_rcnt              number := 0;
    obj_row             json_object_t;
    obj_data            json_object_t;

    v_dtestrtwk         date;
    v_dteendwk          date;

    v_qtydaywk          number;
    v_qtymin            number;
    v_qtyot_reqoth      number;
    v_qtyot_req         number;
    v_qtyot_total       number;
    v_qtytotal          number;

    v_codempid          ttotreq.codempid%type;
    v_dtereq            ttotreq.dtereq%type;
    v_numseq            ttotreq.numseq%type;
    v_numotreq          ttotreq.numotreq%type;

    v_qtyminot          number;
    v_qtyminotOth       number;
    v_dteot             date;
    obj_data_rows       json_object_t;
    v_ttemprpt          ttemprpt%rowtype;
    v_codempid_tmp      temploy1.codempid%type;
    v_codempid_old_tmp  temploy1.codempid%type;
    v_tmp_qtyot_req     number;
    v_msg_error         varchar2(2000);
    v_qtymxotwk         tcontrot.qtymxotwk%type;
    v_qtymxallwk        tcontrot.qtymxallwk%type;
    v_typalert          tcontrot.typalert%type;
    v_qtyminotOth_cumulative number;
    v_numseq_tmp    number;

    CURSOR c1 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
      ORDER BY numseq;

    CURSOR c2 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
         and item2 = v_codempid_tmp
         and numseq <> v_ttemprpt.numseq
      ORDER BY numseq;

    CURSOR c3 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
         and item2 = v_codempid_old_tmp
      ORDER BY numseq;

    CURSOR c4_main IS
      SELECT distinct item2 codempid,
             to_date(item19,'dd/mm/yyyy') dtestrtwk,
             to_date(item20,'dd/mm/yyyy') dteendwk
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
         and item2 = v_codempid_tmp
      ORDER BY codempid, dtestrtwk;

    CURSOR c4 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
         and item2 = v_codempid_tmp
         and to_date(item19,'dd/mm/yyyy') = v_dtestrtwk
         and to_date(item20,'dd/mm/yyyy') = v_dteendwk
      ORDER BY numseq;

    CURSOR c5_main IS
      SELECT distinct item2 codempid,
             to_date(item19,'dd/mm/yyyy') dtestrtwk,
             to_date(item20,'dd/mm/yyyy') dteendwk
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
         and item2 = v_codempid_old_tmp
      ORDER BY codempid, dtestrtwk;

    CURSOR c5 IS
      SELECT *
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
         and item2 = v_codempid_old_tmp
         and to_date(item19,'dd/mm/yyyy') = v_dtestrtwk
         and to_date(item20,'dd/mm/yyyy') = v_dteendwk
      ORDER BY numseq;
  begin
    initial_value(json_str_input);
    obj_input           := json_object_t(json_str_input);
    v_codempid          := hcm_util.get_string_t(obj_input,'p_codempid_query');
    v_codempid_old_tmp  := hcm_util.get_string_t(obj_input,'p_codempidOld_query');
    v_dtestrt           := to_date(hcm_util.get_string_t(obj_input,'p_dtestrt'),'dd/mm/yyyy');
    ttotreq_typot       := hcm_util.get_string_t(obj_input,'p_typot');
    obj_data_rows       := hcm_util.get_json_t(obj_input,'rowdata');

    if ttotreq_typot = 'B' then
        ttotreq_timbstr       := hcm_util.get_string_t(obj_input,'p_timstrt');
        ttotreq_timbend       := hcm_util.get_string_t(obj_input,'p_timend');
        ttotreqst_qtyminb     := hcm_util.get_string_t(obj_input,'p_qtyminr');
    elsif ttotreq_typot = 'D' then
        ttotreq_timdstr       := hcm_util.get_string_t(obj_input,'p_timstrt');
        ttotreq_timdend       := hcm_util.get_string_t(obj_input,'p_timend');
        ttotreqst_qtymind     := hcm_util.get_string_t(obj_input,'p_qtyminr');
    elsif ttotreq_typot = 'A' then
        ttotreq_timastr       := hcm_util.get_string_t(obj_input,'p_timstrt');
        ttotreq_timaend       := hcm_util.get_string_t(obj_input,'p_timend');
        ttotreqst_qtymina     := hcm_util.get_string_t(obj_input,'p_qtyminr');
    end if;

    ttotreq_dtereq      := to_date(hcm_util.get_string_t(obj_input,'p_dtereq'),'dd/mm/yyyy');
    ttotreq_numseq      := hcm_util.get_string_t(obj_input,'p_numseq');
    v_numotreq          := hcm_util.get_string_t(obj_input,'p_numotreq');

    begin
        select codcomp
          into v_codcomp
          from temploy1
          where codempid = v_codempid;
    exception when others then
        v_codcomp := null;
    end;

    begin
        select nvl(qtymxotwk,0),nvl(qtymxallwk,0), nvl(typalert,'N')
          into v_qtymxotwk,v_qtymxallwk, v_typalert
          from tcontrot
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and dteeffec = (select max(dteeffec)
                             from tcontrot
                            where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                              and dteeffec <= sysdate);
    exception when others then
        v_qtymxotwk     := 0;
        v_qtymxallwk    := 0;
        v_typalert      := 'N';
    end;

    obj_main := json_object_t();
    obj_row := json_object_t();
    v_row := 0;

      obj_data := json_object_t();
      obj_data := obj_data_rows;
      obj_data.put('coderror', '200');

      v_ttemprpt.numseq  := hcm_util.get_string_t(obj_data,'seqno'); --seqno
      v_numseq           := hcm_util.get_string_t(obj_data,'seqno');
    if v_typalert <> 'N' then    
      v_dtestrtwk   := std_ot.get_dtestrt_period (v_codempid, v_dtestrt);
      v_dteendwk    := v_dtestrtwk + 6;
      std_ot.get_week_ot(v_codempid, v_numotreq,ttotreq_dtereq,ttotreq_numseq,v_dtestrtwk,v_dteendwk,
                         null, null, null,
                         null, null, null,
                         null, null, null,
                         global_v_codempid,
                         a_dtestweek,a_dteenweek,
                         a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
      v_qtydaywk    := a_sumwork(1);
      v_qtyminotOth := std_ot.get_qtyminotOth_notTmp (v_codempid ,v_dtestrtwk, v_dteendwk, 'HRMS6KE3', global_v_codempid);
      v_codempid_tmp :=       v_codempid;

      begin
      SELECT sum(hcm_util.convert_time_to_minute(item23))
        into v_tmp_qtyot_req
        FROM ttemprpt
       WHERE codempid = global_v_codempid
         AND codapp = 'HRMS6KE3'
         and item2 = v_codempid_tmp
         and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
         and numseq <> v_ttemprpt.numseq;
      end;

      v_qtyminotOth := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
      v_qtyminot    := std_ot.get_qtyminot(v_codempid_tmp, v_dtestrt, v_dtestrt,
                                            hcm_util.convert_time_to_minute(ttotreqst_qtyminb), ttotreq_timbend, ttotreq_timbstr,
                                            hcm_util.convert_time_to_minute(ttotreqst_qtymind), ttotreq_timdend, ttotreq_timdstr,
                                            hcm_util.convert_time_to_minute(ttotreqst_qtymina), ttotreq_timaend, ttotreq_timastr);

      if v_codempid is not null then
          obj_data.put('dtestrtwk',to_char(v_dtestrtwk,'dd/mm/yyyy'));
          obj_data.put('dteendwk',to_char(v_dteendwk,'dd/mm/yyyy'));
          obj_data.put('qtydaywk',hcm_util.convert_minute_to_hour(v_qtydaywk));
          obj_data.put('qtyot_reqoth',hcm_util.convert_minute_to_hour(v_qtyminotOth));
          obj_data.put('qtyot_req',hcm_util.convert_minute_to_hour(v_qtyminot));
          obj_data.put('qtyot_total',hcm_util.convert_minute_to_hour(v_qtyminotOth + v_qtyminot));
          obj_data.put('qtytotal',hcm_util.convert_minute_to_hour(v_qtydaywk + v_qtyminotOth + v_qtyminot));
          v_qtyot_total := v_qtyminotOth + v_qtyminot;
          v_qtytotal    := v_qtydaywk + v_qtyot_total;
      else
          obj_data.put('dtestrtwk','');
          obj_data.put('dteendwk','');
          obj_data.put('qtydaywk','');
          obj_data.put('qtyot_reqoth','');
          obj_data.put('qtyot_req','');
          obj_data.put('qtyot_total','');
          obj_data.put('qtytotal','');
          v_qtyot_total := null;
          v_qtytotal    := null;
      end if;
    else
          obj_data.put('dtestrtwk','');
          obj_data.put('dteendwk','');
          obj_data.put('qtydaywk','');
          obj_data.put('qtyot_reqoth','');
          obj_data.put('qtyot_req','');
          obj_data.put('qtyot_total','');
          obj_data.put('qtytotal','');
          v_qtyot_total := null;
          v_qtytotal    := null;    
    end if;  
      begin
          select max(numseq)
            into v_report_numseq
            from ttemprpt
           where codempid = global_v_codempid
             and codapp = 'HRMS6KE3';
      exception when others then
        v_report_numseq := 0;
      end;

      v_report_numseq   := nvl(v_report_numseq,0) + 1;
      v_ttemprpt.item1  := hcm_util.get_string_t(obj_data,'dtestrt'); --dtestrt
      v_ttemprpt.item2  := hcm_util.get_string_t(obj_data,'codempid'); -- codempid
      v_ttemprpt.item3  := hcm_util.get_string_t(obj_data,'numseq'); -- numseq
      v_ttemprpt.item4  := get_temploy_name(hcm_util.get_string_t(obj_data,'codempid'),global_v_lang); --desc_codempid
      v_ttemprpt.item5  := hcm_util.get_string_t(obj_data,'typot'); --typot

      begin
        select codshift
          into v_ttemprpt.item6
          from tattence
         where codempid = v_ttemprpt.item2
           and dtework  = to_date(v_ttemprpt.item1,'dd/mm/yyyy');
      exception when no_data_found then
        v_ttemprpt.item6        := '';
      end;--codshift

      v_ttemprpt.item7  := hcm_util.get_string_t(obj_data,'v_timstrt'); --v_timstrt
      v_ttemprpt.item8  := hcm_util.get_string_t(obj_data,'v_timend'); --v_timend
      v_ttemprpt.item9  := hcm_util.get_string_t(obj_data,'staappr'); --staappr
      v_ttemprpt.item10  := hcm_util.get_string_t(obj_data,'v_staappr'); --v_staappr
      v_ttemprpt.item11  := hcm_util.get_string_t(obj_data,'flgchglv_'); --flgchglv_
      v_ttemprpt.item12  := hcm_util.get_string_t(obj_data,'flgchglv'); --flgchglv
      v_ttemprpt.item13  := hcm_util.get_string_t(obj_data,'codcompw'); --codcompw
      v_ttemprpt.item14  := hcm_util.get_string_t(obj_data,'qtyminr'); --qtyminr
      v_ttemprpt.item15  := hcm_util.get_string_t(obj_data,'timstrt'); --timstrt
      v_ttemprpt.item16  := hcm_util.get_string_t(obj_data,'timend'); --timend
      v_ttemprpt.item17  := hcm_util.get_string_t(obj_data,'costcent'); --costcent
      v_ttemprpt.item18  := hcm_util.get_string_t(obj_data,'qtytotal'); --qtytotal
      v_ttemprpt.item19  := hcm_util.get_string_t(obj_data,'dtestrtwk');--dtestrtwk
      v_ttemprpt.item20  := hcm_util.get_string_t(obj_data,'dteendwk');--,dteendwk
      v_ttemprpt.item21  := hcm_util.get_string_t(obj_data,'qtydaywk'); --qtydaywk
      v_ttemprpt.item22  := hcm_util.get_string_t(obj_data,'qtyot_reqoth'); --qtyot_reqoth
      v_ttemprpt.item23  := hcm_util.get_string_t(obj_data,'qtyot_req'); --qtyot_req
      v_ttemprpt.item24  := hcm_util.get_string_t(obj_data,'qtyot_total'); --qtyot_total
      v_ttemprpt.item30  := hcm_util.get_string_t(obj_data,'flgDeleteDisabled'); --flgDeleteDisabled
      v_ttemprpt.item31  := v_typalert; --typalert

      if hcm_util.get_boolean_t(obj_data,'flgAdd') then
        v_ttemprpt.item25   := 1;
      else
        v_ttemprpt.item25   := 0;
      end if;
      if hcm_util.get_boolean_t(obj_data,'flgEdit') then
        v_ttemprpt.item26   := 1;
      else
        v_ttemprpt.item26   := 0;
      end if;
      if hcm_util.get_boolean_t(obj_data,'flgDelete') then
        v_ttemprpt.item27   := 1;
      else
        v_ttemprpt.item27   := 0;
      end if;

      begin
        insert into ttemprpt (codempid,codapp,numseq,
                              item1,item2,item3,item4,item5,
                              item6,item7,item8,item9,item10,
                              item11,item12,item13,item14,item15,
                              item16,item17,item18,item19,item20,
                              item21,item22,item23,item24,
                              item25,item26,item27,item30,item31)
        values(global_v_codempid,'HRMS6KE3',v_ttemprpt.numseq,
                              v_ttemprpt.item1,v_ttemprpt.item2,v_ttemprpt.item3,v_ttemprpt.item4,v_ttemprpt.item5,
                              v_ttemprpt.item6,v_ttemprpt.item7,v_ttemprpt.item8,v_ttemprpt.item9,v_ttemprpt.item10,
                              v_ttemprpt.item11,v_ttemprpt.item12,v_ttemprpt.item13,v_ttemprpt.item14,v_ttemprpt.item15,
                              v_ttemprpt.item16,v_ttemprpt.item17,v_ttemprpt.item18,v_ttemprpt.item19,v_ttemprpt.item20,
                              v_ttemprpt.item21,v_ttemprpt.item22,v_ttemprpt.item23,v_ttemprpt.item24,
                              v_ttemprpt.item25,v_ttemprpt.item26,v_ttemprpt.item27,v_ttemprpt.item30,v_ttemprpt.item31);
      exception when dup_val_on_index then
        update ttemprpt
           set item1 = v_ttemprpt.item1, item2 = v_ttemprpt.item2,
               item3 = v_ttemprpt.item3, item4 = v_ttemprpt.item4,
               item5 = v_ttemprpt.item5, item6 = v_ttemprpt.item6,
               item7 = v_ttemprpt.item7, item8 = v_ttemprpt.item8,
               item9 = v_ttemprpt.item9, item10 = v_ttemprpt.item10,
               item11 = v_ttemprpt.item11, item12 = v_ttemprpt.item12,
               item13 = v_ttemprpt.item13, item14 = v_ttemprpt.item14,
               item15 = v_ttemprpt.item15, item16 = v_ttemprpt.item16,
               item17 = v_ttemprpt.item17, item18 = v_ttemprpt.item18,
               item19 = v_ttemprpt.item19, item20 = v_ttemprpt.item20,
               item21 = v_ttemprpt.item21, item22 = v_ttemprpt.item22,
               item23 = v_ttemprpt.item23, item24 = v_ttemprpt.item24,
               item25 = v_ttemprpt.item25, item26 = v_ttemprpt.item26,
               item27 = v_ttemprpt.item27, item31 = v_ttemprpt.item31
         where codempid = global_v_codempid
           and codapp = 'HRMS6KE3'
           and numseq = v_ttemprpt.numseq;
      end;

    if v_typalert <> 'N' then
        if (v_qtyot_total > v_qtymxotwk) then
            v_msg_error := replace(get_error_msg_php('ES0075',global_v_lang),'@#$%400');
        elsif (v_qtytotal > v_qtymxallwk) then
            v_msg_error := replace(get_error_msg_php('ES0076',global_v_lang),'@#$%400');
        end if;

        for r2 in c2 loop
          v_dtestrtwk   := to_date(r2.item19,'dd/mm/yyyy');
          v_dteendwk    := to_date(r2.item20,'dd/mm/yyyy');

          std_ot.get_week_ot(v_codempid_tmp, '','','',v_dtestrtwk,v_dteendwk,
                             null, null, null,
                             null, null, null,
                             null, null, null,
                             global_v_codempid,
                             a_dtestweek,a_dteenweek,
                             a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);

          v_qtyminotOth := std_ot.get_qtyminotOth_notTmp (v_codempid_tmp ,v_dtestrtwk, v_dteendwk, 'HRMS6KE3', global_v_codempid);

         begin
          SELECT sum(hcm_util.convert_time_to_minute(item23))
            into v_tmp_qtyot_req
            FROM ttemprpt
           WHERE codempid = r2.codempid
             AND codapp = r2.codapp
             and item2 = r2.item2
             and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
             and numseq <> r2.numseq;
         end;

          v_qtyminotOth := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
          v_ttemprpt.item22 := hcm_util.convert_minute_to_hour(v_qtyminotOth);
          v_ttemprpt.item24 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r2.item23) + v_qtyminotOth);
          v_ttemprpt.item18 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r2.item21) + hcm_util.convert_time_to_minute(r2.item23) + v_qtyminotOth);
          update ttemprpt
             set item22 = v_ttemprpt.item22,
                 item24 = v_ttemprpt.item24,
                 item18 = v_ttemprpt.item18
           where codempid = r2.codempid
             and codapp = r2.codapp
             and numseq = r2.numseq;
        end loop;

        for r4_main in c4_main loop
            v_dtestrtwk                 := r4_main.dtestrtwk;
            v_dteendwk                  := r4_main.dteendwk;
            std_ot.get_week_ot(v_codempid_tmp, '','','',v_dtestrtwk,v_dteendwk,
                               null, null, null,
                               null, null, null,
                               null, null, null,
                               global_v_codempid,
                               a_dtestweek,a_dteenweek,
                               a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
            v_qtydaywk    := a_sumwork(1);

            v_qtyminotOth_cumulative    := std_ot.get_qtyminotOth_notTmp (v_codempid_tmp ,v_dtestrtwk, v_dteendwk, 'HRMS6KE3', global_v_codempid);

            for r4 in c4 loop
                v_qtyot_total   := v_qtyminotOth_cumulative + hcm_util.convert_time_to_minute(r4.item23);
                v_qtytotal      := v_qtydaywk + v_qtyot_total;
                v_ttemprpt.item26 := r4.item26;
                if (v_qtyot_total > v_qtymxotwk or v_qtytotal > v_qtymxallwk) then
                    v_ttemprpt.item28   := 'Y';
                else
                    v_ttemprpt.item28   := 'N';
                end if;
                if r4.numseq > v_numseq then
                    v_ttemprpt.item26 := 1;
                end if;
                v_qtyminotOth_cumulative := v_qtyot_total;
                update ttemprpt
                   set item28 = v_ttemprpt.item28,
                       item26 = v_ttemprpt.item26
                 where codempid = r4.codempid
                   and codapp = r4.codapp
                   and numseq = r4.numseq;
            end loop;
        end loop;

        for r3 in c3 loop
          v_dtestrtwk   := to_date(r3.item19,'dd/mm/yyyy');
          v_dteendwk    := to_date(r3.item20,'dd/mm/yyyy');

          v_qtyminotOth := std_ot.get_qtyminotOth_notTmp (r3.item2 ,v_dtestrtwk, v_dteendwk, 'HRMS6KE3', global_v_codempid);

        begin
          SELECT sum(hcm_util.convert_time_to_minute(item23))
            into v_tmp_qtyot_req
            FROM ttemprpt
           WHERE codempid = r3.codempid
             AND codapp = r3.codapp
             and item2 = r3.item2
             and to_date(item1,'dd/mm/yyyy') between v_dtestrtwk and v_dteendwk
             and numseq <> r3.numseq;
        end;

          v_qtyminotOth     := v_qtyminotOth + nvl(v_tmp_qtyot_req,0);
          v_ttemprpt.item22 := hcm_util.convert_minute_to_hour(v_qtyminotOth);
          v_ttemprpt.item24 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r3.item23) + v_qtyminotOth);
          v_ttemprpt.item18 := hcm_util.convert_minute_to_hour(hcm_util.convert_time_to_minute(r3.item21) + hcm_util.convert_time_to_minute(r3.item23) + v_qtyminotOth);
          update ttemprpt
             set item22 = v_ttemprpt.item22,
                 item24 = v_ttemprpt.item24,
                 item18 = v_ttemprpt.item18
           where codempid = r3.codempid
             and codapp = r3.codapp
             and numseq = r3.numseq;
        end loop;

        for r5_main in c5_main loop
            v_dtestrtwk                 := r5_main.dtestrtwk;
            v_dteendwk                  := r5_main.dteendwk;
            std_ot.get_week_ot(v_codempid_old_tmp, '','','',v_dtestrtwk,v_dteendwk,
                               null, null, null,
                               null, null, null,
                               null, null, null,
                               global_v_codempid,
                               a_dtestweek,a_dteenweek,
                               a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
            v_qtydaywk    := a_sumwork(1);

            v_qtyminotOth_cumulative    := std_ot.get_qtyminotOth_notTmp (v_codempid_old_tmp ,v_dtestrtwk, v_dteendwk, 'HRMS6KE3', global_v_codempid);

            for r5 in c5 loop
                v_qtyot_total   := v_qtyminotOth_cumulative + hcm_util.convert_time_to_minute(r5.item23);
                v_qtytotal      := v_qtydaywk + v_qtyot_total;
                v_ttemprpt.item26 := r5.item26;
                if (v_qtyot_total > v_qtymxotwk or v_qtytotal > v_qtymxallwk) then
                    v_ttemprpt.item28   := 'Y';
                    if r5.numseq > v_numseq then
                        v_ttemprpt.item26 := 1;
                    end if;
                else
                    v_ttemprpt.item28   := 'N';
                end if;
                v_qtyminotOth_cumulative := v_qtyot_total;
                update ttemprpt
                   set item28 = v_ttemprpt.item28,
                       item26 = v_ttemprpt.item26
                 where codempid = r5.codempid
                   and codapp = r5.codapp
                   and numseq = r5.numseq;
            end loop;
        end loop;
    end if;

    for r1 in c1 loop
        v_row := v_row+1;

        obj_data := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('seqno',r1.numseq); --dtestrt
        obj_data.put('dtestrt',r1.item1); --dtestrt
        obj_data.put('dtestrtOld',r1.item1); --dtestrt
        obj_data.put('codempid',r1.item2); -- codempid
        obj_data.put('codempidOld',r1.item2); -- codempid
        obj_data.put('numseq',r1.item3); -- numseq
        obj_data.put('desc_codempid',r1.item4); --desc_codempid
        obj_data.put('typot',r1.item5); --typot
        obj_data.put('codshift',r1.item6); --codshift
        obj_data.put('v_timstrt',r1.item7); --v_timstrt
        obj_data.put('v_timend',r1.item8); --v_timend
        obj_data.put('staappr',r1.item9); --staappr
        obj_data.put('v_staappr',r1.item10); --v_staappr
        obj_data.put('flgchglv_',r1.item11); --flgchglv_
        obj_data.put('flgchglv',r1.item12); --flgchglv
        obj_data.put('codcompw',r1.item13); --codcompw
        obj_data.put('qtyminr',r1.item14); --qtyminr
        obj_data.put('timstrt',r1.item15); --timstrt
        obj_data.put('timend',r1.item16); --timend
        obj_data.put('costcent',r1.item17); --costcent
        obj_data.put('qtytotal',r1.item18); --qtytotal
        obj_data.put('dtestrtwk',r1.item19);--dtestrtwk
        obj_data.put('dteendwk',r1.item20);--,dteendwk
        obj_data.put('qtydaywk',r1.item21); --qtydaywk
        obj_data.put('qtyot_reqoth',r1.item22); --qtyot_reqoth
        obj_data.put('qtyot_req',r1.item23); --qtyot_req
        obj_data.put('qtyot_total',r1.item24); --qtyot_total
        if r1.item25 = 1 then
            obj_data.put('flgAdd',true);
        else
            obj_data.put('flgAdd',false);
        end if;
        if r1.item26 = 1 then
            obj_data.put('flgEdit',true);
        else
            obj_data.put('flgEdit',false);
        end if;
        if r1.item27 = 1 then
            obj_data.put('flgDelete',true);
        else
            obj_data.put('flgDelete',false);
        end if;
        obj_data.put('staovrot',r1.item28);
        obj_data.put('numotreq',r1.item29);
        obj_data.put('flgDeleteDisabled',r1.item30);
        obj_data.put('typalert',r1.item31);
        obj_row.put(to_char(v_row-1),obj_data);
    end loop;
    obj_main.put('coderror', '200');
    obj_main.put('table', obj_row);
    obj_main.put('msgerror', v_msg_error);
    json_str_output := obj_main.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_cumulative_hours;


  procedure get_detail_create(json_str_input in clob, json_str_output out clob) is
    obj_data          json_object_t;
    obj_data2         json_object_t;
    obj_detail1          json_object_t;
    obj_detail2          json_object_t;
    v_cost_center     varchar2(100 char);
    tcontrot_flgchglv varchar2(100 char);

  begin
    initial_value(json_str_input);
    begin
        delete ttemprpt
        where codempid = global_v_codempid
        and codapp = 'HRMS6KE3';
    exception when others then
        null;
    end;

    if param_msg_error is null then
      obj_data := json_object_t();
      obj_data.put('coderror', '200');

      obj_detail1 := json_object_t();
      obj_detail1.put('dtereq',nvl(to_char(sysdate,'dd/mm/yyyy'),''));
      obj_detail1.put('dtestrt',to_char(sysdate,'dd/mm/yyyy'));
      obj_detail1.put('dteend',to_char(sysdate,'dd/mm/yyyy'));
      obj_detail1.put('flgchglv','N');
      obj_detail1.put('tcontrot_flgchglv','N');
      obj_detail1.put('numotgen','');
      obj_detail1.put('codcomp','');
      obj_detail1.put('codcalen','');
      obj_detail1.put('codshift','');
      obj_detail1.put('timbstr','');
      obj_detail1.put('timbend','');
      obj_detail1.put('timdstr','');
      obj_detail1.put('timdend','');
      obj_detail1.put('timastr','');
      obj_detail1.put('timaend','');
      obj_detail1.put('codrem','');
      obj_detail1.put('remark','');
      obj_detail1.put('codempid','');
      obj_detail1.put('codinput','');
      obj_detail1.put('name_codinput','');
      obj_detail1.put('codcompw','');
      obj_detail1.put('costcent','');
      obj_detail1.put('qtyminb','');
      obj_detail1.put('qtymind','');
      obj_detail1.put('qtymina','');
      obj_detail1.put('staappr','N');


      obj_data2 := json_object_t();
      obj_data2.put('departmentbudget','');
      obj_data2.put('wkbudgetdate','');
      obj_data2.put('wkbudget','');
      obj_data2.put('requesthr','');
      obj_data2.put('otherrequesthr','');
      obj_data2.put('totalhr','');
      obj_data2.put('remainhr','');
      obj_data2.put('percentused','');
      obj_data2.put('overbudgetstatus', 0);

      obj_detail1.put('budgetdetail', obj_data2);

      obj_data.put('tab1', obj_detail1);

      obj_detail2 := json_object_t();
      obj_detail2.put('rows', json_object_t());
      obj_data.put('tab2', obj_detail2);



      json_str_output := obj_data.to_clob;
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
     end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

 -- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1782 & fix change date effect or codempid is get data in table tattence
 procedure get_detail_tattence(json_str_input in clob, json_str_output out clob) is
    obj_data          json_object_t;
    obj_data2         json_object_t;
    obj_detail1          json_object_t;
    obj_detail2          json_object_t;
    v_cost_center     varchar2(100 char);
    tcontrot_flgchglv varchar2(100 char);

    v_codcompw   tattence.codcomp%type;

  begin
    initial_value(json_str_input);

    if b_index_codempid is not null then
        begin
            select codcomp into v_codcompw
              from tattence
             where codempid = b_index_codempid
               and dtework = b_index_dtestrt;
        exception when no_data_found then
            v_codcompw := null;
        end;
        insert into a (b) values (v_codcompw);commit;
        if v_codcompw is not null then
          begin  
          select costcent into v_cost_center
            from tcenter
           where codcomp = v_codcompw;
          end;
        end if;
    end if;

    if param_msg_error is null then
      obj_data := json_object_t();
      obj_data.put('coderror', '200');

      obj_detail1 := json_object_t();

      obj_detail1.put('codcompw',nvl(v_codcompw,''));
      obj_detail1.put('costcent',nvl(v_cost_center,''));

      obj_data.put('tab1', obj_detail1);

      json_str_output := obj_data.to_clob;
      else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
     end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;
  -- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1782 & fix change date effect or codempid is get data in table tattence

  procedure update_temp(json_str_input in clob, json_str_output out clob) as
    obj_input           json_object_t;
    json_obj            json_object_t;
    v_cost_center       tcenter.costcent%type;
    -- check null data --
    obj_data            json_object_t;
    v_codempid          ttotreq.codempid%type;
    v_ttemprpt          ttemprpt%rowtype;
    v_codempid_tmp      temploy1.codempid%type;
  begin
    initial_value(json_str_input);
    obj_input       := json_object_t(json_str_input);
    obj_data        := hcm_util.get_json_t(obj_input,'rowdata');

    v_ttemprpt.numseq  := hcm_util.get_string_t(obj_data,'seqno'); --seqno
    v_ttemprpt.item1  := hcm_util.get_string_t(obj_data,'dtestrt'); --dtestrt
    v_ttemprpt.item2  := hcm_util.get_string_t(obj_data,'codempid'); -- codempid
    v_ttemprpt.item3  := hcm_util.get_string_t(obj_data,'numseq'); -- numseq
    v_ttemprpt.item4  := get_temploy_name(hcm_util.get_string_t(obj_data,'codempid'),global_v_lang); --desc_codempid
    v_ttemprpt.item5  := hcm_util.get_string_t(obj_data,'typot'); --typot
    v_ttemprpt.item6  := hcm_util.get_string_t(obj_data,'codshift'); --codshift
    v_ttemprpt.item7  := hcm_util.get_string_t(obj_data,'v_timstrt'); --v_timstrt
    v_ttemprpt.item8  := hcm_util.get_string_t(obj_data,'v_timend'); --v_timend
    v_ttemprpt.item9  := hcm_util.get_string_t(obj_data,'staappr'); --staappr
    v_ttemprpt.item10  := hcm_util.get_string_t(obj_data,'v_staappr'); --v_staappr
    v_ttemprpt.item11  := hcm_util.get_string_t(obj_data,'flgchglv_'); --flgchglv_
    v_ttemprpt.item12  := hcm_util.get_string_t(obj_data,'flgchglv'); --flgchglv
    v_ttemprpt.item13  := hcm_util.get_string_t(obj_data,'codcompw'); --codcompw
    v_ttemprpt.item14  := hcm_util.get_string_t(obj_data,'qtyminr'); --qtyminr
    v_ttemprpt.item15  := hcm_util.get_string_t(obj_data,'timstrt'); --timstrt
    v_ttemprpt.item16  := hcm_util.get_string_t(obj_data,'timend'); --timend
    v_ttemprpt.item18  := hcm_util.get_string_t(obj_data,'qtytotal'); --qtytotal
    v_ttemprpt.item19  := hcm_util.get_string_t(obj_data,'dtestrtwk');--dtestrtwk
    v_ttemprpt.item20  := hcm_util.get_string_t(obj_data,'dteendwk');--,dteendwk
    v_ttemprpt.item21  := hcm_util.get_string_t(obj_data,'qtydaywk'); --qtydaywk
    v_ttemprpt.item22  := hcm_util.get_string_t(obj_data,'qtyot_reqoth'); --qtyot_reqoth
    v_ttemprpt.item23  := hcm_util.get_string_t(obj_data,'qtyot_req'); --qtyot_req
    v_ttemprpt.item24  := hcm_util.get_string_t(obj_data,'qtyot_total'); --qtyot_total


    begin
        select costcent into v_cost_center
          from tcenter
         where codcomp = v_ttemprpt.item13
           and rownum <= 1
      order by codcomp;
    exception when no_data_found then
        v_cost_center := null;
    end;
    v_ttemprpt.item17  := v_cost_center; --costcent

    if hcm_util.get_boolean_t(obj_data,'flgAdd') then
        v_ttemprpt.item25   := 1;
    else
        v_ttemprpt.item25   := 0;
    end if;
    if hcm_util.get_boolean_t(obj_data,'flgEdit') then
        v_ttemprpt.item26   := 1;
    else
        v_ttemprpt.item26   := 0;
    end if;
    if hcm_util.get_boolean_t(obj_data,'flgDelete') then
        v_ttemprpt.item27   := 1;
    else
        v_ttemprpt.item27   := 0;
    end if;

    begin
        insert into ttemprpt (codempid,codapp,numseq,
                              item1,item2,item3,item4,item5,
                              item6,item7,item8,item9,item10,
                              item11,item12,item13,item14,item15,
                              item16,item17,item18,item19,item20,
                              item21,item22,item23,item24,
                              item25,item26,item27)
        values(global_v_codempid,'HRMS6KE3',v_ttemprpt.numseq,
                              v_ttemprpt.item1,v_ttemprpt.item2,v_ttemprpt.item3,v_ttemprpt.item4,v_ttemprpt.item5,
                              v_ttemprpt.item6,v_ttemprpt.item7,v_ttemprpt.item8,v_ttemprpt.item9,v_ttemprpt.item10,
                              v_ttemprpt.item11,v_ttemprpt.item12,v_ttemprpt.item13,v_ttemprpt.item14,v_ttemprpt.item15,
                              v_ttemprpt.item16,v_ttemprpt.item17,v_ttemprpt.item18,v_ttemprpt.item19,v_ttemprpt.item20,
                              v_ttemprpt.item21,v_ttemprpt.item22,v_ttemprpt.item23,v_ttemprpt.item24,
                              v_ttemprpt.item25,v_ttemprpt.item26,v_ttemprpt.item27);
    exception when dup_val_on_index then
        update ttemprpt
           set item1 = v_ttemprpt.item1, item2 = v_ttemprpt.item2,
               item3 = v_ttemprpt.item3, item4 = v_ttemprpt.item4,
               item5 = v_ttemprpt.item5, item6 = v_ttemprpt.item6,
               item7 = v_ttemprpt.item7, item8 = v_ttemprpt.item8,
               item9 = v_ttemprpt.item9, item10 = v_ttemprpt.item10,
               item11 = v_ttemprpt.item11, item12 = v_ttemprpt.item12,
               item13 = v_ttemprpt.item13, item14 = v_ttemprpt.item14,
               item15 = v_ttemprpt.item15, item16 = v_ttemprpt.item16,
               item17 = v_ttemprpt.item17, item18 = v_ttemprpt.item18,
               item19 = v_ttemprpt.item19, item20 = v_ttemprpt.item20,
               item21 = v_ttemprpt.item21, item22 = v_ttemprpt.item22,
               item23 = v_ttemprpt.item23, item24 = v_ttemprpt.item24,
               item25 = v_ttemprpt.item25, item26 = v_ttemprpt.item26,
               item27 = v_ttemprpt.item27
         where codempid = global_v_codempid
           and codapp = 'HRMS6KE3'
           and numseq = v_ttemprpt.numseq;
    end;

      if not std_ot.chk_duptemp(v_ttemprpt.item2, to_date(v_ttemprpt.item1,'dd/mm/yyyy'), v_ttemprpt.item5, global_v_codempid) then
        -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
        -- v_numseq_tmp := std_ot.get_max_numseq(global_v_codempid); -- bk
        v_numseq_tmp := std_ot.get_max_numseq(global_v_codempid,v_ttemprpt.item2); -- add
        -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887
        insert into ttemprpt (codempid,codapp,numseq,
                              item1,item2,item3,item4,item5,
                              item6,item7,item8,item10,temp31)
        -- values(global_v_codempid, 'CALOT36',v_numseq_tmp, -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (bk)
        values(global_v_codempid, 'CALOT36'||v_ttemprpt.item2,v_numseq_tmp, -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (add)
               v_ttemprpt.item2, v_ttemprpt.item1, v_ttemprpt.item5, '',
               v_ttemprpt.item1, replace(v_ttemprpt.item15,':'),
               v_ttemprpt.item1, replace(v_ttemprpt.item16,':'),
               '5', hcm_util.convert_time_to_minute(v_ttemprpt.item14));
      else
        update ttemprpt
           set temp31 = v_ttemprpt.item14,
               item10 = '5'
         where codempid = global_v_codempid
           -- and codapp = 'CALOT36' -- -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (bk)
           and codapp = 'CALOT36'||v_ttemprpt.item2 -- -- KOHU-HR2301 | 000504-Tae-Surachai-Dev | 17/04/2024 | 4449#1887 (add)
           and item1 = v_ttemprpt.item2
           and to_date(item2,'dd/mm/yyyy') = to_date(v_ttemprpt.item1,'dd/mm/yyyy')
           and item3 = v_ttemprpt.item5;
      end if;

    param_msg_error := get_error_msg_php('HR2401',global_v_lang);
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end update_temp;
  -->> user18 ST11 03/08/2021 change std



  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) is
    param_json       json_object_t;
    param_data       json_object_t;
    param_column     json_object_t;
    param_column_row json_object_t;
    param_json_row   json_object_t;
    json_obj_list    json_list;
    --
    v_filename  	   varchar2(1000);
    linebuf  			   varchar2(6000);
    data_file 		   varchar2(6000);
    v_column			   number := 12;
    v_error				   boolean;
    v_err_code  	   varchar2(1000);
    v_err_filed  	   varchar2(1000);
    v_err_table		   varchar2(20);
    v_comments  	   varchar2(1000);
    v_namtbl    	   varchar2(300);
    i 						   number;
    j 						   number;
    k 						   number;
    v_numseq    	   number := 0;
    --
    v_dtereq 			   ttotreqst.dtereq%type;
    v_codempid		   temploy1.codempid%type;
    v_dtewkreq 		   totreqd.dtewkreq%type;
    v_timbstr  		   varchar2(4 char);
    v_timbend  		   varchar2(4 char);
    v_qtyminb  		   varchar2(4 char);
    v_timdstr  		   varchar2(4 char);
    v_timdend  		   varchar2(4 char);
    v_qtymind  		   varchar2(4 char);
    v_timastr  		   varchar2(4 char);
    v_timaend  		   varchar2(4 char);
    v_qtymina  		   varchar2(4 char);
    v_codrem			   totreqst.codrem%type;
    v_codappr			   totreqst.codappr%type;
    v_dteappr			   totreqst.dteappr%type;
    v_flgchglv  	   totreqst.flgchglv%type;

    --
    v_code				   varchar2(100);
    v_codcomp			   temploy1.codcomp%type;
    v_staempap		   temploy1.staemp%type;
    v_numlvlap		   temploy1.numlvl%type;
    v_dtestrt  		   totreqd.dtestrt%type;
    v_dteend   		   totreqd.dteend%type;
    v_timstrt  		   totreqd.timstrt%type;
    v_timend    	   totreqd.timend%type;
    v_qtyminr        totreqd.qtyminr%type;
    v_dtewkst  		   date;
    v_dtewken   	   date;
    v_dteotst   	   date;
    v_dteoten   	   date;
    v_codcompw       totreqd.codcompw%type;
    v_flag				   varchar2(1);
    v_numotreq		   totreqd.numotreq%type;
    v_flgfound  	   boolean;
    v_cnt					   number := 0;
    v_codapp			   varchar2(10) := 'HRMS6KEP3';
    v_typotreq       varchar2(10);
    v_num            number := 0;
    v_flg_dup        varchar2(1);
    v_typ_grp    varchar2(100);
    v_flg_t        varchar2(1);

    v_staemp         temploy1.staemp%type;
    v_staemp1        temploy1.staemp%type;
    v_staemp2        temploy1.staemp%type;
    v_staemp3        temploy1.staemp%type;
    v_staemp4        temploy1.staemp%type;

    p_codcompbg     ttotreq.codcomp%type;
    p_qtybudget     number;
    p_qtyothot      number;
    p_dtestrt       date;
    p_dteend        date;

    v_sumotreqoth        number;
    v_sumotreq          number;
    v_percentused       number;
    v_remainhr          number;
    v_qtyminot          number;
    para_allqtyotreq    number;

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

    v_loop              number;
    v_count             number;
    --
    test clob;

    type text is table of varchar2(1000) index by binary_integer;
      v_text   text;
      v_filed  text;

    cursor c_tattence is
      select codempid,dtework,codcomp,typwork,codshift,codcalen,dtestrtw,timstrtw,dteendw,timendw
        from tattence
       where codempid = v_codempid
         and dtework  = v_dtewkreq;
  begin
    v_rec_tran  := 0;
    v_rec_error := 0;
   v_qtyminot := 0;
    para_allqtyotreq := 0;
    --
    for i in 1..v_column loop
      v_filed(i) := null;
    end loop;
    param_json   := hcm_util.get_json_t(json_object_t(json_str_input),'param_json');
    param_data   := hcm_util.get_json_t(param_json, 'p_filename');
    param_column := hcm_util.get_json_t(param_json, 'p_columns');
    p_flgconfirm := hcm_util.get_string_t(param_json, 'flgconfirm');

    -- get text columns from json
    for i in 0..param_column.get_size-1 loop
      param_column_row  := hcm_util.get_json_t(param_column,to_char(i));
      v_num             := v_num + 1;
      v_filed(v_num)    := hcm_util.get_string_t(param_column_row,'name');
      test := test||' | '||hcm_util.get_string_t(param_column_row,'name');
    end loop;
    --
    for i in 0..param_data.get_size-1 loop
-- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 14/03/2024 | (4449#1762)
        param_json_row := hcm_util.get_json_t(param_data,to_char(i));
-- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 14/03/2024 | (4449#1762)
      begin
        v_err_code  := null;
        v_err_filed := null;
        v_err_table := null;
        linebuf     := i;
        v_numseq    := 0;
        v_error 	  := false;
--<< user22 : 08/03/2024 : KOH-HR2301 || 
        para_allqtyotreq  := 0;
        p_qtybudget       := 0;  
        p_qtyothot        := 0;
        v_percentused     := 0;
-->> user22 : 08/03/2024 : KOH-HR2301 || 
        --
        if v_numseq = 0 then
          <<cal_loop>> loop
            v_text(1)   := hcm_util.get_string_t(param_json_row,'dtereq');
            v_text(2)   := hcm_util.get_string_t(param_json_row,'codempid');
            v_text(3)   := hcm_util.get_string_t(param_json_row,'dtewkreq');
            v_text(4)   := hcm_util.get_string_t(param_json_row,'timbstr');
            v_text(5)   := hcm_util.get_string_t(param_json_row,'timbend');
            v_text(6)   := hcm_util.get_string_t(param_json_row,'timdstr');
            v_text(7)   := hcm_util.get_string_t(param_json_row,'timdend');
            v_text(8)  := hcm_util.get_string_t(param_json_row,'timastr');
            v_text(9)  := hcm_util.get_string_t(param_json_row,'timaend');
            v_text(10)  := hcm_util.get_string_t(param_json_row,'codrem');

            -- push row values
            data_file := null;
            for i in 1..10 loop
              if data_file is null then
                data_file := v_text(i);
              else
                data_file := data_file||','||v_text(i);
              end if;
            end loop;

--1.Validate --
            for i in 1..3 loop
              if v_text(i) is null then
                v_error	 	  := true;
                v_err_code  := 'HR2045';
                v_err_filed := v_filed(i);
                exit cal_loop;
              end if;
            end loop;

            -- check null time
            if v_text(4)  is null and v_text(5)  is null and
               v_text(6)  is null and v_text(7)  is null and
               v_text(8) is null and v_text(9) is null then
              v_error	 	  := true;
              v_err_code  := 'HR2045';
              -- << KOHU-SS2301 | 000504-Tae-Surachai-Dev | 10/04/2024 | Fix issue 4449: #1847
              -- v_err_filed := v_filed(4)
              v_err_filed := v_filed(4)||', '||v_filed(5)||', '||v_filed(6)||', '||v_filed(7)||', '||v_filed(8)||', '||v_filed(9);
              -- >> KOHU-SS2301 | 000504-Tae-Surachai-Dev | 10/04/2024 | Fix issue 4449: #1847
              exit cal_loop;
            end if;

-- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 03/04/2024 | Fix issue 4449: #1847
            if v_text(4) is not null and v_text(5) is not null then
                if v_text(6) is not null or v_text(7) is not null or v_text(8) is not null or v_text(9) is not null then
                    v_error	 	:= true;
                    v_err_code  := 'MSZ004';

                    if v_text(6) is not null then
                        v_err_filed := v_filed(6);
                    elsif v_text(7) is not null then
                        v_err_filed := v_filed(7);
                    elsif v_text(8) is not null then
                        v_err_filed := v_filed(8);
                    elsif v_text(9) is not null then
                        v_err_filed := v_filed(9);
                    end if;

                    exit cal_loop;
                end if;
            end if;
            if v_text(6) is not null and v_text(7) is not null then
                if v_text(4) is not null or v_text(5) is not null or v_text(8) is not null or v_text(9) is not null then
                    v_error	 	:= true;
                    v_err_code  := 'MSZ004';

                    if v_text(4) is not null then
                        v_err_filed := v_filed(4);
                    elsif v_text(5) is not null then
                        v_err_filed := v_filed(5);
                    elsif v_text(8) is not null then
                        v_err_filed := v_filed(8);
                    elsif v_text(9) is not null then
                        v_err_filed := v_filed(9);
                    end if;

                    exit cal_loop;
                end if;
            end if;
            if v_text(8) is not null and v_text(9) is not null then
                if v_text(4) is not null or v_text(5) is not null or v_text(6) is not null or v_text(7) is not null then
                    v_error	 	:= true;
                    v_err_code  := 'MSZ004';

                    if v_text(4) is not null then
                        v_err_filed := v_filed(4);
                    elsif v_text(5) is not null then
                        v_err_filed := v_filed(5);
                    elsif v_text(6) is not null then
                        v_err_filed := v_filed(6);
                    elsif v_text(7) is not null then
                        v_err_filed := v_filed(7);
                    end if;

                    exit cal_loop;
                end if;
            end if;
-- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 03/04/2024 | Fix issue 4449: #1847

            if v_text(4) is not null or v_text(5) is not null then
                if v_text(4) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(4);
                  exit cal_loop;
                elsif v_text(5) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(5);
                  exit cal_loop;
                end if;
                v_flg_t := 'b';
            end if;

            if v_text(6) is not null or v_text(7) is not null then
                if v_text(6) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(6); -- KOHU-SS2301 | 000504-Tae-Surachai-Dev | 10/04/2024 | Fix issue 4449: #1847
                  exit cal_loop;
                elsif v_text(7) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(7); -- KOHU-SS2301 | 000504-Tae-Surachai-Dev | 10/04/2024 | Fix issue 4449: #1847
                  exit cal_loop;
                end if;
                 v_flg_t := 'd';
            end if;

            if v_text(8) is not null or v_text(9) is not null then
                if v_text(8) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(8); -- KOHU-SS2301 | 000504-Tae-Surachai-Dev | 10/04/2024 | Fix issue 4449: #1847
                  exit cal_loop;
                elsif v_text(9) is null then
                  v_error	 	  := true;
                  v_err_code  := 'HR2045';
                  v_err_filed := v_filed(9); -- KOHU-SS2301 | 000504-Tae-Surachai-Dev | 10/04/2024 | Fix issue 4449: #1847
                  exit cal_loop;
                end if;
                v_flg_t := 'a';
            end if;

            for i in 10..10 loop
                if v_text(i) is null and i <> 11 then
                    v_error	 	:= true;
                    v_err_code:= 'HR2045';
                    v_err_filed := v_filed(i);
                    exit cal_loop;
                end if;
             end loop;


            --1.dtereq
            v_error  := check_date(v_text(1),global_v_zyear);
            if v_error then
              v_error     := true;
              v_err_code  := 'HR2025' ;
              v_err_filed := v_filed(1) ;
              exit cal_loop;
            end if;
            v_dtereq := check_dteyre(v_text(1));

            --2.codempid
            begin
              select codcomp, staemp
                into v_codcomp, v_staemp1
                from temploy1
               where codempid = upper(v_text(2));
            exception when no_data_found then
              v_error     := true;
              v_err_code  := 'HR2010' ;
              v_err_table := 'TEMPLOY1';
              v_err_filed := v_filed(2);
              exit cal_loop;
            end;

            v_codcompw := v_codcomp;

            -- check secure --
            if not secur_main.secur2(upper(v_text(2)),global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen) then
              v_error     := true;
              v_err_code  := 'HR3007' ;
              v_err_filed := v_filed(2);
              exit cal_loop; 
            end if;
            v_codempid := upper(v_text(2));

            -- check status
            if v_staemp1 = 0 then
              v_error	   := true;
              v_err_code  := 'HR2102';
              v_err_filed := v_filed(2);
              exit cal_loop; 
            elsif v_staemp1 = 9 then
              v_error	   := true;
              v_err_code  := 'HR2101';
              v_err_filed := v_filed(2);
              exit cal_loop; 
            end if;


            -- 3.dtewkreq
            v_error  := check_date(v_text(3),global_v_zyear);
            if v_error then
              v_error     := true;
              v_err_code  := 'HR2025';
              v_err_filed := v_filed(3);
              exit cal_loop; 
            end if;
            v_dtewkreq := check_dteyre(v_text(3));
            begin
              select codempid
                into v_code
                from tattence
               where codempid = v_codempid
                 and dtework  = v_dtewkreq;
            exception when no_data_found then
              v_error     := true;
              v_err_code  := 'HR2010' ;
              v_err_table := 'TATTENCE';
              v_err_filed := v_filed(3) ;
              exit cal_loop; 
            end;

            if v_dtestrtwk is null then
                v_dtestrtwk     := std_ot.get_dtestrt_period (v_codempid, v_dtewkreq);
                v_dteendwk      := v_dtestrtwk + 6;
            end if;

                   -- 4.timbstr
            if v_text(4) is not null then
              if length(v_text(4)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(4) ;
                exit cal_loop;
              end if;
              v_flgfound := check_times(v_text(4));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(4) ;
                exit cal_loop;
              end if;
            end if;
            v_timbstr := v_text(4);

            -- 5.timbend
            if v_text(5) is not null then
              if length(v_text(5)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015';
                v_err_filed := v_filed(5);
                exit cal_loop;
              end if;
              v_flgfound := check_times(v_text(5));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(5) ;
                exit cal_loop; 
              end if;
            end if;
            v_timbend := v_text(5);

            -- 6.timdstr
            if v_text(6) is not null then
              if length(v_text(6)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(6) ; -- KOHU-SS2301 | 000504-Tae-Surachai-Dev | 10/04/2024 | Fix issue 4449: #1847
                exit cal_loop;
              end if;
              v_flgfound := check_times(v_text(6));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(6) ;
                exit cal_loop; 
              end if;
            end if;
            v_timdstr := v_text(6);

            -- 7.timdend
            if v_text(7) is not null then
              if length(v_text(7)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(7) ;
                exit cal_loop; 
              end if;
              v_flgfound := check_times(v_text(7));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(7) ;
                exit cal_loop; 
              end if;
            end if;
            v_timdend := v_text(7);

            -- 8.timastr
            if v_text(8) is not null then
              if length(v_text(8)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(8) ; -- KOHU-SS2301 | 000504-Tae-Surachai-Dev | 10/04/2024 | Fix issue 4449: #1847
                exit cal_loop; 
              end if;
              v_flgfound := check_times(v_text(8));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(8) ;
                exit cal_loop; 
              end if;
            end if;
            v_timastr := v_text(8);

            -- 9.timaend
            if v_text(9) is not null then
              if length(v_text(9)) <> 4 then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(9) ;
                exit cal_loop; 
              end if;
              v_flgfound := check_times(v_text(9));
              if not v_flgfound then
                v_error     := true;
                v_err_code  := 'HR2015' ;
                v_err_filed := v_filed(9) ;
                exit cal_loop; 
              end if;
            end if;
            v_timaend := v_text(9);


            -- 10.codrem
            if upper(v_text(10)) is not null then
              begin
                select codcodec	into v_code
                  from tcodotrq
                 where codcodec = upper(v_text(10));
              exception when no_data_found then
                v_error     := true;
                v_err_code  := 'HR2010';
                v_err_table := 'TCODOTRQ';
                v_err_filed := v_filed(10);
                exit cal_loop; 
              end;
            end if;
            v_codrem := upper(v_text(10));

--             p_dtestrt       := greatest(v_dtestrtwk, trunc(v_dtewkreq,'mm'));
--             p_dteend        := least(v_dteendwk, v_dtewkreq);
--             
            p_dtestrt       := least(v_dtestrtwk, v_dtewkreq);
            IF TO_CHAR(v_dtewkreq, 'MM') != TO_CHAR(v_dtestrt, 'MM') THEN
                v_dtestrt := TRUNC(v_dtewkreq, 'MM');
            END IF;
            p_dteend        := greatest(v_dteendwk, trunc(v_dtewkreq,'mm'));
            IF TO_CHAR(v_dtewkreq, 'MM') != TO_CHAR(p_dteend, 'MM') THEN
                p_dteend := LAST_DAY(v_dtewkreq);
            END IF;


               otbudget.get_bugget_data(v_codempid,v_dtewkreq,v_codcomp,
                            v_dtereq,v_numseq,p_dtestrt,p_dteend,
                            p_codcompbg,p_qtybudget,p_qtyothot);

             if p_codcompbg is  null 
-- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 14/03/2024 | (4449#1762)
                or nvl(p_qtybudget,0) <= 0 then
-- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 14/03/2024 | (4449#1762)
                v_error     := true;
                v_err_code  := 'MSZ001';
                v_err_table := 'tbudgetot';
                v_err_filed := v_codempid;
               exit cal_loop; 
             end if;

             if v_timbstr is not null then
                v_timdstr := null;
                v_timdend := null;
                v_timastr := null;
                v_timaend := null;
             elsif v_timdstr is not null then
                v_timbstr := null;
                v_timbend := null;
                v_timastr := null;
                v_timaend := null;
             elsif v_timastr is not null then
                v_timbstr := null;
                v_timbend := null;
                v_timdstr := null;
                v_timdend := null;
             end if;




            v_qtyminot    := std_ot.get_qtyminot(v_codempid, v_dtewkreq , v_dtewkreq ,
                null, v_timbend, v_timbstr,
                null, v_timdend, v_timdstr,
                null, v_timaend, v_timastr);

              if v_qtyminot >=  0 then
                para_allqtyotreq := para_allqtyotreq + v_qtyminot;
              end if;



            exit cal_loop;
          end loop; -- cal_loop

            -->> user18 04/03/2021
            v_qtyminb   := null;
            v_qtymind   := null;
            v_qtymina   := null;
            v_flgchglv  := 'N';
            v_staovrot := 'N';
            -- << user18 04/03/2021

    --2.insert/update --
          if not v_error then
            if p_codcomp is null then
               begin
                select codcomp into v_codcomp
                  from temploy1
                  where codempid = v_codempid;
                exception when others then
                  v_codcomp := null;
               end;
            end if;
            v_rec_tran := v_rec_tran + 1;
            v_typotreq := '1';
            begin
              select 'Y'
                into v_flg_dup
                from ttotreqst
               where dtereq         = v_dtereq
                 and codempid       = v_codempid
                 and nvl(codrem,'$%#@') = nvl(v_codrem,'$%#@')
                 and nvl(dtestrt,trunc(sysdate)) = nvl(v_dtewkreq,trunc(sysdate))
                 and nvl(dteend,trunc(sysdate))  = nvl(v_dtewkreq,trunc(sysdate))
                 and nvl(timbstr,'$%#@') = nvl(v_timbstr,'$%#@')
                 and nvl(timbend,'$%#@') = nvl(v_timbend,'$%#@')
                 and nvl(qtyminb,99999999) = nvl(v_qtyminb,99999999)
                 and nvl(timdstr,'$%#@') = nvl(v_timdstr,'$%#@')
                 and nvl(timdend,'$%#@') = nvl(v_timdend,'$%#@')
                 and nvl(qtymind,99999999) = nvl(v_qtymind,99999999)
                 and nvl(timastr,'$%#@') = nvl(v_timastr,'$%#@')
                 and nvl(timaend,'$%#@') = nvl(v_timaend,'$%#@')
                 and nvl(qtymina,99999999) = nvl(v_qtymina,99999999)
                 and nvl(flgchglv,'$%#@') = nvl(v_flgchglv,'$%#@')
                 and nvl(codcompw,'$%#@') = nvl(v_codcompw,'$%#@')
                 and rownum = 1;
            exception when no_data_found then
              v_flg_dup := 'N';
            end;
            -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 16/04/2024 | 4449#1887 (bk)
            -- if v_flg_dup = 'N' then
                --   v_numotreq := replace(std_al.gen_req('TTOT','TTOTREQST','NUMOTGEN',global_v_zyear),'-',null);
                --   v_typ_grp := '';
                -- if p_typotreq = '2' then
                --   v_typ_grp := 'G';
                -- end if;
                -- std_al.upd_req('OTRQ',v_numotreq,global_v_coduser,global_v_zyear,hcm_util.get_codcompy(v_codcomp),v_typ_grp);
            -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 16/04/2024 | 4449#1887 (bk)

            -- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 16/04/2024 | 4449#1887 (add)
            if v_flg_dup = 'N' then
                v_loop := 0;
                loop
                    v_loop := v_loop + 1;
                    v_numotreq := replace(std_al.gen_req('TTOT','TTOTREQST','NUMOTGEN',global_v_zyear,hcm_util.get_codcompy(v_codcomp),''),'-',null);
                    std_al.upd_req('TTOT',v_numotreq,global_v_coduser,global_v_zyear,hcm_util.get_codcompy(v_codcomp),'');

                    begin
                        select count(*)
                        into v_count
                        from ttotreqst
                        where numotgen = v_numotreq;
                    exception when no_data_found then
                        null;
                    end;

                    exit when (v_count = 0 or v_loop = 100);
                end loop;   
            -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 16/04/2024 | 4449#1887 (add)
--              for r_tattence in c_tattence loop

                begin
                    select nvl(qtymxotwk,0), nvl(qtymxallwk,0) , nvl(typalert,'N')
                      into v_qtymxotwk, v_qtymxallwk, v_typalert
                      from tcontrot
                     where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
                       and dteeffec = (select max(dteeffec)
                                         from tcontrot
                                        where codcompy = hcm_util.get_codcomp_level(v_codcomp, 1)
                                          and dteeffec <= sysdate);
                exception when others then
                    v_qtymxotwk     := 0;
                    v_qtymxallwk    := 0;
                    v_typalert      := 'N';
                end;

                if v_typalert <> 'N' then
                  if nvl(p_flgconfirm,'N') = 'N' then

                    p_qtyminb   := v_qtyminb;
                    p_qtymind   := v_qtymind;
                    p_qtymina   := v_qtymina;

                    p_timendb   := v_timbend;
                    p_timstrtb  := v_timbstr;

                    p_timendd   := v_timdend;
                    p_timstrtd  := v_timdstr;

                    p_timenda   := v_timaend;
                    p_timstrta  := v_timastr;

                    std_ot.get_week_ot(v_codempid, v_numotreq,v_dtewkreq,'',v_dtewkreq, v_dtewkreq,
                                       p_qtyminb, p_timendb, p_timstrtb,
                                       p_qtymind, p_timendd, p_timstrtd,
                                       p_qtymina, p_timenda, p_timstrta,
                                       global_v_codempid,
                                       a_dtestweek,a_dteenweek,
                                       a_sumwork,a_sumotreqoth,a_sumotreq,a_sumot,a_totwork,v_qtyperiod);
                    v_qtydaywk      := a_sumwork(1);
                    v_qtyminotOth   := a_sumotreqoth(1);
                    v_qtyminot      := a_sumotreq(1);
                    v_qtyot_total   := a_sumot(1);
                    v_qtytotal      := a_totwork(1);

                    if (v_qtyot_total > v_qtymxotwk) then
                        v_staovrot := 'Y';
                        if v_typalert = '1' then
                            if v_msgerror is null  then
                                v_msgerror      := replace(get_error_msg_php('ES0075',global_v_lang),'@#$%400');
                                rollback;
                                return;
                            end if;
                        elsif v_typalert = '2' then
                            v_rec_tran := v_rec_tran - 1;
                            v_rec_error     := v_rec_error + 1;
                            v_cnt           := v_cnt+1;

                            p_text(v_cnt)       := data_file;
                            p_error_code(v_cnt) := replace(get_error_msg_php('ES0075',global_v_lang),'@#$%400');
                            p_numseq(v_cnt)     := linebuf;
                        end if;
                        goto next_step_loop;
                    elsif v_qtytotal > v_qtymxallwk then
                       v_staovrot := 'Y';
                        if v_typalert = '1' then
                            if v_msgerror is null  then
                                v_msgerror      := replace(get_error_msg_php('ES0076',global_v_lang),'@#$%400');
                                rollback;
                                return;
                            end if;
                        elsif v_typalert = '2' then
                            v_rec_tran := v_rec_tran - 1;
                            v_rec_error     := v_rec_error + 1;
                            v_cnt           := v_cnt+1;

                            p_text(v_cnt)       := data_file;
                            p_error_code(v_cnt) := replace(get_error_msg_php('ES0075',global_v_lang),'@#$%400');
                            p_numseq(v_cnt)     := linebuf;
                        end if;
                        goto next_step_loop;
                    end if;
                  end if;
                end if;

                  begin
                    select nvl(max(numseq), 0) into v_numseq
                    from   ttotreq
                    where  codempid = v_codempid
                    and    dtereq   = v_dtereq;
                  exception  when others then
                    v_numseq := 0;
                  end;

                  v_numseq := nvl(v_numseq,0) + 1;

                 p_qtybudget   := nvl(round(p_qtybudget, 0), 0);
                 -- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 03/04/2024 | fix Error value / 0
                 if nvl(p_qtybudget,0) > 0 then
                    v_percentused := nvl((nvl(para_allqtyotreq,0) + nvl(p_qtyothot,0))/p_qtybudget*100,0); -- % ใช้ไป (ใช้จริงให้เปิด)
                 else
                    v_percentused := 0;
                 end if;
                 -- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 03/04/2024 | fix Error value / 0
                 v_remainhr    := nvl(p_qtybudget,0) - (nvl(para_allqtyotreq,0) + nvl(p_qtyothot,0)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ


                insert into ttotreqst(numotgen,dtereq,codinput,codempid,
                                     dtestrt,dteend,timbstr,timbend,timdstr,timdend,timastr,timaend,codrem,flgchglv,
                                     codcomp, codcompw, codcalen, remark, codcompbg, qtybudget, qtyothot, pctbguse, qtyotreq)
                              values(v_numotreq,v_dtereq,global_v_codempid,v_codempid,
                                     v_dtewkreq,v_dtewkreq,v_timbstr,v_timbend,v_timdstr,v_timdend,v_timastr,v_timaend,v_codrem,'N',
                                     v_codcomp,v_codcompw,null,'import',p_codcompbg,p_qtybudget,nvl(p_qtyothot,0),v_percentused, para_allqtyotreq);

--                for i in 1..3 loop
                  v_dtestrt	:= null; v_dteend	:= null;
--                  if i = 1 then
--                    if v_text(4) is not null then
--                      v_timstrt := v_timbstr;
--                      v_timend  := v_timbend;
--                      v_qtyminr := v_qtyminb;
--                      if v_timend > r_tattence.timendw then
--                        v_dteend := r_tattence.dteendw - 1;
--                      else
--                        v_dteend := r_tattence.dteendw;
--                      end if;
--                      if v_timstrt > v_timend then
--                        v_dtestrt := v_dteend - 1;
--                      else
--                        v_dtestrt := v_dteend;
--                      end if;
--                    else
--                      goto next_ot_type_loop;
--                    end if;
--                  elsif i = 2 then
--                    if v_text(6) is not null then
--                      v_flag    := 'N';
--                      v_timstrt := v_timdstr;
--                      v_timend  := v_timdend;
--                      v_qtyminr := v_qtymind;
--                      v_dtewkst := to_date(to_char(r_tattence.dtestrtw,'dd/mm/yyyy')||r_tattence.timstrtw,'dd/mm/yyyyhh24mi');
--                      v_dtewken := to_date(to_char(r_tattence.dteendw,'dd/mm/yyyy')||r_tattence.timendw,'dd/mm/yyyyhh24mi');
--                      v_dtestrt  := v_dtewkreq;
--                      if v_timstrt >= v_timend then
--                        v_dteend := v_dtestrt + 1;
--                      else
--                        v_dteend := v_dtestrt;
--                      end if;
--                      v_dteotst := to_date(to_char(v_dtestrt,'dd/mm/yyyy')||v_timstrt,'dd/mm/yyyyhh24mi');
--                      v_dteoten := to_date(to_char(v_dteend,'dd/mm/yyyy')||v_timend,'dd/mm/yyyyhh24mi');
--                      --
--                      if v_dtewkst between v_dteotst and v_dteoten
--                      or v_dtewken between v_dteotst and v_dteoten
--                      or v_dteotst between v_dtewkst and v_dtewken
--                      or v_dteoten between v_dtewkst and v_dtewken then
--                        v_flag := 'Y';
--                      end if;
--                      --
--                      if v_flag = 'N' then
--                        v_dtestrt  := v_dtestrt - 1;
--                        v_dteend   := v_dteend  - 1;
--                        v_dteotst  := v_dteotst - 1;
--                        v_dteoten  := v_dteoten - 1;
--
--                        if v_dtewkst between v_dteotst and v_dteoten
--                        or v_dtewken between v_dteotst and v_dteoten
--                        or v_dteotst between v_dtewkst and v_dtewken
--                        or v_dteoten between v_dtewkst and v_dtewken then
--                          v_flag := 'Y';
--                        end if;
--                      end if;
--                      --
--                      if v_flag = 'N' then
--                        v_dtestrt  := v_dtestrt + 2;
--                        v_dteend   := v_dteend  + 2;
--                      end if;
--                    else
--                      goto next_ot_type_loop;
--                    end if;
--                  elsif i = 3 then
--                    if v_text(8) is not null then
--                      v_timstrt := v_timastr;
--                      v_timend  := v_timaend;
--                      v_qtyminr := v_qtymina;
--                      if v_timstrt < r_tattence.timstrtw then
--                        v_dtestrt := r_tattence.dtestrtw + 1;
--                      else
--                        v_dtestrt := r_tattence.dtestrtw;
--                      end if;
--                      if v_timstrt > v_timend then
--                        v_dteend := v_dtestrt + 1;
--                      else
--                        v_dteend := v_dtestrt;
--                      end if;
--                    else
--                      goto next_ot_type_loop;
--                    end if;
--                  end if;

                  if nvl(v_qtyminr,0) > 0 then
                    v_timstrt    := null;
                    v_timend     := null;
                    v_dtestrt    := null;
                    v_dteend     := null;
                  end if;

                  if v_codcompw is null then
                    begin
                      select codcompw
                        into v_codcompw
                        from v_tattence_cc
                       where codempid = v_codempid
                         and dtework  = v_dtewkreq;
                    exception when no_data_found then
                      v_codcompw := null;
                    end;
                  end if;
                  begin

                    insert into ttotreq (codempid, dtereq, numseq, numotgen, codinput, codcomp, codcompw, dtestrt, dteend,
                                        timbstr, timbend, timdstr, timdend, timastr, timaend, codrem, flgchglv, remark, staovrot, staappr,
                                        routeno, codcompbg, qtybudget, qtyothot, pctbguse, qtyotreq)
                                 values(v_codempid, v_dtereq, v_numseq , v_numotreq, global_v_codempid,v_codcomp, v_codcomp, v_dtewkreq, v_dtewkreq,
                                         v_timbstr,v_timbend,v_timdstr,v_timdend,v_timastr,v_timaend,v_codrem,'N','import', v_staovrot, 'P',
                                         null, p_codcompbg,p_qtybudget,nvl(p_qtyothot,0),v_percentused, para_allqtyotreq);
                   EXCEPTION WHEN OTHERS THEN
                        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                      rollback;
                  end;

                  begin 
                   -- << KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 24/09/2023 | Modify
                    begin
                        select pctotreq1, pctotreq2, pctotreq3, pctotreq4, codappr1, codappr2, codappr3, codappr4
                        into v_pctotreq1, v_pctotreq2, v_pctotreq3, v_pctotreq4, v_codappr1, v_codappr2, v_codappr3, v_codappr4
                        From  TEMPFLOW
                        Where codapp = 'HRES6KE'
                            and  codempid = v_codempid;
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
                    if v_percentused > v_pctotreq4 then
                        v_maxstep := 4;
                    elsif v_percentused > v_pctotreq3 then
                        v_maxstep := 3;
                    elsif v_percentused > v_pctotreq2 then
                        v_maxstep := 2;
                    else 
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
                        Where codempid = v_codempid
                        And    dtereq  = v_dtereq
                        And    numseq  = v_numseq;
                    exception when others then
                        null;
                    end;
               if v_maxstep > 0 then
                for  k in 1..v_maxstep loop
                    begin
                        Insert into TEMPAPRQ(codapp,codempid,dtereq,numseq,approvno,codempap,seqno,
                                            codcompap,codposap,routeno)
                        values('HRES6KE',v_codempid,v_dtereq,v_numseq,k,v_codappr_arr(k),1,null,null,null);
                    EXCEPTION WHEN OTHERS THEN
                        param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
                        rollback;
                    end;
                end loop; 

               end if; --end if maxst


                  end;
                  commit;
                  << next_ot_type_loop >>
                  null;
--                end loop; -- for i in 1..3
                << next_step_loop >>
                null;
--              end loop; -- for r_tattence
            else
                v_rec_tran      := v_rec_tran - 1;
                v_rec_error     := v_rec_error + 1;
                v_cnt           := v_cnt+1;
                v_err_code  := 'HR2005';

                p_text(v_cnt)       := data_file;
                -- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 14/03/2024 | คุยกับพี่อ้อมให้ลบ v_err_filed
                -- p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null)||'['||v_err_filed||']'; -- >> bk
                p_error_code(v_cnt) := replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null); -->> add
                p_numseq(v_cnt)     := i;
            end if;
          else
            v_rec_error     := v_rec_error + 1;
            v_cnt           := v_cnt+1;

            p_text(v_cnt)       := data_file;
            p_error_code(v_cnt) := '['||v_err_filed||']' || ' - ' ||replace(get_error_msg_php(v_err_code,global_v_lang,v_err_table,null,false),'@#$%400',null);
            p_numseq(v_cnt)     := i;
          end if;--not v_error

          -- >> KOHU-HR2301 | 000551-Nuii-Kowit-Dev | 24/09/2023 | Modify

        end if;--v_numseq = 1
        commit;
      exception when others then
        rollback;
        param_msg_error := get_error_msg_php('HR2508',global_v_lang);
      end;
    end loop;
  end;

  procedure get_import_process(json_str_input in clob, json_str_output out clob) as
    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_result      json_object_t;
    v_error         varchar2(1000 char);
    v_flgsecu       boolean := false;
    v_rec_tran      number;
    v_rec_err       number;
    v_numseq        varchar2(1000 char);
    v_rcnt          number  := 0;
    para_qtybudget  number  := 0;
  begin
    initial_value(json_str_input);
    begin
        delete ttemprpt
         where codempid = global_v_codempid
           and codapp = 'HRAL41E';
    exception when others then
        null;
    end;
    v_report_numseq := 0;
    format_text_json(json_str_input, v_rec_tran, v_rec_err);
    --
    if param_msg_error is null then
      obj_row    := json_object_t();
      obj_result := json_object_t();
      obj_row.put('coderror', '200');
      if v_msgerror is null then
          obj_row.put('rec_tran', v_rec_tran);
          obj_row.put('rec_err', p_numseq.last);
          obj_row.put('response', replace(get_error_msg_php('HR2715',global_v_lang),'@#$%200',null));
      else
          obj_row.put('response', v_msgerror);
          obj_row.put('flg', 'warning');
      end if;
      if p_numseq.exists(p_numseq.first) then
        for i in p_numseq.first .. p_numseq.last
        loop
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('text', p_text(i));
          obj_data.put('error_code', p_error_code(i));
          obj_data.put('numseq', p_numseq(i) + 1);
          obj_result.put(to_char(v_rcnt-1),obj_data);
        end loop;
      end if;

      obj_row.put('datadisp', obj_result);

      json_str_output := obj_row.to_clob;
    else
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure ot_budget(json_str_input in clob, json_str_output out clob) as
    obj_data        json_object_t;
    obj_detail1     json_object_t;
    json_obj        json_object_t;
    json_obj2       json_object_t;
    p_codcompbg     ttotreq.codcomp%type;
    v_numotreq      ttotreq.numotreq%type;
    p_qtybudget     number;
    p_qtyothot      number;
    p_dtestrt       date;
    p_dteend        date;
    v_dtestrt       date;
    v_dteend        date;
    v_codempid      temploy1.codempid%type;

    v_sumotreqoth       number;
    v_sumotreq          number;
    v_percentused       number;
    v_remainhr          number;
    v_qtyminot          number;

    -- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 21/03/2024 | Fix issue 4449 : #1782
    v_index_codcomp     temploy1.codcomp%type;
    v_index_codcalen    temploy1.codcalen%type;
    -- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 21/03/2024 | Fix issue 4449 : #1782

    v_dtestrtwk     date;
    v_dteendwk      date;
    v_set_qtybudget number;
    v_qtyminotOth   number;
    para_allqtyotreq number;
    para_codcompbg  varchar2(100);
    para_qtybudget number;
    v_qtyothot     number;
    v_qtyothot_AL  number;
    v_qtyothot_AL2 number;
    v_qtyotreq_all number;
    v_qtyotreq number;
    v_codcompy varchar(100);
    v_flg_edit boolean := false;

  v_ttotreqst_timbstr       ttotreqst.timbstr%type;  --varchar2 4
  v_ttotreqst_timbend       ttotreqst.timbend%type;  --varchar2 4
  v_ttotreqst_timdstr       ttotreqst.timdstr%type;  --varchar2 4
  v_ttotreqst_timdend       ttotreqst.timdend%type;  --varchar2 4
  v_ttotreqst_timastr       ttotreqst.timastr%type;  --varchar2 4
  v_ttotreqst_timaend       ttotreqst.timaend%type;  --varchar2 4
  v_ttotreqst_qtyminb       varchar2(1000 char);
  v_ttotreqst_qtymind       varchar2(1000 char);
  v_ttotreqst_qtymina       varchar2(1000 char);

  begin

    initial_value(json_str_input);
    json_obj := json_object_t(json_str_input).get_object('p_param_tab2');


    v_qtyminot := 0;
    para_allqtyotreq := 0;


    for i in 0..json_obj.get_size-1 loop
          json_obj2      := hcm_util.get_json_t(json_obj,to_char(i));

            if hcm_util.get_boolean_t(json_obj2, 'flgDelete') = true then
                    v_flg_edit := true;
              end if;

             if hcm_util.get_boolean_t(json_obj2, 'flgEdit') = true then
                    v_flg_edit := true;
              end if;

              -->> Site: mo-kohu-ss2301 Author: Nuii Kowit (000551) Date updated: 2024/01/01 01:01 Comment: -
              if hcm_util.get_boolean_t(json_obj2, 'flgAdd') = true then
                    v_flg_edit := true;
              end if;
             --<< Site: mo-kohu-ss2301 Author: Nuii Kowit (000551) Date updated: 2024/01/01 01:01 Comment: -

                v_ttotreqst_qtyminb := null;
                v_ttotreqst_timbend := null;
                v_ttotreqst_timbstr := null;
                v_ttotreqst_qtymind := null;
                v_ttotreqst_timdend := null;
                v_ttotreqst_timdstr := null;
                v_ttotreqst_qtymina := null;
                v_ttotreqst_timaend := null;
                v_ttotreqst_timastr := null;



           if hcm_util.get_string_t(json_obj2,'typot') = 'B' then
                v_ttotreqst_qtyminb := hcm_util.get_string_t(json_obj2,'qtyminr');
                v_ttotreqst_timbend := replace(trim(hcm_util.get_string_t(json_obj2,'timend')),':','');
                v_ttotreqst_timbstr := replace(trim(hcm_util.get_string_t(json_obj2,'timstrt')),':','');
           elsif hcm_util.get_string_t(json_obj2,'typot') = 'D' then
                v_ttotreqst_qtymind := hcm_util.get_string_t(json_obj2,'qtyminr');
                v_ttotreqst_timdend := replace(trim(hcm_util.get_string_t(json_obj2,'timend')),':','');
                v_ttotreqst_timdstr := replace(trim(hcm_util.get_string_t(json_obj2,'timstrt')),':','');
           elsif hcm_util.get_string_t(json_obj2,'typot') = 'A' then
                v_ttotreqst_qtymina := hcm_util.get_string_t(json_obj2,'qtyminr');
                v_ttotreqst_timaend := replace(trim(hcm_util.get_string_t(json_obj2,'timend')),':','');
                v_ttotreqst_timastr := replace(trim(hcm_util.get_string_t(json_obj2,'timstrt')),':','');
           end if;


           if hcm_util.get_boolean_t(json_obj2, 'flgDelete') = false then
                v_qtyminot    := std_ot.get_qtyminot(hcm_util.get_string_t(json_obj2,'codempid'), to_date(hcm_util.get_string_t(json_obj2,'dtestrt'),'dd/mm/yyyy') , to_date(hcm_util.get_string_t(json_obj2,'dtestrt'),'dd/mm/yyyy') ,
                            hcm_util.convert_time_to_minute(v_ttotreqst_qtyminb), v_ttotreqst_timbend, v_ttotreqst_timbstr,
                            hcm_util.convert_time_to_minute(v_ttotreqst_qtymind), v_ttotreqst_timdend, v_ttotreqst_timdstr,
                            hcm_util.convert_time_to_minute(v_ttotreqst_qtymina), v_ttotreqst_timaend, v_ttotreqst_timastr);
--                            if hcm_util.get_string_t(json_obj2,'codempid') = '16020' then
--                                param_msg_error := hcm_util.get_string_t(json_obj2,'typot') || get_error_msg_php('HR2508',global_v_lang);
--                                json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--                                return;
--                            end if;
                  if v_qtyminot >=  0 then
                    para_allqtyotreq := para_allqtyotreq + v_qtyminot;
                  end if;
          end if;
        end loop;

    begin

        select codcomp, qtybudget into para_codcompbg, v_set_qtybudget
        from TBUDGETOT
        where dteyear = to_number(to_char(ttotreqst_dtestrt, 'yyyy'))
        and dtemonth = to_number(to_char(ttotreqst_dtestrt, 'mm'))
        and ttotreqst_codcompw  like codcomp || '%' 
        order by codcomp desc
        FETCH FIRST 1 ROW ONLY;
    exception when no_data_found then
      GOTO response;
      return;
     end;
--<< user22 : 14/03/2024 : KOH-HR2301 #1767 ||
--     if json_obj2 is not null then
--        v_dtestrtwk      := std_ot.get_dtestrt_period (hcm_util.get_string_t(json_obj2,'codempid') ,ttotreqst_dtestrt);
--     else 
--        v_dtestrtwk      := std_ot.get_dtestrt_period (b_index_codempid ,ttotreqst_dtestrt);
--     end if;
     --v_dtestrtwk     := std_ot.get_dtestrt_prdcomp(para_codcompbg, ttotreqst_dtestrt);  
-->> user22 : 14/03/2024 : KOH-HR2301 #1767 ||

-- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 21/03/2024 | Fix ssue 4449 : #1782
     if b_index_codempid is not null then
        begin
            select codcomp, codcalen
              into v_index_codcomp, v_index_codcalen
              from temploy1 
             where codempid = b_index_codempid;
        end;        
        v_dtestrtwk        := std_ot.get_dtestrt_period2(v_index_codcomp, v_index_codcalen, ttotreqst_dtestrt);
     else        
        v_dtestrtwk        := std_ot.get_dtestrt_period2(ttotreqst_codcomp, ttotreqst_codcalen, ttotreqst_dtestrt);
     end if;
-- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 21/03/2024 | Fix ssue 4449 : #1782

     v_dteendwk      := v_dtestrtwk + 6;
--     p_dtestrt       := greatest(v_dtestrtwk, trunc(ttotreqst_dtestrt,'mm'));
--     p_dteend        := least(v_dteendwk, ttotreqst_dtestrt);
     p_dtestrt       := least(v_dtestrtwk, ttotreqst_dtestrt);
     IF TO_CHAR(ttotreqst_dtestrt, 'MM') != TO_CHAR(p_dtestrt, 'MM') THEN
        p_dtestrt := TRUNC(ttotreqst_dtestrt, 'MM');
     END IF;
     p_dteend        := greatest(v_dteendwk, trunc(ttotreqst_dtestrt,'mm'));
     IF TO_CHAR(ttotreqst_dtestrt, 'MM') != TO_CHAR(p_dteend, 'MM') THEN
        p_dteend := LAST_DAY(ttotreqst_dtestrt);
     END IF;
     para_qtybudget  := v_set_qtybudget * (p_dteend - p_dtestrt + 1)
           	/ (last_day(ttotreqst_dtestrt) - trunc(ttotreqst_dtestrt, 'mm') + 1);


   p_codcompbg := hcm_util.get_codcomp_level(ttotreqst_codcompw,1);

    if ttotreqst_numotgen is not null and v_flg_edit = false then  
    -- mo-kohu-hr2301 | 000505-mook-adisak-dev | 05/04/2024 10:19 | refactor select into cover sa p'boy
      begin
         Select codcompbg, qtybudget, qtyothot, pctbguse , qtyotreq
         into para_codcompbg, para_qtybudget, v_qtyotreq_all, v_percentused, para_allqtyotreq
        From TTOTREQST
        Where numotgen = ttotreqst_numotgen;
      exception when no_data_found then
        para_codcompbg      := '';
        para_qtybudget      := '';
        v_qtyotreq_all      := '';
        v_percentused       := '';
        para_allqtyotreq    := '';
      end;
      -- end mo-kohu-hr2301 | 000505-mook-adisak-dev | 05/04/2024 10:19 | refactor select into cover sa p'boy

    else 
        begin
            Select nvl(sum(nvl(b.qtyminot, a.qtyotreq)), 0)
            into   v_qtyothot
            from   TTOTREQ a, TOVRTIME b
            where  a.codcompbg  = para_codcompbg
            and    a.dtestrt    between p_dtestrt and p_dteend
            and    a.staappr    not in ('C', 'N')
            and    a.numotreq   = b.numotreq (+)
            and    nvl(numotgen, '-') <> nvl(ttotreqst_numotgen, 'newreq')
            and    to_char(a.dtereq,'yyyymmdd')||lpad(a.numseq,3,'0') 
                   = (Select max(to_char(c.dtereq,'yyyymmdd')||lpad(c.numseq,3,'0'))
                      From   TTOTREQ c
                      Where  a.codempid = c.codempid            
                      And    a.dtestrt  = c.dtestrt
                      and    c.staappr  not in ('C', 'N') --user36 KOHU 02/04/2024
                      );
          end;

          begin
            Select nvl(sum(nvl(b.qtyminot, a.qtyotreq)), 0)
            into    v_qtyothot_AL
            from   TOTREQD a, TOVRTIME b
            where  otbudget.get_codcompbg(nvl(a.codcompw, a.codcomp), a.dtewkreq) = para_codcompbg 
            and    a.dtewkreq     between p_dtestrt and p_dteend
            and    a.numotreq    = b.numotreq (+)
            and    a.codempid    = b.codempid (+)
            and    a.dtewkreq    = b.dtework (+)
            and    a.typot       = b.typot (+)
            and    not exists (select c.numotreq 
                from  TTOTREQ c 
                where c.numotreq = a.numotreq)
            and    a.numotreq     =  (Select max(c.numotreq)
                                               From   TOTREQD c
                                               Where a.codempid = c.codempid   
                                               and    a.dtewkreq   = c.dtewkreq     
                                               and    a.typot         = c.typot);      
          end;


        begin
            Select nvl(sum(qtyminot), 0)
            into    v_qtyothot_AL2
            from   TOVRTIME 
            where otbudget.get_codcompbg(nvl(codcompw, codcomp), dtework) = para_codcompbg 
            and    dtework     between p_dtestrt and p_dteend
            and    numotreq  is null;

        end;

            v_qtyotreq_all := v_qtyothot + v_qtyothot_AL + v_qtyothot_AL2;
    end if;


    <<response>>
    obj_data := json_object_t();
    obj_data.put('coderror', '200');



    -- if json_obj.get_size > 0 then
            para_qtybudget := round(para_qtybudget, 0);

             if nvl(para_qtybudget,0) > 0 then --user36 KOHU #1823 27/03/2024
                v_percentused := nvl((nvl(para_allqtyotreq,0) + nvl(v_qtyotreq_all,0))/para_qtybudget*100,0); -- % ใช้ไป (ใช้จริงให้เปิด)
             else
                v_percentused := 0;
             end if;
             v_remainhr     := nvl(para_qtybudget,0) - (nvl(para_allqtyotreq,0) + nvl(v_qtyotreq_all,0)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ

        obj_data.put('codcompbg', para_codcompbg); -- รหัส งบประมาณของหน่วยงาน
        obj_data.put('departmentbudget', get_tcenter_name(para_codcompbg, global_v_lang));                                          -- งบประมาณของหน่วยงาน
        obj_data.put('wkbudgetdate',to_char(p_dtestrt,'dd/mm/yyyy')||' - '||to_char(p_dteend,'dd/mm/yyyy'));                    -- งบประมาณประจำสัปดาห์ วันที่
        obj_data.put('wkbudget',hcm_util.convert_minute_to_hour(nvl(para_qtybudget,0)));                                           -- งบประมาณประจำสัปดาห์ 
        obj_data.put('requesthr',hcm_util.convert_minute_to_hour(nvl(para_allqtyotreq,0)));                                           -- จำนวนชั่วโมงล่วงเวลาในใบคำขอนี้
        obj_data.put('otherrequesthr',hcm_util.convert_minute_to_hour(nvl(v_qtyotreq_all,0)));                                      -- จำนวนชั่วโมงล่วงเวลาในใบคำขออื่น
        obj_data.put('totalhr',hcm_util.convert_minute_to_hour(nvl(para_allqtyotreq,0) + nvl(v_qtyotreq_all,0)));    
        if v_remainhr < 0 then
            obj_data.put('remainhr',hcm_util.convert_minute_to_hour(0)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ (ถ้าติดลบให้แสดง 0)
        else
            obj_data.put('remainhr',hcm_util.convert_minute_to_hour(v_remainhr)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ
        end if;

        obj_data.put('percentused',  round(v_percentused)); -- % ใช้ไป-- user22 : 01/04/2024 : KOHU-HR2301 || obj_data.put('percentused',  round(v_percentused,2)); -- % ใช้ไป
        if v_percentused <= 100 or v_percentused is null then
            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'240'));
        elsif v_percentused > 100 then
            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'230'));
        else
            obj_data.put('overbudgetstatus',get_label_name('HRMS6LU1',global_v_lang,'9999'));
        end if;

    -- else 

    --     obj_data.put('codcompbg',''); -- รหัส งบประมาณของหน่วยงาน
    --     obj_data.put('departmentbudget', '');                                          -- งบประมาณของหน่วยงาน
    --     obj_data.put('wkbudgetdate','');                    -- งบประมาณประจำสัปดาห์ วันที่
    --     obj_data.put('wkbudget','');                                           -- งบประมาณประจำสัปดาห์ 
    --     obj_data.put('requesthr','');                                           -- จำนวนชั่วโมงล่วงเวลาในใบคำขอนี้
    --     obj_data.put('otherrequesthr','');                                      -- จำนวนชั่วโมงล่วงเวลาในใบคำขออื่น
    --     obj_data.put('totalhr','');    
    --     obj_data.put('remainhr',''); -- จำนวนชั่วโมงของงบประมาณคงเหลือ
    --     obj_data.put('percentused', ''); 
    --     obj_data.put('overbudgetstatus','');
    -- end if;



    json_str_output := obj_data.to_clob;
--
--    param_msg_error := p_dtework || get_error_msg_php('HR2508',global_v_lang);
--    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
--     return;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
   end ot_budget;
   -- >>


    procedure ot_budget_check(json_str in clob, qtubudget out number, qtyothot out number , percentused out number, codcompbg out varchar2) as
       json_obj        json_object_t := json_object_t(json_str);
      json_obj2      json_object_t;
    p_codcompbg     ttotreq.codcomp%type;
    v_numotreq      ttotreq.numotreq%type;
    p_qtybudget     number;
    p_qtyothot      number;
    p_dtestrt       date;
    p_dteend        date;
    v_dtestrt       date;
    v_dteend        date;

    v_sumotreqoth       number;
    v_sumotreq          number;
    v_percentused       number;
    v_remainhr          number;
    v_qtyminot          number;


    v_dtestrtwk     date;
    v_dteendwk      date;
    v_set_qtybudget number;
    v_qtyminotOth   number;
    para_allqtyotreq number;
    para_codcompbg  varchar2(100);
    para_qtybudget number;
    v_qtyothot     number;
    v_qtyothot_AL  number;
    v_qtyothot_AL2 number;
    v_qtyotreq_all number;
    v_codcompy varchar(100);


  v_ttotreqst_timbstr       ttotreqst.timbstr%type;  --varchar2 4
  v_ttotreqst_timbend       ttotreqst.timbend%type;  --varchar2 4
  v_ttotreqst_timdstr       ttotreqst.timdstr%type;  --varchar2 4
  v_ttotreqst_timdend       ttotreqst.timdend%type;  --varchar2 4
  v_ttotreqst_timastr       ttotreqst.timastr%type;  --varchar2 4
  v_ttotreqst_timaend       ttotreqst.timaend%type;  --varchar2 4
  v_ttotreqst_qtyminb       varchar2(1000 char);
  v_ttotreqst_qtymind       varchar2(1000 char);
  v_ttotreqst_qtymina       varchar2(1000 char);
  v_index_codcomp           varchar2(40);-- user22 : 01/04/2024 : KOHU-HR2301 || 
  v_index_codcalen          varchar2(40);-- user22 : 01/04/2024 : KOHU-HR2301 || 

     begin
       --json_obj := json_str_input;


    v_qtyminot := 0;
    para_allqtyotreq := 0;
    percentused := 0;


    for i in 0..json_obj.get_size-1 loop
      json_obj2      := hcm_util.get_json_t(json_obj,to_char(i));

                v_ttotreqst_qtyminb := null;
                v_ttotreqst_timbend := null;
                v_ttotreqst_timbstr := null;
                v_ttotreqst_qtymind := null;
                v_ttotreqst_timdend := null;
                v_ttotreqst_timdstr := null;
                v_ttotreqst_qtymina := null;
                v_ttotreqst_timaend := null;
                v_ttotreqst_timastr := null;



           if hcm_util.get_string_t(json_obj2,'typot') = 'B' then
                v_ttotreqst_qtyminb := hcm_util.get_string_t(json_obj2,'qtyminr');
                v_ttotreqst_timbend := replace(trim(hcm_util.get_string_t(json_obj2,'timend')),':','');
                v_ttotreqst_timbstr := replace(trim(hcm_util.get_string_t(json_obj2,'timstrt')),':','');
           elsif hcm_util.get_string_t(json_obj2,'typot') = 'D' then
                v_ttotreqst_qtymind := hcm_util.get_string_t(json_obj2,'qtyminr');
                v_ttotreqst_timdend := replace(trim(hcm_util.get_string_t(json_obj2,'timend')),':','');
                v_ttotreqst_timdstr := replace(trim(hcm_util.get_string_t(json_obj2,'timstrt')),':','');
           elsif hcm_util.get_string_t(json_obj2,'typot') = 'A' then
                v_ttotreqst_qtymina := hcm_util.get_string_t(json_obj2,'qtyminr');
                v_ttotreqst_timaend := replace(trim(hcm_util.get_string_t(json_obj2,'timend')),':','');
                v_ttotreqst_timastr := replace(trim(hcm_util.get_string_t(json_obj2,'timstrt')),':','');
           end if;


            v_qtyminot    := std_ot.get_qtyminot(hcm_util.get_string_t(json_obj2,'codempid'), to_date(hcm_util.get_string_t(json_obj2,'dtestrt'),'dd/mm/yyyy') , to_date(hcm_util.get_string_t(json_obj2,'dtestrt'),'dd/mm/yyyy') ,
                        hcm_util.convert_time_to_minute(v_ttotreqst_qtyminb), v_ttotreqst_timbend, v_ttotreqst_timbstr,
                        hcm_util.convert_time_to_minute(v_ttotreqst_qtymind), v_ttotreqst_timdend, v_ttotreqst_timdstr,
                        hcm_util.convert_time_to_minute(v_ttotreqst_qtymina), v_ttotreqst_timaend, v_ttotreqst_timastr);

              if v_qtyminot >=  0 then
                para_allqtyotreq := para_allqtyotreq + v_qtyminot;
              end if;
    end loop;



            begin
                select codcomp, qtybudget into para_codcompbg, v_set_qtybudget
                from TBUDGETOT
                where dteyear = to_number(to_char(ttotreqst_dtestrt, 'yyyy'))
                and dtemonth = to_number(to_char(ttotreqst_dtestrt, 'mm'))
                and ttotreqst_codcompw like codcomp || '%'
                order by codcomp desc -- user22 : 28/03/2024 : KOHU-HR2301 ||
                FETCH FIRST 1 ROW ONLY;
            exception when no_data_found then
              param_msg_error := get_error_msg_php('MSZ001',global_v_lang);
              return;
            end;

            --<<user36 KOHU #1823 27/03/2024
            if nvl(v_set_qtybudget,0) <= 0 then
              param_msg_error := get_error_msg_php('MSZ001',global_v_lang);
              return;
            end if;
            -->>user36 KOHU #1823 27/03/2024


--<< user22 : 01/04/2024 : KOHU-HR2301 || 
            if ttotreqst_codempid is not null then
              begin
                select codcomp, codcalen
                  into v_index_codcomp, v_index_codcalen
                  from temploy1 
                 where codempid = ttotreqst_codempid;
              end;        
              v_dtestrtwk := std_ot.get_dtestrt_period2(v_index_codcomp, v_index_codcalen, ttotreqst_dtestrt);
            else        
              v_dtestrtwk := std_ot.get_dtestrt_period2(ttotreqst_codcomp, ttotreqst_codcalen, ttotreqst_dtestrt);
            end if;
              --v_dtestrtwk      := std_ot.get_dtestrt_period (hcm_util.get_string_t(json_obj2,'codempid') ,ttotreqst_dtestrt);
              --v_dtestrtwk     := std_ot.get_dtestrt_prdcomp(para_codcompbg, ttotreqst_dtestrt); 
-->> user22 : 01/04/2024 : KOHU-HR2301 || 
--insert_temp2('YYY','YYY',1,ttotreqst_codempid,v_index_codcomp,v_index_codcalen,ttotreqst_codcomp,ttotreqst_codcalen,to_char(ttotreqst_dtestrt,'dd/mm/yyyy'),to_char(v_dtestrtwk,'dd/mm/yyyy'),null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
                 v_dteendwk      := v_dtestrtwk + 6;
--                 p_dtestrt       := greatest(v_dtestrtwk, trunc(ttotreqst_dtestrt,'mm'));
--                 p_dteend        := least(v_dteendwk, ttotreqst_dtestrt);
--                 para_qtybudget  := v_set_qtybudget * (p_dteend - p_dtestrt + 1)
--                        / (last_day(ttotreqst_dtestrt) - trunc(ttotreqst_dtestrt, 'mm') + 1);

                p_dtestrt       := least(v_dtestrtwk, ttotreqst_dtestrt);
                IF TO_CHAR(ttotreqst_dtestrt, 'MM') != TO_CHAR(p_dtestrt, 'MM') THEN
                    p_dtestrt := TRUNC(ttotreqst_dtestrt, 'MM');
                END IF;
                p_dteend        := greatest(v_dteendwk, trunc(ttotreqst_dtestrt,'mm'));
                IF TO_CHAR(ttotreqst_dtestrt, 'MM') != TO_CHAR(p_dteend, 'MM') THEN
                    p_dteend := LAST_DAY(ttotreqst_dtestrt);
                END IF;
                para_qtybudget  := v_set_qtybudget * (p_dteend - p_dtestrt + 1)
                    / (last_day(ttotreqst_dtestrt) - trunc(ttotreqst_dtestrt, 'mm') + 1);

-- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 03/04/2024 | Update Code For Review ( Add Begin & end )
            begin
                Select nvl(sum(nvl(b.qtyminot, a.qtyotreq)), 0)
                into   v_qtyothot
                from   TTOTREQ a, TOVRTIME b
                where  a.codcompbg  = para_codcompbg
                and    a.dtestrt    between p_dtestrt and p_dteend
                and    a.staappr    not in ('C', 'N')
                and    a.numotreq   = b.numotreq (+)
                and    nvl(numotgen, '-') <> nvl(ttotreqst_numotgen, 'newreq')
                and    to_char(a.dtereq,'yyyymmdd')||lpad(a.numseq,3,'0') 
                       = (Select max(to_char(c.dtereq,'yyyymmdd')||lpad(c.numseq,3,'0'))
                          From   TTOTREQ c
                          Where  a.codempid = c.codempid            
                          And    a.dtestrt  = c.dtestrt
                          and    c.staappr  not in ('C', 'N') --user36 KOHU 02/04/2024
                          );
            exception when no_data_found then
                v_qtyothot := 0;
            end;

            begin
                Select nvl(sum(nvl(b.qtyminot, a.qtyotreq)), 0)
                into    v_qtyothot_AL
                from   TOTREQD a, TOVRTIME b
                where  otbudget.get_codcompbg(nvl(a.codcompw, a.codcomp), a.dtewkreq) = para_codcompbg 
                and    a.dtewkreq     between p_dtestrt and p_dteend
                and    a.numotreq    = b.numotreq (+)
                and    a.codempid    = b.codempid (+)
                and    a.dtewkreq    = b.dtework (+)
                and    a.typot       = b.typot (+)
                and    not exists (select c.numotreq 
                    from  TTOTREQ c 
                    where c.numotreq = a.numotreq)
                and    a.numotreq     =  (Select max(c.numotreq)
                                                   From   TOTREQD c
                                                   Where a.codempid = c.codempid   
                                                   and    a.dtewkreq   = c.dtewkreq     
                                                   and    a.typot         = c.typot);      
             exception when no_data_found then
                v_qtyothot_AL := 0;
             end;

            begin
                Select nvl(sum(qtyminot), 0)
                into    v_qtyothot_AL2
                from   TOVRTIME 
                where otbudget.get_codcompbg(nvl(codcompw, codcomp), dtework) = para_codcompbg 
                and    dtework     between p_dtestrt and p_dteend
                and    numotreq  is null;
            exception when no_data_found then
                v_qtyothot_AL2 := 0;
             end;
-- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 03/04/2024 | Update Code For Review ( Add Begin & end )
                v_qtyotreq_all := v_qtyothot + v_qtyothot_AL + v_qtyothot_AL2;

                v_remainhr     := nvl(para_qtybudget,0) - (nvl(para_allqtyotreq,0) + nvl(v_qtyotreq_all,0)); -- จำนวนชั่วโมงของงบประมาณคงเหลือ

                qtubudget    := para_allqtyotreq;

                qtyothot       := v_qtyotreq_all;

                if nvl(para_qtybudget,0) > 0 then --user36 KOHU #1823 27/03/2024
                    percentused := nvl((nvl(para_allqtyotreq,0) + nvl(v_qtyotreq_all,0))/para_qtybudget*100,0); -- % ใช้ไป (ใช้จริงให้เปิด)
                else
                    percentused := 0;
                end if;

        end;

-- << KOHU-HR2301 | 000504-Tae-Surachai-Dev | 09/12/2023 | Modify
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
    where codempid = ttotreqst_codempid
       and codapp  = v_codapp;

    cursor c_tempaprq is
        select * 
        from   tempaprq
        where codempid = ttotreqst_codempid
            and    dtereq  = ttotreqst_dtestrt
            and    numseq  = b_index_numseq
            and    codapp  = v_codapp
        order by approvno asc;

   begin

    initial_value(json_str_input);
--      ttotreqst_percentused := 61;
    v_check := '';
    if p_staappr = 'P' or p_staappr is null then
        for r in c_tempflow loop    

            v_check := 'Y';
            if ttotreqst_percentused > r.pctotreq4 then
                v_maxstep := 4;
            elsif ttotreqst_percentused > r.pctotreq3 then
                v_maxstep := 3;
            elsif ttotreqst_percentused > r.pctotreq2 then
                v_maxstep := 2;
            else   
                v_maxstep := 1;
            end if;
            v_codappr := array_t();
            v_codappr(1) := null;
            v_codappr(2) := null;
            v_codappr(3) := null;
            v_codappr(4) := null;
            If v_maxstep = 1 then
                v_codappr(1) := r.codappr1;	
            Elsif v_maxstep = 2 then
                v_codappr(1) := r.codappr1;
                v_codappr(2) := r.codappr2;
            Elsif v_maxstep = 3 then
                v_codappr(1) := r.codappr1;
                v_codappr(2) := r.codappr2;
                v_codappr(3) := r.codappr3;
            Elsif v_maxstep = 4 then
                v_codappr(1) := r.codappr1;
                v_codappr(2) := r.codappr2;
                v_codappr(3) := r.codappr3;
                v_codappr(4) := r.codappr4;
            end if;	

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
            -- comment -- v_count := v_count + 1; -- KOHU-SS2301 | 000537-Boy-Apisit-Dev | 21/03/2024 | Error Program #1794
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
-- >> KOHU-HR2301 | 000504-Tae-Surachai-Dev | 09/12/2023 | Modify

end;

/
