--------------------------------------------------------
--  DDL for Package Body HRPY59X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY59X" AS
  --
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');

    -- index params
    p_period            := hcm_util.get_string_t(json_obj, 'numperiod');
    p_dtemthpay         := hcm_util.get_string_t(json_obj, 'dtemthpay');
    p_dteyrepay         := hcm_util.get_string_t(json_obj, 'dteyrepay');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcomp       tcenter.codcomp%type;
    v_typpayroll    tcodtypy.codcodec%type;
    v_codempid      temploy1.codempid%type;
    v_flg_secure  boolean := false;
  begin
    if p_codcomp is null and p_codempid_query is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;
    if p_codcomp is not null then
      begin
        select codcompy into v_codcomp
        from tcenter
        where codcomp = get_compful(p_codcomp);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCENTER');
        return;
      end;
      v_flg_secure := secur_main.secur7(v_codcomp,global_v_coduser);
      if not v_flg_secure  then
        param_msg_error :=  get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_typpayroll is not null then
      begin
        select codcodec into v_typpayroll from TCODTYPY where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TCODTYPY');
        return;
      end;
    end if; 
    v_flg_secure := false;
    if p_codempid_query is not null then
      begin
        select codempid into v_codempid from temploy1 where codempid = p_codempid_query;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang,'TEMPLOY1');
        return;
      end;
      v_flg_secure := secur_main.secur2(p_codempid_query,global_v_coduser,global_v_zminlvl,global_v_zwrklvl,v_zupdsal);
      if not v_flg_secure then
        param_msg_error :=  get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if; 
  end check_index;
  --
  procedure gen_index(json_str_output out clob) is
    obj_row              json_object_t;
    obj_data             json_object_t;
    v_flg_secure         boolean := false;
    v_flg_permission     boolean := false;
    v_flg_exist          boolean := false;
    v_rcnt               number  := 0;
    v_total              number  := 0;
    v_incomperiod        number  := 0;
    v_codempid           tothded.codempid%type;

    cursor c_emp is
      select unique codcomp,codempid,dteyrepay,dtemthpay,numperiod
        from tothded
       where codcomp like p_codcomp||'%'
         and codempid = nvl(p_codempid_query,codempid)
         and typpayroll = nvl(p_typpayroll,typpayroll)
         and dteyrepay = p_dteyrepay
         and dtemthpay = p_dtemthpay
         and numperiod = p_period
    order by codcomp,codempid,dteyrepay,dtemthpay,numperiod;    

    cursor c1 is
        select b.* 
          from (
                select codcomp,
                       codpay,
                       stddec(amtpay,codempid,v_chken) as amtpay,
                       stddec(amtded,codempid,v_chken) as amtded
                  from tothded
                 where codempid = v_codempid			  
                   and dteyrepay = p_dteyrepay
                   and dtemthpay = p_dtemthpay
                   and numperiod = p_period
                 union
                select a.codcomp,
                       a.codpay,
                       stddec(a.amtpay,a.codempid,v_chken) as amtpay,
                       stddec(a.amtpay,a.codempid,v_chken) as amtded
                  from tsincexp a
                 where a.codempid = v_codempid
                   and a.codpay not in ( select codpay
                                           from tothded b
                                          where codempid = a.codempid			  
                                            and dteyrepay = a.dteyrepay
                                            and dtemthpay = a.dtemthpay
                                            and numperiod = a.numperiod)
                   and a.typincexp in ('4','5','6')                         
                   and a.dteyrepay = p_dteyrepay
                   and a.dtemthpay = p_dtemthpay
                   and a.numperiod = p_period) b 
     left join tcondept c
			on hcm_util.get_codcomp_level(b.codcomp,1) = c.codcompy
           and b.codpay = c.codpay
		   and c.dteeffec = (select max(d.dteeffec)
			                   from tcondept d
			                  where d.codcompy  = c.codcompy
			                    and d.dteeffec <= sysdate)
      order by nvl(c.numseq,9999), b.codpay;

  begin
    obj_row                := json_object_t();
    for r1 in c_emp loop
      v_flg_exist := true;
      exit;
    end loop;
    for r1 in c_emp loop
      v_flg_secure := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_codempid := r1.codempid;
        v_flg_permission  := true;
        obj_data            := json_object_t();
        for r2 in c1 loop
            begin
              select  stddec(amtcal,codempid,v_chken) + 
                      stddec(amtincl,codempid,v_chken) + 
                      stddec(amtincc,codempid,v_chken) + 
                      stddec(amtincn,codempid,v_chken) incomperiod
                      into v_incomperiod
                 from ttaxcur
                where codempid = r1.codempid
                  and dteyrepay = r1.dteyrepay
                  and dtemthpay = r1.dtemthpay
                  and numperiod = r1.numperiod;
            exception when no_data_found then
              v_incomperiod := 0;
            end;

            obj_data.put('codcomp', r1.codcomp);
            obj_data.put('image',  get_emp_img(r1.codempid));
            obj_data.put('codempid', r1.codempid);
            obj_data.put('desc_codempid', get_temploy_name(r1.codempid,global_v_lang));
            obj_data.put('codpay', r2.codpay);
            obj_data.put('desc_codpay', get_tinexinf_name(r2.codpay,global_v_lang));
            obj_data.put('amonth', to_char(r2.amtpay,'fm9999999990'));
            obj_data.put('deducty', to_char(r2.amtded,'fm9999999990'));
            --obj_data.put('deductn', r2.amtpay - r2.amtded);
            obj_data.put('deductn', r2.amtpay - r2.amtded);
            obj_data.put('incomperiod', v_incomperiod);

            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt           := v_rcnt + 1;        
        end loop;

      end if;
    end loop;

    if not v_flg_exist then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TOTHDED');
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('400',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;
  --
  procedure get_index (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
    null;
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_index;
END HRPY59X;

/
