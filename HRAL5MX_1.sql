--------------------------------------------------------
--  DDL for Package Body HRAL5MX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL5MX" as

  procedure initial_value(json_str_input in clob) as
    json_obj json_object_t;
  begin
    json_obj        := json_object_t(json_str_input);
    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    p_codcomp           := hcm_util.get_string_t(json_obj,'p_codcomp');
    p_codempid          := hcm_util.get_string_t(json_obj,'p_codempid_query');
    p_year              := hcm_util.get_string_t(json_obj,'p_year');
    p_month             := hcm_util.get_string_t(json_obj,'p_month');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index as
    v_staemp varchar2(4000 char);
  begin
    if p_year is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_month is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_codcomp is null and p_codempid is null then
        param_msg_error := get_error_msg_php('HR2045',global_v_lang);
        return;
    end if;
    if p_codcomp is not null then
        param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
        if param_msg_error is not null then
            return;
        end if;
    end if;
    if p_codempid is not null then
      if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
      begin
        select  staemp
        into    v_staemp
        from    temploy1
        where   codempid = p_codempid;
      exception when no_data_found then
         v_staemp := null;
      end;
      if v_staemp = '9' then -- HR2101
          param_msg_error := get_error_msg_php('HR2101',global_v_lang);
          return;
      end if;
    end if;
  end check_index;

  procedure gen_index(json_str_output out clob) as
    json_obj    json_object_t;
    json_obj2   json_object_t;
    json_row    json_object_t;
    v_qtyvacat  number;
    v_qtypriyr  number;
    v_token     number;
    v_year      number;
    v_month     number;
    v_day       number;
    v_comlevel  number;
    v_ddmmyyyy  varchar2(4000 char);
    v_codleave  varchar2(4000 char);
    v_codcomp   varchar2(4000 char);
    v_complb1   varchar2(4000 char);
    v_complb2   varchar2(4000 char);
    v_codcompy  varchar2(4000 char);
    v_secur     varchar2(4000 char);
    v_flgpass   boolean := false;
    v_flg_secur varchar2(4000 char) := 'N';
    v_flg_data  varchar2(1 char) := 'N';
    v_dteeffec  date;
    v_dtecycst  date;
    v_dtecycen  date;
    v_flgcal    tcontrlv.flgcal%type;
    v_flgmthvac tcontrlv.flgmthvac%type;
    v_count     number := 0;
    v_date date := last_day(to_date('01'||lpad(p_month,2,'0')||p_year,'ddmmyyyy'));
    v_exist     varchar2(1 char) := '1';
    v_chk       varchar2(1 char) := 'N';
    v_qtylepay  number; ----
    --
    cursor c_temploy1 is
      select  a.codempid, a.codcomp, dteempmt,
              hcm_util.get_codcomp_level(a.codcomp,1) codcompy,
              dteeffex, staemp, qtywkday,
              a.dteeffeclv, b.qtyvacat, b.monthno
        from  tleavsum  a, tleavsum2 b, temploy1 c
       where a.codempid = nvl(p_codempid,a.codempid)
         and a.codcomp  like p_codcomp||'%'
         and c.staemp   in ('1','3')
         and b.dtemonth = p_month 
         and b.dteyear  = p_year
         and b.qtyvacat > 0
         and a.codempid = b.codempid
         and a.codempid = c.codempid
         and a.dteyear  = b.dteyear
         and a.codleave = b.codleave         
        order by a.codcomp,a.codempid;
  begin
    json_obj := json_object_t();
    json_row := json_object_t();
    --
    begin
      select  codleave into  v_codleave
        from  tleavecd
       where  staleave = 'V'
         and  rownum <= 1 ;
    exception when no_data_found then
      param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tleavecd');
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end;
    --<<User37 Final Test Phase 1 V11 #1681 14/10/2020
    /*nut  begin
      select 'Y'
        into v_chk
        from tleavcom
       where typleave
        in (select typleave  from tleavety a where flgtype = 'V')
        and codcompy like p_codcomp ||'%';
    exception when no_data_found then
      param_msg_error := get_error_msg_php('AL0060',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end;
    --
    if p_codempid is not null then
      begin
        select codcomp into v_codcomp
        from temploy1
        where codempid = p_codempid;
      exception when no_data_found then null;
      end;
    else
        v_codcomp := p_codcomp;
    end if;*/
    if p_codempid is not null then
      begin
        select codcomp into v_codcomp
        from temploy1
        where codempid = p_codempid;
      exception when no_data_found then null;
      end;
    else
        v_codcomp := p_codcomp;
    end if;

    begin
      select 'Y'
        into v_chk
        from tleavcom
       where typleave
        in (select typleave  from tleavety a where flgtype = 'V')
        and codcompy like hcm_util.get_codcomp_level(v_codcomp,1) ||'%';
    exception when no_data_found then
      param_msg_error := get_error_msg_php('AL0060',global_v_lang);
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
      return;
    end;
    -->>User37 Final Test Phase 1 V11 #1681 14/10/2020
    --
    begin
      select  t1.flgcal,  t1.flgmthvac
        into  v_flgcal, v_flgmthvac
        from  tcontrlv t1
       where  codcompy = hcm_util.get_codcomp_level(v_codcomp,1)
         and  t1.dteeffec = ( select max(t2.dteeffec)
                                from tcontrlv t2
                               where t2.codcompy  = hcm_util.get_codcomp_level(v_codcomp,1)
                                 and t2.dteeffec <= sysdate);
    exception when no_data_found then null;
    end;
    --
    if v_flgcal = '1' then
      json_row.put('desc_flgcal',get_label_name('HRAL5MXC1',global_v_lang,'150'));
    elsif v_flgcal = '2' then
      json_row.put('desc_flgcal',get_label_name('HRAL5MXC1',global_v_lang,'160'));
    end if;
    --
    json_row.put('flgcal',v_flgcal);
    --
    if v_flgmthvac = '1' then
      json_row.put('desc_flgmthvac',get_label_name('HRAL5MXC1',global_v_lang,'170'));
    else
    --
      std_al.cycle_leave( hcm_util.get_codcomp_level(v_codcomp,1),null,v_codleave,
                          v_date,v_year,v_dtecycst,v_dtecycen);
      json_row.put('desc_flgmthvac',  get_nammthful(to_char(v_dtecycst,'mm'),global_v_lang) || '-' ||
                                      get_nammthful(to_char(v_dtecycen,'mm'),global_v_lang));
    end if;
    --
    json_row.put('flgmthvac',v_flgmthvac);
    json_obj.put('detail',json_row);
    --
    json_obj2 := json_object_t();
    for c1 in c_temploy1 loop
      ----std_al.entitlement(c1.codempid,v_codleave,v_date,0,v_qtyvacat,v_qtypriyr,v_dteeffec);
      ----if v_qtyvacat > 0 then
        v_flg_data := 'Y' ;
        v_flgpass := secur_main.secur2(c1.codempid,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
        v_codcomp := c1.codcomp;
        --
        if v_flgpass then
          v_flg_secur := 'Y';
          json_row := json_object_t();
          json_row.put('image',get_emp_img(c1.codempid));
          json_row.put('codcomp',c1.codcomp);
          json_row.put('codempid',to_char(c1.codempid));
          json_row.put('desc_codempid',get_temploy_name(c1.codempid,global_v_lang));
          json_row.put('desc_codempid',get_temploy_name(c1.codempid,global_v_lang));

          json_row.put('dteyear',p_year);
          json_row.put('codleave',v_codleave);
          --
          --<<----
          if c1.monthno = 12 then --Last month of Leave Cycle
            begin
              select nvl(sum(nvl(qtylepay,0)),0)
                into v_qtylepay
                from tpayvac
               where codempid = c1.codempid
                 and dteyear  = v_year
                 and to_number(to_char(dteyrepay)||lpad(to_char(dtemthpay),2,'0')) 
                             >= to_number(p_year||lpad(p_month,2,'0'))
                 and staappr  = 'Y';
            exception when no_data_found then
              v_qtylepay := 0;
            end;
          else
            begin
              select nvl(sum(nvl(qtylepay,0)),0)
                into v_qtylepay
                from tpayvac
               where codempid = c1.codempid
                 and dteyear  = v_year
                 and to_number(to_char(dteyrepay)||lpad(to_char(dtemthpay),2,'0')) 
                             <= to_number(p_year||lpad(p_month,2,'0'))
                 and staappr  = 'Y';
            exception when no_data_found then
              v_qtylepay := 0;
            end;
          end if;
          v_qtyvacat := greatest(c1.qtyvacat - v_qtylepay ,0);
          -->>----
          v_ddmmyyyy := hcm_util.cal_dhm_concat(v_qtyvacat,hcm_util.get_qtyavgwk(c1.codcomp,null));
          json_row.put('qtyvacat',v_ddmmyyyy);
          --
--          if v_dteeffec is not null then
--            json_row.put('montheffec',get_nammthful(to_char(v_dteeffec,'mm'),global_v_lang));
--          end if;
          if c1.dteeffeclv is not null then
            json_row.put('montheffec',get_nammthful(to_char(c1.dteeffeclv,'mm'),global_v_lang)); ----
          end if;

          json_row.put('monthno',p_month);--User37 #5372 Final Test Phase 1 V11 03/03/2021
          --
          json_row.put('dteempmt',to_char(c1.dteempmt,'dd/mm/yyyy'));
          get_service_year (c1.dteempmt + nvl(c1.qtywkday,0),
                            least(nvl(c1.dteeffex,sysdate),last_day(v_date)),   'Y',
                            v_year,v_month,v_day);
          json_row.put('wrkyear',to_char(v_year) || ' (' || to_char(v_month) || ')');
          json_obj2.put(to_char(v_count),json_row);
          v_count := v_count + 1;
        end if;
      ----end if;
    end loop;
    --
    if v_flg_data like 'N' then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TLEAVSUM');
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
    elsif v_flg_secur = 'N' then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
    end if;
    --
    json_obj.put('table',json_obj2);
    json_obj.put('coderror','200');
    --
    json_str_output := json_obj.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

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
end HRAL5MX;

/
