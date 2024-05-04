--------------------------------------------------------
--  DDL for Package HCM_LOV_TR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_TR" is
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
  function get_training_course(json_str_input in clob) return clob;             --LOV for TR Training Course
  function get_memorandum(json_str_input in clob) return clob;                  --LOV for TR Memorandum
  function get_hotel_training(json_str_input in clob) return clob;              -- List of Hotel / Training of Place
  function get_code_institute(json_str_input in clob) return clob;              -- List of Institute Code
  function get_instructor_name(json_str_input in clob) return clob;             -- List of Instructor Name
  function get_cost_training_code(json_str_input in clob) return clob;          -- List Cost of Training Code
  function get_certificate_format(json_str_input in clob) return clob;          -- List of Certificate Format Code
  function get_department_jobposition(json_str_input in clob) return clob;      -- List of Department
  function get_course_category(json_str_input in clob) return clob;             -- List of Course
  function get_service_type(json_str_input in clob) return clob;                -- List of Service type
  function get_mail_alert_number_tr(json_str_input in clob) return clob;        -- List of Mail Alert Number
  function get_generation(json_str_input in clob) return clob;                  -- List of Generation
end;

/
