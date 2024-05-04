--------------------------------------------------------
--  DDL for Package HRRP47X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP47X" as 

  v_chken      varchar2(100 char);

  param_msg_error     varchar2(4000 char);

  global_v_coduser      varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(1 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  b_index_codempid      temploy1.codempid%type;
  isInsertReport            boolean := false;
  p_codapp                  varchar2(10 char) := 'HRRP47X';

  procedure initial_value(json_str in clob);
  procedure get_detail (json_str_input in clob,json_str_output out clob);
  procedure get_table1 (json_str_input in clob,json_str_output out clob);
  procedure get_table2 (json_str_input in clob,json_str_output out clob);
  procedure get_table3 (json_str_input in clob,json_str_output out clob);
  procedure get_graph (json_str_input in clob,json_str_output out clob);
  procedure get_career_path (json_str_input in clob,json_str_output out clob);
  procedure get_career_path_table (json_str_input in clob,json_str_output out clob);
  procedure gen_report (json_str_input in clob,json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t); 
  procedure insert_ttemprpt_table(obj_data in json_object_t); 

end hrrp47x;

/
