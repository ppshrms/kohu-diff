--------------------------------------------------------
--  DDL for Package HRRP48X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP48X" is
-- last update: 19/08/2020 11:00
  v_chken               varchar2(100 char);
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(10 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
	global_v_zyear		    number := 0;

  --block b_index
  b_index_dteyear    varchar2(100 char);
  b_index_codcomp    temploy1.codcomp%type;
  b_index_typerep    varchar2(10 char);  --แสดงข้อมูลตาม (1-ครบเกษียณอายุ , 2-ครบกำหนดจ้างงาน)
  b_index_man_age    number;
  b_index_woman_age  number;

  --block drilldown
  b_index_codpos      temploy1.codpos%type;

  --
  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);
  procedure gen_data2(json_str_output out clob);

  procedure get_popup(json_str_input in clob, json_str_output out clob);
  procedure gen_popup(json_str_output out clob);

  procedure gen_graph;
  procedure gen_graph2;
END; -- Package spec

/
