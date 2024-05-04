--------------------------------------------------------
--  DDL for Package Body HRPY5RX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5RX" as

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
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_flgrep            := hcm_util.get_string_t(json_obj,'p_flgrep');
    p_codpay            := hcm_util.get_string_t(json_obj,'p_codpay');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_tmp   varchar2(1 char);
  begin
    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_numperiod');
    end if;

    if p_dtemthpay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dtemthpay');
    end if;

    if p_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_dteyrepay');
    end if;

    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codcomp');
    end if;

    if p_typpayroll is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_typpayroll');
    end if;

    if p_flgrep = '2' then
      if p_codpay is null then
        param_msg_error := get_error_msg_php('HR2045', global_v_lang, 'p_codpay');
      end if;
    end if;

    begin
      select 'X'
        into v_tmp
        from tcodtypy
       where codcodec = p_typpayroll;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TCPDTYPY');
    end;

    if p_codpay is not null then
      begin
        select 'X'
          into v_tmp
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'TINEXINF');
      end;
    end if;

    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
  end check_index;

  procedure chk_tfincadj (v_codempid 	in varchar2,
                         v_start		in date,
                         v_end			in date,
                         v_dteadj 		out varchar2) is

    cursor c_tfincadj is
      select distinct dteeffec
        from tfincadj
       where codempid = v_codempid
         and dteyrepay = p_dteyrepay
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
         and dteeffec = ( select max(dteeffec)
                            from tfincadj
                           where codempid = v_codempid
                             and dteyrepay = p_dteyrepay
                             and dtemthpay = p_dtemthpay
                             and numperiod = p_numperiod)
         and rownum    <= 1
    order by dteeffec;

    v_eff   varchar2(10);

  begin
    v_dteadj := null;
    for r_tfincadj in c_tfincadj loop
      v_eff := to_char(r_tfincadj.dteeffec,'dd')||'/'||to_char(r_tfincadj.dteeffec,'mm')||
               '/'||to_char(r_tfincadj.dteeffec,'yyyy');
      if v_dteadj is not null then
        v_dteadj := v_dteadj||','||v_eff;
      else
        v_dteadj := v_eff;
      end if;
    end loop;
  end;

  procedure chk_tfincadj2 (v_codempid 	in varchar2,
                           v_cdseq		in number,
                           v_start		in date,
                           v_end		in date,
                           v_dteadj 	out varchar2) IS

    cursor c_tfincadj is
      select dteeffec,
             decode(v_cdseq,1,amtincn1,2,amtincn2,3,amtincn3,4,amtincn4,5,amtincn5,
                    6,amtincn6,7,amtincn7,8,amtincn8,9,amtincn9,10,amtincn10,null) amt
        from tfincadj
       where codempid = v_codempid
         and dteyrepay = p_dteyrepay
         and dtemthpay = p_dtemthpay
         and numperiod = p_numperiod
  --      and dteeffec between v_start and v_end
    order by dteeffec;

    v_eff   varchar2(10);

  begin
    v_dteadj := null;
    for r_tfincadj in c_tfincadj loop
      if nvl(stddec(r_tfincadj.amt,v_codempid,v_chken),0) <> 0 then
        v_eff := to_char(r_tfincadj.dteeffec,'dd')||'/'||to_char(r_tfincadj.dteeffec,'mm')||
                 '/'||to_char(r_tfincadj.dteeffec,'yyyy');
        if v_dteadj is not null then
--          v_dteadj := v_dteadj||','||v_eff;-- user18 15/12/2021
          v_dteadj := v_dteadj||','||hcm_util.GET_DATE_BUDDHIST_ERA(trunc(to_date(v_eff,'dd/mm/yyyy'))) ;-- user18 15/12/2021
        else
