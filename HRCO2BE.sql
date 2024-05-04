--------------------------------------------------------
--  DDL for Package HRCO2BE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2BE" AS

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';

  json_index_rows   json_object_t;
  param_json        json_object_t;
  p_codapp      ttemprpt.codapp%type;
  p_codform     tintview.codform%type;
  p_numgrup     tintvews.numgrup%type;
  procedure initial_value(json_str_input in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure get_copy_codform(json_str_input in clob, json_str_output out clob);
  procedure get_data_tintvews(json_str_input in clob, json_str_output out clob);
  procedure get_formDetail(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure save_formDetail(json_str_input in clob, json_str_output out clob);
  procedure save_gradeDetail(json_str_input in clob, json_str_output out clob);
  procedure get_report(json_str_input in clob, json_str_output out clob);
END HRCO2BE;

/
