--------------------------------------------------------
--  DDL for Package HRAP16X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP16X" is
-- last update: 09/09/2020 14:17

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
  b_index_numtime       number;
  b_index_codcomp       varchar2(4000 char);
  b_index_codaplvl      varchar2(4000 char);
  b_index_codempid      varchar2(4000 char);

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_data_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_data_detail(json_str_output out clob);
END; -- Package spec

/
