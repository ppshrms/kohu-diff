--------------------------------------------------------
--  DDL for Package Body HRES69X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRES69X" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_period            := hcm_util.get_number_t(json_obj, 'p_period');
    p_month             := hcm_util.get_number_t(json_obj, 'p_month');
    p_year              := hcm_util.get_number_t(json_obj, 'p_year');
    p_deduct            := upper(hcm_util.get_string_t(json_obj, 'p_deduct'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcomp       ttaxcur.codcomp%type;
    v_typpayroll    ttaxcur.typpayroll%type;
    v_dtewatch      tdtepay.dtewatch%type;
    v_dtepaymt      tdtepay.dtepaymt%type;
    v_timwatch      tdtepay.timwatch%type;
  begin
    if p_period is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
    end if;

    if p_month is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
    end if;

    if p_year is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
    end if;

    if p_deduct is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang);
        return;
    --<<User37 #5390 Final Test Phase 1 V11 23/03/2021 
    else
        begin
            select codalw
              into p_codalw
              from tpaysum 
             where codempid = global_v_codempid
               and dteyrepay  = p_year
               and numperiod  = p_period
               and dtemthpay  = p_month
               and codpay     = p_deduct
               and rownum     = 1;
        exception when no_data_found then
            null;
        end;
        if p_codalw = 'OT' then
            p_codalw := 'OT';
        elsif (p_codalw = 'AWARD') or (p_codalw = 'PAY_VACAT') then
            p_codalw := 'AWARD';
        else
            p_codalw := 'PAYOTH';
        end if;
    -->>User37 #5390 Final Test Phase 1 V11 23/03/2021 
    end if;

    -- check dtewatch
   begin
    select codcomp, typpayroll into v_codcomp, v_typpayroll
      from ttaxcur
     where codempid  = global_v_codempid
       and dteyrepay = p_year
       and dtemthpay = p_month
       and numperiod = p_period;
    exception when no_data_found then
      v_codcomp     := null;
      v_typpayroll  := null;
    end;
    --
    begin
      select dtepaymt, dtewatch, timwatch into v_dtepaymt, v_dtewatch, v_timwatch
        from tdtepay
       where codcompy   = hcm_util.get_codcomp_level(v_codcomp, 1)
         and typpayroll = v_typpayroll
         and numperiod  = p_period
         and dtemthpay  = p_month
         and dteyrepay  = p_year;
    exception when no_data_found then
      v_dtewatch := null;
      v_timwatch := null;
    end ;

    if v_dtewatch is null then
      v_dtewatch := v_dtepaymt;
    else
      v_dtewatch := to_date(to_char(v_dtewatch, 'dd/mm/yyyy') || nvl(v_timwatch, '0000'), 'dd/mm/yyyyhh24mi');
    end if;

    if v_dtewatch is not null then
      if sysdate < v_dtewatch then
        param_msg_error := get_error_msg_php('HR2055', global_v_lang);
        return;
      end if;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      --<<User37 #5390 Final Test Phase 1 V11 23/03/2021 
      if p_codalw = 'OT' then
        gen_index(json_str_output);
      elsif (p_codalw = 'AWARD') or (p_codalw = 'PAY_VACAT') then
        gen_award(json_str_output);
      else
        gen_pay_other(json_str_output);
      end if;
      --gen_index(json_str_output);
      -->>User37 #5390 Final Test Phase 1 V11 23/03/2021 
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    obj_result         json_object_t; --User37 #5390 Final Test Phase 1 V11 23/03/2021 
    v_rcnt             number := 0;

    cursor cl is
      select  a.dtework,
              b.typot,
              rteotpay,
              qtyminot,
              amtottot
          from tpaysum2 a, totpaydt b
         where dteyrepay  = p_year
           and numperiod  = p_period
           and dtemthpay  = p_month
           and a.codpay   = p_deduct--User37 #5390 Final Test Phase 1 V11 23/03/2021 and codalw     = 'OT'
           and a.codempid = global_v_codempid
           and a.dtework  = b.dtework
           and a.codempid = b.codempid
           and a.codshift = b.typot
        order by a.dtework, codshift, rteotpay;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in cl loop
      v_rcnt               := v_rcnt + 1;
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtework', to_char(r1.dtework, 'dd/mm/yyyy'));
      obj_data.put('typot', r1.typot);
      obj_data.put('desc_typot', get_tlistval_name('TYPOT', r1.typot, global_v_lang));
      obj_data.put('rteotpay', r1.rteotpay);
      obj_data.put('qtyminot', r1.qtyminot);
      obj_data.put('amtottot', nvl(stddec(r1.amtottot, global_v_codempid, v_chken), 0));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tpaysum2');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      --<<User37 #5390 Final Test Phase 1 V11 23/03/2021 
      obj_result := json_object_t();
      obj_result.put('coderror', '200');
      obj_result.put('typeColumn', p_codalw);
      obj_result.put('amtpay', '');
      obj_result.put('table', obj_row);
      json_str_output := obj_result.to_clob;
      --json_str_output := obj_row.to_clob;
      -->>User37 #5390 Final Test Phase 1 V11 23/03/2021 
    end if;
  end gen_index;

  procedure get_pay_other (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_pay_other(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_pay_other;

  procedure gen_pay_other (json_str_output out clob) AS
    obj_row            json_object_t;
    obj_data           json_object_t;
    obj_result         json_object_t; --User37 #5390 Final Test Phase 1 V11 23/03/2021 
    v_rcnt             number := 0;
    v_timstrt          varchar2(5 char) := '';
    v_timend           varchar2(5 char) := '';
    v_time             varchar2(100 char) := '-';

    cursor cl is
      select dtework,
             codshift,
             timstrt,
             timend,
             qtymin,
             amtpay
         from tpaysum2
        where dteyrepay = p_year
          and numperiod = p_period
          and dtemthpay = p_month
          and codpay    = p_deduct--User37 #5390 Final Test Phase 1 V11 23/03/2021 and codalw    = p_deduct
          and codempid  = global_v_codempid
        order by dtework;

  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    for r1 in cl loop
      v_rcnt               := v_rcnt + 1;
      obj_data             := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('dtework', to_char(r1.dtework, 'dd/mm/yyyy'));
      obj_data.put('codshift', r1.codshift);
      -- obj_data.put('desc_codshift', r1.codshift || ' - ' || get_tshiftcd_name(r1.codshift, global_v_lang));
      obj_data.put('desc_codshift', r1.codshift);
      v_timstrt            := '';
      v_timend             := '';
      v_time               := '-';
      if r1.timstrt is not null then
        v_timstrt := to_char(substr(r1.timstrt, 1, 2) || ':' || substr(r1.timstrt, 3, 4));
      end if;
      if r1.timend is not null then
        v_timend := to_char(substr(r1.timend, 1, 2) || ':' || substr(r1.timend, 3, 4));
      end if;
      v_time := v_timstrt || ' - ' || v_timend;
      obj_data.put('time', v_time);
      obj_data.put('qtymin', r1.qtymin);
      obj_data.put('amtpay', nvl(stddec(r1.amtpay, global_v_codempid, v_chken), 0));

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;

    if v_rcnt = 0 then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tpaysum2');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    else
      --<<User37 #5390 Final Test Phase 1 V11 23/03/2021 
      obj_result := json_object_t();
      obj_result.put('coderror', '200');
      obj_result.put('typeColumn', p_codalw);
      obj_result.put('amtpay', '');
      obj_result.put('table', obj_row);
      json_str_output := obj_result.to_clob;
      --json_str_output := obj_row.to_clob;
      -->>User37 #5390 Final Test Phase 1 V11 23/03/2021 
    end if;
  end gen_pay_other;

  procedure get_award (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_award(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_award;

  procedure gen_award (json_str_output out clob) AS
    obj_data           json_object_t;
    obj_result         json_object_t;--User37 #5390 Final Test Phase 1 V11 23/03/2021 
    obj_row            json_object_t;--User37 #5390 Final Test Phase 1 V11 23/03/2021 
    v_amtpay           number := 0;
  begin
    obj_data             := json_object_t();
    obj_row              := json_object_t();
    begin
      select sum(stddec(amtpay, codempid, v_chken)) into v_amtpay--User37 #5390 Final Test Phase 1 V11 23/03/2021 stddec(amtpay, codempid, v_chken) into v_amtpay
        from tpaysum
      where dteyrepay = p_year
        and numperiod = p_period
        and dtemthpay = p_month
        and codpay    = p_deduct--and codalw    = p_deduct
        and codempid  = global_v_codempid;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tpaysum');
    end;
    if param_msg_error is null then
      obj_data.put('coderror', '200');
      obj_data.put('typeColumn', p_codalw);--User37 #5390 Final Test Phase 1 V11 23/03/2021 
      obj_data.put('amtpay', to_char(nvl(v_amtpay, 0)));
      obj_data.put('table', obj_row);--User37 #5390 Final Test Phase 1 V11 23/03/2021 
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_award;

  procedure get_lov_codalw(json_str_input in clob, json_str_output out clob) as

    obj_row         json_object_t;
    obj_data        json_object_t;
    obj_lang1       json_object_t;
    obj_lang2       json_object_t;
    obj_lang3       json_object_t;
    obj_lang4       json_object_t;
    obj_lang5       json_object_t;

    --<<User37 #5390 Final Test Phase 1 V11 23/03/2021 
    cursor c1 is
      select distinct a.codpay
        from tpaysum a
       where a.codempid  = global_v_codempid
         and a.numperiod = p_period
         and a.dtemthpay = p_month
         and a.dteyrepay = p_year
       order by codpay;

    /*cursor c1 is
      select distinct a.codalw , b.codapp, b.codlang, b.desc_label, b.numseq, b.list_value
        from tpaysum a, tlistval b
       where a.codempid  = global_v_codempid
         and a.numperiod = p_period
         and a.dtemthpay = p_month
         and a.dteyrepay = p_year
         and b.codapp    = 'CODALW'
         and b.numseq > 0
         and (flgused = 'Y' or flgused is null)
         and a.codalw = b.list_value
       order by b.codapp, b.codlang, b.numseq;*/
    -->>User37 #5390 Final Test Phase 1 V11 23/03/2021  

  begin
    initial_value(json_str_input);
    obj_row := json_object_t();

    obj_lang1       := json_object_t();
    obj_lang2       := json_object_t();
    obj_lang3       := json_object_t();
    obj_lang4       := json_object_t();
    obj_lang5       := json_object_t();
    --<<User37 #5390 Final Test Phase 1 V11 23/03/2021 
    for r1 in c1 loop
      for i in 1..5 loop
          obj_data := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('value', r1.codpay);
          obj_data.put('label', GET_TINEXINF_NAME(r1.codpay,'10'||i));
          if i = 1 then
            obj_lang1.put(obj_lang1.get_size, obj_data);
          elsif i = 2 then
            obj_lang2.put(obj_lang2.get_size, obj_data);
          elsif i = 3 then
            obj_lang3.put(obj_lang3.get_size, obj_data);
          elsif i = 4 then
            obj_lang4.put(obj_lang4.get_size, obj_data);
          elsif i = 5 then
            obj_lang5.put(obj_lang5.get_size, obj_data);
          end if;
      end loop;
    end loop;
    /*for r1 in c1 loop
      obj_data := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('codapp', r1.codapp);
      obj_data.put('codlang', r1.codlang);
      obj_data.put('value', r1.list_value);
      obj_data.put('label', r1.desc_label);

      if r1.codlang = '101' then
        obj_lang1.put(obj_lang1.get_size, obj_data);
      elsif r1.codlang = '102' then
        obj_lang2.put(obj_lang2.get_size, obj_data);
      elsif r1.codlang = '103' then
        obj_lang3.put(obj_lang3.get_size, obj_data);
      elsif r1.codlang = '104' then
        obj_lang4.put(obj_lang4.get_size, obj_data);
      elsif r1.codlang = '105' then
        obj_lang5.put(obj_lang5.get_size, obj_data);
      end if;
    end loop;*/
    -->>User37 #5390 Final Test Phase 1 V11 23/03/2021 
    obj_row.put('coderror', '200');
    obj_row.put('lang1', obj_lang1);
    obj_row.put('lang2', obj_lang2);
    obj_row.put('lang3', obj_lang3);
    obj_row.put('lang4', obj_lang4);
    obj_row.put('lang5', obj_lang5);

    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400', param_msg_error, global_v_lang);
  end get_lov_codalw;
end HRES69X;

/
