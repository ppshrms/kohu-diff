--------------------------------------------------------
--  DDL for Package Body HRPY5LX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY5LX" as

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_month      := to_number(hcm_util.get_string_t(obj_detail,'month'));
    p_year       := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp    := hcm_util.get_string_t(obj_detail,'codcomp');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
  begin
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
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
    v_flg_exist          boolean := false;
    v_flg_secure         boolean := false;
    v_flg_permission     boolean := false;
    obj_rows             json_object_t := json_object_t();
    obj_data             json_object_t;
    v_count              number := 0;

    v_numoffid           temploy2.numoffid%type;
    v_day                number;
    v_month              number;
    v_year               number;
    v_address            varchar2(4000 char);
    v_codsubdistr        temploy2.codsubdistr%type;
    v_coddistr           temploy2.coddistr%type;
    v_codprovr           temploy2.codprovr%type;
    v_codnatnl           temploy2.codnatnl%type;
    v_amtincom1          number;
    v_sumhur             number;
    v_sumday             number;
    v_summth             number;
    v_unitcal1           tcontpmd.unitcal1%type;
    v_dtestr             date;
    v_dteend             date;
    cursor c1 is
      select codempid   ,codcomp  ,numlvl   ,
             typpayroll ,codsex   ,dteempdb ,
             codpos     ,dteempmt ,dteeffex ,
             codempmt   ,rowid
        from temploy1 a
       where a.codcomp like p_codcomp || '%'
         and nvl(a.staemp,0) <> 0
         and a.dteempmt <= v_dteend
         and (a.dteeffex is null or a.dteeffex > v_dtestr)
    order by codcomp,codempid;
  begin
    v_dtestr := to_date(get_period_date(1,p_year,'S'),'dd/mm/yyyy');
    if p_month is not null then
      v_dteend := to_date(get_period_date(p_month,p_year,'E'),'dd/mm/yyyy');
    else
      v_dteend := to_date(get_period_date(12,p_year,'E'),'dd/mm/yyyy');
    end if;
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'temploy1');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    for r1 in c1 loop
--      v_flg_secure := secur_main.secur2(r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      v_flg_secure := secur_main.secur2(r1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal,global_v_numlvlsalst,global_v_numlvlsalen);
      if v_flg_secure then
        v_flg_permission := true;
        obj_data := json_object_t();
        obj_data.put('image'           ,get_emp_img(r1.codempid));
        obj_data.put('codempid'        ,r1.codempid);
        obj_data.put('desc_codempid'   ,get_temploy_name(r1.codempid,global_v_lang));
        begin
          select numoffid,
                 decode(global_v_lang,'101',adrrege,
                                      '102',adrregt,
                                      '103',adrreg3,
                                      '104',adrreg4,
                                      '105',adrreg5,
                                      adrrege),
                 codsubdistr  ,
                 coddistr     ,
                 codprovr     ,
                 codnatnl
            into v_numoffid   ,
                 v_address    ,
                 v_codsubdistr,
                 v_coddistr   ,
                 v_codprovr   ,
                 v_codnatnl
            from temploy2
           where codempid = r1.codempid;
          obj_data.put('nationalID'   ,v_numoffid);
        exception when no_data_found then
          v_numoffid := null;
          v_address := null;
          v_codsubdistr := null;
          v_coddistr := null;
          v_codprovr := null;
          v_codnatnl := null;
        end;
        obj_data.put('gender'          ,get_tlistval_name('NAMSEX',r1.codsex,global_v_lang));
        obj_data.put('dteempdb'        ,to_char(r1.dteempdb,'dd/mm/yyyy'));
        if p_month is not null then
          get_service_year(r1.dteempdb,v_dteend,'Y',v_year,v_month,v_day);
        else
          get_service_year(r1.dteempdb,sysdate,'Y',v_year,v_month,v_day);
        end if;
        obj_data.put('age'             ,to_char(v_year));
        if v_codsubdistr is not null then
          v_address := v_address || ' ' ||
                       get_label_name('HRPY5LX',global_v_lang,'220') || ' ' ||
                       get_tsubdist_name(v_codsubdistr,global_v_lang);
        end if;
        if v_coddistr is not null then
          v_address := v_address || ' ' ||
                       get_label_name('HRPY5LX',global_v_lang,'230') || ' ' ||
                       get_tcoddist_name(v_coddistr,global_v_lang);
        end if;
        if v_codprovr is not null then
          v_address := v_address || ' ' ||
                       get_label_name('HRPY5LX',global_v_lang,'240') || ' ' ||
                       get_tcodec_name('tcodprov',v_codprovr,global_v_lang);
        end if;
        obj_data.put('address'         ,v_address);
        obj_data.put('nationality'     ,get_tcodec_name('TCODNATN',v_codnatnl,global_v_lang));
        obj_data.put('codpos'          ,r1.codpos);
        obj_data.put('desc_codpos'     ,get_tpostn_name(r1.codpos,global_v_lang));
        obj_data.put('codcomp'         ,r1.codcomp);
        obj_data.put('desc_codcomp'    ,get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('dteempmt'        ,to_char(r1.dteempmt,'dd/mm/yyyy'));
        if r1.numlvl between global_v_numlvlsalst and global_v_numlvlsalen then
          begin
            select stddec(amtincom1,codempid,global_v_chken)
              into v_amtincom1
              from temploy3
             where codempid = r1.codempid;
            get_wage_income(r1.codcomp,r1.codempmt,v_amtincom1,0,0,0,0,0,0,0,0,0,
                            v_sumhur  ,v_sumday   ,v_summth);
            begin
              select unitcal1
                into v_unitcal1
                from tcontpmd
               where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                 and codempmt = r1.codempmt
                 and dteeffec = (select max(dteeffec)
                                   from tcontpmd
                                  where codcompy = hcm_util.get_codcomp_level(r1.codcomp,1)
                                    and codempmt = r1.codempmt
                                    and dteeffec < sysdate);
              if (v_unitcal1 = 'H' or v_unitcal1 = 'D') then -- per date
                if v_zupdsal = 'Y' then
                    obj_data.put('salaryDAY',to_char(v_sumday,'fm9999999999990.00'));
                end if;
              else -- per month
                if v_zupdsal = 'Y' then
                    obj_data.put('salaryMTH',to_char(v_summth,'fm9999999999990.00'));
                end if;
              end if;
            exception when no_data_found then
              null;
            end;
          exception when no_data_found then
            null;
          end;
        end if;
        if r1.dteeffex <= v_dteend + 1 then
          obj_data.put('dteffex',to_char(r1.dteeffex,'dd/mm/yyyy'));
        end if;
        obj_data.put('coderror','200');
        obj_rows.put(to_char(v_count),obj_data);
        v_count := v_count + 1;
      end if;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    json_str_output :=  obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return;
  end gen_index;

end hrpy5lx;

/
