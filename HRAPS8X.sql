--------------------------------------------------------
--  DDL for Package HRAPS8X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAPS8X" is
-- last update: 29/08/2020 15:17

  v_chken      varchar2(100 char);

  param_msg_error     varchar2(4000 char);

  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  b_index_codcomp       varchar2(4000 char);
  b_index_jobgrade      varchar2(4000 char);
  b_index_salarymin     number;
  b_index_salarymax     number;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_detail_min(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_min(json_str_output out clob);
  procedure get_detail_max(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_max(json_str_output out clob);

--  procedure get_index_graph(json_str_input in clob, json_str_output out clob);
  procedure gen_index_graph;
END; -- Package spec

/
