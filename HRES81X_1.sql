--------------------------------------------------------
--  DDL for Package Body HRES81X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES81X" is
-- last update: 23/01/2017 17:10
  procedure clear_array_data is
    arr_temp arr;
  begin
    income_arr            := arr_temp;
    deduc_arr             := arr_temp;
    ytd_amount_arr        := arr_temp;
    block_amtinc          := arr_temp;
    block_amtinc_e        := arr_temp;
    block_codinc          := arr_temp;
    block1_amtpay         := arr_temp;
    block1_amtpay_e       := arr_temp;
    block1_codded         := arr_temp;
    block2_qtysmot        := arr_temp;
    block2_rteot          := arr_temp;
    block2_desot          := arr_temp;
    block2_hrs            := arr_temp;
    block3_suminc         := arr_temp;
    block3_sumpay         := arr_temp;
    block3_sumnet         := arr_temp;
    block3_sumnet_e       := arr_temp;
    block3_day1           := arr_temp;
    block3_day2           := arr_temp;
    block3_vacation       := arr_temp;
    block3_qtywrk         := arr_temp;
    block3_salary         := arr_temp;
    block3_amtcalt        := arr_temp;
    block3_amttax         := arr_temp;
    block3_amtsoc         := arr_temp;
    block3_amtpf          := arr_temp;
  end;

  procedure initial_value(json_str in clob) is
    json_obj  json_object_t;
  begin
    clear_array_data;

    json_obj              := json_object_t(json_str);

    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid     := hcm_util.get_string_t(json_obj,'p_codempid');

    b_index_codempid      := hcm_util.get_string_t(json_obj,'p_codempid');    -- 26/02/2019
    b_index_period        := hcm_util.get_string_t(json_obj,'p_period');
    b_index_month         := hcm_util.get_string_t(json_obj,'p_month');
    b_index_year          := hcm_util.get_string_t(json_obj,'p_year');
    b_index_acc_id        := 0;
    b_index_bank          := '';
    b_index_paymentdate   := null;
    b_index_periodal      := '';
    b_index_periodpy      := '';
    ctrl_label_di_v240    := substr(get_label_name('HRES81XCM',global_v_lang,250),1,600);
    ctrl_label_di_v250    := substr(get_label_name('HRES81XCM',global_v_lang,260),1,600);
    ctrl_label_di_v260    := substr(get_label_name('HRES81XCM',global_v_lang,270),1,600);
    ctrl_label_lbothinc   := '';
    ctrl_label_amtothinc  := '';
    ctrl_label_lbothpay   := '';
    ctrl_label_amtothpay  := '';
    v_row                 := 0;
    param_total_income    := 0;
    param_total_deduc     := 0;
    param_total_income_e  := 0;
    param_total_deduc_e   := 0;
    parameter_qtyavgwk    := null;
    param_msg_error       := null;
    global_v_coduser      := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd      := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang         := hcm_util.get_string_t(json_obj,'p_lang');

    block_amtinc(1)   := null;
    block_amtinc_e(1) := null;
    block_codinc(1)   := null;
    block1_amtpay(1)   := null;
    block1_amtpay_e(1) := null;
    block1_codded(1)   := null;
    block2_qtysmot(1)  := null;
    block2_rteot(1)    := null;
    block2_desot(1)    := null;
    block2_hrs(1)      := null;
    block3_suminc(1)      := null;
    block3_sumpay(1)      := null;
    block3_sumnet(1)      := null;
    block3_sumnet_e(1)    := null;
    block3_day1(1)        := null;
    block3_day2(1)        := null;
    block3_vacation(1)    := null;
    block3_qtywrk(1)      := null;
    block3_salary(1)      := null;
    block3_amtcalt(1)     := null;
    block3_amttax(1)      := null;
    block3_amtsoc(1)      := null;
    block3_amtpf(1)       := null;
    global_v_zyear      := 0;

  end initial_value;
  --
  procedure get_period(json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_row        number := 0;
    cursor c1 is
      select distinct(numperiod) as numperiod
      from ttaxcur 
      where codempid = global_v_codempid
      order by numperiod;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    v_row   := 0;
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numperiod', to_char(r1.numperiod));
      obj_row.put(to_char(v_row),obj_data);
      v_row := v_row+1;
    end loop; 
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_period;

  procedure get_new_period(json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_row        number := 0;
    cursor c1 is
      select distinct(numperiod) as numperiod
      from ttaxcur 
      where codempid = global_v_codempid
      and dtemthpay = b_index_month 
      and dteyrepay = b_index_year
      order by numperiod;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    v_row   := 0;
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('numperiod', to_char(r1.numperiod));
      obj_row.put(to_char(v_row),obj_data);
      v_row := v_row+1;
    end loop; 
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_new_period;

  procedure get_latest(json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_row        number := 0;
    v_numperiod  ttaxcur.numperiod%type;
    v_dtemthpay  ttaxcur.dtemthpay%type;
    v_dteyrepay  ttaxcur.dteyrepay%type;

  begin
    initial_value(json_str_input);
    begin
      select numperiod, dtemthpay, dteyrepay
        into v_numperiod, v_dtemthpay, v_dteyrepay
        from ttaxcur 
       where codempid = global_v_codempid
         and rownum = 1
       order by dteyrepay desc;
    exception when no_data_found then null;
    end;
    obj_data := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('numperiod', v_numperiod);
    obj_data.put('dtemthpay', v_dtemthpay);
    obj_data.put('dteyrepay', v_dteyrepay);
    json_str_output := obj_data.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_latest;
  --
  procedure get_dteyrepay(json_str_input in clob, json_str_output out clob) is
    obj_data     json_object_t;
    obj_row      json_object_t;
    v_row        number := 0;
    cursor c1 is
      select distinct(dteyrepay) 
        from ttaxmas  
       where codempid = global_v_codempid 
    order by dteyrepay;
  begin
    initial_value(json_str_input);
    obj_row := json_object_t();
    v_row   := 0;
    for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dteyrepay', r1.dteyrepay);
      obj_row.put(to_char(v_row),obj_data);
      v_row := v_row+1;
    end loop; 
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_dteyrepay;
  --
  procedure get_payslip(json_str_input in clob, json_str_output out clob) is
  begin
      initial_value(json_str_input);
      clear_ttemprpt;
      gen_payslip(json_str_output);
  end get_payslip;

  procedure gen_payslip(json_str_output out clob) is
    v_tfrmslip tfrmslip%rowtype;
    v_codinc	  varchar2(10 char);
    v_suminc	  number:=0;
    v_sumpay	  number:=0;
    v_suminc_e  number:=0;
    v_sumpay_e  number:=0;
    v_sumothinc	number:=0;
    v_sumothpay	number:=0;
    v_sumothinc_e number:=0;
    v_sumothpay_e number:=0;
    v_sumnet_e  number:=0;
    v_amtcalt   number;
    v_amttax 	  number;
    v_amtsoc 	  number;
    v_amtpf  	  number;
    v_qtyvacat  number;
    v_codcomp	 	tcenter.codcomp%type;
    v_typpayroll varchar(10 char);
    v_qtyot      number ;

    v_amtcal    number ;
    v_amtincl   number ;
    v_amtincc   number ;
    v_amtexpl   number ;
    v_amtexpc   number ;
    v_amtgrstx  number ;

    v_dtepaymt  tdtepay.dtepaymt%type;
    v_dtemthpay tdtepay.dtemthpay%type;
    v_dteyrepay tdtepay.dteyrepay%type;
    v_dteend    tdtepay.dteend%type;
    v_dtestrt   tdtepay.dtestrt%type;
    v_year			number;

    v_dteend1		date;
    v_work			varchar2(100 char);
    v_dtecycst	date;
    v_dtecycen	date;

    v_dte_st		date;
    v_dte_en		date;
    v_ot        number ;

    v_numbank2  ttaxcur.numbank2%type;
    v_codbank1  ttaxcur.codbank2%type;
    v_codbank2  ttaxcur.codbank2%type;
    v_unitcal1	tcontpmd.unitcal1%type;
    v_codwage	  tcontpms.codincom1%type;
    v_qtypayda	tothinc.qtypayda%type;
    v_qtypayhr	tothinc.qtypayhr%type;
    v_qtypaysc	tothinc.qtypaysc%type;
    v_qtywork		ttaxcur.qtywork%type;
    v_dteeffec	tcontral.dteeffec%type;
    v_codempmt	temploy1.codempmt%type;
    v_codlate   varchar2(10);
    v_dtestrate	date ;
    V_dteenrate	date ;
    v_amtmoney  number ;
    v_amthur    number ;
    v_amtday    number ;
    v_amtmth    number ;

    v_msg     varchar2(4000 char);
    v_dtewatch	date;
    v_timwatch	varchar2(4 char);

    cursor c1 is
        select rtesmot,sum(qtysmot) qtysmot
        from		totsumd
        where		codempid 	= b_index_codempid
        and			dteyrepay	=	b_index_year-global_v_zyear
        and			dtemthpay	=	b_index_month
        and			numperiod	= b_index_period
        group by rtesmot 
        order by rtesmot  ;

    cursor c_incom is
            select  distinct typpayr
            from		tsincexp
            where		substr(typpayr,4,1) = '1'
            and		 	codempid	  	= b_index_codempid
            and		 	dteyrepay 		= b_index_year - global_v_zyear
            and		 	dtemthpay 		= b_index_month
            and			numperiod			=	b_index_period
            and		 	flgslip 			= '1'
            order by typpayr;
    cursor c_deduc is
            select  distinct typpayr
            from		tsincexp
            where		substr(typpayr,4,1) = '3'
            and		 	codempid	  	= b_index_codempid
            and		 	dteyrepay 		= b_index_year - global_v_zyear
            and		 	dtemthpay 		= b_index_month
            and			numperiod			=	b_index_period
            and		 	flgslip 			= '1'
            order by typpayr;
  begin



      ctrl_label_lbothinc	:=	null;
      ctrl_label_amtothinc	:=	null;
      ctrl_label_lbothpay	:=	null;
      ctrl_label_amtothpay	:=	null;

      begin
        select  numbank,codbank ,
                numbank2,codbank2,nvl(stddec(amtincom1,codempid,global_v_chken),0)
        into 		b_index_acc_id,v_codbank1,
                v_numbank2,v_codbank2,v_amtmoney
        from 	 	ttaxcur
        where  	codempid  = b_index_codempid
        and     dteyrepay = b_index_year - global_v_zyear
        and     dtemthpay = b_index_month
        and     numperiod = b_index_period ;
      exception when no_data_found then
        b_index_acc_id	:= null;  v_numbank2  := null;
        v_codbank1      := null;  v_codbank2  := null;
        b_index_paymentdate	:=	null;
        param_msg_error := get_error_msg_php('ES0001', global_v_lang);

      end;

      b_index_bank := get_tcodec_name('TCODBANK',v_codbank1,global_v_lang);
      if v_numbank2 is not null then
         b_index_acc_id := b_index_acc_id||','||v_numbank2;
      end if;

      if v_codbank2 is not null then
         if v_codbank1 <> v_codbank2 then
            b_index_bank  := b_index_bank||' , '||get_tcodec_name('TCODBANK',v_codbank2,global_v_lang);
         end if;
      end if;

      begin
        select 	codcomp,typpayroll into	v_codcomp,v_typpayroll
        from		ttaxcur
        where		codempid	  	= b_index_codempid
        and		 	dteyrepay 		= b_index_year - global_v_zyear
        and		 	dtemthpay 		= b_index_month
        and			numperiod			=	b_index_period  ;
      exception when no_data_found then
        v_codcomp			:= null;
        v_typpayroll	:= null;
      end;

      begin
        select dtepaymt ,to_char(dtestrt,'dd/mm/yyyy')||' - '||to_char(dteend,'dd/mm/yyyy')
          into b_index_paymentdate,b_index_periodpy
          from tdtepay
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and typpayroll = v_typpayroll
           and numperiod = b_index_period
           and dtemthpay = b_index_month
           and dteyrepay = b_index_year - global_v_zyear
           and rownum <= 1;
      exception when no_data_found then null;
--<< user22 : 06/06/2019 : SMTL620332 ||
        begin
          select dtepaymt
            into b_index_paymentdate
            from tdtepay2
           where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
             and typpayroll = v_typpayroll
             and numperiod = b_index_period
             and dtemthpay = b_index_month
             and dteyrepay = b_index_year - global_v_zyear
             and rownum <= 1;
        exception when no_data_found then null;
        end;
-->> user22 : 06/06/2019 : SMTL620332 ||
      end;

      begin
        select codlate  into v_codlate
        from   tcontal2
        where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
        and    dteeffec = (select max(dteeffec)
                           from   tcontal2
                           where  dteeffec <= sysdate);
      exception when no_data_found then
        v_codlate := null;
      end;

      begin
        select codempmt
        into	 v_codempmt
        from   temploy1
        where  codempid = b_index_codempid;
      exception when no_data_found then
        v_codempmt := null;
      end;

      begin
        select dtestrt,dteend into v_dtestrate,v_dteenrate
        from   tpriodal
        where  codcompy   = hcm_util.get_codcomp_level(v_codcomp,1)
        and    typpayroll = v_typpayroll
        and    codpay     = v_codlate
        and		 dteyrepay  = (b_index_year - global_v_zyear)
        and		 dtemthpay  =  b_index_month
        and 	 numperiod  =  b_index_period;
        b_index_periodal := to_char(v_dtestrate,'dd/mm/yyyy')||' - '||to_char(v_dteenrate,'dd/mm/yyyy') ;
      exception when no_data_found then
        v_dtestrate	 := null;
        v_dteenrate	 := null;
      end ;

      get_wage_income(hcm_util.get_codcomp_level(v_codcomp,1),v_codempmt,v_amtmoney,0,0,0,0,
                      0,0,0,0,0,v_amthur,v_amtday,v_amtmth);
      block3_salary(1) := v_amtmth;

      --<< Modify MER 23/09/2017
      begin
        select hcm_util.get_codcomp_level(v_codcomp,1),get_tcenter_name(hcm_util.get_codcomp_level(v_codcomp,1),global_v_lang)
          into v_codcompny,v_desc_codcompny
          from dual;
      end;
      -->> Modify MER 23/09/2017

      /*
      --Modify 20/07/2552
      if b_index_paymentdate is not null and b_index_paymentdate > trunc(sysdate) then
        param_msg_error := msg_error(null,'ES0001','b_index_period');
      end if;	*/

      -->>User8:Nirantee: HRMS590277 : 23/06/2016 16:40
      --<<user36 STA4-1701 14/11/2017
       begin
        select 	dtewatch,timwatch into v_dtewatch,v_timwatch
        from (select 	dtewatch,timwatch
              from 	tdtepay
              where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
              and typpayroll = v_typpayroll
              and numperiod = b_index_period
              and dtemthpay = b_index_month
              and dteyrepay = (b_index_year - global_v_zyear)
              union
              select 	dtewatch,timwatch
              from 	tdtepay2
              where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
              and typpayroll = v_typpayroll
              and numperiod = b_index_period
              and dtemthpay = b_index_month
              and dteyrepay = (b_index_year - global_v_zyear))
        where rownum = 1;

      exception when no_data_found then
        v_dtewatch := null;
        v_timwatch := null;
      end ;

      if v_dtewatch is null then
        v_dtewatch := b_index_paymentdate ;
      else
        v_dtewatch := to_date(to_char(v_dtewatch,'dd/mm/yyyy')||nvl(v_timwatch,'0000'),'dd/mm/yyyyhh24mi') ;
      end if;

      if v_dtewatch is not null then
        if sysdate < v_dtewatch then
          param_msg_error := get_error_msg_php('ES0001', global_v_lang,b_index_period);
        end if;
      end if;

      /*
      if v_dtewatch is not null and v_timwatch is null  then
        if to_number(to_char(sysdate,'yyyymmddhh24mi')) <= to_number(to_char(v_dtewatch,'yyyymmddhh24mi')) then
           msg_error(null,'ES0001','b_index.period');
        end if;
      end if;
      */
      --<<User8:Nirantee: HRMS590277 : 20/06/2016 16:40

      ---------------------------------------------------------------------------------------------------------
      if param_msg_error is null then

        v_row := 1;
        for i in c_incom loop
          get_amtinc(i.typpayr) ;
          v_row := v_row + 1;
        end loop;

        v_row := 1;
        for i in c_deduc loop
          get_amtded(i.typpayr) ;
          v_row := v_row + 1;
        end loop;

        v_row := 1;
        for i in c1 loop
          block2_qtysmot(v_row) := trunc(i.qtysmot / 60) ||':'||lpad(mod(i.qtysmot , 60),2,'0') ;
          block2_rteot(v_row)	 := i.rtesmot;
          block2_desot(v_row)	 := ctrl_label_di_v240;
          block2_hrs(v_row)  	 := ctrl_label_di_v250;
          v_row := v_row + 1;
        end loop;

        v_row := 1;
        loop
          if block_amtinc(v_row) is not null then
            v_suminc		:= v_suminc + to_number(block_amtinc(v_row));
          end if;
        exit when v_row = block_amtinc.count;
          v_row := v_row + 1;
        end loop;

        v_row := 1;
        loop
          if block_amtinc_e(v_row) is not null then
            v_suminc_e	:= v_suminc_e + to_number(block_amtinc_e(v_row));
          end if;
        exit when v_row = block_amtinc_e.count;
          v_row := v_row + 1;
        end loop;

        v_row := 1;
        loop
          if block1_amtpay(v_row) is not null then
            v_sumpay		:= v_sumpay + to_number(block1_amtpay(v_row));
          end if;
        exit when v_row = block1_amtpay.count;
          v_row := v_row + 1;
        end loop;

        v_row := 1;
        loop
          if block1_amtpay_e(v_row) is not null then
            v_sumpay_e	:= v_sumpay_e + to_number(block1_amtpay_e(v_row));
          end if;
        exit when v_row = block1_amtpay_e.count;
          v_row := v_row + 1;
        end loop;
        v_sumnet_e			:= v_suminc_e - v_sumpay_e;
        block3_suminc(1)    := v_suminc;
        block3_sumpay(1)    := v_sumpay;
        if block3_sumpay(1) is not null then
          block3_salary(1)    := v_amtmth ;
        end if;
        block3_sumnet(1)		:= block3_suminc(1)	- block3_sumpay(1);
        block3_sumnet_e(1)	:= v_sumnet_e;
        block3_day1(1)   	  := ctrl_label_di_v260;
        block3_day2(1)   	  := ctrl_label_di_v260;

        begin
          select dtepaymt,dtemthpay,dteyrepay,dteend,dtestrt
            into v_dtepaymt,v_dtemthpay,v_dteyrepay,v_dteend,v_dtestrt
            from tdtepay
           where codcompy   = hcm_util.get_codcomp_level(v_codcomp,1)
             and typpayroll = v_typpayroll
             and dteyrepay  = (b_index_year - global_v_zyear)
             and dtemthpay  = b_index_month
             and numperiod  = b_index_period;
        exception when no_data_found then
          v_dtepaymt  := null;
          v_dtemthpay := null;
          v_dteyrepay := null;
          v_dteend    := null;
          v_dtestrt   := null;
--<< user22 : 06/06/2019 : SMTL620332 ||
          begin
            select dtepaymt,dtemthpay,dteyrepay
              into v_dtepaymt,v_dtemthpay,v_dteyrepay
              from tdtepay2
             where codcompy   = hcm_util.get_codcomp_level(v_codcomp,1)
               and typpayroll = v_typpayroll
               and dteyrepay  = (b_index_year - global_v_zyear)
               and dtemthpay  = b_index_month
               and numperiod  = b_index_period;
          exception when no_data_found then null;
          end;
-->> user22 : 06/06/2019 : SMTL620332 ||
        end;

        begin
          select sum(qtyvacat-qtydayle)
          into	 v_qtyvacat
          from	 tleavsum
          where	 codempid = b_index_codempid
          and		 dteyear  = b_index_year
          and		 staleave = 'V';
        exception when no_data_found then
          v_qtyvacat := null;
        end;
        v_dte_st :=  v_dtestrt;
        v_dte_en :=  v_dteend;

        begin
          select unitcal1
            into v_unitcal1
            from tcontpmd
           where codempmt = v_codempmt
             and codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
             and dteeffec = (select max(dteeffec)
                               from tcontpmd
                              where dteeffec <= sysdate
                                and codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
                                and codempmt = v_codempmt);
        exception when no_data_found then
          v_unitcal1 := null;
        end;
        if v_unitcal1 in ('M','Y') then
          begin
            select qtywork
              into v_qtywork
              from ttaxcur
             where codempid  = b_index_codempid
               and dteyrepay = (b_index_year - global_v_zyear)
               and dtemthpay = b_index_month
               and numperiod = b_index_period;
               /*select count(*)
                 into v_qtywork
                 from tattence
                where codempid= b_index_codempid
                  and dtework between v_dtestrt and v_dteend
                  and typwork <> 'H';*/
          exception when no_data_found then
            v_qtywork := 0;
          end;
          if v_qtywork > 0 then
            v_work := v_qtywork;
          else
            v_work := null;
          end if;
        else
          begin
            select dteeffec
              into v_dteeffec
              from tcontral
             where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
               and dteeffec = (select max(dteeffec)
                                 from tcontral
                                where codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
                                  and dteeffec <= trunc(sysdate));
          exception when no_data_found then
            v_dteeffec := null;
          end;

          begin
            select codincom1
              into v_codwage
              from tcontpms
             where codcompy = hcm_util.get_codcomp_level(v_codcomp,1) AND dteeffec = (select max(dteeffec)
                                 from tcontpms
                                where codcompy = hcm_util.get_codcomp_level(v_codcomp,1) AND dteeffec <= v_dteeffec);
          exception when no_data_found then
            v_codwage := null;
          end;
          begin
            select qtypayda,qtypayhr,qtypaysc
              into v_qtypayda,v_qtypayhr,v_qtypaysc
              from tothinc
             where codempid  = b_index_codempid
               and dteyrepay = (b_index_year - global_v_zyear)
               and dtemthpay = b_index_month
               and numperiod = b_index_period
               and codpay    = v_codwage;
            exception when no_data_found then
              v_qtypayda := 0;
              v_qtypayhr := 0;
              v_qtypaysc := 0;
          end;
            v_work := v_qtypayda||':'||v_qtypayhr||':'||v_qtypaysc;
        end if;
        ----------------------------------------------------------------
        -- head report
        begin
          select qtyavgwk
          into	 parameter_qtyavgwk
          from 	 tcontral
          where	 dteeffec = (select max(dteeffec) from tcontral where dteeffec < sysdate)
          and		 rownum 	= 1;
        exception when no_data_found then
          parameter_qtyavgwk := null;
        end;

--          block3_vacation(1) := v_qtyvacat;--cal_dhm_concat(v_qtyvacat);
          block3_vacation(1) := cal_dhm_concat(v_qtyvacat);

          block3_qtywrk(1)		:= v_work;

        -- blockil Other
        begin
          select sum(stddec(amtcal,codempid,global_v_chken)),
                 sum(stddec(amtincl,codempid,global_v_chken)),
                 sum(stddec(amtincc,codempid,global_v_chken)),
                 sum(stddec(amtexpl,codempid,global_v_chken)),
                 sum(stddec(amtexpc,codempid,global_v_chken)),
                 sum(stddec(amtgrstx,codempid,global_v_chken)),

                 sum(stddec(amttax,codempid,global_v_chken)),
                 sum(stddec(amtprove,codempid,global_v_chken)),
                 sum(stddec(amtsoca,codempid,global_v_chken))
          into	 v_amtcal,v_amtincl,v_amtincc,v_amtexpl,v_amtexpc,v_amtgrstx,
                 v_amttax,v_amtsoc,v_amtpf
          from 	 ttaxcur
          where  codempid  = b_index_codempid
          and		 ((dtemthpay between 1 and b_index_month - 1) or (dtemthpay = b_index_month and numperiod <= b_index_period))
          and		 dteyrepay = (b_index_year - global_v_zyear);
        exception when no_data_found then
          v_amtcalt := 0; v_amttax := 0;	v_amtsoc := 0; v_amtpf  := 0;
        end;
--        block3_amtcalt(1)	:= v_amtcal + v_amtincl + v_amtincc - v_amtexpl - v_amtexpc ;
        block3_amtcalt(1)	:= v_amtcal + v_amtincl + v_amtincc + v_amtgrstx - v_amtexpl - v_amtexpc ;
        block3_amttax(1)	:= v_amttax;
        block3_amtsoc(1)	:= v_amtsoc;
        block3_amtpf(1)		:= v_amtpf;
      end if;

    json_str_output := resp_json_str;

  exception when others then
    param_msg_error := DBMS_UTILITY.FORMAT_ERROR_STACK||' '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_payslip;


  procedure get_amtinc(p_codinc in varchar2) is
    v_amtinc		number;
    v_amtinc_e	number;
  begin
    if p_codinc is not null then
      begin
          select    nvl(sum(stddec(amtpay,codempid,global_v_chken) * decode(typincexp,'3',1,'4',-1,'5',-1,'6',-1,1)),0) amtpay,
                    nvl(sum(stddec(amtpay_e,codempid,global_v_chken) * decode(typincexp,'3',1,'4',-1,'5',-1,'6',-1,1)),0) amtpay_e
            into    v_amtinc,v_amtinc_e
            from	tsincexp
           where	typpayr     = p_codinc
             and    codempid    = b_index_codempid
             and	dteyrepay   = b_index_year - global_v_zyear
             and	dtemthpay 	= b_index_month
             and	numperiod	= b_index_period
             and	flgslip 	= '1' ;
      exception when no_data_found then
          v_amtinc		:=	null;
          v_amtinc_e	:=	null;
      end;

      block_amtinc(v_row)       := v_amtinc;
      block_amtinc_e(v_row)     := v_amtinc_e;
      block_codinc(v_row)       := get_tcodec_name('TCODSLIP',p_codinc,global_v_lang);

    end if;
  end get_amtinc;

  procedure get_amtded(p_codded in varchar2) is
    v_amtpay		number;
    v_amtpay_e	number;
  begin
    if p_codded is not null then
      begin
          select  nvl(sum(nvl(stddec(amtpay,codempid,global_v_chken),0) * decode(typincexp,'1',1,'2',1,'3',1,'4',-1,'5',-1,'6',-1,0)),0) amtpay,
                  nvl(sum(nvl(stddec(amtpay_e,codempid,global_v_chken),0) * decode(typincexp,'1',1,'2',1,'3',1,'4',-1,'5',-1,'6',-1,0)),0) amtpay_e
          into		v_amtpay,	v_amtpay_e
          from		tsincexp
          where		typpayr				= p_codded
          and		 	codempid	  	= b_index_codempid
          and		 	dteyrepay 		= b_index_year - global_v_zyear
          and		 	dtemthpay 		= b_index_month
          and			numperiod			=	b_index_period
          and		 	flgslip 			= '1' ;
      exception when no_data_found then
          v_amtpay		:=	null;
          v_amtpay_e	:=	null;
      end;

      block1_amtpay(v_row)		:=	v_amtpay * -1;
      block1_amtpay_e(v_row)	:=	v_amtpay_e * -1;
      block1_codded(v_row)	:= get_tcodec_name('TCODSLIP',p_codded,global_v_lang);

    end if;
  end get_amtded;

  function cal_dhm_concat (p_qtyday		in  number) return varchar2 is
    v_min 	number(2);
    v_hour  number(2);
    v_day   number;
    v_num   number;
    v_dhm		varchar2(10);
  begin
    if p_qtyday is not null and p_qtyday > 0 then
      v_day		:= trunc(p_qtyday / 1);
      v_num 	:= round(mod((p_qtyday * parameter_qtyavgwk),parameter_qtyavgwk),0);
      v_hour	:= trunc(v_num / 60);
      v_min		:= mod(v_num,60);
      v_dhm   := to_char(v_day)||':'||
                 lpad(to_char(v_hour),2,'0')||':'||
                 lpad(to_char(v_min),2,'0');
      --v_dhm		:= 	to_char(v_day);
    else
      v_dhm := null;
    end if;
    return(v_dhm);
  end cal_dhm_concat;

  function resp_json_str return clob is
    block_index_obj     json_object_t;
    block_obj           json_object_t;
    block1_obj          json_object_t;
    block2_obj          json_object_t;
    block3_obj          json_object_t;
    block_amtinc_obj    json_object_t;
    block_amtinc_e_obj  json_object_t;
    block_codinc_obj    json_object_t;
    block1_amtpay_obj   json_object_t;
    block1_amtpay_e_obj json_object_t;
    block1_codded_obj   json_object_t;
    block2_qtysmot_obj  json_object_t;
    block2_rteot_obj    json_object_t;
    block2_desot_obj    json_object_t;
    block2_hrs_obj      json_object_t;
    resp_obj            json_object_t;
    v_count             number;
    v_numseq            number := 0;
    v_suminc            varchar2(100 char);
    v_sumpay            varchar2(100 char);
    v_sumnet            varchar2(100 char);
    v_sumnet_e          varchar2(100 char);
    v_salary            varchar2(100 char);
    v_amtcalt           varchar2(100 char);
    v_amttax            varchar2(100 char);
    v_amtsoc            varchar2(100 char);
    v_amtpf             varchar2(100 char);
    v_dteend			date;
 	v_dtestrt			date;
    v_typpayroll        temploy1.typpayroll%type;
  begin
    block_index_obj     := json_object_t();
    block_obj           := json_object_t();
    block1_obj          := json_object_t();
    block2_obj          := json_object_t();
    block3_obj          := json_object_t();
    resp_obj            := json_object_t();

    if block_amtinc(1) is not null then
      block_amtinc_obj    := json_object_t();
      block_amtinc_e_obj  := json_object_t();
      block_codinc_obj    := json_object_t();
      v_count := 0;

      for i in 1..block_amtinc.count loop
        if block_amtinc(i) <> 0 then
            v_count := v_count + 1;
            block_amtinc_obj.put(to_char(v_count),to_char(block_amtinc(i),'fm999,999,999,990.90'));
            block_amtinc_e_obj.put(to_char(v_count),to_char(block_amtinc_e(i),'fm999,999,999,990.90'));
            block_codinc_obj.put(to_char(v_count),block_codinc(i));
            insert_ttemprpt_items('HRES81X2',block_codinc(i),to_char(to_number(block_amtinc(i)),'fm999,999,999,990.00'),'');
        end if;
      end loop;
    end if;
    if block1_amtpay(1) is not null then
      block1_amtpay_obj   := json_object_t();
      block1_amtpay_e_obj := json_object_t();
      block1_codded_obj   := json_object_t();
      v_count := 0;
      for i in 1..block1_amtpay.count loop
        if block1_amtpay(i) <> 0 then
            v_count := v_count + 1;
            block1_amtpay_obj.put(to_char(v_count),to_char(block1_amtpay(i),'fm999,999,999,990.90'));
            block1_amtpay_e_obj.put(to_char(v_count),to_char(block1_amtpay_e(i),'fm999,999,999,990.90'));
            block1_codded_obj.put(to_char(v_count),block1_codded(i));
            insert_ttemprpt_items('HRES81X3',block1_codded(i),to_char(to_number(block1_amtpay(i)),'fm999,999,999,990.00'),'');
        end if;
      end loop;
    end if;
    if block2_qtysmot(1) is not null then
      block2_qtysmot_obj  := json_object_t();
      for i in 1..block2_qtysmot.count loop
        block2_qtysmot_obj.put(to_char(i),block2_qtysmot(i));
      end loop;
    end if;
    if block2_rteot(1) is not null then
      block2_rteot_obj    := json_object_t();
      for i in 1..block2_rteot.count loop
        block2_rteot_obj.put(to_char(i),block2_rteot(i));
        insert_ttemprpt_items('HRES81X4',block2_rteot(i),block2_qtysmot(i),get_label_name('HRPY55XC3',global_v_lang,140));
      end loop;
    end if;
    if block2_desot(1) is not null then
      block2_desot_obj    := json_object_t();
      for i in 1..block2_desot.count loop
        block2_desot_obj.put(to_char(i),block2_desot(i));
      end loop;
    end if;
    if block2_hrs(1) is not null then
      block2_hrs_obj      := json_object_t();
      for i in 1..block2_hrs.count loop
        block2_hrs_obj.put(to_char(i),block2_hrs(i));
      end loop;
    end if;
    --
    begin
      select 	codpos,codcomp,typpayroll
      into 		b_index_codpos,b_index_codcomp,v_typpayroll
      from 	 	temploy1
      where  	codempid = b_index_codempid;
    exception when no_data_found then
      null ;
    end;

     begin
       select dteend,dtestrt
         into v_dteend,v_dtestrt
         from tdtepay
        where codcompy = hcm_util.get_codcomp_level(b_index_codcomp,'1')
          and typpayroll = v_typpayroll
          and dteyrepay = b_index_year
          and dtemthpay = b_index_month
          and numperiod = b_index_period;
      exception when no_data_found then
        v_dteend    := null;
        v_dtestrt   := null;
    end;
    --
    block_index_obj.put('codempid',b_index_codempid);
    block_index_obj.put('desc_codempid',get_temploy_name(b_index_codempid,global_v_lang));
    block_index_obj.put('desc_codpos',get_tpostn_name(b_index_codpos,global_v_lang));
    block_index_obj.put('desc_codcomp',get_tcenter_name(b_index_codcomp,global_v_lang));
    block_index_obj.put('paymentdate',nvl(to_char(b_index_paymentdate,'dd/mm/yyyy'),'-'));
    block_index_obj.put('acc_id',nvl(b_index_acc_id,'-'));
    block_index_obj.put('desc_codbank',nvl(b_index_bank,'-'));
    block_index_obj.put('periodpy',nvl(b_index_periodpy,'-'));
    block_index_obj.put('periodal',nvl(b_index_periodal,'-'));
    block_index_obj.put('numperiod',b_index_period);
    block_index_obj.put('dtemthpay',b_index_month);
    block_index_obj.put('dteyrepay',b_index_year);
    block_index_obj.put('codcompny',v_codcompny);
    block_index_obj.put('desc_codcompny',v_desc_codcompny);
    block_index_obj.put('dtestrt',hcm_util.get_date_config(v_dtestrt) || ' - ' || hcm_util.get_date_config(v_dteend));

    block3_obj.put('amtinc',block_amtinc_obj);
    block3_obj.put('amtinc_e',block_amtinc_e_obj);
    block3_obj.put('codinc',block_codinc_obj);

    block3_obj.put('amtpay',block1_amtpay_obj);
    block3_obj.put('amtpay_e',block1_amtpay_e_obj);
    block3_obj.put('codded',block1_codded_obj);

    block2_obj.put('qtysmot',block2_qtysmot_obj);
    block2_obj.put('rteot',block2_rteot_obj);
    block2_obj.put('desot',block2_desot_obj);
    block2_obj.put('hrs',block2_hrs_obj);
    block2_obj.put('day1',block3_day1(1));
    block2_obj.put('day2',block3_day2(1));
    block2_obj.put('qtywrk',block3_qtywrk(1));
    block2_obj.put('vacation',block3_vacation(1));

    v_suminc    := to_char(block3_suminc(1),'fm999,999,999,990.90');
    v_sumpay    := to_char(block3_sumpay(1),'fm999,999,999,990.90');
    v_sumnet    := to_char(block3_sumnet(1),'fm999,999,999,990.90');
    v_sumnet_e  := to_char(block3_sumnet_e(1),'fm999,999,999,990.90');
    v_salary    := to_char(block3_salary(1),'fm999,999,999,990.90');
    v_amtcalt   := to_char(block3_amtcalt(1),'fm999,999,999,990.90');
    v_amttax    := to_char(block3_amttax(1),'fm999,999,999,990.90');
    v_amtsoc    := to_char(block3_amtsoc(1),'fm999,999,999,990.90');
    v_amtpf     := to_char(block3_amtpf(1),'fm999,999,999,990.90');

    block3_obj.put('suminc',v_suminc);
    block3_obj.put('sumpay',v_sumpay);
    block3_obj.put('sumnet',v_sumnet);
    block3_obj.put('sumnet_e',v_sumnet_e);
    block3_obj.put('salary',v_salary);

    block1_obj.put('amtcalt',v_amtcalt);
    block1_obj.put('amttax',v_amttax);
    block1_obj.put('amtsoc',v_amtsoc);
    block1_obj.put('amtpf',v_amtpf);

    resp_obj.put('coderror','200');
    resp_obj.put('desc_coderror',' ');
    resp_obj.put('httpcode',' ');

    resp_obj.put('employee',block_index_obj);
    resp_obj.put('salary',block3_obj);
    resp_obj.put('others',block2_obj);
    resp_obj.put('ytdAmount',block1_obj);
    resp_obj.put('block',block_obj);

    -- insert temprpt
    insert_ttemprpt('HRES81X1',block_index_obj, block3_obj, block1_obj, block3_qtywrk(1), block3_vacation(1));
    insert_ttemprpt_items('HRES81X5',get_label_name('HRES81X4',global_v_lang,20),v_amtcalt,get_label_name('HRES81X4',global_v_lang,60));
    insert_ttemprpt_items('HRES81X5',get_label_name('HRES81X4',global_v_lang,30),v_amttax,get_label_name('HRES81X4',global_v_lang,60));
    insert_ttemprpt_items('HRES81X5',get_label_name('HRES81X4',global_v_lang,40),v_amtsoc,get_label_name('HRES81X4',global_v_lang,60));
    insert_ttemprpt_items('HRES81X5',get_label_name('HRES81X4',global_v_lang,50),v_amtpf,get_label_name('HRES81X4',global_v_lang,60));
    -- insert temprpt
    if param_msg_error is not null then
      resp_obj.put('flgData','N');
      param_msg_error := replace(param_msg_error,'@#$%400','');
    else
      resp_obj.put('flgData','Y');
    end if;

    resp_obj.put('msg',param_msg_error);

    return resp_obj.to_clob;
  end;

  procedure initial_report(json_str in clob) is
    json_obj        json_object_t;
  begin
    global_v_chken      := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_numperiod         := hcm_util.get_string_t(json_obj, 'p_numperiod');
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj, 'p_dteyrepay');
    p_codapp            := hcm_util.get_string_t(json_obj, 'p_codapp');
   hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_report;

  procedure clear_ttemprpt is
  begin
    begin
      delete
        from ttemprpt
       where codempid = b_index_codempid
         and codapp like p_codapp || '%';
    exception when others then
      null;
    end;
  end clear_ttemprpt;

  procedure gen_report(json_str_input in clob,json_str_output out clob) is
    json_output       clob;
  begin
    initial_report(json_str_input);
    isInsertReport := true;
    if param_msg_error is null then
      clear_ttemprpt;
    end if;

    if param_msg_error is null then
      param_msg_error := get_error_msg_php('HR2715',global_v_lang);
      commit;
    else
      rollback;
    end if;
    json_str_output := get_response_message(null,param_msg_error,global_v_lang);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end gen_report;

  procedure insert_ttemprpt(r_codapp in varchar2, obj_data in json_object_t,obj_data2 in json_object_t,obj_data3 in json_object_t,
                            v_qtywrk in varchar2,v_qtyvacat in varchar2) is

    v_item1             ttemprpt.item1%type;    v_item2             ttemprpt.item2%type;    v_item3             ttemprpt.item3%type;
    v_item4             ttemprpt.item4%type;    v_item5             ttemprpt.item5%type;    v_item6             ttemprpt.item6%type;
    v_item7             ttemprpt.item7%type;    v_item8             ttemprpt.item8%type;    v_item9             ttemprpt.item9%type;
    v_item10            ttemprpt.item10%type;   v_item11            ttemprpt.item11%type;   v_item12            ttemprpt.item12%type;
    v_item13            ttemprpt.item13%type;   v_item14            ttemprpt.item14%type;   v_item15            ttemprpt.item15%type;
    v_item16            ttemprpt.item16%type;   v_item17            ttemprpt.item17%type;   v_item18            ttemprpt.item18%type;
    v_item19            ttemprpt.item19%type;   v_item20            ttemprpt.item20%type;   v_item21            ttemprpt.item21%type;
    v_item22            ttemprpt.item22%type;   v_item23            ttemprpt.item23%type;   v_item24            ttemprpt.item24%type;
    v_item25            ttemprpt.item25%type;   v_item26            ttemprpt.item26%type;   v_item27            ttemprpt.item27%type;
    v_item28            ttemprpt.item28%type;   v_item29            ttemprpt.item29%type;   v_item30            ttemprpt.item30%type;
    v_temp        varchar(10 char) := '';
    v_dtepay_temp date;
    v_numseq      number := 0;

  begin
    v_item1  := hcm_util.get_string_t(obj_data, 'codempid') || ' - ' ||hcm_util.get_string_t(obj_data, 'desc_codempid');
    v_item2  := hcm_util.get_string_t(obj_data, 'desc_codcomp');
    v_item3  := hcm_util.get_string_t(obj_data, 'numperiod');
    v_item4  := hcm_util.get_string_t(obj_data, 'dtemthpay');
    v_item5  := hcm_util.get_string_t(obj_data, 'dteyrepay');
--    v_item5  := to_char(add_months(to_date(v_item5,'yyyy'),543*12),'yyyy');  -- 736
    v_item5  := hcm_util.get_year_config(v_item5);  -- 736
    v_item6  := hcm_util.get_string_t(obj_data, 'acc_id');
    v_item7  := hcm_util.get_string_t(obj_data, 'desc_codbank');
    v_item8  := hcm_util.get_string_t(obj_data, 'paymentdate');
    if v_item8 <> '-' then
--      v_item8 :=  to_char(add_months(to_date(v_item8,'dd/mm/yyyy'),543*12),'dd/mm/yyyy');  -- 736
      v_item8 := hcm_util.get_date_config(to_date(v_item8,'dd/mm/yyyy'));  -- 736
    end if;
    v_item9  := v_qtyvacat;
    v_item10  := v_qtywrk;
    v_item11 := hcm_util.get_string_t(obj_data3, 'amtcalt');
    v_item12 := hcm_util.get_string_t(obj_data3, 'amttax');
    v_item13 := hcm_util.get_string_t(obj_data3, 'amtpf');
    v_item14 := hcm_util.get_string_t(obj_data3, 'amtsoc');

    v_item16 := hcm_util.get_string_t(obj_data2, 'suminc');
    v_item17 := hcm_util.get_string_t(obj_data2, 'sumpay');
    v_item18 := hcm_util.get_string_t(obj_data2, 'sumnet');
    v_item19 := hcm_util.get_string_t(obj_data2, 'sumnet_e');
    v_item20 := to_char((sysdate+ 7/24),'dd/mm/yyyy HH24:MI:SS');
    v_item21 := b_index_period;
    v_item22 := b_index_month;
    v_item23 := b_index_year;
    v_item26 := b_index_codempid;
    v_item30 := hcm_util.get_string_t(obj_data, 'dtestrt');

    begin
      begin
        select nvl(max(numseq),0) into v_numseq
          from ttemprpt
         where codempid = b_index_codempid
           and codapp = r_codapp;
      end;
      v_numseq := v_numseq + 1;
      insert
        into ttemprpt
          (
            codempid, codapp, numseq,
            item1,  item2,  item3,  item4,  item5,  item6,
            item7,  item8,  item9,  item10, item11, item12, 
            item13, item14, item15, item16, item17, item18,
            item19, item20, item21, item22, item23, item24,
            item25, item26, item27, item28, item29, item30
          )
      values
          (
            b_index_codempid, r_codapp, v_numseq,
            v_item1,  v_item2, v_item3, get_nammthful(v_item4, global_v_lang), v_item5, v_item6,
            v_item7,  v_item8, v_item9, v_item10, v_item11, v_item12,
            v_item13, v_item14, v_item15, v_item16, v_item17, v_item18,
            v_item19, v_item20, v_item21, v_item22, v_item23, v_item24,
            v_item25, v_item26, v_item27, v_item28, v_item29, v_item30
          );
    exception when dup_val_on_index then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end insert_ttemprpt;
--
  procedure insert_ttemprpt_items(r_codapp in varchar2, v_cod in varchar2, v_des in varchar2, v_unt in varchar2) is

    v_item1             ttemprpt.item1%type;
    v_item2             ttemprpt.item2%type;
    v_item3             ttemprpt.item3%type;    v_item21            ttemprpt.item21%type;
    v_item22            ttemprpt.item22%type;   v_item23            ttemprpt.item23%type;   v_item24            ttemprpt.item24%type;
    v_item25            ttemprpt.item25%type;   v_item26            ttemprpt.item26%type;   v_item27            ttemprpt.item27%type;
    v_item28            ttemprpt.item28%type;   v_item29            ttemprpt.item29%type;   v_item30            ttemprpt.item30%type;
    v_numseq number := 0;
  begin

    v_item1  := v_cod;
    v_item2  := v_des;
    v_item3  := v_unt;
--    v_item24 := nvl(p_codslip,' ');
--    v_item25 := nvl(p_codcomp,' ');
--    v_item26 := nvl(p_codempid_temp,' ');
--    v_item27 := nvl(p_typpayroll,' ');
--    v_item28 := nvl(p_dtepay_temp,' ');
--    v_item29 := nvl(p_codempst,' ');

    v_item21 := b_index_period;
    v_item22 := b_index_month;
    v_item23 := b_index_year;
    v_item26 := b_index_codempid;



    begin
      begin
        select nvl(max(numseq),0) into v_numseq
          from ttemprpt
         where codempid = b_index_codempid
           and codapp = r_codapp;
      end;
      v_numseq := v_numseq + 1;
      insert
        into ttemprpt
          (
            codempid, codapp, numseq,
            item1,  item2 ,item3, item21, item22, item23, item24,
            item25, item26, item27, item28, item29
          )
      values
          (
            b_index_codempid, r_codapp, v_numseq,
            v_item1,  v_item2, v_item3, v_item21, v_item22, v_item23, v_item24,
            v_item25, v_item26, v_item27, v_item28, v_item29
          );
    exception when dup_val_on_index then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      return;
    end;
  end insert_ttemprpt_items;
end hres81x;

/
