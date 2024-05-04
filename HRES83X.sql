--------------------------------------------------------
--  DDL for Package HRES83X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES83X" is

  param_msg_error   varchar2(4000 char);

  v_chken           varchar2(10 char) := hcm_secur.get_v_chken;
  v_zyear           number;
  global_v_coduser  varchar2(100 char);
  global_v_codpswd  varchar2(100 char);
  global_v_lrunning varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  v_file            utl_file.file_type;
  v_file_name       varchar2 (4000 char);

  obj_row           json_object_t;
  json_long         varchar2(4000 char);
  b_index_codempid  varchar2(4000 char);
  p_mode            varchar2(4000 char);
  p_start           number;
  p_end             number;
  p_limit           number;
  b_sdate           varchar2(4000 char);
  b_amtintaccu      varchar2(4000 char);
  v_amtintaccu      varchar2(4000 char);
  v_amtinteccu      varchar2(4000 char);
  v_view_codapp     varchar2(100 char);
  global_v_codapp   varchar2(100 char);

  procedure initial_value(json_str in clob);
  procedure get_index_table1(json_str_input in clob, json_str_output out clob);
  procedure gen_data_table1(json_str_output out clob);
  function get_amt_func(p_amt in varchar2) return varchar2;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);

  procedure get_index_popup(json_str_input in clob, json_str_output out clob);
  procedure gen_data_popup(json_str_output out clob);

  procedure get_popup_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_popup_detail(json_str_output out clob);

  procedure check_index;

END;

/
