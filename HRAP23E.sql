--------------------------------------------------------
--  DDL for Package HRAP23E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP23E" as
  --para
  param_msg_error       varchar2(4000);

  --global
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_zupdsal      varchar2(4 char);

  global_v_coduser      varchar2(100);
  global_v_codempid     varchar2(100);
  global_v_lang         varchar2(100);
  global_v_zyear        number  := 0;
  global_v_chken        varchar2(10) := hcm_secur.get_v_chken;
  global_v_codcurr      varchar2(100);

  b_index_dteyreap      ttemadj1.dteyreap%type;
  b_index_codcomadj     ttemadj1.codcomadj%type;
  b_index_codincom      ttemadj1.codincom%type;
  parameter_ptr         varchar2(10);

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_process(json_str_input in clob,json_str_output out clob);
  procedure get_condition(json_str_input in clob,json_str_output out clob);
  procedure get_list_emp(json_str_input in clob,json_str_output out clob);
  procedure save_adj(json_str_input in clob,json_str_output out clob);
  procedure save_index(json_str_input in clob,json_str_output out clob);
  procedure send_mail_to_approve(json_str_input in clob,json_str_output out clob);
end;

/
