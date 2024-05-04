--------------------------------------------------------
--  DDL for Package HRAP18E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP18E" as 
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
  
  b_index_codcompy      tstdisd.codcomp%type;
  b_index_codaplvl      tstdisd.codaplvl%type; --03/03/2021
  procedure initial_value(json_str in clob);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
end hrap18e;

/
