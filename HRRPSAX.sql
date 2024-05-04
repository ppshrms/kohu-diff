--------------------------------------------------------
--  DDL for Package HRRPSAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRPSAX" AS


  v_chken      varchar2(100 char);

  param_msg_error     varchar2(4000 char);

  global_v_coduser      varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
	global_v_zyear		    number := 0;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_codempid     temploy1.codempid%type;

  b_index_codcompy    varchar2(4000 char);
  b_index_dteyear1    varchar2(4000 char);
  b_index_dteyear2    varchar2(10 char);
  b_index_dteyear3    varchar2(10 char);
  b_index_dteyear4    varchar2(10 char);
  b_index_dteyear5    varchar2(10 char);
  b_index_dteyear6    varchar2(10 char);
  p_logic1            json_object_t;
  p_logic2            json_object_t;
  p_logic3            json_object_t;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure check_index;
  function get_data_row1(v_year in varchar2) return number;
  function get_data_row2(v_year in varchar2) return number;
  function get_data_row3(v_year in varchar2) return number;
  function get_data_row4(v_year in varchar2) return number;
  function get_data_row5(v_year in varchar2) return number;
END HRRPSAX;

/
