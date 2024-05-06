--------------------------------------------------------
--  DDL for Package HRAP4OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP4OE" AS 

  v_chken      varchar2(100 char);

  param_msg_error     varchar2(4000 char);

  global_v_coduser      varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  b_index_dteyreap      number;
  b_index_codcompy      tapbudgt.codcomp%type;
  b_index_codcomp       tapbudgt.codcomp%type;
  p_pctsal              tapbudgt.pctsal%type;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure get_drilldown(json_str_input in clob, json_str_output out clob);
  procedure cal_budget(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
END HRAP4OE;

/
