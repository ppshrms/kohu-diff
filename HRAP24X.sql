--------------------------------------------------------
--  DDL for Package HRAP24X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP24X" is
-- last update: 26/08/2020 12:24

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

  b_index_dteyear       number;
  b_index_numtime       number;
  b_index_codincom      varchar2(100 char);
  b_index_codcomp       varchar2(4000 char);  
  b_index_typrep        varchar2(100 char); 

  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure get_index_tableDesc(json_str_input in clob, json_str_output out clob);
  procedure gen_index_tableDesc(json_str_output out clob);
  procedure get_index_tableSum(json_str_input in clob, json_str_output out clob);
  procedure gen_index_tableSum(json_str_output out clob);
  procedure get_index_tableAdjust(json_str_input in clob, json_str_output out clob);
  procedure gen_index_tableAdjust(json_str_output out clob);

END; -- Package spec

/
