--------------------------------------------------------
--  DDL for Package Body HRPY52X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRPY52X" as

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
    p_codcompy          := hcm_util.get_string_t(json_obj, 'p_codcompy');
    p_locstart          := hcm_util.get_string_t(json_obj, 'p_locstart');
    p_locend            := hcm_util.get_string_t(json_obj, 'p_locend');
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');
    p_numperiod         := to_number(hcm_util.get_string_t(json_obj, 'p_numperiod'));
    p_dtemthpay         := to_number(hcm_util.get_string_t(json_obj, 'p_dtemthpay'));
    p_dteyrepay         := to_number(hcm_util.get_string_t(json_obj, 'p_dteyrepay'));

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_locstart   ttaxcur.codbrlc%type;
    v_locend     ttaxcur.codbrlc%type;
    v_typpayroll ttaxcur.typpayroll%type;
  begin
    if p_codcompy is not null then
      param_msg_error := hcm_secur.secur_codcomp(global_v_coduser, global_v_lang, p_codcompy);
      if param_msg_error is not null then
        return;
      end if;
    end if;
    --
    if p_locstart is not null then
      begin
        select codcodec
          into v_locstart
          from tcodloca
         where codcodec = p_locstart;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodloca');
        return;
      end;
    end if;
    --
    if p_locend is not null then
      begin
        select codcodec
          into v_locend
          from tcodloca
         where codcodec = p_locend;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodloca');
        return;
      end;
    end if;

    if p_locstart > p_locend then
      param_msg_error := get_error_msg_php('HR2022', global_v_lang, 'tcodloca');
      return;
    end if;
    --
    if p_typpayroll is not null then
      begin
        select codcodec
          into v_typpayroll
          from tcodtypy
         where codcodec = p_typpayroll;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcodtypy');
        return;
      end;
    end if;
  end check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_data(json_str_output);
    else
      json_str_output := get_response_message(null,param_msg_error,global_v_lang);
    end if;
  exception when others then
    param_msg_error := dbms_utility.format_error_stack||' '||dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400',param_msg_error,global_v_lang);
  end get_data;

  procedure gen_data(json_str_output out clob) is
    obj_row             json_object_t;
    obj_data            json_object_t;
    v_rcnt              number;
    v_flgdata           varchar2(1 char) := 'N';
    v_total             number := 0;
    v_total_all         number := 0;
    v_old_loc           ttaxcur.codbrlc%type := '####';
    v_codapp            varchar2(100 char) := 'HRPY52XC2';
    v_flg_data          boolean := false;
    v_flg_secure        boolean := false;
    v_flg_permission    boolean := false;

    cursor c1 is
      select b.codempid, stddec(a.amtnet,a.codempid,v_chken) amtnet,
             a.codcomp, a.codbrlc, a.rowid,a.dtemthpay,a.dteyrepay,a.numperiod
        from ttaxcur a, temploy1 b
       where a.codempid = b.codempid
         and a.codcomp like p_codcompy||'%'
         and a.codbrlc between p_locstart and p_locend
         and a.typpayroll = p_typpayroll
         and a.numperiod  = p_numperiod
         and a.dtemthpay  = p_dtemthpay
         and a.dteyrepay  = p_dteyrepay
    order by a.codbrlc,b.codempid;
  begin
    obj_row                := json_object_t();
    v_rcnt                 := 0;
    --
    for r1 in c1 loop
      v_flg_data := true;
      exit;
    end loop;
    if not v_flg_data then
      param_msg_error := get_error_msg_php('HR2055',global_v_lang,'TTAXCUR');
      json_str_output := get_response_message('404',param_msg_error,global_v_lang);
      return;
    end if;
    --
    for r1 in c1 loop
      v_flg_secure  := secur_main.secur3(r1.codcomp,r1.codempid,global_v_coduser,global_v_numlvlsalst,global_v_numlvlsalen,v_zupdsal);
      if v_flg_secure then
        v_flg_permission := true;
        if r1.codbrlc <> v_old_loc then
          if v_total <> 0 then
            obj_data         := json_object_t();
            obj_data.put('coderror', '200');
            obj_data.put('desc_codcomp', get_label_name(v_codapp,global_v_lang,'70'));
            obj_data.put('flgsum', 'Y');
            obj_data.put('amtnet', v_total);
            v_total := 0;
            obj_row.put(to_char(v_rcnt), obj_data);
            v_rcnt           := v_rcnt + 1;
          end if;
          obj_data         := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codempid', get_label_name(v_codapp,global_v_lang,'60'));
          obj_data.put('desc_codempid', r1.codbrlc||' - '||get_tcodec_name('tcodloca',r1.codbrlc,global_v_lang));
          obj_data.put('flgbreak', 'Y');

          obj_row.put(to_char(v_rcnt), obj_data);
          v_rcnt           := v_rcnt + 1;
          v_old_loc        := r1.codbrlc;
        end if;
        v_flgdata        := 'Y';
        obj_data         := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', nvl(get_emp_img(r1.codempid),r1.codempid));
        obj_data.put('codempid', r1.codempid);
        obj_data.put('desc_codempid', get_temploy_name(r1.codempid, global_v_lang));
        obj_data.put('codcomp', r1.codcomp);
        obj_data.put('desc_codcomp', get_tcenter_name(r1.codcomp,global_v_lang));
        obj_data.put('codbrlc', r1.codbrlc);
        obj_data.put('dtemthpay', r1.dtemthpay);
        obj_data.put('dteyrepay', r1.dteyrepay);
        obj_data.put('numperiod', r1.numperiod);
        -- check permissions
        if nvl(v_zupdsal, 'Y') = 'Y' then
          obj_data.put('amtnet', r1.amtnet);
          v_total := v_total + r1.amtnet;
          v_total_all := v_total_all + r1.amtnet;
        end if;
        --



        obj_row.put(to_char(v_rcnt), obj_data);
        v_rcnt           := v_rcnt + 1;
      end if;
    end loop;
    --
    if v_total <> 0 then
      obj_data         := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_codcomp', get_label_name(v_codapp,global_v_lang,'70'));
      obj_data.put('flgsum', 'Y');
      obj_data.put('amtnet', v_total);
      --
      v_total := 0;

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt           := v_rcnt + 1;
	end if;
    --
    if v_total_all <> 0 then
      obj_data         := json_object_t();
      obj_data.put('coderror', '200');
      obj_data.put('desc_codcomp', get_label_name(v_codapp,global_v_lang,'80'));
      obj_data.put('flgsum', 'Y');
      obj_data.put('amtnet', v_total_all);
      --
      v_total_all := 0;

      obj_row.put(to_char(v_rcnt), obj_data);
      v_rcnt           := v_rcnt + 1;
	end if;
    --

    if not v_flg_permission then
      param_msg_error := get_error_msg_php('HR3007',global_v_lang);
      json_str_output := get_response_message('403',param_msg_error,global_v_lang);
      return;
    end if;
    json_str_output := obj_row.to_clob;
  exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_data;
end HRPY52X;

/
