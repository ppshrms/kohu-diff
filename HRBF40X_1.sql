--------------------------------------------------------
--  DDL for Package Body HRBF40X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF40X" as

  procedure initial_value(json_str_input in clob) AS
    json_obj    json_object_t;
  begin
    json_obj            := json_object_t(json_str_input);

    --global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_numisr            := hcm_util.get_string_t(json_obj, 'p_numisr');
    p_dtemonth          := hcm_util.get_string_t(json_obj, 'p_dtemonth');
    p_dteyear           := hcm_util.get_string_t(json_obj, 'p_dteyear');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_numprdpay         := hcm_util.get_string_t(json_obj, 'p_numprdpay');
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'p_dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj, 'p_dteyrepay');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  END initial_value;

  procedure get_index(json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  END get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_data            json_object_t;
    obj_row             json_object_t;
    v_rcnt              number := 0;
    v_check_codcompy    number := 0;
    v_check_tdepltdte   number := 0;
    v_check_numisr      number := 0;
    v_check_tisrinf     number := 0;
    v_check_typpayroll  number := 0;
    v_flg_secur7        boolean := false;
    v_flg_secur2        boolean := false;
    v_flg_exist         boolean := false;
    v_flg_permission    boolean := false;
    dynamicCursor       sys_refcursor;
    v_codempid          tinsdinf.codempid%type;
    v_codcomp           tinsdinf.codcomp%type;
    v_codcompy          tisrinf.codcompy%type;
    v_typpayroll        tinsdinf.typpayroll%type;
    v_numisr            tinsdinf.numisr%type;
    v_codisrp           tinsdinf.codisrp%type;
    v_amtpmiume         tinsdinf.amtpmiume%type;
    v_numprdpay         tinsdinf.numprdpay%type;
    v_dtemthpay         tinsdinf.dtemthpay%type;
    v_dteyrepay         tinsdinf.dteyrepay%type;
    v_dtemonth          tinsdinf.dtemonth%type;
    v_dteyear           tinsdinf.dteyear%type;
    v_namimage          tempimge.namimage%type;
    v_stmt              clob;

    cursor c1 is
      select codempid,codcomp,typpayroll,numisr,codisrp,amtpmiume,numprdpay,dtemthpay,dteyrepay,dtemonth,dteyear
        from tinsdinf
       where codcomp like p_codcomp||'%'
         and numisr = nvl(p_numisr,numisr)
         and dtemonth = p_dtemonth
         and dteyear = p_dteyear
         and (p_typpayroll is null or typpayroll = p_typpayroll)
         and (p_numprdpay is null or numprdpay = p_numprdpay)
         and (p_dtemthpay is null or dtemthpay = p_dtemthpay)
         and (p_dteyrepay is null or dteyrepay = p_dteyrepay)
         and flgtranpy = 'Y'
    order by codcomp,codempid,numisr;

  begin
    obj_row := json_object_t();
    v_codcomp := get_compful(p_codcomp);       
    begin
      select count(codcomp) into v_check_codcompy
      from  tcenter
      where codcomp = v_codcomp
      and   rownum  = 1;
    end;  
    if v_check_codcompy = 0 then
       param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;

    if p_codcomp is not null then
      v_flg_secur7 := secur_main.secur7(p_codcomp, global_v_coduser);
      if not v_flg_secur7 then
        param_msg_error := get_error_msg_php('HR3007',global_v_lang);
        json_str_output := get_response_message('400',param_msg_error,global_v_lang);
        return;
      end if;
    end if;

    if p_numisr is not null then
      begin
        select count(numisr) into v_check_numisr
        from tisrinf
        where numisr = p_numisr
        and rownum = 1;
      end;
      if v_check_numisr = 0 then
         param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TISRINF');
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
      end if;

      v_codcompy := get_codcompy(v_codcomp); 
      begin
        select count(numisr) into v_check_tisrinf
          from tisrinf
         where numisr   = p_numisr
           and codcompy = v_codcompy
           and rownum   = 1;
      end;
      if v_check_tisrinf = 0 then
         param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TISRINF');
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
      end if;
    end if;

    if p_typpayroll is not null then
      begin
        select count(codcodec) into v_check_typpayroll
        from  tcodtypy
        where codcodec = p_typpayroll
        and   rownum = 1;
      end;
      if v_check_typpayroll = 0 then
         param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODTYPY');
         json_str_output := get_response_message('400',param_msg_error,global_v_lang);
         return;
      end if;
    end if;

    begin
      select count(numisr) into v_check_tdepltdte
        from tdepltdte
       where codcomp like p_codcomp||'%'
         and (p_numisr is null or numisr = p_numisr)
         and dtemonth = p_dtemonth
         and dteyear = p_dteyear
         and rownum = 1;
    end;    
    if v_check_tdepltdte = 0 then
       param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TDEPLTDTE');
       json_str_output := get_response_message('400',param_msg_error,global_v_lang);
       return;
    end if;

    for r1 in c1 loop
      v_flg_exist := true;
      exit;
    end loop;

    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TINSDINF');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;

    for r1 in c1 loop
      begin
        select  namimage
        into    v_namimage
        from    tempimge
        where   codempid = r1.codempid;
      exception when no_data_found then
        v_namimage := r1.codempid;
      end;
      --secur_main.secur2
      v_flg_secur2 := secur_main.secur2(r1.codempid,global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal);
      if v_flg_secur2 then
        obj_data := json_object_t();
        obj_data.put('image',v_namimage);
        obj_data.put('codempid',r1.codempid);
        obj_data.put('codcomp',r1.codcomp);
        obj_data.put('namempid',get_temploy_name(r1.codempid,global_v_lang));
        obj_data.put('typpayroll',get_tcodec_name('TCODTYPY',r1.typpayroll,global_v_lang));
        obj_data.put('numisr',r1.numisr);
        obj_data.put('desc_codisrp',get_tcodec_name('TCODISRP',r1.codisrp,global_v_lang));
        obj_data.put('amtpmiume',nvl(r1.amtpmiume,0));
        obj_data.put('dtepayroll',nvl(to_char(r1.numprdpay),'-')||'/'||nvl(to_char(get_tlistval_name('NAMMTHFUL', r1.dtemthpay ,global_v_lang)),'-')||'/'||nvl(to_char(r1.dteyrepay),'-'));
        obj_data.put('dtemonth',r1.dtemonth);
        obj_data.put('dteyear',r1.dteyear);
        obj_row.put(to_char(v_rcnt-1),obj_data);
        v_rcnt := v_rcnt + 1;
        v_flg_permission := true;
      end if;
    end loop;
    if not v_flg_permission and v_flg_exist then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    dbms_lob.createtemporary(json_str_output, true);
    obj_row.to_clob(json_str_output);
    exception when others then
      param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
    END gen_index;

end HRBF40X;

/
