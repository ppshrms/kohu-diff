--------------------------------------------------------
--  DDL for Package HCM_APPSETTINGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_APPSETTINGS" IS
-- last update: 21/05/2018 12:02

  param_msg_error           varchar2(4000 char);

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);

  procedure initial_value (json_str in clob);

  procedure get_settings (json_str_input in clob, json_str_output out clob);
  procedure gen_settings (json_str_output out clob);
  function get_additional_year return number;
END HCM_APPSETTINGS;

/
