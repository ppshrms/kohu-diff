--------------------------------------------------------
--  DDL for Package Body HRBF1YX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRBF1YX" AS
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

    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'DDMMYYYY');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'DDMMYYYY');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codempid_query    := hcm_util.get_string_t(json_obj, 'p_codempid_query');

    p_additional_year   := hcm_appsettings.get_additional_year;
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
    v_desold            varchar2(500 char);
    v_desnew            varchar2(500 char);

    cursor c1 is
     select codempid, dteedit, fldedit, desold, desnew, dteupd, codcreate
       from trepaylog
      where codempid = nvl(p_codempid_query, codempid)
        and codcomp  like p_codcomp || '%'
        and trunc(dteedit)  between p_dtestrt and p_dteend
      order by codempid, dteedit;
  begin
    obj_rows    := json_object_t();
    for i in c1 loop
      v_found     := true;
      if secur_main.secur2(i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, p_zupdsal) then
        v_rcnt      := v_rcnt + 1;
        v_desold    := i.desold;
        v_desnew    := i.desnew;
        if upper(i.fldedit) in ('DTEAPPR', 'DTECLOSE', 'DTETRANPY', 'DTEAPPRAJ', 'DTECREATE', 'DTEUPD') then
          if v_desold is not null then
            v_desold    := to_char(to_date(v_desold, 'dd/mm/yyyy'), 'dd/mm/') || (to_number(to_char(to_date(v_desold, 'dd/mm/yyyy'), 'yyyy')) + p_additional_year);
          end if;
          if v_desnew is not null then
            v_desnew    := to_char(to_date(v_desnew, 'dd/mm/yyyy'), 'dd/mm/') || (to_number(to_char(to_date(v_desnew, 'dd/mm/yyyy'), 'yyyy')) + p_additional_year);
          end if;
        end if;
        if upper(i.fldedit) = 'DTESTRPM' or upper(i.fldedit) = 'DTELSTPAY' then
          if v_desold is not null then
            v_desold    := to_char(to_number(substr(v_desold, 0, 4)) + p_additional_year) || '/' || substr(v_desold, 5, 2) || '/' || substr(v_desold, 7, 2);
          end if;
          if v_desnew is not null then
            v_desnew    := to_char(to_number(substr(v_desnew, 0, 4)) + p_additional_year) || '/' || substr(v_desnew, 5, 2) || '/' || substr(v_desnew, 7, 2);
          end if;
        end if;
        if upper(i.fldedit) in ('AMTTPAY', 'AMTOUTSTD', 'AMTREPAYM', 'AMTTOTPAY', 'AMTCLOSE', 'AMTLSTPAY') then
          if v_desold is not null then
            v_desold    := to_char(v_desold, 'fm99,999,990.90');
          end if;
          if v_desnew is not null then
            v_desnew    := to_char(v_desnew, 'fm99,999,990.90');
          end if;
        end if;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('dteedit', to_char(i.dteedit, 'DD/MM/YYYY HH24:MI:SS'));
        obj_data.put('dtedate', to_char(i.dteedit, 'DD/MM/YYYY'));
        obj_data.put('timedit', to_char(i.dteedit, 'HH24:MI:SS'));
        obj_data.put('fldedit', i.fldedit);
        obj_data.put('desc_fldedit', get_tcoldesc_name('TREPAY', i.fldedit, global_v_lang));
        obj_data.put('desold', v_desold);
        obj_data.put('desnew', v_desnew);
        obj_data.put('dteupd', to_char(i.dteupd, 'DD/MM/YYYY'));
        obj_data.put('coduser', i.codcreate);
        obj_data.put('desc_coduser', get_temploy_name(get_codempid(i.codcreate), global_v_lang));

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
      param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'trepaylog');
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;
end HRBF1YX;


/
