--------------------------------------------------------
--  DDL for Package Body HRTR73X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR73X" AS
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

    p_dteyear           := to_number(hcm_util.get_number_t(json_obj, 'p_dteyear'));
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj, 'p_codpos');

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  function convert_numhour_to_minute (v_number number) return varchar2 is
  begin
    return (trunc(v_number) * 60) +  (mod(v_number, 1) * 100);
  end convert_numhour_to_minute;

  procedure check_index is
    v_codcompy        tcompny.codcompy%type;
    v_codpos          tpostn.codpos%type;
  begin
    if p_codcomp is not null then
      begin
        select codcompy
          into v_codcompy
          from tcompny
         where codcompy = hcm_util.get_codcomp_level(p_codcomp, 1);
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tcompny');
        return;
      end;
      if not secur_main.secur7(p_codcomp, global_v_coduser) then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
        return;
      end if;
    end if;
    if p_codpos is not null then
      begin
        select codpos
          into v_codpos
          from tpostn
         where codpos = p_codpos;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tpostn');
        return;
      end;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) AS
  begin
    initial_value(json_str_input);
    check_index;
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
    obj_row            json_object_t;
    obj_data           json_object_t;
    v_rcnt             number := 0;
    v_qtytrmin         thistrnn.qtytrmin%type;
    v_zupdsal          varchar2(100 char);
    v_data_found       boolean := false;

    cursor c1 is
      select a.codempid, a.codcomp, a.codpos, a.numlvl, nvl(b.qtyminhr, 0) qtyminhr
        from temploy1 a
        left join ttrnnhr b on a.codcomp like b.codcomp || '%' and a.codpos = b.codpos
       where a.codcomp like p_codcomp || '%'
         and a.codpos  = nvl(p_codpos, a.codpos)
         and a.staemp  not in ('0', '9')
       order by a.codpos, a.codempid;

  begin
    obj_row       := json_object_t();

    for i in c1 loop
      begin
        select sum((trunc(nvl(qtytrmin, 0)) * 60) +  (mod(nvl(qtytrmin, 0), 1) * 100))
          into v_qtytrmin
          from thistrnn
          where codempid = i.codempid
            and dteyear  = p_dteyear;
      exception when no_data_found then
        v_qtytrmin := 0;
      end;
      if convert_numhour_to_minute(nvl(i.qtyminhr, 0)) > nvl(v_qtytrmin, 0) then
        v_data_found := true;
        if secur_main.secur1(i.codcomp, i.numlvl, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
          v_rcnt      := v_rcnt+1;
          obj_data    := json_object_t();
          obj_data.put('coderror', '200');
          obj_data.put('codcomp', i.codcomp);
          obj_data.put('codpos', i.codpos);
          obj_data.put('desc_codpos', get_tpostn_name(i.codpos, global_v_lang));
          obj_data.put('image', get_emp_img(i.codempid));
          obj_data.put('codempid', i.codempid);
          obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
          obj_data.put('qtyminhr', convert_numhour_to_minute(nvl(i.qtyminhr, 0)));
          obj_data.put('qtytrmin', nvl(v_qtytrmin, 0));
          obj_data.put('result', convert_numhour_to_minute(nvl(i.qtyminhr, 0)) - nvl(v_qtytrmin, 0));

          obj_row.put(to_char(v_rcnt - 1), obj_data);
        end if;
      end if;
    end loop;

    if obj_row.get_size > 0 then
      json_str_output := obj_row.to_clob;
    else
      if v_data_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'ttrnnhr');
      end if;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;
end HRTR73X;

/
