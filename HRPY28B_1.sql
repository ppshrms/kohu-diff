--------------------------------------------------------
--  DDL for Package Body HRPY28B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY28B" as

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));
    p_typpay            := to_number(hcm_util.get_string_t(json_obj,'p_typpay'));
    p_typtran           := to_number(hcm_util.get_string_t(json_obj,'p_typtran'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  end initial_value;

  procedure check_number (p_number in out varchar2,p_case in varchar2,v_error3 out varchar2)is
    v_number 		number;
  begin
    if p_case = '1' then
      begin
        v_number := to_number(p_number);
        if (p_number is null) then
          p_number := '99';
        else
          p_number := p_number;
        end if;
        v_error3 := null;
      exception when others then
        v_error3 := '4';
        p_number := p_number;
      end ;
    elsif p_case = '2' then
      begin
        v_number := to_number(p_number);
        if (p_number is null) then
          p_number := '0';
        else
          p_number := p_number;
        end if;
        v_error3 := null;
      exception when others then
        v_error3 := '4';
        p_number := p_number;
      end ;
    elsif p_case = '3' then
      begin
        v_number := to_number(p_number);
        v_error3 := null;
        if (p_number is null) or (to_number(p_number) = 0) then
          p_number := '0.00';
          v_error3 := '3';
        else
          p_number := to_char(to_number(p_number),'fm9,999,999,990.00');
        end if;
      exception when others then
        v_error3 := '4';
        p_number := p_number;
      end ;
    end if;
  end check_number;

  procedure check_is_number (p_number in varchar2, isnumber out boolean,v_amtpay2 out number)is
    v_number 		number :=null;
  begin
      begin
        if (INSTR(p_number,',') = 0) then
            v_number := to_number(p_number);
        else
            v_number := to_number(p_number,'fm9,999,999,990.00');
        end if;
        v_amtpay2 := v_number;
        isnumber := true;
      exception when others then
        isnumber := false;
      end;
  end check_is_number;

  function check_dup_tothinc2 (v_codempid in varchar2,v_dteyrepay in number,v_dtemthpay in number,
                              v_numperiod in number,v_codpay in varchar2,v_codcompw in varchar2) return boolean is
    v_codempid_tmp	  varchar2(50);
  begin
    begin
      select codempid
        into v_codempid_tmp
        from tothinc2
       where codempid  = v_codempid
         and dteyrepay = v_dteyrepay - global_v_zyear
         and dtemthpay = v_dtemthpay
         and numperiod = v_numperiod
         and codpay    = v_codpay
         and codcompw  = v_codcompw;
      return(false) ;
    exception when no_data_found then
      return(true) ;
    end;
  end check_dup_tothinc2;

  function check_dup_tothinc (v_codempid in varchar2,v_dteyrepay in number,v_dtemthpay in number,
                             v_numperiod in number, v_codpay in varchar2) return boolean is
    v_codempid_tmp	  varchar2(50);
  begin
    begin
      select codempid
        into v_codempid_tmp
        from tothinc
       where codempid  = v_codempid
         and dteyrepay = v_dteyrepay - global_v_zyear
         and dtemthpay = v_dtemthpay
         and numperiod = v_numperiod
         and codpay    = upper(v_codpay);
        return(false) ;
    exception when no_data_found then
        return(true) ;
    end;
  end check_dup_tothinc;

  function check_dup_totsumd (v_codempid in varchar2,v_dteyrepay in number,v_dtemthpay in number,
                              v_numperiod in number,v_rtesmot in number,v_codcompw in varchar2) return boolean is
    v_codempid_tmp	  varchar2(50);
  begin
    begin
      select codempid
        into v_codempid_tmp
        from totsumd
       where codempid  = v_codempid
         and dteyrepay = v_dteyrepay - global_v_zyear
         and dtemthpay = v_dtemthpay
         and numperiod = v_numperiod
         and rtesmot   = round(v_rtesmot,2)
         and codcompw  = v_codcompw;
      return(false) ;
    exception when no_data_found then
      return(true) ;
    end;
  end check_dup_totsumd;

  function check_dup_totsum (v_codempid in varchar2,v_dteyrepay in number,v_dtemthpay in number,
                             v_numperiod in number) return boolean is
    v_codempid_tmp	  varchar2(50);
  begin
    begin
      select codempid
        into v_codempid_tmp
        from totsum
       where codempid = v_codempid
         and dteyrepay = v_dteyrepay - global_v_zyear
         and dtemthpay = v_dtemthpay
         and numperiod = v_numperiod;
        return(false) ;
    exception when no_data_found then
        return(true) ;
    end;
  end check_dup_totsum;

  function chk_emp_processed(p_codempid in varchar2) return varchar2 is
    v_codempid	  varchar2(50);
  begin
    begin
      select codempid
        into v_codempid
        from ttemprpt
       where item1 		= p_codempid
         and codapp 	= 'HRPY28B'
         and codempid	= global_v_coduser
         and rownum 	= 1;
      return 'Y';
    exception when no_data_found then
      return 'N';
    end;
  end;

  function get_amtotpay (v_rtesmot number,v_qtysmot number,v_amtothr number) return number is
    v_amtotpay  			number;
  begin
    v_amtotpay  := (v_rtesmot * v_qtysmot) * (v_amtothr / 60);
    return(v_amtotpay);
  end get_amtotpay;

  procedure get_ratepay (p_codempid temploy1.codempid%type,p_rateday out number,p_ratehr out number) is
    v_codcomp    tcenter.codcomp%type;
    v_codempmt   varchar2(4);

    type v_char is table of varchar2(20) index by binary_integer;
         p_amtincom       v_char;

    type v_number is table of number index by binary_integer;
         v_amtincom       v_number;

    v_sumhur      number;
    v_sumday      number;
    v_summth      number;
    v_codcurr     varchar2(6);
    v_codcurr_e   varchar2(6);
    v_rate 			  number:=0;

  begin
    for i in 1..10 loop
        p_amtincom(i) := null;
        v_amtincom(i) := null;
    end loop;

    begin
      select hcm_util.get_codcomp_level(a.codcomp,'1'),a.codempmt,
             b.amtincom1,b.amtincom2,b.amtincom3,
             b.amtincom4,b.amtincom5,b.amtincom6,
             b.amtincom7,b.amtincom8,b.amtincom9,
             b.amtincom10,codcurr
        into v_codcomp,v_codempmt,
             p_amtincom(1),p_amtincom(2),p_amtincom(3),
             p_amtincom(4),p_amtincom(5),p_amtincom(6),
             p_amtincom(7),p_amtincom(8),p_amtincom(9),
             p_amtincom(10),v_codcurr_e
        from temploy1 a,temploy3 b
       where a.codempid = b.codempid
         and a.codempid = p_codempid;
    exception when no_data_found then null;
    end;

    for i in 1..10 loop
        v_amtincom(i)  := stddec(p_amtincom(i),p_codempid,v_chken);
    end loop;

    get_wage_income (v_codcomp,v_codempmt,
                     v_amtincom(1),v_amtincom(2),v_amtincom(3),
                     v_amtincom(4),v_amtincom(5),v_amtincom(6),
                     v_amtincom(7),v_amtincom(8),v_amtincom(9),
                     v_amtincom(10),
                     v_sumhur,v_sumday,v_summth);

     begin
       select codcurr
         into v_codcurr
         from tcontrpy
        where codcompy = v_codcomp
          and dteeffec = (select max(b.dteeffec)
                            from tcontrpy b
                           where b.codcompy = v_codcomp
                             and b.dteeffec <= trunc(sysdate));
      exception when no_data_found then null;
      end;

        begin
           select ratechge
             into v_rate
             from tratechg
            where dteyrepay = (p_dteyrepay - global_v_zyear)
              and dtemthpay = p_dtemthpay
              and codcurr   = v_codcurr
              and codcurr_e = v_codcurr_e;
        exception when no_data_found then
            v_rate := 1;
        end;

     p_ratehr   := v_sumhur;

     begin
       select stddec(amtday,codempid,v_chken)
       into   p_rateday
       from   temploy3
       where  codempid = p_codempid;
     exception when no_data_found then
       p_rateday := 0;
     end;
  end;

  procedure get_process (json_str_input in clob, json_str_output out clob) is
    json_obj       json_object_t;
    obj_param_json json_object_t;
    param_json_row json_object_t;
    -- get value parameter
    v_codempid     varchar2(4000 char);
    v_codpay       varchar2(4000 char);
    v_dtepay       date;
    v_dtepaystr    varchar2(100 char);
    v_amtpay       varchar2(4000 char);
    v_flgpyctax    varchar2(4000 char);
    --
    v_qtypayda     varchar2(4000 char);
    v_qtypayhr     varchar2(4000 char);
    v_qtypaysc     varchar2(4000 char);
    v_ratepay      varchar2(4000 char);
    v_codcompw     varchar2(4000 char);
    --
    v_rtesmot      varchar2(4000 char);
    v_qtysmot      varchar2(4000 char);
    v_amtspot      varchar2(4000 char);
    -- local value
    v_rcnt         number := 0;
    v_total        number := 0;
    v_complete     number := 0;
    v_complete_sum number := 0;
    v_error        number := 0;
    v_error_sum    number := 0;
    v_status       varchar2(4000 char);
    v_reason       varchar2(4000 char);
    v_failcolumn   varchar2(100 char);
    obj_data       json_object_t;
    obj_row        json_object_t;
    obj_result     json_object_t;
    v_data_error   varchar2(4000 char);
    v_reason_error varchar2(4000 char);
    v_amt_sum      number := 0;
  begin
    initial_value(json_str_input);
    obj_row         := json_object_t();
    obj_result      := json_object_t();
    --    obj_param_json  := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    json_obj  := json_object_t(json_str_input);
    obj_param_json  := json_object_t(hcm_util.get_clob_t(json_obj,'json_input_str'));

    for i in 0..obj_param_json.get_size-1 loop
      param_json_row      := hcm_util.get_json_t(obj_param_json,to_char(i));
      v_codempid          := hcm_util.get_string_t(param_json_row,'codempid');
      v_codpay            := hcm_util.get_string_t(param_json_row,'codpay');
      v_dtepaystr         := hcm_util.get_string_t(param_json_row,'dtepay');
      v_amtpay            := hcm_util.get_string_t(param_json_row,'amtpay');
      v_flgpyctax         := hcm_util.get_string_t(param_json_row,'flgpyctax');
      v_codcompw          := hcm_util.get_string_t(param_json_row,'codcompw');
      v_qtypayda          := hcm_util.get_string_t(param_json_row,'qtypayda');
      v_qtypayhr          := hcm_util.get_string_t(param_json_row,'qtypayhr');
      v_qtypaysc          := hcm_util.get_string_t(param_json_row,'qtypaysc');
      v_ratepay           := hcm_util.get_string_t(param_json_row,'ratepay');
      v_rtesmot           := hcm_util.get_string_t(param_json_row,'rtesmot');
      v_qtysmot           := hcm_util.get_string_t(param_json_row,'qtysmot');
      v_amtspot           := hcm_util.get_string_t(param_json_row,'amtspot');
      --
--      begin
--        v_qtypayda          := to_number(hcm_util.get_string(param_json_row,'qtypayda'));
--      exception when others then
--        json_str_output     := get_response_message(400,get_error_msg_php('HR2816',global_v_lang),global_v_lang);
--        return;
--      end;
--      begin
--        v_qtypayhr          := to_number(hcm_util.get_string(param_json_row,'qtypayhr'));
--      exception when others then
--        json_str_output     := get_response_message(400,get_error_msg_php('HR2816',global_v_lang),global_v_lang);
--        return;
--      end;
--      begin
--        v_qtypaysc          := to_number(hcm_util.get_string(param_json_row,'qtypaysc'));
--      exception when others then
--        json_str_output     := get_response_message(400,get_error_msg_php('HR2816',global_v_lang),global_v_lang);
--        return;
--      end;
--      begin
--        v_ratepay           := to_number(hcm_util.get_string(param_json_row,'ratepay'));
--      exception when others then
--        json_str_output     := get_response_message(400,get_error_msg_php('HR2816',global_v_lang),global_v_lang);
--        return;
--      end;
      --
--      begin
--        v_rtesmot           := to_number(hcm_util.get_string(param_json_row,'rtesmot'));
--      exception when others then
--        json_str_output     := get_response_message(400,get_error_msg_php('HR2816',global_v_lang),global_v_lang);
--        return;
--      end;
--      begin
--        v_qtysmot           := to_number(hcm_util.get_string(param_json_row,'qtysmot'));
--      exception when others then
--        json_str_output     := get_response_message(400,get_error_msg_php('HR2816',global_v_lang),global_v_lang);
--        return;
--      end;
--      begin
--        v_amtspot           := to_number(hcm_util.get_string(param_json_row,'amtspot'));
--      exception when others then
--        json_str_output     := get_response_message(400,get_error_msg_php('HR2816',global_v_lang),global_v_lang);
--        return;
--      end;

      if p_typpay = '1' then
        check_tothpay(v_codempid,upper(v_codpay),v_dtepaystr,v_dtepay,v_amtpay,v_flgpyctax,v_status,v_reason,v_failcolumn,v_codcompw);
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('status', v_status);
        obj_data.put('codempid', v_codempid);
        obj_data.put('codpay', upper(v_codpay));
        if v_failcolumn = 'dtepay' then
            obj_data.put('dtepay',v_dtepaystr);
        else
            if v_dtepay is null then
              begin
                v_dtepay            := to_date(hcm_util.get_string_t(param_json_row,'dtepay'),'dd/mm/yyyy');
                if EXTRACT(YEAR FROM v_dtepay) > 2300 then
                    v_dtepay := add_months(trunc(v_dtepay),-(12*543));
                end if;
                obj_data.put('dtepay',to_char(v_dtepay,'dd/mm/yyyy'));
              exception when others then
                obj_data.put('dtepay',v_dtepaystr);
              end;
            else
                obj_data.put('dtepay',to_char(v_dtepay,'dd/mm/yyyy'));
            end if;
        end if;
        obj_data.put('amtpay', v_amtpay);
        obj_data.put('flgpyctax', v_flgpyctax);
        obj_data.put('reason', v_reason);
        obj_data.put('typpay', p_typpay);
        obj_data.put('failcolumn', v_failcolumn);
        obj_data.put('codcompw', v_codcompw);
        obj_result.put(to_char(v_rcnt-1),obj_data);
        if v_status = 'Y' then
          v_amt_sum := v_amt_sum + nvl(to_number(v_amtpay,'fm9,999,999,990.00'),0);
        end if;
      elsif p_typpay = '2' then
        check_tothinc(v_codempid,upper(v_codpay),v_qtypayda,v_qtypayhr,v_qtypaysc,v_ratepay,
                      v_amtpay,v_codcompw,v_complete,v_error,v_status,v_reason,v_failcolumn);
        if param_msg_error is null then
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('status', v_status);
          obj_data.put('codempid', v_codempid);
          obj_data.put('codpay', upper(v_codpay));
          obj_data.put('qtypayda', v_qtypayda);
          obj_data.put('qtypayhr', v_qtypayhr);
          obj_data.put('qtypaysc', v_qtypaysc);
          obj_data.put('ratepay', v_ratepay);
          obj_data.put('amtpay', v_amtpay);
          obj_data.put('codcompw', v_codcompw);
          obj_data.put('reason', v_reason);
          obj_data.put('typpay', p_typpay);
          obj_data.put('failcolumn', v_failcolumn);
          obj_result.put(to_char(v_rcnt-1),obj_data);
--insert_ttemprpt('PY28B','PY28B',v_rcnt,v_amtpay,to_number(v_amtpay,'fm9,999,999,990.00'),'bef.Y,sum='||v_amt_sum,to_char(sysdate,'dd/mm/yyyy hh24:mi'));          
          if v_status = 'Y' then
            v_amt_sum := v_amt_sum + nvl(to_number(v_amtpay,'fm9,999,999,990.00'),0);
--insert_ttemprpt('PY28B','PY28B',v_rcnt,v_amtpay,to_number(v_amtpay,'fm9,999,999,990.00'),'af.Y,sum='||v_amt_sum,to_char(sysdate,'dd/mm/yyyy hh24:mi'));            
          end if;
        end if;
      elsif p_typpay = '3' then
        check_totsum (v_codempid,v_rtesmot,v_qtysmot,v_amtspot,v_codcompw,v_complete,
                      v_error,v_status,v_reason,v_failcolumn);
        if param_msg_error is null then
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('status', v_status);
          obj_data.put('codempid', v_codempid);
          obj_data.put('rtesmot', v_rtesmot);
          obj_data.put('qtysmot', v_qtysmot);
          obj_data.put('amtspot', v_amtspot);
          obj_data.put('codcompw', v_codcompw);
          obj_data.put('reason', v_reason);
          obj_data.put('typpay', p_typpay);
          obj_data.put('failcolumn', v_failcolumn);
          obj_result.put(to_char(v_rcnt-1),obj_data);
--insert_ttemprpt('PY28B','PY28B',v_rcnt,v_amtpay,to_number(v_amtpay,'fm9,999,999,990.00'),'af.Y,sum='||v_amt_sum,to_char(sysdate,'dd/mm/yyyy hh24:mi'));
          if v_status = 'Y' then
--#2522            v_amt_sum := v_amt_sum + nvl(to_number(v_amtspot,'fm9,999,999,990.00'),0);
            v_amt_sum := nvl(v_amt_sum,0) + nvl(to_number(v_amtspot,'fm9,999,999,990.00'),0);
--#2522
--insert_ttemprpt('PY28B','PY28B',v_rcnt,v_amtpay,to_number(v_amtpay,'fm9,999,999,990.00'),'af.Y,sum='||v_amt_sum,to_char(sysdate,'dd/mm/yyyy hh24:mi'));            
          end if;
        end if;
      end if;
      v_total := v_total + 1;
    end loop;
    -- put detail table
    if param_msg_error is null then
      v_data_error    := get_error_msg_php('HR2715',global_v_lang);
      v_reason_error  := replace(v_data_error,'@#$%200','');
      obj_data    := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('response', v_reason_error);
      obj_data.put('total', v_total);
      obj_data.put('complete', p_complete);
      obj_data.put('error', p_error);
      obj_data.put('sum', to_char(v_amt_sum,'fm9,999,999,999,990.00'));
    end if;
    --
    obj_row.put('details', obj_data);
    obj_row.put('table', obj_result);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_process;

  procedure save_index(json_str_input in clob, json_str_output out clob) is
  begin

    initial_value(json_str_input);
    if p_typpay = '1' then
      transfer_tothpay(json_str_input, json_str_output);
    elsif p_typpay = '2' then
      transfer_tothinc(json_str_input, json_str_output);
    elsif p_typpay = '3' then
      transfer_totsum(json_str_input, json_str_output);
    end if;
    --
    if param_msg_error is null then
      commit;
      param_msg_error := get_error_msg_php('HR2401',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    else
      rollback;
      json_str_output := get_response_message(400,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end save_index;

  procedure check_tothpay (v_codempid   in  varchar2,
                           v_codpay     in  varchar2,
                           v_dtepaystr  in  varchar2,
                           v_dtepay     out date,
                           v_amtpay     in out  varchar2,
                           v_flgpyctax  in  varchar2,
                           v_status     out varchar2,
                           v_reason     out varchar2,
                           v_failcolumn out varchar2,
                           v_codcompw   in varchar2) is
    v_data_error     varchar2(4000 char);
    v_flgsecu        boolean;
    v_codcomp        varchar2(4000 char);
    v_codcompy       varchar2(4000 char);
    v_numlvl         number;
    v_staemp         number;
    v_codpay_tmp     varchar2(4000 char);
    v_date           date;
    v_amtpay2        number;
    v_isnumber       boolean;
    v_compw          tcenter.codcomp%type;
  begin
    v_status := 'Y';
    -- check amtpay
    if v_amtpay is not null then
      check_is_number(v_amtpay,v_isnumber,v_amtpay2);
      if(v_isnumber) then
          v_amtpay := to_char(v_amtpay2,'fm9,999,999,990.00');
      end if;
    end if;

    -- check codempid
    if v_codempid is not null then
        begin
          select codcomp, numlvl, staemp
            into v_codcomp, v_numlvl, v_staemp
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          v_data_error := 'HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
          v_status := 'N';
          p_error  :=  nvl(p_error,0) + 1;
          v_reason  := replace(v_data_error,'@#$%400','');
          v_failcolumn := 'codempid';
          return;
        end;

      if v_staemp = 0 then
        v_data_error := get_error_msg_php('HR2102',global_v_lang);
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codempid';
        return;
      end if;
      --
      v_flgsecu := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if not v_flgsecu  then
        v_data_error := get_error_msg_php('HR3007',global_v_lang);
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        return;
      end if;
    else
      v_data_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      v_status := 'N';
      p_error  :=  nvl(p_error,0) + 1;
      v_reason  := replace(v_data_error,'@#$%400','');
      return;
    end if;
    
    -- check codpay 
    if v_codpay is not null then
      begin
        select codpay into v_codpay_tmp
          from tinexinf
        where codpay = upper(v_codpay);
      exception when no_data_found then
        v_data_error := 'HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TINEXINF)';
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codpay';
      return;
      end;
      --check codcompy
      begin
        select codcompy into v_codcompy
          from tinexinfc
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codpay   = upper(v_codpay);
      exception when no_data_found then
        v_data_error := get_error_msg_php('PY0044',global_v_lang);
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codpay';
        return;
      end;
    else
      v_data_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      v_status := 'N';
      p_error  := nvl(p_error,0) + 1;
      v_reason := replace(v_data_error,'@#$%400','');
      return;
    end if;

    if v_dtepaystr is null then
      v_data_error := get_error_msg_php('HR2045',global_v_lang,'dtepay');
      v_status := 'N';
      p_error  := nvl(p_error,0) + 1;
      v_reason := replace(v_data_error,'@#$%400','');
      v_failcolumn := 'dtepay';
      return;
    else
      begin
        v_dtepay            := to_date(v_dtepaystr,'dd/mm/yyyy');
        if EXTRACT(YEAR FROM v_dtepay) > 2300 then
            v_dtepay := add_months(trunc(v_dtepay),-(12*543));
        end if;
      exception when others then
        v_data_error     := get_error_msg_php('HR2025',global_v_lang,'dd/mm/yyyy');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'dtepay';
        return;
      end;
    end if;
    -- check amtpay
    if v_amtpay is not null then
      check_is_number(v_amtpay,v_isnumber,v_amtpay2);
      if(v_isnumber) then
          v_amtpay := to_char(to_number(v_amtpay2),'fm9,999,999,990.00');
          if v_amtpay2 < (-99999999.99) or v_amtpay2 > 99999999.99 then
            v_data_error := get_error_msg_php('HR2020',global_v_lang,'amtpay');
            v_status := 'N';
            p_error  := nvl(p_error,0) + 1;
            v_reason := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'amtpay';
            return;
          end if;
      else
        v_data_error := get_error_msg_php('HR2816',global_v_lang,'amtpay');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'amtpay';
        return;
      end if;
    else
      v_data_error := get_error_msg_php('HR2045',global_v_lang,'amtpay');
      v_status := 'N';
      p_error  := nvl(p_error,0) + 1;
      v_reason := replace(v_data_error,'@#$%400','');
      return;
    end if;
    -- check cal tax py
    if v_flgpyctax is not null then
      if v_flgpyctax not in ('Y','N') then
        v_data_error := get_error_msg_php('HR2020',global_v_lang,'flgpyctax');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'flgpyctax';
        return;
      end if;
    else
      v_data_error := get_error_msg_php('HR2045',global_v_lang,'flgpyctax');
      v_status := 'N';
      p_error  := nvl(p_error,0) + 1;
      v_reason := replace(v_data_error,'@#$%400','');
      return;
    end if;
    -- check codcompw
    if v_codcompw is not null then
      begin
        select codcomp into v_compw
          from tcenter
          where codcomp = v_codcompw;
      exception when no_data_found then
        v_data_error := 'HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TCENTER)';
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codcompw';
        return;
      end;

      if not secur_main.secur7(v_codcompw, global_v_coduser) then
        v_data_error := get_error_msg_php('HR3007',global_v_lang);
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        return;
      end if;
    end if;
    -- case complete all
    p_complete :=  nvl(p_complete,0) + 1;
  end check_tothpay;

  procedure check_tothinc (v_codempid   in  varchar2,
                           v_codpay     in  varchar2,
                           v_qtypayda   in out varchar2,
                           v_qtypayhr   in out varchar2,
                           v_qtypaysc   in out varchar2,
                           v_ratepay    in out  varchar2,
                           v_amtpay     in out  varchar2,
                           v_codcompw   in  varchar2,
                           v_complete   out number,
                           v_error      out number,
                           v_status     out varchar2,
                           v_reason     out varchar2,
                           v_failcolumn out varchar2) is
    v_data_error     varchar2(4000 char);
    v_flgsecu        boolean;
    v_codcomp        varchar2(4000 char);
    v_codcompy       varchar2(4000 char);
    v_numlvl         number;
    v_staemp         number;
    v_codpay_tmp     varchar2(4000 char);
    v_count          number := 0;
    v_tdtepay        number := 0;
    v_tcontpms       number := 0;
    v_compw          varchar2(4000 char);
    v_isnumber       boolean := false;

    v_ratepay2       number := 0;
    v_amtpay2        number := 0;

    v_codcompw_tmp   varchar2(4000 char);
    v_qtypayda_tmp   number;
    v_qtypayhr_tmp   number;
    v_qtypaysc_tmp   number;
    v_amtpay_old     varchar2(4000 char);
  begin
    if v_qtypayda = '0' then
        v_qtypayda := null;
    end if;
    if v_qtypayhr = '0' then
        v_qtypayhr := null;
    end if;
    if v_qtypaysc = '0' then
        v_qtypaysc := null;
    end if;

    -- check rate pay
    if v_ratepay is not null then
      check_is_number(v_ratepay,v_isnumber,v_amtpay2);
      if(v_isnumber) then
        v_ratepay := to_char(v_amtpay2,'fm9,999,999,990.00');
      end if;
    end if;
    -- check amount pay
    if v_amtpay is not null then
      check_is_number(v_amtpay,v_isnumber,v_amtpay2);
      if(v_isnumber) then
        v_amtpay := to_char(v_amtpay2,'fm9,999,999,990.00');
      end if;
    end if;

    v_status := 'Y';
    -- check codempid

    if v_codempid is not null then
        begin
          select codcomp, numlvl, staemp
            into v_codcomp, v_numlvl, v_staemp
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          v_data_error := 'HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
          v_status := 'N';
          p_error  :=  nvl(p_error,0) + 1;
          v_reason  := replace(v_data_error,'@#$%400','');
          v_failcolumn := 'codempid';
          return;
        end;
      if v_staemp = 0 then
        v_data_error := get_error_msg_php('HR2102',global_v_lang);
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codempid';
        return;
      end if;
      --
      v_flgsecu := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if not v_flgsecu  then
        v_data_error := get_error_msg_php('HR3007',global_v_lang);
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        return;
      end if;
    else
      v_data_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      v_status := 'N';
      p_error  :=  nvl(p_error,0) + 1;
      v_reason  := replace(v_data_error,'@#$%400','');
      return;
    end if;
    -- check codpay
    if v_codpay is not null then
      begin
        select codpay into v_codpay_tmp
          from tinexinf
        where codpay = upper(v_codpay);
      exception when no_data_found then
        v_data_error := 'HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TINEXINF)';
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codpay';
        return;
      end;
      --check codcompy
      begin
        select codcompy into v_codcompy
          from tinexinfc
         where codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
           and codpay   = upper(v_codpay);
      exception when no_data_found then
        v_data_error := get_error_msg_php('PY0044',global_v_lang);
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codpay';
        return;
      end;
      -- check period
      begin
      select hcm_util.get_codcomp_level(codcomp,'1')
        into v_codcompy
        from temploy1
       where codempid = v_codempid;
      end;

      begin
        select count(*) into v_tdtepay
          from tdtepay
         where dteyrepay = p_dteyrepay
           and dtemthpay = p_dtemthpay
           and numperiod = p_numperiod
           and codcompy = v_codcompy;
      exception when no_data_found then
        v_tdtepay := 0;
      end;
      --
      begin
        select count(*) into v_tcontpms
          from tcontpms
         where upper(v_codpay) in (codincom1,codincom2,codincom3,codincom4,codincom5,
                            codincom6,codincom7,codincom8,codincom9,codincom10)
           and codcompy = v_codcompy
           and dteeffec = (select max(dteeffec)
                                    from tcontpms
                                   where codcompy = v_codcompy
                                     and dteeffec <= trunc(sysdate));
      exception when no_data_found then
        v_tcontpms := 0;
      end;
      if (nvl(v_tdtepay,0) = 0) and (nvl(v_tcontpms,0) > 0) then
        v_data_error := get_error_msg_php('PY0043',global_v_lang);
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codpay';
        return;
      end if;
      -- check codpaypy5
      begin
        select count(*) into v_count
          from tcontrpy
         where codpaypy5 = upper(v_codpay);
      end;
      if v_count > 0 then
        v_data_error := get_error_msg_php('PY0019',global_v_lang);
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codpay';
        return;
      end if;
    else
      v_data_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      v_status := 'N';
      p_error  := nvl(p_error,0) + 1;
      v_reason := replace(v_data_error,'@#$%400','');
      return;
    end if;
    -- check qty day
    begin
      select qtypayda, qtypayhr, qtypaysc
        into v_qtypayda_tmp, v_qtypayhr_tmp, v_qtypaysc_tmp
        from tothinc2
       where codempid  = v_codempid
         and dteyrepay = p_dteyrepay - global_v_zyear
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
         and codpay    = upper(v_codpay)
         and codcompw  = v_codcompw;
    exception when no_data_found then
      v_qtypayda_tmp  := 0;
      v_qtypayhr_tmp  := 0;
      v_qtypaysc_tmp  := 0;
    end;
    if v_qtypayda is not null then
      check_is_number(v_qtypayda,v_isnumber,v_amtpay2);
      if(v_isnumber) then
        if v_amtpay2 = 0 then
          v_amtpay2 := null;
        elsif v_amtpay2 < 1 or v_amtpay2 > 9999 or v_qtypayda > 30 then
          v_data_error := get_error_msg_php('HR2020',global_v_lang,'qtypayda');
          v_status := 'N';
          p_error  :=  nvl(p_error,0) + 1;
          v_reason  := replace(v_data_error,'@#$%400','');
          v_failcolumn := 'qtypayda';
          return;
        end if;

        if (v_qtypayda_tmp + v_qtypayda) > 30 and p_typtran = '2' then
          v_data_error := get_error_msg_php('PY0060',global_v_lang,'qtypayda');
          v_status := 'N';
          p_error  :=  nvl(p_error,0) + 1;
          v_reason  := replace(v_data_error,'@#$%400','');
          v_failcolumn := 'qtypayda';
          return;
        end if;
        v_qtypayda := v_amtpay2;
      else
        v_data_error := get_error_msg_php('HR2816',global_v_lang,'qtypayda');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'qtypayda';
        return;
      end if;
     else
        if v_qtypayhr is null and v_qtypaysc is null and v_amtpay is null then
            v_data_error := get_error_msg_php('HR2045',global_v_lang,'qtypayda');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            return;
        end if;
    end if;
    -- check qty hr.
    if v_qtypayhr is not null then
      check_is_number(v_qtypayhr,v_isnumber,v_amtpay2);
      if(v_isnumber) then
          if v_amtpay2 = 0 then
            v_amtpay2 := null;
          elsif v_amtpay2 < 1 or v_amtpay2 > 999999 or v_qtypayhr >= 24 then --04/12/2020 || > 24
            v_data_error := get_error_msg_php('HR2020',global_v_lang,'qtypayhr');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'qtypayhr';
            return;
          end if;
          if (v_qtypayhr_tmp + v_qtypayhr) >= 24 and p_typtran = '2' then --04/12/2020 || > 24
            v_data_error := get_error_msg_php('PY0061',global_v_lang,'qtypayhr');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'qtypayhr';
            return;
          end if;
          v_qtypayhr := v_amtpay2;
      else
        v_data_error := get_error_msg_php('HR2816',global_v_lang,'qtypayhr');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'qtypayhr';
        return;
      end if;
    else
        if v_qtypayda is null and v_qtypaysc is null and v_amtpay is null then
            v_data_error := get_error_msg_php('HR2045',global_v_lang,'qtypayhr');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            return;
        end if;
    end if;
    -- check qty min
    if v_qtypaysc is not null then
      check_is_number(v_qtypaysc,v_isnumber,v_amtpay2);
      if(v_isnumber) then
          if v_amtpay2 = 0 then
            v_amtpay2 := null;
          elsif v_amtpay2 < 1 or v_amtpay2 > 999999 or v_qtypaysc >= 60 then --04/12/2020 || > 60
            v_data_error := get_error_msg_php('HR2020',global_v_lang,'qtypaysc');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'qtypaysc';
            return;
          end if;
          if (v_qtypaysc_tmp + v_qtypaysc) >= 60 and p_typtran = '2' then --04/12/2020 || > 60
            v_data_error := get_error_msg_php('PY0062',global_v_lang,'qtypaysc');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'qtypaysc';
            return;
          end if;
          v_qtypaysc := v_amtpay2;
      else
        v_data_error := get_error_msg_php('HR2816',global_v_lang,'qtypaysc');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'qtypaysc';
        return;
      end if;
    else
        if v_qtypayda is null and v_qtypayhr is null and v_amtpay is null then
            v_data_error := get_error_msg_php('HR2045',global_v_lang,'qtypaysc');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            return;
        end if;
    end if;
    -- check rate pay
    if v_ratepay is not null then
      check_is_number(v_ratepay,v_isnumber,v_amtpay2);
      if(v_isnumber) then
          if nvl(v_amtpay2,0) < 0 then
            v_data_error := get_error_msg_php('HR2023',global_v_lang,'ratepay');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'ratepay';
            return;
          end if;
      else
        v_data_error := get_error_msg_php('HR2816',global_v_lang,'ratepay');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'ratepay';
        return;
      end if;
    end if;
    -- check amount pay
    if v_amtpay is not null then
      check_is_number(v_amtpay,v_isnumber,v_amtpay2);
      if(v_isnumber) then
          if nvl(v_amtpay2,0) < (-99999999.99) or v_amtpay2 > 99999999.99 then
            v_data_error := get_error_msg_php('HR2020',global_v_lang,'amtpay');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'amtpay';
            return;
          end if;
      else
        v_data_error := get_error_msg_php('HR2816',global_v_lang,'amtpay');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'amtpay';
        return;
      end if;
    else
        if (v_qtypayda is null and v_qtypayhr is null and v_qtypaysc is null) and v_ratepay is null then
            v_data_error := get_error_msg_php('HR2045',global_v_lang,'amtpay');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            return;
        end if;
    end if;
    -- check codcompw
    if v_codcompw is not null then
      begin
        select codcomp into v_compw
          from tcenter
          where codcomp = v_codcompw;
      exception when no_data_found then
        v_data_error := 'HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TCENTER)';
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codcompw';
        return;
      end;

      if not secur_main.secur7(v_codcompw, global_v_coduser) then
        v_data_error := get_error_msg_php('HR3007',global_v_lang);
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        return;
      end if;
    end if;
    -- case complete all
    p_complete :=  nvl(p_complete,0) + 1;
  end check_tothinc;

  procedure check_totsum (v_codempid  in  varchar2,
                          v_rtesmot   in out varchar2,
                          v_qtysmot   in out varchar2,
                          v_amtspot   in out varchar2,
                          v_codcompw  in  varchar2,
                          v_complete  out number,
                          v_error     out number,
                          v_status    out varchar2,
                          v_reason    out varchar2,
                           v_failcolumn out varchar2) is
    v_data_error     varchar2(4000 char);
    v_flgsecu        boolean;
    v_codcomp        varchar2(4000 char);
    v_codcompy       varchar2(4000 char);
    v_numlvl         number;
    v_staemp         number;
    v_compw          varchar2(4000 char);
    v_newnumber      number := 0;
    v_isnumber       boolean := false;
  begin
    v_status := 'Y';
    -- check codempid

    if v_qtysmot is not null then
      check_is_number(v_qtysmot,v_isnumber,v_newnumber);
      if(v_isnumber) then


        if (INSTR(to_char(v_newnumber),'.') = 0) then
            v_qtysmot := to_char(v_newnumber,'fm9,999,999,990');
        else
            v_qtysmot := to_char(v_newnumber,'fm9,999,999,990.00');
        end if;

--        v_qtysmot := to_char(v_newnumber,'fm9,999,999,990.00');
      end if;
    end if;
    -- amount ot
    if v_amtspot is not null then
      check_is_number(v_amtspot,v_isnumber,v_newnumber);
      if(v_isnumber) then
        v_amtspot := to_char(v_newnumber,'fm9,999,999,990.00');
      end if;
    end if;


    if v_codempid is not null then
    begin
          select codcomp, numlvl, staemp
            into v_codcomp, v_numlvl, v_staemp
            from temploy1
           where codempid = v_codempid;
        exception when no_data_found then
          v_data_error := 'HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TEMPLOY1)';
          v_status := 'N';
          p_error  :=  nvl(p_error,0) + 1;
          v_reason  := replace(v_data_error,'@#$%400','');
          v_failcolumn := 'codempid';
          return;
        end;
      if v_staemp = 0 then
        v_data_error := get_error_msg_php('HR2102',global_v_lang);
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codempid';
        return;
      end if;
      --
      v_flgsecu := secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if not v_flgsecu  then
        v_data_error := get_error_msg_php('HR3007',global_v_lang);
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        return;
      end if;
    else
      v_data_error := get_error_msg_php('HR2045',global_v_lang,'codempid');
      v_status := 'N';
      p_error  :=  nvl(p_error,0) + 1;
      v_reason  := replace(v_data_error,'@#$%400','');
      return;
    end if;
    -- rate pay ot
    if v_rtesmot is not null then
      check_is_number(v_rtesmot,v_isnumber,v_newnumber);
      if(v_isnumber) then
          if v_newnumber < 0.01 or v_newnumber > 99.99 then
            v_data_error := get_error_msg_php('HR2020',global_v_lang,'rtesmot');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'rtesmot';
            return;
          end if;
      else
        v_data_error := get_error_msg_php('HR2816',global_v_lang,'rtesmot');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'rtesmot';
        return;
      end if;
    else
      v_data_error := get_error_msg_php('HR2045',global_v_lang,'rtesmot');
      v_status := 'N';
      p_error  :=  nvl(p_error,0) + 1;
      v_reason  := replace(v_data_error,'@#$%400','');
      return;
    end if;
    -- qty pay ot min.
    if v_qtysmot is not null then
      check_is_number(v_qtysmot,v_isnumber,v_newnumber);
      if(v_isnumber) then
          if v_newnumber < 0.01 or v_newnumber > 10000 then
            v_data_error := get_error_msg_php('HR2020',global_v_lang,'qtysmot');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'qtysmot';
            return;
          end if;
      else
        v_data_error := get_error_msg_php('HR2816',global_v_lang,'qtysmot');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'qtysmot';
        return;
      end if;
    else
      v_data_error := get_error_msg_php('HR2045',global_v_lang,'qtysmot');
      v_status := 'N';
      p_error  :=  nvl(p_error,0) + 1;
      v_reason  := replace(v_data_error,'@#$%400','');
      return;
    end if;
    -- amount ot
    if v_amtspot is not null then
      check_is_number(v_amtspot,v_isnumber,v_newnumber);
      if(v_isnumber) then
          if v_newnumber < 0 then
            v_data_error := get_error_msg_php('HR2023',global_v_lang,'amtspot');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'amtspot';
            return;
          end if;
          --
          if v_newnumber < 1 or v_newnumber > 99999999.99  then
            v_data_error := get_error_msg_php('HR2020',global_v_lang,'amtspot');
            v_status := 'N';
            p_error  :=  nvl(p_error,0) + 1;
            v_reason  := replace(v_data_error,'@#$%400','');
            v_failcolumn := 'amtspot';
            return;
          end if;
      else
        v_data_error := get_error_msg_php('HR2816',global_v_lang,'amtspot');
        v_status := 'N';
        p_error  := nvl(p_error,0) + 1;
        v_reason := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'amtspot';
        return;
      end if;
    end if;
    -- check codcompw
    if v_codcompw is not null then
      begin
        select codcomp into v_compw
          from tcenter
          where codcomp = v_codcompw;
      exception when no_data_found then
        v_data_error := 'HR2010 '||get_errorm_name('HR2010',global_v_lang)||' (TCENTER)';
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        v_failcolumn := 'codcompw';
        return;
      end;

      if not secur_main.secur7(v_codcompw, global_v_coduser) then
        v_data_error := get_error_msg_php('HR3007',global_v_lang);
        v_status := 'N';
        p_error  :=  nvl(p_error,0) + 1;
        v_reason  := replace(v_data_error,'@#$%400','');
        return;
      end if;
    end if;
    -- case complete all
    p_complete :=  nvl(p_complete,0) + 1;
  end check_totsum;

  procedure transfer_tothpay(json_str_input in clob, json_str_output out clob) is
    obj_param_json  json_object_t;
    param_json_row  json_object_t;
    json_obj       json_object_t;
    --
    v_flgfnd				varchar2(1);
    v_flgpass			  boolean;
    v_rec_tran      number := 0;
    v_numseq        number := 0;
    -- get param from json
    v_codempid      varchar2(4000 char);
    v_codpay        varchar2(4000 char);
    v_dtepay        date;
    v_amtpay        varchar2(4000 char);
    v_flgpyctax     varchar2(4000 char);
    v_status        varchar2(4000 char);
    -- tmp value
    v_amtpay_tmp    varchar2(4000 char);
    v_flgpyctax_tmp varchar2(4000 char);
    v_codcompw_tmp  varchar2(4000 char);
    v_costcent      varchar2(4000 char);
    v_codcompw      varchar2(4000 char);
    --
  	cursor c_temploy1 is
		 select	codempid,codcomp,typpayroll,typemp,staemp,numlvl
			 from	temploy1
			where	codempid	= v_codempid
	 order by codempid;

	cursor c_tothpay is
		 select	codempid,dteyrepay,dtemthpay,numperiod,codpay,typemp,rowid,amtpay,flgpyctax,codcompw
			 from	tothpay
			where	codempid	= v_codempid
				and	dteyrepay	=	(p_dteyrepay - global_v_zyear)
				and	dtemthpay	= p_dtemthpay
				and	numperiod	= p_numperiod
				and	codpay		= upper(v_codpay)
				and dtepay    = v_dtepay
			order by codempid,dteyrepay,dtemthpay,numperiod,codpay
			for update;
  begin
    --    obj_param_json  := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    json_obj  := json_object_t(json_str_input);
    obj_param_json  := json_object_t(hcm_util.get_clob_t(json_obj,'json_input_str'));

    for c_loop in 0..obj_param_json.get_size-1 loop
      param_json_row      := hcm_util.get_json_t(obj_param_json,to_char(c_loop));
      v_status            := hcm_util.get_string_t(param_json_row,'status');
      if v_status = 'Y' Then
        v_codempid          := hcm_util.get_string_t(param_json_row,'codempid');
        v_codpay            := hcm_util.get_string_t(param_json_row,'codpay');
        v_dtepay            := to_date(hcm_util.get_string_t(param_json_row,'dtepay'),'dd/mm/yyyy');
        v_amtpay            := to_char(to_number(hcm_util.get_string_t(param_json_row,'amtpay'),'fm9,999,999,990.00'));
        v_flgpyctax         := hcm_util.get_string_t(param_json_row,'flgpyctax');
        v_codcompw          := hcm_util.get_string_t(param_json_row,'codcompw');
--insert_ttemprpt('PY28B','PY28B',v_codempid,v_codpay,v_codcompw,null,to_char(sysdate,'dd/mm/yyyy hh24:mi'));        
        if v_codempid is null then
           exit;
        end if;
        --
        v_amtpay_tmp      := null;
        v_flgpyctax_tmp   := null;
        v_flgfnd		      := 'N';
        for r_temploy1 in c_temploy1 loop
          --- check secuerity
          v_flgpass := secur_main.secur1(r_temploy1.codcomp,r_temploy1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
          if v_flgpass then
            if v_dtepay is not null then
              if v_amtpay <> 0 then
                v_rec_tran	:= v_rec_tran + 1;
                if v_codcompw is null then
                  v_codcompw  :=  r_temploy1.codcomp;
                end if;
                -- find costcent
                begin
                  select costcent into v_costcent
                    from tcenter
                   where codcomp = nvl(v_codcompw,r_temploy1.codcomp);
                exception when no_data_found then
                  v_costcent := null;
                end;

                for r_tothpay in c_tothpay loop
                  v_amtpay_tmp    := r_tothpay.amtpay;
                  v_flgpyctax_tmp := r_tothpay.flgpyctax;
                  v_codcompw_tmp  := r_tothpay.codcompw;
                  v_flgfnd	      := 'Y';
                  if p_typtran = '1' then
                    -- delete
                    begin
                      delete tothpay
                       where codempid	  = v_codempid
                         and dteyrepay	=	(p_dteyrepay - global_v_zyear)
                         and dtemthpay	= p_dtemthpay
                         and numperiod	= p_numperiod
                         and codpay		  = upper(v_codpay)
                         and dtepay     = v_dtepay;
                    end;
                    insert into tothpay(codempid,dteyrepay,dtemthpay,numperiod,codpay,dtepay,
                                        codcomp,typpayroll,typemp,amtpay,
                                        flgpyctax,coduser,dteupd,codcreate,costcent,
                                        codcompw) --08/12/2020--
                          values(v_codempid,(p_dteyrepay - global_v_zyear),p_dtemthpay,p_numperiod,upper(v_codpay),v_dtepay,
                                 r_temploy1.codcomp,r_temploy1.typpayroll,r_temploy1.typemp,stdenc(v_amtpay,v_codempid,v_chken),
                                 v_flgpyctax,global_v_coduser,trunc(sysdate),global_v_coduser,v_costcent,
                                 v_codcompw); --08/12/2020--
                  else
                    update	tothpay
                      set	  codcomp		  = r_temploy1.codcomp, --08/12/2020--
                            codcompw		= v_codcompw, --08/12/2020--nvl(v_codcompw,r_temploy1.codcomp),
                            costcent    = v_costcent,
                            amtpay		  = stdenc(stddec(v_amtpay_tmp,v_codempid,v_chken) + v_amtpay,v_codempid,v_chken),
                            flgpyctax   = v_flgpyctax,
                            dteupd      = trunc(sysdate),
                            coduser		  = global_v_coduser
                      where rowid = r_tothpay.rowid;
                  end if;
                end loop; -- c_tothpay;
                --
                if v_flgfnd = 'N' then
                  insert into tothpay(codempid,dteyrepay,dtemthpay,numperiod,codpay,dtepay,
                                      codcomp,typpayroll,typemp,amtpay,
                                      flgpyctax,coduser,dteupd,codcreate,costcent,
                                      codcompw) --08/12/2020--
                          values(v_codempid,(p_dteyrepay - global_v_zyear),p_dtemthpay,p_numperiod,upper(v_codpay),v_dtepay,
                                 r_temploy1.codcomp,r_temploy1.typpayroll,r_temploy1.typemp,stdenc(v_amtpay,v_codempid,v_chken),
                                 v_flgpyctax,global_v_coduser,trunc(sysdate),global_v_coduser,v_costcent,
                                 v_codcompw); --08/12/2020--
                  /*insert into
                    tlogothpay (numseq, codempid, dteyrepay, dtemthpay, numperiod, codpay,
                                dtepay, codcomp, desfld, desold, desnew,
                                codcreate, coduser)
                        values (v_numseq, v_codempid, p_dteyrepay, p_dtemthpay, p_numperiod, v_codpay,
                                v_dtepay, r_temploy1.codcomp, null, v_amtpay_tmp, stdenc(v_amtpay,v_codempid,v_chken),
                                global_v_coduser, global_v_coduser);         */
                end if;
                -- insert log table (AMTPAY)
                if nvl(v_amtpay_tmp,'') <> stdenc(v_amtpay,v_codempid,v_chken) OR v_amtpay_tmp IS NULL then
                  v_numseq := v_numseq + 1;
                  insert into tlogothpay (numseq, codempid, dteyrepay, dtemthpay, numperiod, codpay,
                                dtepay, codcomp, desfld, desold, desnew,
                                codcreate, coduser)
                        values (v_numseq, v_codempid, p_dteyrepay, p_dtemthpay, p_numperiod, upper(v_codpay),
                                v_dtepay, r_temploy1.codcomp, 'AMTPAY', v_amtpay_tmp, stdenc(v_amtpay,v_codempid,v_chken),
                                global_v_coduser, global_v_coduser);
                end if;
                -- insert log table (FLGPYCTAX)
                if nvl(v_flgpyctax_tmp,'') <> v_flgpyctax OR v_flgpyctax_tmp IS NULL then
                  v_numseq := v_numseq + 1;
                  insert into tlogothpay (numseq, codempid, dteyrepay, dtemthpay, numperiod, codpay,
                                dtepay, codcomp, desfld, desold, desnew,
                                codcreate, coduser)
                        values (v_numseq, v_codempid, p_dteyrepay, p_dtemthpay, p_numperiod, upper(v_codpay),
                                v_dtepay, r_temploy1.codcomp, 'FLGPYCTAX', v_flgpyctax_tmp, v_flgpyctax,
                                global_v_coduser, global_v_coduser);
                end if;
                -- insert log table (CODCOMPW) 08/12/2020
                if nvl(v_codcompw_tmp,'') <> v_codcompw OR v_codcompw_tmp IS NULL then
                  v_numseq := v_numseq + 1;
                  insert into tlogothpay (numseq, codempid, dteyrepay, dtemthpay, numperiod, codpay,
                                dtepay, codcomp, desfld, desold, desnew,
                                codcreate, coduser)
                        values (v_numseq, v_codempid, p_dteyrepay, p_dtemthpay, p_numperiod, upper(v_codpay),
                                v_dtepay, r_temploy1.codcomp, 'CODCOMPW', v_codcompw_tmp, v_codcompw,
                                global_v_coduser, global_v_coduser);
                end if;
                --
                v_flgfnd	:= 'Y';
              end if;
            end if;
          end if;
        end loop;
      end if;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end transfer_tothpay;

  procedure transfer_tothinc(json_str_input in clob, json_str_output out clob) is
    obj_param_json  json_object_t;
    param_json_row  json_object_t;
    json_obj  json_object_t;
    --
    v_flgpass			  boolean;
    v_rec_tran      number := 0;
    v_numseq        number := 0;
    v_dup			      boolean;
    v_dup2		      boolean;
    -- get param from json
    v_status        varchar2(4000 char);
    v_codempid      varchar2(4000 char);
    v_codpay        varchar2(4000 char);
    v_qtypayda      number;
    v_qtypayhr      number;
    v_qtypaysc      number;
    v_ratepay       number;
    v_amtpay        number;
    v_codcompw      varchar2(4000 char);
    v_costcent      varchar2(4000 char);
    -- tmp value
    tmp_ratepay     varchar2(4000 char);
    tmp_amtpay      varchar2(4000 char);
    v_qtyavgwk      number;
    v_enamtpay      number;
    v_amtpayda      number;
    v_amtpayhr      number;
    v_amtpaysc      number;
    v_amtday        number;
    v_codcompw_tmp  varchar2(4000 char);
    v_qtypayda_tmp  number;
    v_qtypayhr_tmp  number;
    v_qtypaysc_tmp  number;
    v_amtpay_old    varchar2(4000 char);
    v_amtpay_new    number;
    v_ratepay_old   varchar2(4000 char);
    --
  cursor c_temploy1 is
		 select	codempid,codcomp,typpayroll,typemp,staemp,numlvl
			 from	temploy1
			where	codempid	= v_codempid
	 order by codempid;

	cursor c_tothinc is
		 select	codempid,dteyrepay,dtemthpay,numperiod,codpay,typemp,rowid
			 from	tothinc
			where	codempid	= v_codempid
				and	dteyrepay	=	(p_dteyrepay - global_v_zyear)
				and	dtemthpay	= p_dtemthpay
				and	numperiod	= p_numperiod
				and	codpay		= upper(v_codpay)
			order by codempid,dteyrepay,dtemthpay,numperiod,codpay
			for update;

  cursor c_tothinc2 is
      select codempid,sum(stddec(amtpay,codempid,v_chken)) sum_amtpay
        from tothinc2
       where codempid  = v_codempid
         and dteyrepay = (p_dteyrepay - global_v_zyear)
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
         and codpay		 = upper(v_codpay)
    group by codempid
    order by codempid;
  begin
    --    obj_param_json  := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    json_obj  := json_object_t(json_str_input);
    obj_param_json  := json_object_t(hcm_util.get_clob_t(json_obj,'json_input_str'));


    for c_loop in 0..obj_param_json.get_size-1 loop

      param_json_row      := hcm_util.get_json_t(obj_param_json,to_char(c_loop));
      v_status            := hcm_util.get_string_t(param_json_row,'status');

      if v_status = 'Y' Then

          v_codempid          := hcm_util.get_string_t(param_json_row,'codempid');
          v_codpay            := hcm_util.get_string_t(param_json_row,'codpay');
          v_qtypayda          := to_number(hcm_util.get_string_t(param_json_row,'qtypayda'));
          v_qtypayhr          := to_number(hcm_util.get_string_t(param_json_row,'qtypayhr'));
          v_qtypaysc          := to_number(hcm_util.get_string_t(param_json_row,'qtypaysc'));
          v_ratepay           := to_number(hcm_util.get_string_t(param_json_row,'ratepay'),'fm9,999,999,990.00');
          v_amtpay            := to_number(hcm_util.get_string_t(param_json_row,'amtpay'),'fm9,999,999,990.00');
          v_codcompw          := hcm_util.get_string_t(param_json_row,'codcompw');

        if v_codempid is null then
           exit;
        end if;
        --
        for r_temploy1 in c_temploy1 loop
          --- check secuerity
          v_flgpass := secur_main.secur1(r_temploy1.codcomp,r_temploy1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
          v_flgpass := true;
          if v_flgpass then
            v_rec_tran := v_rec_tran + 1;
            -- check codcompw
            if v_codcompw is null then
              v_codcompw := r_temploy1.codcomp;
            end if; --08/12/2020--
            -- get temp value for insert logs
            begin
              select codcompw, qtypayda, qtypayhr,
                     qtypaysc, amtpay
                into v_codcompw_tmp, v_qtypayda_tmp, v_qtypayhr_tmp,
                     v_qtypaysc_tmp, v_amtpay_old
                from tothinc2
               where codempid  = v_codempid
                 and dteyrepay = p_dteyrepay - global_v_zyear
                 and dtemthpay = p_dtemthpay
                 and numperiod = p_numperiod
                 and codpay    = upper(v_codpay)
                 and codcompw  = v_codcompw;
            exception when no_data_found then
              v_codcompw_tmp  := null;
              v_qtypayda_tmp  := 0;
              v_qtypayhr_tmp  := 0;
              v_qtypaysc_tmp  := 0;
              v_amtpay_old    := null;
            end;

            -- insert tothinc2
            if v_amtpay is not null then
              tmp_amtpay  := stdenc(v_amtpay,v_codempid,v_chken);
            else
              -- check ratepay
              if nvl(v_ratepay,0) > 0 then
                begin
                  select qtyavgwk into v_qtyavgwk
                    from tcontral a
                   where a.codcompy = hcm_util.get_codcomp_level(v_codcompw,1)
                     and a.dteeffec = (select max(b.dteeffec)
                                         from tcontral b
                                        where b.codcompy = a.codcompy);
                exception when no_data_found then
                  v_qtyavgwk := 0;
                end;
                v_amtpayda  := round(v_ratepay,2);
                v_amtpayhr  := nvl(v_amtpayda,0)/(nvl(v_qtyavgwk,0)/60);
                v_amtpaysc  := nvl(v_amtpayhr,0)/60;
              else
                get_ratepay(v_codempid,v_amtpayda,v_amtpayhr);
                v_amtpaysc  := nvl(v_amtpayhr,0)/60;
              end if;
              v_enamtpay  := (nvl(v_qtypayda,0) * nvl(v_amtpayda,0)) +
                             (nvl(v_qtypayhr,0) * nvl(v_amtpayhr,0)) +
                             (nvl(v_qtypaysc,0) * nvl(v_amtpaysc,0));
              tmp_amtpay  := stdenc(v_enamtpay,v_codempid,v_chken);
            end if;


            v_dup := check_dup_tothinc2(v_codempid,p_dteyrepay,p_dtemthpay,p_numperiod,upper(v_codpay),v_codcompw);
            -- get cost center
            begin
              select costcent into v_costcent
                from tcenter
               where codcomp = v_codcompw;
            exception when no_data_found then
              v_costcent := null;
            end;
            if v_dup then  --true not found
              --
              insert into
                 tothinc2(codempid,dteyrepay,dtemthpay,numperiod,codpay,
                          codcompw,qtypayda,qtypayhr,qtypaysc,
                          amtpay,costcent,coduser,codcreate,codsys)
                   values(v_codempid,(p_dteyrepay - global_v_zyear),p_dtemthpay,p_numperiod,upper(v_codpay),
                          v_codcompw,v_qtypayda,v_qtypayhr,v_qtypaysc,
                          tmp_amtpay,v_costcent,global_v_coduser,global_v_coduser,'PY');
            else -- found false

              if p_typtran = '1' then
                delete tothinc2
                 where codempid    = v_codempid
                   and dteyrepay   = p_dteyrepay - global_v_zyear
                   and dtemthpay   = p_dtemthpay
                   and numperiod   = p_numperiod
                   and codpay      = upper(v_codpay)
                   and codcompw    = v_codcompw;

                insert into tothinc2(codempid,dteyrepay,dtemthpay,numperiod,codpay,
                            codcompw,qtypayda,qtypayhr,qtypaysc,
                            amtpay,costcent,coduser,codcreate,codsys)
                     values(v_codempid,(p_dteyrepay - global_v_zyear),p_dtemthpay,p_numperiod,upper(v_codpay),
                            v_codcompw,v_qtypayda,v_qtypayhr,v_qtypaysc,
                            tmp_amtpay,v_costcent,global_v_coduser,global_v_coduser,'PY');
              else
                v_amtpay_new  :=  stddec(tmp_amtpay,v_codempid,v_chken) + stddec(v_amtpay_old,v_codempid,v_chken);
--insert_ttemprpt('PY28B','PY28B',v_codempid,v_codpay||','||v_codcompw,'up amtpay='||v_amtpay_new,stddec(tmp_amtpay,v_codempid,v_chken)||' + '||stddec(v_amtpay_old,v_codempid,v_chken),to_char(sysdate,'dd/mm/yyyy hh24:mi'));                
                update tothinc2
                   set amtpay    = stdenc(v_amtpay_new,v_codempid,v_chken),
                       qtypayda	 = nvl(v_qtypayda_tmp,0) + nvl(v_qtypayda,0),
                       qtypayhr	 = nvl(v_qtypayhr_tmp,0) + nvl(v_qtypayhr,0),
                       qtypaysc	 = nvl(v_qtypaysc_tmp,0) + nvl(v_qtypaysc,0),
                       dteupd    = trunc(sysdate),
                       coduser	 = global_v_coduser,
                       codsys      = 'PY'
                 where codempid    = v_codempid
                   and dteyrepay   = p_dteyrepay - global_v_zyear
                   and dtemthpay   = p_dtemthpay
                   and numperiod   = p_numperiod
                   and codpay      = upper(v_codpay)
                   and codcompw    = v_codcompw;
              end if;
            end if;
            ---------------------------- insert log tlogothinc --------------------------------
            -- insert log table (CODCOMPW)
            if nvl(v_codcompw_tmp,'XXX') <> nvl(v_codcompw,'XXX') then
              v_numseq := v_numseq + 1;
              insert into
                 tlogothinc (numseq, codempid, dteyrepay, dtemthpay, numperiod, codpay,
                            codcomp, desfld, desold, desnew, codcreate, coduser)
                    values (v_numseq, v_codempid, p_dteyrepay, p_dtemthpay, p_numperiod, upper(v_codpay),
                            r_temploy1.codcomp, 'CODCOMPW', v_codcompw_tmp, v_codcompw,
                            global_v_coduser, global_v_coduser);
            end if;
            -- insert log table (QTYPAYDA)
                if nvl(v_qtypayda_tmp,0) <> nvl(v_qtypayda,0) then
                  v_numseq := v_numseq + 1;
                  insert into
                     tlogothinc (numseq, codempid, dteyrepay, dtemthpay, numperiod, codpay,
                                codcomp, desfld, desold, desnew, codcreate, coduser)
                        values (v_numseq, v_codempid, p_dteyrepay, p_dtemthpay, p_numperiod, upper(v_codpay),
                                r_temploy1.codcomp, 'QTYPAYDA', v_qtypayda_tmp, v_qtypayda,
                                global_v_coduser, global_v_coduser);
                end if;
                -- insert log table (QTYPAYHR)
                if nvl(v_qtypayhr_tmp,0) <> nvl(v_qtypayhr,0) then
                  v_numseq := v_numseq + 1;
                  insert into
                     tlogothinc (numseq, codempid, dteyrepay, dtemthpay, numperiod, codpay,
                                codcomp, desfld, desold, desnew, codcreate, coduser)
                        values (v_numseq, v_codempid, p_dteyrepay, p_dtemthpay, p_numperiod, upper(v_codpay),
                                r_temploy1.codcomp, 'QTYPAYHR', v_qtypayhr_tmp, v_qtypayhr,
                                global_v_coduser, global_v_coduser);
                end if;
                -- insert log table (QTYPAYSC)
                if nvl(v_qtypaysc_tmp,0) <> nvl(v_qtypaysc,0) then
                  v_numseq := v_numseq + 1;
                  insert into
                     tlogothinc (numseq, codempid, dteyrepay, dtemthpay, numperiod, codpay,
                                codcomp, desfld, desold, desnew, codcreate, coduser)
                        values (v_numseq, v_codempid, p_dteyrepay, p_dtemthpay, p_numperiod, upper(v_codpay),
                                r_temploy1.codcomp, 'QTYPAYSC', v_qtypaysc_tmp, v_qtypaysc,
                                global_v_coduser, global_v_coduser);
                end if;
            -- insert log table (AMTPAY)
            if v_amtpay_old <> tmp_amtpay OR v_amtpay_old IS NULL then
              v_numseq := v_numseq + 1;
              insert into
                 tlogothinc (numseq, codempid, dteyrepay, dtemthpay, numperiod, codpay,
                            codcomp, desfld, desold, desnew, codcreate, coduser)
                    values (v_numseq, v_codempid, p_dteyrepay, p_dtemthpay, p_numperiod, upper(v_codpay),
                            r_temploy1.codcomp, 'AMTPAY', v_amtpay_old, tmp_amtpay,
                            global_v_coduser, global_v_coduser);
            end if;
            ------------------------------------------------------------------------------------
            -- loop insert tothinc
            for r_tothinc2 in c_tothinc2 loop
              begin
                select costcent into v_costcent
                  from tcenter
                 where codcomp = nvl(v_codcompw,r_temploy1.codcomp);
              exception when no_data_found then
                v_costcent := null;
              end;
              --
              -- get temp value for insert logs
              begin
                select qtypayda, qtypayhr,qtypaysc,amtpay
                  into v_qtypayda_tmp, v_qtypayhr_tmp,v_qtypaysc_tmp,v_amtpay_old
                  from tothinc
                 where codempid  = v_codempid
                   and dteyrepay = p_dteyrepay - global_v_zyear
                   and dtemthpay = p_dtemthpay
                   and numperiod = p_numperiod
                   and codpay    = upper(v_codpay);
              exception when no_data_found then
                v_qtypayda_tmp  := 0;
                v_qtypayhr_tmp  := 0;
                v_qtypaysc_tmp  := 0;
                v_amtpay_old    := null;
              end;
              tmp_ratepay   := stdenc(round(v_ratepay,2),v_codempid,v_chken);
--              tmp_amtpay    := stdenc(v_amtpay,v_codempid,v_chken);
              v_dup2 := check_dup_tothinc(v_codempid,p_dteyrepay,p_dtemthpay,p_numperiod,upper(v_codpay));
              if v_dup2 then  --true not found
                -- Insert tothinc
                insert into
                   tothinc(codempid,dteyrepay,dtemthpay,numperiod,codpay,
                           codcomp,typpayroll,qtypayda,qtypayhr,qtypaysc,
                           ratepay,amtpay,codsys,coduser,typemp,codcreate,costcent)
                    values(v_codempid,(p_dteyrepay - global_v_zyear),p_dtemthpay,
                           p_numperiod,upper(v_codpay),r_temploy1.codcomp,
                           r_temploy1.typpayroll,v_qtypayda,v_qtypayhr,v_qtypaysc,
                           tmp_ratepay,stdenc(r_tothinc2.sum_amtpay,v_codempid,v_chken),'PY',global_v_coduser,r_temploy1.typemp,
                           global_v_coduser,v_costcent);
              else
                -- Update tothinc
                for r_tothinc in c_tothinc loop
                  if p_typtran = '1' then
                    delete tothinc
                     where codempid    = v_codempid
                       and dteyrepay   = p_dteyrepay - global_v_zyear
                       and dtemthpay   = p_dtemthpay
                       and numperiod   = p_numperiod
                       and codpay      = upper(v_codpay);

                    insert into tothinc(codempid,dteyrepay,dtemthpay,numperiod,codpay,
                                codcomp,typpayroll,qtypayda,qtypayhr,qtypaysc,
                                ratepay,amtpay,codsys,coduser,typemp,codcreate,costcent)
                        values(v_codempid,(p_dteyrepay - global_v_zyear),p_dtemthpay,
                               p_numperiod,upper(v_codpay),nvl(v_codcompw,r_temploy1.codcomp),
                               r_temploy1.typpayroll,v_qtypayda,v_qtypayhr,v_qtypaysc,
                               tmp_ratepay,stdenc(r_tothinc2.sum_amtpay,v_codempid,v_chken),'PY',global_v_coduser,r_temploy1.typemp,
                               global_v_coduser,v_costcent);
                  else
                    update	tothinc
                      set		codcomp			= nvl(v_codcompw,r_temploy1.codcomp),
                            costcent    = v_costcent,
                            typpayroll	= r_temploy1.typpayroll,
                            qtypayda	  = nvl(v_qtypayda_tmp,0) + nvl(v_qtypayda,0),
                            qtypayhr	  = nvl(v_qtypayhr_tmp,0) + nvl(v_qtypayhr,0),
                            qtypaysc	  = nvl(v_qtypaysc_tmp,0) + nvl(v_qtypaysc,0),
                            ratepay			= tmp_ratepay,
                            amtpay			= stdenc(r_tothinc2.sum_amtpay,v_codempid,v_chken),
                            typemp			= r_temploy1.typemp,
                            codsys			= 'PY',
                            dteupd      = trunc(sysdate),
                            coduser			= global_v_coduser
                      where rowid = r_tothinc.rowid;
                  end if;
                end loop; -- c_tothinc;
              end if;
            end loop;
            commit;
          end if;
        end loop;
      end if;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end transfer_tothinc;

  procedure transfer_totsum(json_str_input in clob, json_str_output out clob) is
    obj_param_json  json_object_t;
    param_json_row  json_object_t;
    json_obj       json_object_t;
    --
    v_year          number := p_dteyrepay - global_v_zyear;
    v_rec_tran      number := 0;
    v_dup2		      boolean;
    v_flgpass       boolean;
    tmp_amtottot    totsum.amtottot%type;
    v_amtothr			  temploy3.amtothr%type;
    v_codcurr			  temploy3.codcurr%type;
    -- jsom parameter
    v_status        varchar2(4000 char);
    v_codempid		  varchar2(4000 char);
    v_rtesmot       number;
    v_qtysmot       number;
    v_amtspot       number;
    v_codcompw      varchar2(4000 char);
    v_costcent      varchar2(4000 char);
    --
    v_dup			      boolean;
    v_enamtspot     number; --totsumd.amtspot%type;
    v_amtspot1      varchar2(4000);
    v_qtysmot1      number;
    v_sum_qtysmot	  totsumd.qtysmot%type;
    v_sum_amtspot	  number;
    v_sum_amtspot1  varchar2(4000);
    --
    cursor c_temploy1 is
      select codempid,codcomp,typpayroll,typemp,staemp,numlvl
        from temploy1
       where codempid	= v_codempid
    order by codempid;

    cursor c_emp is
      select codempid,sum(stddec(amtspot,codempid,v_chken)) sum_amtspot,sum(qtysmot) sum_qtysmot
        from totsumd
--       where codempid in (select item1
--                            from ttemprpt
--                           where codapp 	= 'HRPY28B'
--                             and codempid	= global_v_coduser)
       where codempid  = v_codempid
         and dteyrepay = v_year
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
    group by codempid
    order by codempid;
  begin
    --    obj_param_json  := json_object_t(hcm_util.get_string_t(json_object_t(json_str_input),'json_input_str'));
    json_obj  := json_object_t(json_str_input);
    obj_param_json  := json_object_t(hcm_util.get_clob_t(json_obj,'json_input_str'));
    for c_loop in 0..obj_param_json.get_size-1 loop
      param_json_row      := hcm_util.get_json_t(obj_param_json,to_char(c_loop));

      v_status            := hcm_util.get_string_t(param_json_row,'status');
      if v_status = 'Y' Then
          v_codempid          := hcm_util.get_string_t(param_json_row,'codempid');
          v_rtesmot           := to_number(hcm_util.get_string_t(param_json_row,'rtesmot'));
          v_qtysmot           := to_number(hcm_util.get_string_t(param_json_row,'qtysmot'),'fm9,999,999,990.00');
          v_amtspot           := to_number(hcm_util.get_string_t(param_json_row,'amtspot'),'fm9,999,999,990.00');
          v_codcompw          := hcm_util.get_string_t(param_json_row,'codcompw');
        -- loop insert totsumd
        for r_temploy1 in c_temploy1 loop
          v_flgpass := secur_main.secur1(r_temploy1.codcomp,r_temploy1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
            if v_flgpass then
              v_rec_tran := v_rec_tran + 1;
--              if chk_emp_processed(upper(v_codempid)) = 'N' then
--                null;
--              end if;
              --
              -- check codcompw
              if v_codcompw is null then
                v_codcompw := r_temploy1.codcomp;
              end if;
              v_dup := check_dup_totsumd(v_codempid,p_dteyrepay,p_dtemthpay,p_numperiod,v_rtesmot,v_codcompw);
              if v_dup then  --true not found
                -- check amtspot
                if nvl(v_amtspot,0) > 0 then
                  v_enamtspot := round(v_amtspot,2);
                else
                  begin
                    select amtothr into v_amtothr
                      from temploy3
                     where codempid = v_codempid;
                  exception when no_data_found then
                    v_amtothr := null;
                  end;
                  v_enamtspot := round((nvl(v_rtesmot,0) * nvl(v_qtysmot/60,0)) * nvl(stddec(v_amtothr,v_codempid,v_chken),0),2);
                end if;
                -- get cost center
                begin
                  select costcent into v_costcent
                    from tcenter
                   where codcomp = v_codcompw;
                exception when no_data_found then
                  v_costcent := null;
                end;
                --
                insert into totsumd (codempid,dteyrepay,dtemthpay,numperiod,rtesmot,codcompw,
                                     qtysmot,amtspot,costcent,codcreate,dteupd,coduser,codsys)
                      values (v_codempid,v_year ,p_dtemthpay,p_numperiod,v_rtesmot,v_codcompw,
                              v_qtysmot, stdenc(v_enamtspot,v_codempid,v_chken),v_costcent,global_v_coduser,trunc(sysdate),global_v_coduser,'PY');
              else -- found	false
                if nvl(v_amtspot,0) > 0 then
                  v_enamtspot := round(v_amtspot,2);
                else
                  begin
                    select amtothr into v_amtothr
                      from temploy3
                     where codempid = v_codempid;
                  exception when no_data_found then
                    v_amtothr := null;
                  end;
                  v_enamtspot := round((nvl(v_rtesmot,0) * nvl(v_qtysmot/60,0)) * nvl(stddec(v_amtothr,v_codempid,v_chken),0),2);
                end if;
                begin
                  select qtysmot,amtspot
                    into v_qtysmot1,v_amtspot1
                    from totsumd
                   where codempid  = v_codempid
                     and dteyrepay = v_year
                     and dtemthpay = p_dtemthpay
                     and numperiod = p_numperiod
                     and codcompw  = v_codcompw
                     and rtesmot   = round(v_rtesmot,2);
                exception when no_data_found then null;
                end;
                v_amtspot1     := stddec(v_amtspot1,v_codempid,v_chken);
                v_sum_qtysmot  := nvl(v_qtysmot,0) + nvl(v_qtysmot1,0);
                v_sum_amtspot	 := nvl(v_enamtspot,0) + nvl(to_number(v_amtspot1),0);
                v_sum_amtspot1 := stdenc(round(v_sum_amtspot,2),v_codempid,v_chken);
                -- get cost center
                begin
                  select costcent into v_costcent
                    from tcenter
                   where codcomp = v_codcompw;
                exception when no_data_found then
                  v_costcent := null;
                end;
                --
                if p_typtran = '1' then
                  delete totsumd
                   where codempid  = v_codempid
                     and dteyrepay = v_year
                     and dtemthpay = p_dtemthpay
                     and numperiod = p_numperiod
                     and codcompw  = v_codcompw
                     and rtesmot   = round(v_rtesmot,2);

                   insert into totsumd (codempid,dteyrepay,dtemthpay,numperiod,rtesmot,codcompw,
                                        qtysmot,amtspot,costcent,codcreate,dteupd,coduser,codsys)
                        values (v_codempid,v_year ,p_dtemthpay,p_numperiod,v_rtesmot,v_codcompw,
                                v_qtysmot, stdenc(v_enamtspot,v_codempid,v_chken),v_costcent,global_v_coduser,trunc(sysdate),global_v_coduser,'PY');
                else
                  update totsumd
                     set qtysmot = v_sum_qtysmot,
                         amtspot = v_sum_amtspot1,
                         dteupd  = trunc(sysdate),
                         codsys = 'PY'
                   where codempid  = v_codempid
                     and dteyrepay = v_year
                     and dtemthpay = p_dtemthpay
                     and numperiod = p_numperiod
                     and codcompw  = v_codcompw
                     and rtesmot   = round(v_rtesmot,2);
                end if;
              end if;	-- totsumd
            end if;
        end loop;
        -- loop insert totsum
        if v_rec_tran > 0 then
          for i in c_emp loop
            v_dup2 := check_dup_totsum(i.codempid,p_dteyrepay,p_dtemthpay,p_numperiod);
            v_codempid := i.codempid;
            for j in c_temploy1 loop
              begin
                select amtothr,codcurr
                  into v_amtothr,v_codcurr
                  from temploy3
                 where codempid = i.codempid;
              exception when no_data_found then null;
              end;
              -- get cost center
              begin
                select costcent into v_costcent
                  from tcenter
                 where codcomp = j.codcomp;
              exception when no_data_found then
                v_costcent := null;
              end;
              if v_dup2 then  -- true insert
                --
                tmp_amtottot := stdenc(round(v_amtspot,2),i.codempid,v_chken);
                insert into totsum
                            (codempid,dteyrepay,dtemthpay,numperiod,
                             codcomp,typpayroll,typemp,qtysmot,
                             amtottot,amtothr,dteupd,coduser,codcreate,costcent)
                       values
                            (i.codempid,v_year,p_dtemthpay,p_numperiod,
                            j.codcomp,j.typpayroll,j.typemp,i.sum_qtysmot,
                            stdenc(i.sum_amtspot,v_codempid,v_chken),v_amtothr,trunc(sysdate),
                            global_v_coduser,global_v_coduser,v_costcent);
              else	-- false found update
                if p_typtran = '1' or p_typtran = '2' then
                  update totsum
                       set codcomp  	= j.codcomp,
                           typpayroll	= j.typpayroll,
                           typemp			= j.typemp,
                           qtysmot    = i.sum_qtysmot,
                           amtottot   = stdenc(i.sum_amtspot,v_codempid,v_chken),
                           dteupd     = trunc(sysdate)
                     where codempid  = v_codempid
                       and dteyrepay = v_year
                       and dtemthpay = p_dtemthpay
                       and numperiod = p_numperiod;
                end if;
              end if;
            end loop;
          end loop;
--          commit;
        end if;
      end if;
    end loop;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end transfer_totsum;

end HRPY28B;

/
