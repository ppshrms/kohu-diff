--------------------------------------------------------
--  DDL for Package STD_EMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_EMP" is
  --global
  global_v_coduser    varchar2(100 char);
  global_v_codpswd    varchar2(100 char);
  global_v_lang       varchar2(10 char);

  --value
  obj_row             json_object_t;
  obj_data            json_object_t;

  b_index_codempid    varchar2(100 char);
  b_index_mnuname     varchar2(100 char);
  param_msg_error     varchar2(600);
  global_v_zminlvl      varchar2(10 char);
  global_v_zwrklvl      varchar2(10 char);
  global_v_zupdsal      varchar2(10 char);
  global_v_numlvlsalst  varchar2(10 char);
  global_v_numlvlsalen  varchar2(10 char);
  v_zupdsal             varchar2(1);

  procedure getdata_tab1(json_str_input in clob, json_str_output out clob);
  procedure getdata_tab2(json_str_input in clob, json_str_output out clob);
  procedure getdata_tab3_table1(json_str_input in clob, json_str_output out clob);
  procedure getdata_tab3_table2(json_str_input in clob, json_str_output out clob);
  procedure getdata_tab4(json_str_input in clob, json_str_output out clob);
  procedure getdata_tab5(json_str_input in clob, json_str_output out clob);

end;

/
