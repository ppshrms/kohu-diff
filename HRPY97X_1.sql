--------------------------------------------------------
--  DDL for Package Body HRPY97X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY97X" as

  procedure initial_value (json_str_input in clob) as
    obj_detail json_object_t;
  begin
    obj_detail          := json_object_t(json_str_input);
    global_v_codempid   := hcm_util.get_string_t(obj_detail,'p_codempid');
    global_v_coduser    := hcm_util.get_string_t(obj_detail,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(obj_detail,'p_lang');
    global_v_chken      := hcm_secur.get_v_chken;

    p_year       := to_number(hcm_util.get_string_t(obj_detail,'year'));
    p_codcomp    := hcm_util.get_string_t(obj_detail,'codcomp');
    p_codempid   := hcm_util.get_string_t(obj_detail,'codempid_query');
    p_typpayroll := hcm_util.get_string_t(obj_detail,'typpayroll');
    p_codpay     := hcm_util.get_string_t(obj_detail,'codpay');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
  end initial_value;

  procedure check_index as
    v_numlvl  number;
    v_codcomp tcenter.codcomp%type;
  begin
    if p_year is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'year');
      return;
    end if;
    if p_codempid is null and p_codcomp is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codempid,codcomp');
      return;
    end if;
    if p_typpayroll is null and p_codcomp is not null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'typpayroll');
      return;
    end if;
    if p_codpay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang,'codpay');
      return;
    end if;
    if p_codempid is not null then
      p_codcomp := '';
      p_typpayroll := '';
      begin
        select numlvl,codcomp
          into v_numlvl,v_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then null;
      end;
      if not secur_main.secur1(v_codcomp,v_numlvl,global_v_coduser,global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser,global_v_lang,p_codcomp);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec
          into p_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tcodtypy');
      end;
    end if;
    if p_codpay is not null then
      begin
        select codpay
          into p_codpay
          from tinexinf
         where codpay = p_codpay;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'tinexinf');
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
    v_flg_exist           boolean := false;
    v_flg_secure          boolean := false;
    v_flg_permission      boolean := false;
    obj_rows              json_object_t := json_object_t();
    obj_data              json_object_t;
    v_count               number := 0;
    cursor c1 is
      select a.codempid,a.codcomp,a.numlvl,
             stddec(b.amtpay1 ,b.codempid,global_v_chken) amtpay1 ,
             stddec(b.amtpay2 ,b.codempid,global_v_chken) amtpay2 ,
             stddec(b.amtpay3 ,b.codempid,global_v_chken) amtpay3 ,
             stddec(b.amtpay4 ,b.codempid,global_v_chken) amtpay4 ,
             stddec(b.amtpay5 ,b.codempid,global_v_chken) amtpay5 ,
             stddec(b.amtpay6 ,b.codempid,global_v_chken) amtpay6 ,
             stddec(b.amtpay7 ,b.codempid,global_v_chken) amtpay7 ,
             stddec(b.amtpay8 ,b.codempid,global_v_chken) amtpay8 ,
             stddec(b.amtpay9 ,b.codempid,global_v_chken) amtpay9 ,
             stddec(b.amtpay10,b.codempid,global_v_chken) amtpay10,
             stddec(b.amtpay11,b.codempid,global_v_chken) amtpay11,
             stddec(b.amtpay12,b.codempid,global_v_chken) amtpay12,
             b.codcompy,b.dteyrepay, b.codpay
        from temploy1 a,tytdinc b
       where a.codempid   = b.codempid
         and a.codcomp    like p_codcomp || '%'
         and a.typpayroll = nvl(p_typpayroll,a.typpayroll)
         and a.codempid   = nvl(p_codempid,a.codempid)
         and b.dteyrepay  = p_year
         and b.codpay     = p_codpay
         and b.typpay     <> '7'
    order by a.codcomp,a.codempid;
  begin
    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;
    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'tytdinc');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    for r1 in c1 loop
       -- v_flg_secure := secur_main.secur1(r1.codcomp,r1.numlvl,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
       v_flg_secure := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);

      if v_flg_secure then
        v_flg_permission := true;
        obj_data := json_object_t();
        obj_data.put('image'         ,get_emp_img(r1.codempid));
        obj_data.put('codempid'      ,r1.codempid);
        obj_data.put('desc_codempid' ,get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('codcomp'       ,r1.codcomp);
        obj_data.put('codcompy'      ,r1.codcompy);
        obj_data.put('dteyrepay'     ,r1.dteyrepay);
        obj_data.put('codpay'        ,r1.codpay);
        if(v_zupdsal = 'Y') then
            obj_data.put('amtpay1'       ,to_char(nvl(r1.amtpay1 ,0),'fm999999999990.00'));
            obj_data.put('amtpay2'       ,to_char(nvl(r1.amtpay2 ,0),'fm999999999990.00'));
            obj_data.put('amtpay3'       ,to_char(nvl(r1.amtpay3 ,0),'fm999999999990.00'));
            obj_data.put('amtpay4'       ,to_char(nvl(r1.amtpay4 ,0),'fm999999999990.00'));
            obj_data.put('amtpay5'       ,to_char(nvl(r1.amtpay5 ,0),'fm999999999990.00'));
            obj_data.put('amtpay6'       ,to_char(nvl(r1.amtpay6 ,0),'fm999999999990.00'));
            obj_data.put('amtpay7'       ,to_char(nvl(r1.amtpay7 ,0),'fm999999999990.00'));
            obj_data.put('amtpay8'       ,to_char(nvl(r1.amtpay8 ,0),'fm999999999990.00'));
            obj_data.put('amtpay9'       ,to_char(nvl(r1.amtpay9 ,0),'fm999999999990.00'));
            obj_data.put('amtpay10'      ,to_char(nvl(r1.amtpay10,0),'fm999999999990.00'));
            obj_data.put('amtpay11'      ,to_char(nvl(r1.amtpay11,0),'fm999999999990.00'));
            obj_data.put('amtpay12'      ,to_char(nvl(r1.amtpay12,0),'fm999999999990.00'));
            obj_data.put('amtpayall'     ,to_char(nvl(r1.amtpay1,0) + nvl(r1.amtpay2 ,0) + nvl(r1.amtpay3 ,0) + nvl(r1.amtpay4 ,0) +
                                                  nvl(r1.amtpay5,0) + nvl(r1.amtpay6 ,0) + nvl(r1.amtpay7 ,0) + nvl(r1.amtpay8 ,0) +
                                                  nvl(r1.amtpay9,0) + nvl(r1.amtpay10,0) + nvl(r1.amtpay11,0) + nvl(r1.amtpay12,0) ,
                                                  'fm999999999990.00'));
        else
            obj_data.put('amtpay1'       ,'');
            obj_data.put('amtpay2'       ,'');
            obj_data.put('amtpay3'       ,'');
            obj_data.put('amtpay4'       ,'');
            obj_data.put('amtpay5'       ,'');
            obj_data.put('amtpay6'       ,'');
            obj_data.put('amtpay7'       ,'');
            obj_data.put('amtpay8'       ,'');
            obj_data.put('amtpay9'       ,'');
            obj_data.put('amtpay10'      ,'');
            obj_data.put('amtpay11'      ,'');
            obj_data.put('amtpay12'      ,'');
            obj_data.put('amtpayall'     ,'');
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
    json_str_output := obj_rows.to_clob;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end gen_index;

end hrpy97x;

/
