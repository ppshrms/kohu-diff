--------------------------------------------------------
--  DDL for Package Body HRAL75X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRAL75X" is
-- last update: 27/03/2018 14:16
  procedure initial_value(json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj,'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj,'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj,'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj,'p_codempid');
    -- index
    p_codcomp           := upper(hcm_util.get_string_t(json_obj,'p_codcomp'));
    p_typpayroll        := hcm_util.get_string_t(json_obj,'p_typpayroll');
    p_codempid          := upper(hcm_util.get_string_t(json_obj,'p_codempid'));
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj,'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj,'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj,'p_dteyrepay'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_typpayroll        varchar2(10 char);
    v_staemp            temploy1.staemp%type;
    v_flgsecu           boolean := true;
  begin
--    if p_codcomp is null and p_codempid is null then
--      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
--      return;
--    end if;
    if p_codcomp is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcomp);
      if param_msg_error is not null then
        return;
      else
        p_codcomp  := p_codcomp || '%';
      end if;
    end if;

    if p_typpayroll is not null then
      begin
        select codcodec
          into v_typpayroll
          from tcodtypy
         where codcodec = upper(p_typpayroll);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010',global_v_lang, 'tcodtypy');
        return;
      end;
    end if;

--    if p_codempid is null and p_codcomp is null then
--      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
--      return;
--    end if;
    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is null then
          param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1'); -- for procedure
          return; -- for procedure
      else
          v_flgsecu := secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
          if not v_flgsecu then
            param_msg_error := get_error_msg_php('HR3007', global_v_lang); -- for procedure
            return; -- for procedure
          end if;
      end if;

      begin
        select codcomp into p_codcomp
          from temploy1
         where codempid = p_codempid;
      exception when no_data_found then
        p_codcomp := null;
      end;

    end if;

    if p_dteyrepay is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    if p_numperiod is null then
      param_msg_error := get_error_msg_php('HR2045',global_v_lang);
      return;
    end if;

    begin
      select qtyavgwk into p_qtyavgwk
        from tcontral
       where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
         and dteeffec = ( select max(dteeffec)
                            from tcontral
                           where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1)
                             and dteeffec <= sysdate);
    exception when no_data_found then
      p_qtyavgwk := 0;
    end;
  end check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob) as
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error   := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output   := get_response_message('400',param_msg_error,global_v_lang);
  end;

  procedure gen_index(json_str_output out clob) as
    obj_row           json_object_t;
    obj_data          json_object_t;
    v_rcnt            number := 0;
    flg_data          varchar2(1 char) := 'N';
    v_codcomp         varchar2(4000 char);
    v_lvlst           number;
    v_lvlen           number;
    v_namcentlvl      varchar2(4000 char);
    v_namcent         varchar2(4000 char);
    v_flgsecu         boolean := true;
    v_amtpay          varchar2(4000 char);
    v_amtday          varchar2(4000 char);

    cursor c1_tpaysum is
      select t1.codalw, t1.codempid, t1.codcomp, t1.typpayroll, t1.codpos, t1.codpay, t1.amtday,
            t1.qtyday, t1.amtpay, t1.dteupd, t1.coduser, t1.dtemthpay, t1.dteyrepay, t1.numperiod
        from tpaysum t1, temploy1 t2
       where t1.codempid   = t2.codempid
         and t1.codcomp    like p_codcomp||'%'
         and t1.typpayroll = nvl(p_typpayroll, t1.typpayroll)
         and t1.codempid   = nvl(p_codempid, t1.codempid)
         and t1.dtemthpay  = p_dtemthpay
         and t1.dteyrepay  = p_dteyrepay
         and t1.numperiod  = p_numperiod
         and t1.flgtran    = 'Y'
    order by codcomp, codempid,codpay;
  begin

    flg_data        := 'N';
    obj_row         := json_object_t();
    obj_data        := json_object_t();
    for r1 in c1_tpaysum loop
      flg_data      := 'Y';
      v_flgsecu := secur_main.secur2(r1.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_zupdsal);
      if v_flgsecu then
        v_amtday := null;
        if r1.codalw not in ('AWARD','RET_AWARD') then
          if global_v_zupdsal = 'Y' then
            v_amtday := to_char(stddec(r1.amtday, r1.codempid, v_chken), 'fm999,999,990.00');
          end if;
        end if;
        v_amtpay  := null;
        if global_v_zupdsal = 'Y' then
          v_amtpay := to_char(stddec(r1.amtpay, r1.codempid, v_chken), 'fm999,999,990.00');
        end if;


        v_rcnt        := v_rcnt + 1;
        obj_data      := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codpos', r1.codpos);
        obj_data.put('desc_codpos', get_tpostn_name(r1.codpos, global_v_lang));
        obj_data.put('typpayroll', get_tcodec_name('tcodtypy', r1.typpayroll, global_v_lang));
        obj_data.put('codpay', r1.codpay || ' - ' || get_tinexinf_name(r1.codpay, global_v_lang));
        obj_data.put('amtday', v_amtday);
        obj_data.put('qtyday', cal_dhm_concat(r1.qtyday, p_qtyavgwk));
        obj_data.put('amtpay', v_amtpay);
        obj_data.put('image', get_emp_img(r1.codempid));
        obj_data.put('dteupd', to_char(r1.dteupd, 'DD/MM/YYYY'));
        obj_data.put('coduser', r1.coduser);
        obj_data.put('codpay2', r1.codpay);
        obj_data.put('codalw', r1.codalw);
        obj_data.put('dtemthpay', r1.dtemthpay);
        obj_data.put('dteyrepay', r1.dteyrepay);
        obj_data.put('numperiod', r1.numperiod);

        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if flg_data = 'Y' then
      if obj_row.get_size > 0 then
        json_str_output := obj_row.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      end if;
    else
      param_msg_error     := get_error_msg_php('HR2055', global_v_lang,'tpaysum');
    end if;
    if param_msg_error is not null then
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  end;

end HRAL75X;

/
