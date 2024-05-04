--------------------------------------------------------
--  DDL for Package HRAP51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP51E" as

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

  b_index_dteyreap        number;
  b_index_codcomp         tbonparh.codcomp%type;
  p_codbon                varchar2(10);
  p_numtime               number;
  b_dteyreapQuery         number;
  b_codcompQuery          tbonparh.codcomp%type;
  p_codbonQuery           tbonparh.codbon%type;
  p_numtimeQuery          tbonparh.numtime%type;

  p_isCopy              varchar2(2 char) := 'N';

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_index_table1(json_str_input in clob, json_str_output out clob);
  procedure get_index_table2(json_str_input in clob, json_str_output out clob);
  procedure get_copy_list(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure delete_data(json_str_input in clob, json_str_output out clob);
end hrap51e;

/
