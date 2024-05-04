--------------------------------------------------------
--  DDL for Package Body HCM_APPSETTINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "HCM_APPSETTINGS" IS
-- last update: 23/02/2018 12:02

  procedure initial_value (json_str in clob) is
    json_obj        json_object_t;
  begin
    json_obj            := json_object_t(json_str);
    -- global
    global_v_coduser    := hcm_util.get_string_t(json_obj, 'p_coduser');
    global_v_codpswd    := hcm_util.get_string_t(json_obj, 'p_codpswd');
    global_v_lang       := hcm_util.get_string_t(json_obj, 'p_lang');
    global_v_codempid   := hcm_util.get_string_t(json_obj, 'p_codempid');
  end initial_value;

  function get_additional_year return number is
  begin
    return nvl(get_tsetup_value('ADDITIONAL_YEAR'), 0);
  end;

  procedure get_settings (json_str_input in clob, json_str_output out clob) is
  begin
    initial_value (json_str_input);
    gen_settings(json_str_output);
  exception when others then
    param_msg_error := dbms_utility.format_error_stack || ' ' || dbms_utility.format_error_backtrace;
    json_str_output := get_response_message('400', param_msg_error, global_v_lang);
  end get_settings;

  procedure gen_settings (json_str_output out clob) is
    obj_data            json_object_t;
  begin
    obj_data            := json_object_t();
    obj_data.put('coderror', '200');
    obj_data.put('additionalYear', get_additional_year);

    json_str_output := obj_data.to_clob;
  end gen_settings;

END HCM_APPSETTINGS;

/
