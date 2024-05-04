--------------------------------------------------------
--  DDL for Package Body HRBF4NX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4NX" AS
  procedure initial_value (json_str in clob) AS
    json_obj            json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    v_chken             := hcm_secur.get_v_chken;
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');

    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_dteyrepay         := to_number(hcm_util.get_number_t(json_obj, 'p_dteyrepay'));
    p_dtemthpay         := to_number(hcm_util.get_number_t(json_obj, 'p_dtemthpay'));
    p_numperiod         := to_number(hcm_util.get_number_t(json_obj, 'p_numperiod'));
    p_flginput          := to_char(hcm_util.get_number_t(json_obj, 'p_flginput'));
    p_typpayroll        := hcm_util.get_string_t(json_obj, 'p_typpayroll');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index AS
    v_codcomp           temploy1.codcomp%type;
    v_typpayroll        temploy1.typpayroll%type;
  begin
    if p_codcomp is not null then
      begin
        select codcomp
          into v_codcomp
          from tcenter
         where codcomp = hcm_util.get_codcomp_level(p_codcomp, null, null, 'Y');
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcenter');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
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
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
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
  end get_index;

  procedure gen_index (json_str_output out clob) AS
    obj_rows            json_object_t;
    obj_data            json_object_t;
    v_rcnt              number := 0;
    v_found             boolean := false;
    v_table             varchar(50 char) := 'ttravinf';

    cursor c1 is
     select a.codempid, a.dtereq, a.numtravrq, a.codpay, a.amtreq, c.costcent
       from ttravinf a, temploy1 b, tcenter c
      where a.codempid   = b.codempid
        and a.codcomp    = c.codcomp
        and a.codcomp    like p_codcomp || '%'
        and b.typpayroll = nvl(p_typpayroll, b.typpayroll)
        and a.dteyrepay  = p_dteyrepay
        and a.dtemthpay  = p_dtemthpay
        and a.numperiod  = p_numperiod
        and a.flgtranpy  = 'Y'
      order by a.codempid, a.dtereq, a.numtravrq;
    cursor c2 is
     select a.codempid, a.dtereq, a.numvcher, a.codobf, a.amtwidrw, c.costcent
       from tobfinf a, temploy1 b, tcenter c
      where a.codempid   = b.codempid
        and a.codcomp    = c.codcomp
        and a.codcomp    like p_codcomp || '%'
        and b.typpayroll = nvl(p_typpayroll, b.typpayroll)
        and a.dteyrepay  = p_dteyrepay
        and a.dtemthpay  = p_dtemthpay
        and a.numperiod  = p_numperiod
        and a.flgtranpy  = 'Y'
      order by a.codempid, a.dtereq, a.numvcher;
  begin
    obj_rows    := json_object_t();
    if p_flginput = '1' then
      v_table := 'ttravinf';
      for i in c1 loop
        v_found     := true;
        if secur_main.secur2(i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img(i.codempid));
          obj_data.put('codempid', i.codempid);
          obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
          obj_data.put('dtereq', to_char(i.dtereq, 'DD/MM/YYYY'));
          obj_data.put('numtravrq', i.numtravrq);
          obj_data.put('codpay', i.codpay);
          obj_data.put('desc_codpay', get_tinexinf_name(i.codpay, global_v_lang));
          obj_data.put('amtreq', i.amtreq);
          obj_data.put('costcent', i.costcent);

          obj_rows.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end loop;
    else
      v_table := 'tobfinf';
      for j in c2 loop
        v_found     := true;
        if secur_main.secur2(j.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          v_rcnt      := v_rcnt + 1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('image', get_emp_img(j.codempid));
          obj_data.put('codempid', j.codempid);
          obj_data.put('desc_codempid', get_temploy_name(j.codempid, global_v_lang));
          obj_data.put('dtereq', to_char(j.dtereq, 'DD/MM/YYYY'));
          obj_data.put('numtravrq', j.numvcher);
          obj_data.put('codpay', j.codobf);
          obj_data.put('desc_codpay', get_tobfcde_name(j.codobf, global_v_lang));
          obj_data.put('amtreq', j.amtwidrw);
          obj_data.put('costcent', j.costcent);

          obj_rows.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end loop;
    end if;
    if v_found then
      if obj_rows.get_size > 0 then
        json_str_output := obj_rows.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, v_table);
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;
end HRBF4NX;

/
