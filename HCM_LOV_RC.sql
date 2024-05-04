--------------------------------------------------------
--  DDL for Package HCM_LOV_RC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_RC" is
  global_v_coduser      varchar2(1000 char);
  global_v_codempid     varchar2(1000 char);
  global_v_lang         varchar2(100 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4000 char);
  v_chken               varchar2(10 char);

  v_cursor			        number;
  v_dummy               integer;
  v_stmt			          varchar2(5000 char);

  param_flg_secur       varchar2(4000 char);
  param_where           varchar2(4000 char);

  procedure initial_value(json_str in clob);
  function get_examination_code(json_str_input in clob) return clob;      --LOV List of Examination Code
  function get_guarantor_names(json_str_input in clob) return clob;       --LOV List of Guarantor Names
  function get_news_source_code(json_str_input in clob) return clob;      --LOV List of News Source Code
  function get_mail_alert_number_rc(json_str_input in clob) return clob;  --LOV for Mail Alert Number rc
  function get_appointment_type(json_str_input in clob) return clob;      --LOV Appointment type list
  function get_reason_for_rejection(json_str_input in clob) return clob;  --LOV List of Reason For The Rejection
  function get_media_codes(json_str_input in clob) return clob;           --LOV List of Media Codes
  function get_examination_position(json_str_input in clob) return clob;  --LOV List of Examination Position

end;

/
