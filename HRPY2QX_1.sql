--------------------------------------------------------
--  DDL for Package Body HRPY2QX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY2QX" as

-- last update: 21/09/2020 17:30

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;
    p_codcomp   := hcm_util.get_string_t(obj_detail,'codcomp');
    p_codempmt  := hcm_util.get_string_t(obj_detail,'codempmt');
    p_month     := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year      := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_rate      := to_number(hcm_util.get_string_t(obj_detail,'rate'));
    p_typretmt  := hcm_util.get_string_t(obj_detail,'typretmt');
    p_myr       := to_number(hcm_util.get_string_t(obj_detail,'myr'));
    p_fyr       := to_number(hcm_util.get_string_t(obj_detail,'fyr'));
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);

  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
  begin
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_codempmt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempmt');
      return;
    end if;
    if p_month is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_rate is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'rate');
      return;
    end if;
    if p_typretmt is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typretmt');
      return;
    end if;
    if p_myr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'myr');
      return;
    end if;
    if p_fyr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'fyr');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_codempmt is not null then
      begin
        select codcodec
          into p_codempmt
          from tcodempl
         where codcodec = p_codempmt;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODEMPL');
        return;
      end;
    end if;
    if not (p_month between 1 and 12) then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'month');
      return;
    end if;
    if p_rate > 100 then
      param_msg_error := get_error_msg_php('HR2020',global_v_lang,'rate');
      return;
    end if;
    if p_typretmt is not null then
      begin
        select codcodec
          into p_typretmt
          from tcodretm
         where codcodec = p_typretmt;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODRETM');
        return;
      end;
    end if;
  end check_index;

  procedure get_index(json_str_input in clob,json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
        gen_index(json_str_output);
    else
        json_str_output := get_response_message(null,param_msg_error,global_v_lang);
        return;
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;

  procedure gen_index(json_str_output out clob) as
    obj_row             json_object_t := json_object_t();
    obj_data            json_object_t;
    v_count             number := 0;
    v_flg_data_found    boolean := false;
    v_flg_secure        boolean := false;
    v_flg_permission    boolean := false;
    v_dtestrt           date;
    v_dteend            date;
    v_exist             varchar2(1 char) := '1';
    v_com_codcurr       tcontrpy.codcurr%type;
    v_year              number := 0;
    v_month             number := 0;
    v_day               number := 0;
    v_qtyday            number := 0;
    v_ratepay           number := 0;
    v_ratecurr          number := 1;
    v_amt_hour          number := 0;
    v_amt_day           number := 0;
    v_amt_month         number := 0;
    v_current_salary    number := 0;

    v_amtretire1           number := 0;
    v_amtretire2           number := 0;
    cursor c1 is
      select a.codcomp, a.codempmt,
             a.codempid, a.dteempmt, a.numlvl, a.codpos, a.dteempdb,
             decode(codsex, 'M', p_myr,
                                 p_fyr) empAgeWhenRetire,
             a.dteretire,
             nvl(stddec(b.amtincom1, a.codempid, global_v_chken), 0) amtincom1,
             nvl(stddec(b.amtincom2, a.codempid, global_v_chken), 0) amtincom2,
             nvl(stddec(b.amtincom3, a.codempid, global_v_chken), 0) amtincom3,
             nvl(stddec(b.amtincom4, a.codempid, global_v_chken), 0) amtincom4,
             nvl(stddec(b.amtincom5, a.codempid, global_v_chken), 0) amtincom5,
             nvl(stddec(b.amtincom6, a.codempid, global_v_chken), 0) amtincom6,
             nvl(stddec(b.amtincom7, a.codempid, global_v_chken), 0) amtincom7,
             nvl(stddec(b.amtincom8, a.codempid, global_v_chken), 0) amtincom8,
             nvl(stddec(b.amtincom9, a.codempid, global_v_chken), 0) amtincom9,
             nvl(stddec(b.amtincom10, a.codempid, global_v_chken), 0) amtincom10,
             b.codcurr
        from temploy1 a, temploy3 b
       where a.codempid =    b.codempid
--and a.codempid  = '0000055174'
         and a.codcomp  like p_codcomp ||'%'
         and a.codempmt =    p_codempmt
         and a.dteretire between v_dtestrt and v_dteend
--         and decode(codsex, 'M', add_months(a.dteempdb,(p_myr*12)),
--                                 add_months(a.dteempdb,(p_fyr*12)))
--             between v_dtestrt and v_dteend
         and a.staemp in ('1','3')
    order by a.codcomp,a.codempid;

    cursor c2 (p_curr_c varchar2,p_curr_e varchar2)  is
      select ratechge
        from tratechg
       where codcurr = p_curr_c
         and codcurr_e = p_curr_e
         and to_char(dteyrepay)||lpad(to_char(dtemthpay),2,'0') <= to_char(sysdate,'yyyymm')
    order by dteyrepay desc, dtemthpay desc;

  begin
    v_dtestrt := to_date('01'
                      || lpad(to_char(p_month),2,'0')
                      || lpad(to_char(p_year),4,'0'),'ddmmyyyy');
    v_dteend  := last_day(v_dtestrt);
    for r1 in c1 loop
      v_flg_data_found := true;
      exit;
    end loop;
    if not v_flg_data_found then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TEMPLOY1');
      json_str_output := get_response_message('404',param_msg_error,global_v_lang);
      return;
    end if;

    for r1 in c1 loop
      v_flg_secure := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
--v_flg_secure := true;
      if v_flg_secure then
        v_flg_permission := true;
        obj_data := json_object_t();
        obj_data.put('codcomp'         ,r1.codcomp);
        obj_data.put('image'           ,get_emp_img(r1.codempid));
        obj_data.put('codempid'        ,r1.codempid);
        obj_data.put('desc_codempid'   ,get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('desc_codpos'     ,get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('dteempmt'        ,to_char(r1.dteempmt,'dd/mm/yyyy'));
        obj_data.put('dteretire'       ,to_char(r1.dteretire,'dd/mm/yyyy'));
        get_service_year(r1.dteempmt,r1.dteretire,'Y',v_year,v_month,v_day);
        -- work age when retire
        obj_data.put('wrkAgeYear'      ,v_year);
        obj_data.put('wrkAgeMonth'     ,v_month);
        -- employee age when retire
        obj_data.put('empAgeWhenRetire',r1.empAgeWhenRetire);
        begin
          v_qtyday := r1.dteretire - r1.dteempmt;
          select ratepay
            into v_ratepay
            from tretirmt
           where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
             and typretmt = p_typretmt
             and dteeffec = (select max(dteeffec)
                              from tretirmt
                             where typretmt = p_typretmt
                               and codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                               and dteeffec <= v_dteend)
             and v_qtyday between (nvl(qtyyrest,0)*365) + (nvl(qtymthst,0)*30) + nvl(qtydayst,0)
                              and (nvl(qtyyreen,0)*365) + (nvl(qtymthen,0)*30) + nvl(qtydayen,0);
        exception when no_data_found then
          v_ratepay := 0;
        end;
        obj_data.put('ratepay',to_char(v_ratepay, 'fm999999999999990'));
        get_wage_income(hcm_util.get_codcomp_level(r1.codcomp,1), r1.codempmt,
                                r1.amtincom1,r1.amtincom2,r1.amtincom3,r1.amtincom4,r1.amtincom5,
                                r1.amtincom6,r1.amtincom7,r1.amtincom8,r1.amtincom9,r1.amtincom10,
                                v_amt_hour,v_amt_day,v_amt_month);
        begin
          select codcurr into v_com_codcurr
            from tcontrpy
          where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
              and dteeffec = (select max(dteeffec)
                               from tcontrpy
                              where codcompy = hcm_util.get_codcomp_level(p_codcomp,1)
                                and dteeffec <= trunc(sysdate));
        exception when no_data_found then
          v_com_codcurr := null;
        end;
        if v_com_codcurr is not null and v_com_codcurr <> r1.codcurr then
          for r2 in c2(v_com_codcurr,r1.codcurr) loop
            v_ratecurr := r2.ratechge;
            exit;
          end loop;
        else
          v_ratecurr := 1;
        end if;
--        v_current_salary := v_amt_month*v_ratecurr;
        v_current_salary := round((v_amt_month * v_ratecurr),2);

--<<redmine PY-2211
--        obj_data.put('salary'      ,to_char(v_current_salary, 'fm999999999999990.00')); --permonth
        obj_data.put('salary'      ,round(v_current_salary, 2)); --permonth
        --obj_data.put('retireSalary',to_char(v_current_salary * power((1 + (p_rate/100)), p_year - to_char(sysdate,'yyyy')), 'fm999999999990.00'));
        --obj_data.put('retireMoney' ,to_char(round(v_current_salary * power((1 + (p_rate/100)), p_year - to_char(sysdate,'yyyy')),2) * v_ratepay, 'fm999999999990.00'));

        v_amtretire1  := round(v_current_salary * power((1 + (p_rate/100)), p_year - to_char(sysdate,'yyyy')),2);
        get_wage_income(hcm_util.get_codcomp_level(r1.codcomp,1), r1.codempmt,v_amtretire1,0,0,0,0,0,0,0,0,0,v_amt_hour,v_amt_day,v_amt_month);
        v_amtretire2  := round((v_amt_day * v_ratecurr * v_ratepay),2);

--        obj_data.put('retireSalary',to_char(v_amtretire1, 'fm999999999999990.00'));
--        obj_data.put('retireMoney' ,to_char(v_amtretire2, 'fm999999999999990.00'));
        obj_data.put('retireSalary',round(v_amtretire1,2));
        obj_data.put('retireMoney' ,round(v_amtretire2,2));
-->>redmine PY-2211

        obj_data.put('coderror'    ,'200');
        obj_row.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

  procedure get_yearretire (json_str_input in clob, json_str_output out clob) is
    obj_data        json_object_t;
    obj_age         json_object_t;
    v_femaleAge       number;
    v_maleAge         number;
  begin
    initial_value (json_str_input);
    if param_msg_error is null then
      obj_data          := json_object_t();
      obj_age           := json_object_t();

      BEGIN
          select nvl(ageretrm,0), nvl(ageretrf,0)
            into v_maleAge, v_femaleAge
            from tcompny
           where codcompy = hcm_util.get_codcomp_level(p_codcomp,1);
      exception when no_data_found then
            v_maleAge       := 0;
            v_femaleAge     := 0;
      END;
      obj_age.put('femaleAge', v_femaleAge);
      obj_age.put('maleAge', v_maleAge);
      obj_data.put('coderror', '200');
      obj_data.put('response',obj_age);

      json_str_output := obj_data.to_clob;
    else
      json_str_output   := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end get_yearretire;
end hrpy2qx;

/
