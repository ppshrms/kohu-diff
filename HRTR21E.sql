--------------------------------------------------------
--  DDL for Package HRTR21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR21E" AS

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';

  p_codapp          varchar2(10 char) := 'HRTR21E';
  p_codinst         varchar2(10 char);
  p_codempid        varchar2(10 char);
  p_stainst         varchar2(1  char);

  json_params       json;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_tab1_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tab1_detail(json_str_output out clob);
  procedure get_tab2_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tab2_detail(json_str_output out clob);
  procedure get_tab3_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tab3_detail(json_str_output out clob);
  procedure get_tab4_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tab4_detail(json_str_output out clob);

  procedure get_tab1_employee(json_str_input in clob, json_str_output out clob);
  procedure gen_tab1_employee(json_str_output out clob);
  procedure get_tab3_employee(json_str_input in clob, json_str_output out clob);
  procedure gen_tab3_employee(json_str_output out clob);
  procedure get_tab4_employee(json_str_input in clob, json_str_output out clob);
  procedure gen_tab4_employee(json_str_output out clob);

  procedure delete_index(json_str_input in clob, json_str_output out clob);

  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure save_tab1(json_str_output out clob);
  procedure save_tab2(json_str_output out clob);
  procedure save_tab3(json_str_output out clob);
  procedure save_tab4(json_str_output out clob);

  function get_codempid_bycodinst(p_codinst varchar2) return varchar2;
  function get_tinstruc_stainst(p_codinst varchar2) return varchar2;

END HRTR21E;


/