--          v_dteadj := v_eff;-- user18 15/12/2021
          v_dteadj := hcm_util.GET_DATE_BUDDHIST_ERA(trunc(to_date(v_eff,'dd/mm/yyyy')));-- user18 15/12/2021
        end if;
      end if;
    end loop;
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      if p_flgrep = '1' then
        gen_ttaxcur(json_str_output);
      else
        gen_tsincexp(json_str_output);
      end if;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_ttaxcur(json_str_output out clob) is
    obj_row           json_object_t := json_object_t();
    obj_row2          json_object_t := json_object_t();
    obj_data          json_object_t;
    obj_data2         json_object_t;
    v_flgpass		      boolean := true;
    v_row             number := 0;
    v_num             number := 0;
    v_data            varchar2(1 char)  := 'N';
    v_chk	            varchar2(1 char)  := 'N';
    v_chksecu	        varchar2(1 char)	:= 'N';
    v_chktax          varchar2(1 char)	:= 'N';
    v_codcomp         varchar2(100 char);
    v_l_codcomp       varchar2(100 char);
    v_lastdate        date;
    v_enddate         date;
    v_data3		        date;
    v_data4           date;
    v_data5           date;
    v_dteadj		      varchar2(200);

    v_yrmtn           number;
    v_empid           varchar2(100 char) := '00000000';
    v_amtnet1         number := 0;
    v_rebate1         number := 0;
    v_total1          number := 0;
    v_amtnet2         number := 0;
    v_rebate2         number := 0;
    v_total2          number := 0;
    v_total           number := 0;
    v_sum_num1        number := 0;
    v_sum_amtnet1     number := 0;
    v_sum_num2        number := 0;
    v_sum_amtnet2     number := 0;
    v_sum_num3        number := 0;
    v_sum_amtnet3     number := 0;
    v_comment         varchar2(4000 char);
    v_count           number := 0;
    v_codapp          varchar2(100 char):= 'HRPY5RXC2';
    v_dteeffec        date;

    cursor c_tdtepay is
      select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
        from tdtepay
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and typpayroll = p_typpayroll
         and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <= v_yrmtn
    order by dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') desc;

    cursor c1 is
      select a.codcomp,a.codempid,b.dteempmt,b.dteeffex,b.dtereemp,
             a.dteyrepay,a.dtemthpay,a.numperiod,
             nvl(stddec(a.amtnet,a.codempid,v_chken),0) amtnet,a.rowid
        from ttaxcur a,temploy1 b
       where /*a.codcomp like p_codcomp||'%'
         and*/ a.typpayroll = p_typpayroll
         and a.codempid = b.codempid
         and (((a.dteyrepay = p_dteyrepay)
         and  (a.dtemthpay  = p_dtemthpay)
         and  (a.numperiod  = p_numperiod))
          or ((a.dteyrepay  = v_lastyear)
         and  (a.dtemthpay  = v_lastmth)
         and  (a.numperiod  = v_lastperiod)))
         and a.codempid in (select a.codempid
                              from ttaxcur a,temploy1 b
                             where a.typpayroll = p_typpayroll
                               and a.codempid = b.codempid
                               and ((a.codcomp like p_codcomp||'%' and a.dteyrepay = p_dteyrepay
                                       and  a.dtemthpay  = p_dtemthpay
                                       and  a.numperiod  = p_numperiod)
                                   or (a.codcomp like p_codcomp||'%' and a.dteyrepay  = v_lastyear
                                       and  a.dtemthpay  = v_lastmth
                                       and  a.numperiod  = v_lastperiod))
                          group by a.codempid
                            having sum(nvl(stddec(a.amtnet,a.codempid,v_chken),0) *
                                   decode(dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0'),v_yrmtn,1,-1)) <> 0)
      order by a.codempid,a.dteyrepay, a.dtemthpay,a.numperiod;

    cursor c2 is -- count this period
      select a.codcomp,a.codempid,
             sum(nvl(stddec(a.amtnet,a.codempid,v_chken),0)) sum_amtnet
        from ttaxcur a,temploy1 b
       where a.codcomp like p_codcomp||'%'
         and a.typpayroll = p_typpayroll
         and a.codempid = b.codempid
         and a.dteyrepay = p_dteyrepay
         and a.dtemthpay = p_dtemthpay
         and a.numperiod = p_numperiod
      group by a.codcomp,a.codempid
      order by a.codcomp,a.codempid;

    cursor c3 is -- count last period
      select a.codcomp,a.codempid,
             sum(nvl(stddec(a.amtnet,a.codempid,v_chken),0)) sum_amtnet
        from ttaxcur a,temploy1 b
       where a.codcomp like p_codcomp||'%'
         and a.typpayroll = p_typpayroll
         and a.codempid = b.codempid
         and a.dteyrepay = v_lastyear
         and a.dtemthpay = v_lastmth
         and a.numperiod = v_lastperiod
      group by a.codcomp,a.codempid
      order by a.codcomp,a.codempid;

  begin
    obj_row2 := json_object_t();
    v_yrmtn := (p_dteyrepay)||lpad(p_dtemthpay,2,'0')||lpad(p_numperiod,2,'0');
    for r1 in c_tdtepay loop
      v_num := v_num + 1;
      if v_num = 1 then
        v_dtestrt 		:= r1.dtestrt;
        v_dteend 		:= r1.dteend;
        v_lastdtestrt   := r1.dtestrt;
        v_lastdteend    := r1.dteend;
        v_lastyear 		:= r1.dteyrepay;
        v_lastmth 		:= r1.dtemthpay;
        v_lastperiod 	:= r1.numperiod;
      else
        v_lastdtestrt	:= r1.dtestrt;
        v_lastdteend	:= r1.dteend;
        v_lastyear  	:= r1.dteyrepay;
        v_lastmth     := r1.dtemthpay;
        v_lastperiod	:= r1.numperiod;
        exit;
      end if;
    end loop;
    v_sum_num3 := 0;
    for r1 in c1 loop	 --gen_ttaxcur
      v_data := 'Y';

      v_flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass then
         v_chksecu	:= 'Y';

        if v_empid <> r1.codempid then
          v_empid   := r1.codempid;
          v_codcomp := r1.codcomp;
          v_count := 1;
          v_row := v_row + 1;
          v_amtnet1 := 0;
          v_amtnet2 := 0;
        else
          v_count := v_count + 1;
        end if;

        if (r1.dteyrepay = p_dteyrepay) and (r1.dtemthpay = p_dtemthpay) and (r1.numperiod = p_numperiod) then
          v_amtnet1 := r1.amtnet;
        else
          v_amtnet2 := r1.amtnet;
--          v_l_codcomp := hcm_util.get_codcomp_level(r1.codcomp,1);
          v_l_codcomp := r1.codcomp;
        end if;
        v_total1 := v_amtnet1;
        v_total2 := v_amtnet2;
        v_total  := nvl(v_total1,0) - nvl(v_total2,0);
      end if;

      v_lastdate := v_lastdtestrt;
      v_enddate  := v_dteend;
      v_data3    := r1.dteempmt;
      v_data4    := r1.dteeffex;
      v_data5    := r1.dtereemp;

        begin
            select max(dteeffec) 
              into v_dteeffec
              from ttexempt 
             where codempid = r1.codempid 
               and staupd in ('C','U');
        exception when no_data_found then
            v_dteeffec := null;
        end;

      if (r1.dteempmt between v_lastdate and v_enddate ) or (r1.dtereemp between v_lastdate and v_enddate ) then
          begin
            select 'Y'
              into v_chktax
              from ttaxcur
             where dteyrepay = v_lastyear
               and dtemthpay = v_lastmth
               and numperiod = v_lastperiod
               and codempid  = r1.codempid;
          exception when no_data_found then
            v_chktax := 'N';
          end;
      end if;

      if (v_data3 between v_lastdate and v_enddate) and v_chktax = 'N' then
        if v_dteeffec is null then
            v_comment := get_label_name(v_codapp,global_v_lang,10)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(v_data3);
        else
            v_comment := get_label_name(v_codapp,global_v_lang,10)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(v_data3) || ' - ' || hcm_util.GET_DATE_BUDDHIST_ERA(v_dteeffec);
        end if;
      elsif (v_data5 between v_lastdate and v_enddate) and v_chktax = 'N' then
        v_comment := get_label_name(v_codapp,global_v_lang,10)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(v_data5);
      elsif (hcm_util.get_codcomp_level(v_codcomp,1) = hcm_util.get_codcomp_level(p_codcomp,1)) and (hcm_util.get_codcomp_level(v_l_codcomp,1) <> hcm_util.get_codcomp_level(p_codcomp,1)) and (hcm_util.get_codcomp_level(v_l_codcomp,1) is not null) then
        v_comment   := get_label_name(v_codapp,global_v_lang,10);
        v_total2    := 0;
        v_amtnet2   := 0;
        v_total  := nvl(v_total1,0) - nvl(v_total2,0);
      elsif (v_dteeffec between (v_lastdate + 1) and (v_enddate + 1)) then
        v_comment := get_label_name(v_codapp,global_v_lang,20)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(v_data4);
      elsif (hcm_util.get_codcomp_level(v_l_codcomp,1) = hcm_util.get_codcomp_level(p_codcomp,1)) and (hcm_util.get_codcomp_level(v_codcomp,1) <> hcm_util.get_codcomp_level(p_codcomp,1)) and (hcm_util.get_codcomp_level(v_codcomp,1) is not null) then
        v_comment := get_label_name(v_codapp,global_v_lang,20);
        v_total1    := 0;
        v_amtnet1   := 0;
        v_total  := nvl(v_total1,0) - nvl(v_total2,0);
--      elsif (hcm_util.get_codcomp_level(r1.codcomp,1) like hcm_util.get_codcomp_level(p_codcomp,1)) and (v_l_codcomp not like hcm_util.get_codcomp_level(p_codcomp,1)) then
      elsif (v_codcomp like p_codcomp) and (v_l_codcomp not like p_codcomp) then
        v_comment := get_label_name(v_codapp,global_v_lang,40);
--      elsif (v_l_codcomp like hcm_util.get_codcomp_level(p_codcomp,1)) and (hcm_util.get_codcomp_level(r1.codcomp,1) not like p_codcomp,1)) then
      elsif (v_l_codcomp like p_codcomp) and (v_codcomp not like p_codcomp) then
        v_comment := get_label_name(v_codapp,global_v_lang,50);
      else
        chk_tfincadj(r1.codempid,v_lastdate,v_enddate,v_dteadj);
        if v_dteadj is not null then
          v_comment := get_label_name(v_codapp,global_v_lang,60)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(trunc(to_date(v_dteadj,'dd/mm/yyyy')));
        else
          v_comment := null;
        end if;
      end if;

      v_codcomp := r1.codcomp;

--      if v_count = 2 then
--        v_row := v_row + 1;
        obj_data2 := json_object_t();
        obj_data2.put('coderror','200');
        obj_data2.put('image', v_empid);
        obj_data2.put('codempid', v_empid);
        obj_data2.put('desc_codempid', get_temploy_name(v_empid, global_v_lang));
        obj_data2.put('codcomp', v_codcomp);
        obj_data2.put('amtnet1', v_amtnet1);
        obj_data2.put('rebate1', v_rebate1);
        obj_data2.put('total1', v_total1);
        obj_data2.put('amtnet2', v_amtnet2);
        obj_data2.put('rebate2', v_rebate2);
        obj_data2.put('total2', v_total2);
        obj_data2.put('total', v_total);
        obj_data2.put('comment', v_comment);
        obj_data2.put('dtemthpay', r1.dtemthpay);
        obj_data2.put('dteyrepay', r1.dteyrepay);
        obj_data2.put('numperiod', r1.numperiod);
        obj_row2.put(to_char(v_row - 1), obj_data2);

--      end if;
    end loop;

    for r2 in c2 loop
      v_flgpass := secur_main.secur3(r2.codcomp,r2.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass then
        v_sum_num1 := v_sum_num1 + 1;
        v_sum_amtnet1 := nvl(v_sum_amtnet1,0) + r2.sum_amtnet;
      end if;
    end loop;

    if v_dtestrt <> v_lastdtestrt then
      for r3 in c3 loop
        v_flgpass := secur_main.secur3(r3.codcomp,r3.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if v_flgpass then
          v_sum_num2 := v_sum_num2 + 1;
          v_sum_amtnet2 := nvl(v_sum_amtnet2,0) + r3.sum_amtnet;
        end if;
      end loop;
    end if;

    v_sum_num3 := v_sum_num1 - v_sum_num2;
    v_sum_amtnet3 := v_sum_amtnet1 - v_sum_amtnet2;

    obj_data := json_object_t();
    --v_rcnt    := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('sum_num1', nvl(v_sum_num1,0));
    obj_data.put('sum_amtnet1', to_char(nvl(v_sum_amtnet1,0),'FM9,999,999,990.00'));
    obj_data.put('sum_num2', nvl(v_sum_num2,0));
    obj_data.put('sum_amtnet2', to_char(nvl(v_sum_amtnet2,0),'FM9,999,999,990.00'));
    obj_data.put('sum_num3', nvl(v_sum_num3,0));
    obj_data.put('sum_amtnet3', to_char(nvl(v_sum_amtnet3,0),'FM9,999,999,990.00'));

    obj_data.put('table', obj_row2);
    --obj_row.put(to_char(v_rcnt - 1), obj_data);

    if v_data = 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'ttaxcur');
    else
      if v_chksecu = 'N' then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      end if;
    end if;

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_ttaxcur;

  procedure gen_tsincexp(json_str_output out clob) is
    obj_row           json_object_t := json_object_t();
    obj_row2          json_object_t := json_object_t();
    obj_data          json_object_t;
    obj_data2         json_object_t;
    v_flgpass		      boolean := true;
    v_row             number := 0;
    v_num             number := 0;
    TYPE a_string IS TABLE OF VARCHAR2(1000 CHAR) INDEX BY BINARY_INTEGER;
    v_codincom        a_string;
    v_codretro        a_string;
    v_data            varchar2(1 char)  := 'N';
    v_chk	            varchar2(1 char)  := 'N';
    v_chksecu	        varchar2(1 char)	:= 'N';
    v_chktax          varchar2(1 char)	:= 'N';
    v_codcomp         varchar2(100 char);
    v_codpay          varchar2(10 char);
    v_l_codcomp       varchar2(100 char);
    v_lastdate        date;
    v_enddate         date;
    v_data3		        date;
    v_data4           date;
    v_data5           date;
    v_chk_date		    date;
    v_dteadj		      varchar2(200);

    v_yrmtn           number;
    v_empid           varchar2(100 char) := '00000000';
    v_amtnet1         number := 0;
    v_rebate1         number := 0;
    v_total1          number := 0;
    v_amtnet2         number := 0;
    v_rebate2         number := 0;
    v_total2          number := 0;
    v_total           number := 0;
    v_sum_num1        number := 0;
    v_sum_amtnet1     number := 0;
    v_sum_num2        number := 0;
    v_sum_amtnet2     number := 0;
    v_sum_num3        number := 0;
    v_sum_amtnet3     number := 0;
    v_comment         varchar2(4000 char);
    v_count           number := 0;
    v_codapp          varchar2(100 char):= 'HRPY5RXC2';
    v_cdseq		        number;
    v_amtincom1       number;
    v_amtdata         varchar(100 char);

    cursor c_tdtepay is
      select dteyrepay,dtemthpay,numperiod,dtestrt,dteend
        from tdtepay
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and typpayroll = p_typpayroll
         and dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') <= v_yrmtn
    order by dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0') desc;

    cursor c1 is
      select a.codcomp,a.codempid,b.dteempmt,b.dteeffex,b.dtereemp,
             a.dteyrepay,a.dtemthpay,a.numperiod,a.codpay,
             nvl(stddec(a.amtpay,a.codempid,v_chken),0) amtpay,a.rowid
        from tsincexp a,temploy1 b
       where /*a.codcomp like p_codcomp||'%'
         and*/ a.typpayroll = p_typpayroll
         and a.codempid = b.codempid
         and (((a.dteyrepay = p_dteyrepay)
         and  (a.dtemthpay  = p_dtemthpay)
         and  (a.numperiod  = p_numperiod))
          or ((a.dteyrepay  = v_lastyear)
         and  (a.dtemthpay  = v_lastmth)
         and  (a.numperiod  = v_lastperiod)))
         and a.codpay in (p_codpay,v_codpay)
         and a.flgslip = 1
         and a.codempid in (select a.codempid
                              from tsincexp a,temploy1 b
                             where /*a.codcomp like p_codcomp||'%'
                               and*/ a.typpayroll = p_typpayroll
                               and a.codempid = b.codempid
                               and (((a.codcomp like p_codcomp||'%'
                               and a.dteyrepay = p_dteyrepay)
                               and  (a.dtemthpay  = p_dtemthpay)
                               and  (a.numperiod  = p_numperiod))
                                or ((a.codcomp like p_codcomp||'%'
                               and a.dteyrepay  = v_lastyear)
                               and  (a.dtemthpay  = v_lastmth)
                               and  (a.numperiod  = v_lastperiod)))
                               and a.codpay in (p_codpay,v_codpay)
                               and a.flgslip = 1
                          group by a.codempid
                        having sum(nvl(stddec(a.amtpay,a.codempid,v_chken),0) *
                                   decode(dteyrepay||lpad(dtemthpay,2,'0')||lpad(numperiod,2,'0'),v_yrmtn,1,-1)) <> 0)
      order by a.codempid ,a.dteyrepay desc,a.dtemthpay desc,a.numperiod desc ;
      --Chai 2023-02-21


    cursor c2 is -- count this period
      select a.codcomp,a.codempid,
             sum(nvl(stddec(a.amtpay,a.codempid,v_chken),0)) sum_amtpay
        from tsincexp a,temploy1 b
	     where a.codcomp like p_codcomp||'%'
         and a.typpayroll = p_typpayroll
         and a.codempid   = b.codempid
         and a.dteyrepay  = p_dteyrepay
         and a.dtemthpay  = p_dtemthpay
         and a.numperiod  = p_numperiod
         and a.codpay in (p_codpay,v_codpay)
         and a.flgslip = 1
		group by a.codcomp,a.codempid
		order by a.codcomp,a.codempid;

    cursor c3 is -- count last period
      select a.codcomp,a.codempid,
             sum(nvl(stddec(a.amtpay,a.codempid,v_chken),0)) sum_amtpay
        from tsincexp a,temploy1 b
       where a.codcomp like p_codcomp||'%'
         and a.typpayroll = p_typpayroll
         and a.codempid = b.codempid
         and a.dteyrepay = v_lastyear
         and a.dtemthpay = v_lastmth
         and a.numperiod = v_lastperiod
         and a.codpay in (p_codpay,v_codpay)
         and a.flgslip = 1
		group by a.codcomp,a.codempid
		order by a.codcomp,a.codempid;

    v_dteeffec        date;
  begin
    obj_row2    := json_object_t();
    v_yrmtn     := (p_dteyrepay)||lpad(p_dtemthpay,2,'0')||lpad(p_numperiod,2,'0');

    for r1 in c_tdtepay loop
      v_num := v_num + 1;
      if v_num = 1 then
        v_dtestrt 		:= r1.dtestrt;
        v_dteend 		  := r1.dteend;
        v_lastdtestrt := r1.dtestrt;
        v_lastdteend  := r1.dteend;
        v_lastyear 		:= r1.dteyrepay;
        v_lastmth 		:= r1.dtemthpay;
        v_lastperiod 	:= r1.numperiod;
      else
        v_lastdtestrt	:= r1.dtestrt;
        v_lastdteend	:= r1.dteend;
        v_lastyear  	:= r1.dteyrepay;
        v_lastmth     := r1.dtemthpay;
        v_lastperiod	:= r1.numperiod;
        exit;
      end if;
    end loop;

    for i in 0..10 loop
      v_codincom(i) := '';
      v_codretro(i) := '';
    end loop;

    if (v_dteend is not null) then
      v_chk_date := v_dteend;
    else
      v_chk_date := trunc(sysdate);
    end if;
    begin
      select codincom1, codincom2, codincom3, codincom4, codincom5,
             codincom6, codincom7, codincom8, codincom9, codincom10,
             codretro1, codretro2, codretro3, codretro4, codretro5,
             codretro6, codretro7, codretro8, codretro9, codretro10
        into v_codincom(1), v_codincom(2), v_codincom(3), v_codincom(4), v_codincom(5),
             v_codincom(6), v_codincom(7), v_codincom(8), v_codincom(9), v_codincom(10),
             v_codretro(1), v_codretro(2), v_codretro(3), v_codretro(4), v_codretro(5),
             v_codretro(6), v_codretro(7), v_codretro(8), v_codretro(9), v_codretro(10)
        from tcontpms
       where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
         and dteeffec = (select max(dteeffec)
                           from tcontpms
                          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                            and dteeffec <= v_chk_date);
    exception when no_data_found then null;
    end;

    v_chk := 'N';
    for i in 1..10 loop
      if p_codpay = v_codincom(i) then
        v_codpay    := v_codretro(i);
        v_chk       := 'Y';
        v_cdseq     := i;
        exit;
      end if;
    end loop;

    for r1 in c1 loop	 --gen_ttaxcur
      v_data := 'Y';
      v_flgpass := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass then
         v_chksecu	:= 'Y';
        if v_empid <> r1.codempid then
          v_empid       := r1.codempid;
          v_codcomp     := r1.codcomp;
          v_count       := 1;
          v_row         := v_row + 1;
          v_rebate1     := 0;
          v_rebate2     := 0;
          v_amtnet1     := 0;
          v_amtnet2     := 0;
        else
          v_count       := v_count + 1;
        end if;

        if (r1.dteyrepay = p_dteyrepay) and (r1.dtemthpay = p_dtemthpay) and (r1.numperiod = p_numperiod) then -- current
          if r1.codpay = v_codpay then
            v_rebate1 := r1.amtpay;
          else
            v_amtnet1 := r1.amtpay;
          end if;

        else -- Last
          --Chai 2023-02-21
          if  (hcm_util.get_codcomp_level(r1.codcomp,1) = hcm_util.get_codcomp_level(p_codcomp,1)) then
              if r1.codpay = v_codpay then
                v_rebate2 := r1.amtpay;
              else
                v_amtnet2 := r1.amtpay;
              end if;              
           end if;   
           v_l_codcomp := r1.codcomp;
--          v_l_codcomp := hcm_util.get_codcomp_level(r1.codcomp,1);
        end if;



        v_total1 := nvl(v_amtnet1,0) + nvl(v_rebate1,0);
        v_total2 := nvl(v_amtnet2,0) + nvl(v_rebate2,0);
        v_total  := nvl(v_total1,0) - nvl(v_total2,0);
      end if;
      v_lastdate    := v_lastdtestrt;
      v_enddate     := v_dteend;
      v_data3       := r1.dteempmt;
      v_data4       := r1.dteeffex;
      v_data5       := r1.dtereemp;
      --??????????????
      v_amtincom1 := 0;
      begin
        select nvl(stddec(amtincom1,codempid,v_chken),0)
          into v_amtincom1
          from ttaxcur
         where dteyrepay = p_dteyrepay
           and dtemthpay = p_dtemthpay
           and numperiod = p_numperiod
           and codempid  = r1.codempid;
      exception when no_data_found then
        v_amtincom1 := 0;
      end;
      if nvl(v_amtincom1,0) = 0 then
        begin
          select nvl(stddec(amtincom1,codempid,v_chken),0)
            into v_amtincom1
            from ttaxcur
           where dteyrepay = v_lastyear
             and dtemthpay = v_lastmth
             and numperiod = v_lastperiod
             and codempid  = r1.codempid;
        exception when no_data_found then
          v_amtincom1 := 0;
        end;
      end if;
      if nvl(v_amtincom1,0) > 0 then
        v_amtdata := '   ( '||get_label_name(v_codapp,global_v_lang,70)||' : '||to_char(v_amtincom1,'fm999,999,990.00')||' )';
      else
        v_amtdata := null;
      end if;

      begin
        select max(dteeffec) 
          into v_dteeffec
          from ttexempt 
         where codempid = r1.codempid 
           and staupd in ('C','U');
      exception when no_data_found then
        v_dteeffec := null;
      end;      
      --Chai 2023-02-21
      --if (v_data3 between v_lastdate and v_enddate)  then -- ???????????????
      if (v_data3 between v_lastdate and v_enddate) and  (hcm_util.get_codcomp_level(v_codcomp,1) = hcm_util.get_codcomp_level(p_codcomp,1)) then -- ???????????????
        if v_dteeffec is not null then
          v_comment := get_label_name(v_codapp,global_v_lang,10)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(v_data3)||' - '||hcm_util.GET_DATE_BUDDHIST_ERA(v_data4)||v_amtdata;
        else
          v_comment := get_label_name(v_codapp,global_v_lang,10)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(v_data3)||v_amtdata;
        end if;
      --Chai 2023-02-21
      --elsif (v_data5 between v_lastdate and v_enddate)   then	-- ????????????????????????
      elsif (v_data5 between v_lastdate and v_enddate)  and (hcm_util.get_codcomp_level(v_codcomp,1) = hcm_util.get_codcomp_level(p_codcomp,1))   then	-- ????????????????????????
        v_comment := get_label_name(v_codapp,global_v_lang,10)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(v_data5)||v_amtdata;
      elsif (hcm_util.get_codcomp_level(v_codcomp,1) = hcm_util.get_codcomp_level(p_codcomp,1)) and (hcm_util.get_codcomp_level(v_l_codcomp,1) <> hcm_util.get_codcomp_level(p_codcomp,1)) and (hcm_util.get_codcomp_level(v_l_codcomp,1) is not null) then		-- ???????????????
--        v_comment := get_label_name(v_codapp,global_v_lang,10)||v_amtdata;
        v_comment := get_label_name(v_codapp,global_v_lang,10);
        v_amtnet2   := 0;
        v_rebate2   := 0;
        v_total2    := 0;
        v_total  := nvl(v_total1,0) - nvl(v_total2,0);
      elsif (v_dteeffec between (v_lastdate + 1) and (v_enddate + 1)) then --????????????
        v_comment := get_label_name(v_codapp,global_v_lang,20)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(v_data4)||v_amtdata;
      elsif (hcm_util.get_codcomp_level(v_l_codcomp,1) = hcm_util.get_codcomp_level(p_codcomp,1)) and (hcm_util.get_codcomp_level(v_codcomp,1) <> hcm_util.get_codcomp_level(p_codcomp,1)) and (hcm_util.get_codcomp_level(v_codcomp,1) is not null) then --????????????
--        v_comment := get_label_name(v_codapp,global_v_lang,20)||v_amtdata;
        v_comment := get_label_name(v_codapp,global_v_lang,20);
        v_amtnet1   := 0;
        v_rebate1   := 0;
        v_total1    := 0;
        v_total  := nvl(v_total1,0) - nvl(v_total2,0);
--      elsif (hcm_util.get_codcomp_level(r1.codcomp,1) like hcm_util.get_codcomp_level(p_codcomp,1)) and (v_l_codcomp not like hcm_util.get_codcomp_level(p_codcomp,1)) then --???????????????
      elsif (v_codcomp like p_codcomp) and (v_l_codcomp not like p_codcomp) then --???????????????
        v_comment := get_label_name(v_codapp,global_v_lang,40)||v_amtdata;
--      elsif (v_l_codcomp like hcm_util.get_codcomp_level(p_codcomp,1)) and (hcm_util.get_codcomp_level(r1.codcomp,1) not like hcm_util.get_codcomp_level(p_codcomp,1)) then --??????????????
      elsif (v_l_codcomp like p_codcomp) and (v_codcomp not like p_codcomp) then --??????????????
        v_comment := get_label_name(v_codapp,global_v_lang,50)||v_amtdata;
      else	--??????????????
        if v_chk = 'Y' then
          chk_tfincadj2(r1.codempid,v_cdseq,v_lastdate,v_enddate,v_dteadj);
          if v_dteadj is not null then
            --<<User37 ST11 05/03/2020
            --v_comment := get_label_name(v_codapp,global_v_lang,60)||' '||v_dteadj||v_amtdata;
--            v_comment := get_label_name(v_codapp,global_v_lang,60)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(trunc(to_date(v_dteadj,'dd/mm/yyyy')))||v_amtdata;
--            v_comment := get_label_name(v_codapp,global_v_lang,60)||' '||hcm_util.GET_DATE_BUDDHIST_ERA(trunc(to_date(v_dteadj,'dd/mm/yyyy')));
            v_comment := get_label_name(v_codapp,global_v_lang,60)||' '||v_dteadj;-- user18 15/12/2021
            -->>User37 ST11 05/03/2020
          else
            v_comment := null;
          end if;
        else
          v_comment := null;
        end if;
      end if;

      v_codcomp := r1.codcomp;

--      if v_count = 2 then
--        v_row := v_row + 1;
        obj_data2 := json_object_t();
        obj_data2.put('coderror','200');
        obj_data2.put('image', v_empid);
        obj_data2.put('codempid', v_empid);
        obj_data2.put('desc_codempid', get_temploy_name(v_empid, global_v_lang));
        obj_data2.put('codcomp', v_codcomp);
        obj_data2.put('amtnet1', v_amtnet1);
        obj_data2.put('rebate1', v_rebate1);
        obj_data2.put('total1', v_total1);
        obj_data2.put('amtnet2', v_amtnet2);
        obj_data2.put('rebate2', v_rebate2);
        obj_data2.put('total2', v_total2);
        obj_data2.put('total', v_total);
        obj_data2.put('comment', v_comment);
        obj_data2.put('codpay', r1.codpay);
        obj_data2.put('dtemthpay', r1.dtemthpay);
        obj_data2.put('dteyrepay', r1.dteyrepay);
        obj_data2.put('numperiod', r1.numperiod);
        obj_row2.put(to_char(v_row - 1), obj_data2);
--      end if;
    end loop;

    for r2 in c2 loop
      v_flgpass := secur_main.secur3(r2.codcomp,r2.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flgpass then
        v_sum_num1 := v_sum_num1 + 1;
        v_sum_amtnet1 := nvl(v_sum_amtnet1,0) + r2.sum_amtpay;
      end if;
    end loop;

    if v_dtestrt <> v_lastdtestrt then
      for r3 in c3 loop
        v_flgpass := secur_main.secur3(r3.codcomp,r3.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
        if v_flgpass then
          v_sum_num2 := v_sum_num2 + 1;
          v_sum_amtnet2 := nvl(v_sum_amtnet2,0) + r3.sum_amtpay;
        end if;
      end loop;
    end if;

    v_sum_num3 := v_sum_num1 - v_sum_num2;
    v_sum_amtnet3 := v_sum_amtnet1 - v_sum_amtnet2;

    obj_row  := json_object_t();
    obj_data := json_object_t();
    --v_rcnt    := v_rcnt + 1;
    obj_data.put('coderror', '200');
    obj_data.put('sum_num1', nvl(v_sum_num1,0));
    obj_data.put('sum_amtnet1', to_char(nvl(v_sum_amtnet1,0),'FM9,999,999,990.00'));
    obj_data.put('sum_num2', nvl(v_sum_num2,0));
    obj_data.put('sum_amtnet2', to_char(nvl(v_sum_amtnet2,0),'FM9,999,999,990.00'));
    obj_data.put('sum_num3', nvl(v_sum_num3,0));
    obj_data.put('sum_amtnet3', to_char(nvl(v_sum_amtnet3,0),'FM9,999,999,990.00'));

    obj_data.put('table', obj_row2);
    --obj_row.put(to_char(v_rcnt - 1), obj_data);

    if v_row = 0 then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tsincexp');
    else
      if not v_flgpass then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      end if;
    end if;

    if param_msg_error is null then
      json_str_output := obj_data.to_clob;
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_tsincexp;

end HRPY5RX;

/
