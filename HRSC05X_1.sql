--------------------------------------------------------
--  DDL for Package Body HRSC05X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HRSC05X" as
-- last update: 16/11/2018 00:34
  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    v_chken             := hcm_secur.get_v_chken;
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
    global_v_lrunning   := hcm_util.get_string_t(json_obj, 'p_lrunning');

    -- index params
    p_coduser           := hcm_util.get_string_t(json_obj, 'p_coduser_query');
    p_dtestrt           := to_date(hcm_util.get_string_t(json_obj, 'p_dtestrt'), 'dd/mm/yyyy');
    p_dteend            := to_date(hcm_util.get_string_t(json_obj, 'p_dteend'), 'dd/mm/yyyy');

    hcm_secur.get_global_secur(global_v_coduser,global_v_zminlvl,global_v_zwrklvl,global_v_numlvlsalst,global_v_numlvlsalen);
  end initial_value;

  procedure check_index is
    v_coduser         tusrprof.coduser%type;
  begin
    if p_dtestrt is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dteend is null then
      param_msg_error := get_error_msg_php('HR2045', global_v_lang);
      return;
    end if;

    if p_dtestrt > p_dteend then
      param_msg_error := get_error_msg_php('HR2021', global_v_lang);
      return;
    end if;

    if p_coduser is not null then
      begin
        select coduser
          into v_coduser
          from tusrprof
         where coduser = p_coduser;
      exception when no_data_found then
        param_msg_error := get_error_msg_php('HR2010', global_v_lang, 'tusrprof');
        return;
      end;
    end if;
  end check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob) is
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

  procedure gen_index (json_str_output out clob) is
  v_exist                boolean := false;
  obj_row                json_object_t;
  obj_data               json_object_t;
  v_rcnt                 number;
  v_year                 number;
  cursor c_terrlogin is
    select lterminal, loginid, ldteacc, luserid, lipaddress, lremark
      from terrlogin
     where luserid = nvl(p_coduser, luserid)
       and trunc(ldteacc) between p_dtestrt and p_dteend
     order by luserid, ldteacc;
  begin
    obj_row              := json_object_t();
    v_rcnt               := 0;
    for c1 in c_terrlogin loop
      v_exist            := true;
      obj_data           := json_object_t();
      v_rcnt             := v_rcnt + 1;
      v_year             := to_number(to_char(c1.ldteacc, 'yyyy')) + hcm_appsettings.get_additional_year;

      obj_data.put('coderror', '200');
      obj_data.put('numseq', v_rcnt);
      obj_data.put('lterminal', c1.lterminal);
      obj_data.put('loginid', c1.loginid);
      obj_data.put('desc_loginid', get_temploy_name(get_codempid(c1.luserid), global_v_lang));
      obj_data.put('ldteacc', to_char(c1.ldteacc, 'dd/mm/') || to_char(v_year) || to_char(c1.ldteacc, ' hh24:mi:ss'));
      obj_data.put('luserid', c1.luserid);
      obj_data.put('lipaddress', c1.lipaddress);
      obj_data.put('lremark', c1.lremark);

      obj_row.put(to_char(v_rcnt - 1), obj_data);
    end loop;
    if v_exist then
      json_str_output := obj_row.to_clob;
    else
      param_msg_error   := get_error_msg_php('HR2055', global_v_lang, 'terrlogin');
      json_str_output   := get_response_message(null, param_msg_error, global_v_lang);
    end if;
    exception when others then
    param_msg_error     := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output     := get_response_message('400', param_msg_error, global_v_lang);
  end gen_index;
end HRSC05X;

/
