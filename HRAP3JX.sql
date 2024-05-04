--------------------------------------------------------
--  DDL for Package HRAP3JX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP3JX" is
-- last update: 27/08/2020 15:06

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

  b_index_dteyreap1     number;
  b_index_dteyreap2     number;
  b_index_dteyreap3     number;
  b_index_codcomp       varchar2(4000 char);
  p_codempid            varchar2(4000 char);

  global_v_codempid     varchar2(100 char);
  json_index_rows       json_object_t;
  isInsertReport        boolean := false;
  p_codapp              varchar2(10 char) := 'HRAP3JX';

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_data_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_data_detail(json_str_output out clob);
  procedure get_data_table(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table(json_str_output out clob);

  procedure gen_report (json_str_input in clob,json_str_output out clob);
  procedure clear_ttemprpt;  
  procedure insert_ttemprpt(obj_data in json_object_t); 
  procedure insert_ttemprpt_table(obj_data in json_object_t);   
END; -- Package spec

/
