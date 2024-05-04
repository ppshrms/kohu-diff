--------------------------------------------------------
--  DDL for Package STD_TREQEST1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_TREQEST1" as 

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  v_zupdsal                 varchar2(10 char);
  p_numreqst                treqest1.numreqst%type; 

  procedure initial_value (json_str in clob);    
  --tab1
  procedure get_tab1(json_str_input in clob, json_str_output out clob);
  procedure gen_tab1(json_str_output out clob);
  --tab2
  procedure get_tab2(json_str_input in clob, json_str_output out clob);
  procedure gen_tab2(json_str_output out clob);
end std_treqest1;

/
