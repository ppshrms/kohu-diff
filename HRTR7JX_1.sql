--------------------------------------------------------
--  DDL for Package Body HRTR7JX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRTR7JX" AS
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

    p_codempid          := hcm_util.get_string_t(json_obj, 'p_codempid_query');
    p_codcomp           := hcm_util.get_string_t(json_obj, 'p_codcomp');
    p_codpos            := hcm_util.get_string_t(json_obj, 'p_codpos');
    p_dteyear           := to_number(hcm_util.get_number_t(json_obj, 'p_dteyear'));

    hcm_secur.get_global_secur(global_v_coduser, global_v_zminlvl, global_v_zwrklvl, global_v_numlvlsalst, global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_codcompy         tcompny.codcompy%type;
    v_codpos           tpostn.codpos%type;
    v_staemp           temploy1.staemp%type;
    v_zupdsal          varchar2(100 char);
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
    if p_codempid is not null then
      v_staemp := hcm_util.get_temploy_field(p_codempid, 'staemp');
      if v_staemp is not null then
        if not secur_main.secur2(p_codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
          param_msg_error := get_error_msg_php('HR3007', global_v_lang);
          return;
        end if;
      else
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'temploy1');
      end if;
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
    v_zupdsal          varchar2(100 char);
    v_data_found       boolean := false;

    cursor c1 is
      select a.codempid, a.codcours
        from tpotentp a, temploy1 b
       where a.codempid = b.codempid
         and b.codempid = nvl(p_codempid, b.codempid)
         and b.codcomp  like p_codcomp || '%'
         and b.codpos   = nvl(p_codpos, b.codpos)
         and a.dteyear  = p_dteyear
         and a.flgatend = 'N'
       group by a.codempid, a.codcours
       order by a.codempid, a.codcours;

  begin
    obj_row       := json_object_t();

    for i in c1 loop
      v_data_found := true;
      if secur_main.secur2(i.codempid, global_v_coduser, global_v_zminlvl, global_v_zwrklvl, v_zupdsal) then
        v_rcnt      := v_rcnt+1;
        obj_data    := json_object_t();
        obj_data.put('coderror', '200');
        obj_data.put('dteyear', p_dteyear);
        obj_data.put('codcompy', p_codcomp);
        obj_data.put('image', get_emp_img(i.codempid));
        obj_data.put('codempid', i.codempid);
        obj_data.put('desc_codempid', get_temploy_name(i.codempid, global_v_lang));
        obj_data.put('codcours', i.codcours);
        obj_data.put('desc_codcours', get_tcourse_name(i.codcours, global_v_lang));
        obj_row.put(to_char(v_rcnt - 1), obj_data);
      end if;
    end loop;

    if obj_row.get_size > 0 then
      json_str_output := obj_row.to_clob;
    else
      if v_data_found then
        param_msg_error := get_error_msg_php('HR3007', global_v_lang);
      else
        param_msg_error := get_error_msg_php('HR2055', global_v_lang, 'tpotentp');
      end if;
      json_str_output := get_response_message(null, param_msg_error, global_v_lang);
    end if;
  end gen_index;
end HRTR7JX;

/
