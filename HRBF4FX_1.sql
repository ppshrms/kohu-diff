--------------------------------------------------------
--  DDL for Package Body HRBF4FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF4FX" AS
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

    p_dteyre            := hcm_util.get_string_t(json_obj, 'p_dteyre');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DD/MM/YYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DD/MM/YYYY');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index AS
    v_staemp            temploy1.staemp%type;
    v_codcomp           temploy1.codcomp%type;
  begin
    if p_codempid_query is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid_query, 'staemp');
      if v_staemp is not null then
        if not secur_main.secur2(p_codempid_query, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
        return;
      end if;
    end if;
    if p_codcomp is not null then
      begin
        select codcompy
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
  end;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
    if param_msg_error is null then
      gen_index(json_str_output);
    end if;
    if param_msg_error is not null then
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

    cursor c1 is
     select codempid, dteyre, dtemth, codobf, fldedit, desold, desnew, dteupd, coduser
       from tobflog
      where codempid like nvl(p_codempid_query, '%')
        and codempid in (select codempid from temploy1 where codcomp like p_codcomp || '%')
        and dteyre   = nvl(p_dteyre, dteyre)
        and (
            trunc(dteupd) between p_dtestrt and p_dteend
            or (p_dtestrt is null and p_dteend is null)
        )
      order by dteupd, codempid, codobf;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      v_found     := true;
      if secur_main.secur2(i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        v_rcnt      := v_rcnt + 1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('dteyre', i.dteyre);
        obj_data.put('dtemth', i.dtemth);
        obj_data.put('codobf', i.codobf);
        obj_data.put('desc_codobf', get_tobfcde_name(i.codobf, global_v_lang));
        obj_data.put('dteupd', to_char(i.dteupd, 'DD/MM/YYYY HH24:MI:SS'));
        obj_data.put('dteedit', to_char(i.dteupd, 'DD/MM/YYYY'));
        obj_data.put('timedit', to_char(i.dteupd, 'HH24:MI'));
        obj_data.put('fldedit', i.fldedit);
        obj_data.put('desc_fldedit', get_tcoldesc_name('TOBFSUM', i.fldedit, global_v_lang));
        obj_data.put('desold', i.desold);
        obj_data.put('desnew', i.desnew);
        obj_data.put('coduser', i.coduser);
        obj_data.put('desc_coduser', get_temploy_name(get_codempid(i.coduser), global_v_lang));

        obj_rows.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;
    if v_found then
      if obj_rows.get_size > 0 then
        json_str_output := obj_rows.to_clob;
      else
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        json_str_output := get_response_message(null, param_msg_error, global_v_lang);
      end if;
    else
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tobflog');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;
end HRBF4FX;

/
