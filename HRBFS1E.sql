--------------------------------------------------------
--  DDL for Package HRBFS1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFS1E" is
-- last update: 14/09/2020 12:03

  v_chken      varchar2(100 char);

  param_msg_error           varchar2(4000 char);

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  v_zupdsal                 varchar2(4000 char);

  b_index_codcompy          varchar2(100 char);
  b_index_year              varchar2(100 char);
  p_codbenefit              varchar2(100 char);
  p_proccond                varchar2(100 char);
  p_yearcond                varchar2(100 char);
  p_dtetrial                date;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);

  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob);
  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_tab1 (json_str_output out clob);
  procedure gen_detail_tab2 (json_str_output out clob);
  procedure get_detail_right(json_str_input in clob, json_str_output out clob);

  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure process_data (json_str_input in clob, json_str_output out clob);
  procedure gen_empbf (json_str_input in clob);
--  procedure get_process_table (json_str_input in clob, json_str_output out clob);
--  procedure gen_process_table (json_str_output out clob);

END; -- Package spec

/
