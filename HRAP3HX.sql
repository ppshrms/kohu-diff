--------------------------------------------------------
--  DDL for Package HRAP3HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP3HX" is
-- last update: 03/11/2020 10:30
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
  global_vyear 	        number;

  --block b_index
  b_index_dteyear       number;
  b_index_dteyear1      number;
  b_index_numtime       number;
  b_index_codcomp       varchar2(4000 char);
  b_index_codaplvl      varchar2(4000 char);
  b_index_codempid      varchar2(4000 char);
  p_codempid            varchar2(4000 char);
  p_codform             varchar2(4000 char);

  global_v_codempid     varchar2(100 char);
  json_index_rows       json_object_t;
  isInsertReport        boolean := false;
  p_codapp              varchar2(10 char) := 'HRAP3HX';

  procedure initial_value(json_str in clob);
--PAGE HEAD-------------------------------------------------------------------
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  p_codcompy            tcenter.codcompy%type;
  p_codcomp             tcenter.codcomp%type;
  p_codaplvl            varchar2(30 char);
  p_dteapstr            date;  --วันที่เริ่มรอบการประเมิน
  p_dteapend            date;  --วันที่สิ้นรอบการประเมิน

--PAGE DRIL DOWN-------------------------------------------------------------------
  procedure get_data_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_data_detail(json_str_output out clob);

  procedure get_data_table1(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table1(json_str_output out clob);

  procedure get_data_table2(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table2(json_str_output out clob);

  procedure get_data_table3(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table3(json_str_output out clob);

  procedure get_data_table4(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table4(json_str_output out clob);

  procedure get_data_table5(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table5(json_str_output out clob);

  procedure get_data_table6(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table6(json_str_output out clob);

  procedure get_data_table7(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table7(json_str_output out clob);

  procedure get_data_table8(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table8(json_str_output out clob);

  procedure get_data_table9(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table9(json_str_output out clob);

  procedure get_data_table10(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table10(json_str_output out clob);

  procedure get_data_table11(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table11(json_str_output out clob);

---------------------------------------------------------------------
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);

--  procedure insert_ttemprpt_table(obj_data in json_object_t);
--  procedure get_data_table(json_str_input in clob, json_str_output out clob);
--  procedure gen_data_tablea(json_str_output out clob);
  procedure gen_report (json_str_input in clob,json_str_output out clob);

  procedure msg_err2(p_error in varchar2);
  --<<User37 #7268 30/12/2021 
  procedure get_taplvl_where(p_codempid in varchar2,p_codcomp_in in varchar2,p_codaplvl in varchar2,
                             p_dteapend_in in date,p_codcomp_out out varchar2,p_dteeffec out date);
  -->>User37 #7268 30/12/2021 
END; -- Package spec

/
