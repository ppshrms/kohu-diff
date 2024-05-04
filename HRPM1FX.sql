--------------------------------------------------------
--  DDL for Package HRPM1FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM1FX" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          number;
  v_zupdsal   		    varchar2(4 char);

  pa_codcomp                temploy1.codcomp%type;
  pa_codempid               temploy1.codempid%type;
  pa_staemp                 temploy1.staemp%type;
  pa_dtestr_str             varchar2(10 char);
  pa_dteend_str             varchar2(10 char);
  pa_dtestr                 date;
  pa_dteend                 date;

  pa_codasset               tasetinf.codasset%type;

  procedure initial_value (json_str in clob);
  procedure vadidate_variable_getindex(json_str_input in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure initial_value_detail (json_str in clob);
  procedure vadidate_variable_get_detail(json_str_input in clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);

end HRPM1FX;

/
