--------------------------------------------------------
--  DDL for Package HRAP32E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP32E" as
  --para
  param_msg_error       varchar2(4000);

  --global
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_zupdsal      varchar2(4 char);

  global_v_coduser      varchar2(100);
  global_v_codempid     varchar2(100);
  global_v_lang         varchar2(100);
  global_v_zyear        number  := 0;
  global_v_chken        varchar2(10) := hcm_secur.get_v_chken;

  b_index_dteyreap      tobjemp.dteyreap%type;
  b_index_numtime       tobjemp.numtime%type;
  b_index_codempid      tobjemp.codempid%type;
  b_index_codpos        temploy1.codpos%type;
  b_index_codcomp       temploy1.codcomp%type;
  global_v_kpino        varchar2(30);
  type t_arr_varchar2 is table of varchar2(4000) index by varchar2(100);
  arr_col_empty         t_arr_varchar2;
  arr_col_name          t_arr_varchar2;
  arr_col_value         t_arr_varchar2;

  type t_arr_char is table of varchar2(4000) index by binary_integer;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_object_kpi(json_str_input in clob,json_str_output out clob);
  procedure get_job_kpi(json_str_input in clob,json_str_output out clob);
  procedure get_lov_kpi(json_str_input in clob,json_str_output out clob);
  procedure get_kpi_detail(json_str_input in clob,json_str_output out clob);
  procedure get_score_condition(json_str_input in clob,json_str_output out clob);
  procedure get_action_plan(json_str_input in clob,json_str_output out clob);
  procedure save_kpi(json_str_input in clob,json_str_output out clob);
  procedure save_index(json_str_input in clob,json_str_output out clob);
  procedure get_copy_kpi(json_str_input in clob,json_str_output out clob);
  procedure import_data(json_str_input in clob,json_str_output out clob);
  procedure delete_index(json_str_input in clob,json_str_output out clob);
end;

/
