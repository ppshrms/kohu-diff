--------------------------------------------------------
--  DDL for Package Body HRPYBEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPYBEX" as

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_codcomp           := hcm_util.get_string_t(obj_detail,'codcomp');
    p_dtestr            := to_date(hcm_util.get_string_t(obj_detail,'dtestr'),'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(obj_detail,'dteend'),'dd/mm/yyyy');
    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;
  procedure check_index as
  begin
    if p_codcomp is null  then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codcomp');
      return;
    end if;
    if p_dtestr is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dtestr');
      return;
    end if;
    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'dteend');
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
    obj_rows          json_object_t := json_object_t();
    obj_data          json_object_t;
    v_count           number := 0;
    v_flg_exist       boolean := false;
    v_flg_secure      boolean := false;
    v_flg_permission  boolean := false;
    v_dteeffec        date;
    v_year            number;
    v_month           number;
    v_day             number;
    cursor c1 is
      select b.codcomp,a.codempid,a.numvcher,a.ratecret,
             nvl(stddec(a.amtretn ,a.codempid,global_v_chken),0) amtretn ,
             nvl(stddec(a.amtcaccu,a.codempid,global_v_chken),0) amtcaccu,
             nvl(stddec(a.amttax  ,a.codempid,global_v_chken),0) amttax  ,
             a.dtevcher,a.dtereti,b.dteempmt,b.dteeffex,
             b.codpos  ,a.rowid  ,b.numlvl,a.codpfinf
        from tpfpay a,temploy1 b
       where to_date(to_char(a.dtevcher,'dd/mm/yyyy'),'dd/mm/yyyy') between p_dtestr and p_dteend
         and b.codcomp  like p_codcomp || '%'
         and a.codempid = b.codempid
  order by b.codcomp,a.codempid;
  begin
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TPFPAY');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    for r1 in c1 loop
      v_flg_secure := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        obj_data := json_object_t();
        obj_data.put('coderror'       ,'200');
        obj_data.put('dtepayback'   ,to_char(r1.dtevcher,'dd/mm/yyyy'));
        obj_data.put('image'        ,get_emp_img(r1.codempid));
        obj_data.put('codcomp'      ,r1.codcomp);
        obj_data.put('codempid'     ,r1.codempid);
        obj_data.put('desc_codempid',get_temploy_name(r1.codempid,global_v_lang));
        begin
          select dteeffec
            into v_dteeffec
            from tpfmemb
           where codempid = r1.codempid;
          obj_data.put('dtemember'  ,to_char(v_dteeffec ,'dd/mm/yyyy'));
          get_service_year(v_dteeffec,r1.dtereti,'Y',v_year,v_month,v_day);
          obj_data.put('memyre'     ,to_char(v_year));
          obj_data.put('memmth'     ,to_char(v_month));
        exception when no_data_found then
          null;
        end;
        obj_data.put('dteresign'    ,to_char(r1.dteeffex,'dd/mm/yyyy'));
        obj_data.put('emppart'      ,to_char(r1.amtretn ,'fm999999999990.00'));
        obj_data.put('comprate'     ,to_char(r1.ratecret,'fm999999999990.00'));
        obj_data.put('comppart'     ,to_char(r1.amtcaccu,'fm999999999990.00'));
        obj_data.put('sum'          ,to_char(r1.amtretn + r1.amtcaccu,'fm999999999990.00'));
        obj_data.put('tax'          ,to_char(r1.amttax  ,'fm999999999990.00'));
        obj_data.put('net'          ,to_char(r1.amtretn + r1.amtcaccu - r1.amttax,'fm999999999990.00'));
        obj_data.put('codpfinf' ,r1.codpfinf);
        obj_data.put('desc_codpfinf' ,get_tcodec_name('TCODPFINF', r1 .codpfinf,global_v_lang));
        
        obj_data.put('dtereti' ,to_char(r1.dtereti,'dd/mm/yyyy'));

        obj_rows.put(to_char(v_count) ,obj_data);
        v_count := v_count + 1;
      end if;
    end loop;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_rows.to_clob; 
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    return;
  end gen_index;

end hrpybex;

/
