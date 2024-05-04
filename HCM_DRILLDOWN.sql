--------------------------------------------------------
--  DDL for Package HCM_DRILLDOWN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_DRILLDOWN" IS
-- last update: 21/05/2018 12:02

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  p_codempid                TEMPLOY1.CODEMPID%TYPE;
  p_codskill                TCODSKIL.CODCODEC%TYPE;
  p_flgsecur                varchar2(4 char);

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure get_employment_data (json_str_input in clob, json_str_output out clob);
  procedure gen_employment_data (json_str_output out clob);
  procedure get_work_experience (json_str_input in clob, json_str_output out clob);
  procedure gen_work_experience (json_str_output out clob);
  procedure get_history_salary (json_str_input in clob, json_str_output out clob);
  procedure gen_history_salary (json_str_output out clob);
  procedure get_history_punishment (json_str_input in clob, json_str_output out clob);
  procedure gen_history_punishment (json_str_output out clob);

  procedure get_competency_level (json_str_input in clob, json_str_output out clob);
  procedure gen_competency_level (json_str_output out clob);
END HCM_DRILLDOWN;

/
