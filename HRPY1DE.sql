--------------------------------------------------------
--  DDL for Package HRPY1DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY1DE" as

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_empname      varchar2(100 char);

  p_codcompy            tdtepay.codcompy%type;
  p_typpayroll          tdtepay.typpayroll%type;
  p_dteyrepay           tdtepay.dteyrepay%type;

  p_codcompy_query      tdtepay.codcompy%type;
  p_typpayroll_query    tdtepay.typpayroll%type;
  p_dteyrepay_query     tdtepay.dteyrepay%type;

  p_qtynumpay           number;
  param_json            json_object_t;

  procedure get_index_tab1(json_str_input in clob, json_str_output out clob);
  procedure get_index_tab2(json_str_input in clob, json_str_output out clob);

  procedure get_copy_tab1(json_str_input in clob, json_str_output out clob);
  procedure get_copy_tab2(json_str_input in clob, json_str_output out clob);

  procedure save_index(json_str_input in clob, json_str_output out clob);

  procedure get_copy_list(json_str_input in clob, json_str_output out clob);

  procedure copy_detail(json_str_input in clob, json_str_output out clob);

  procedure get_default_period(json_str_input in clob, json_str_output out clob);

  procedure get_flggen(json_str_input in clob, json_str_output out clob);
  
  procedure get_qtynumpay(json_str_input in clob, json_str_output out clob);
  
  procedure get_copy_flggen(json_str_input in clob, json_str_output out clob);
  
  procedure get_copy_qtynumpay(json_str_input in clob, json_str_output out clob);

end HRPY1DE;

/
