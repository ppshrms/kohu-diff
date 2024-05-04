--------------------------------------------------------
--  DDL for Package HRAL3EX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL3EX" is

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal   			    varchar2(4 char);

  p_codapp                  varchar2(10 char) := 'HRAL3EX';
  p_index_rows              varchar2(8 char);

  p_codcomp             varchar2(100 char);
  p_dtestrt             date;
  p_dteend              date;
  p_codcalen            varchar2(100 char);
  p_dtework             date;

  json_index_rows           json_object_t;
  isInsertReport            boolean := false;

  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure gen_graph(obj_row in json_object_t);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt_detail(obj_data in json_object_t);
  procedure insert_ttemprpt_table(obj_data in json_object_t);

end HRAL3EX;

/
