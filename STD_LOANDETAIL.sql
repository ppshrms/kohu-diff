--------------------------------------------------------
--  DDL for Package STD_LOANDETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_LOANDETAIL" as 
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
  p_numcont                 tloaninf.numcont%type; 

  procedure initial_value (json_str in clob);  
  --loaninf
  procedure get_tloaninf(json_str_input in clob, json_str_output out clob);
  procedure gen_tloaninf(json_str_output out clob);
  --tloancol
  procedure get_tloancol(json_str_input in clob, json_str_output out clob);
  procedure gen_tloancol(json_str_output out clob);  
  --tloangar
  procedure get_tloangar(json_str_input in clob, json_str_output out clob);
  procedure gen_tloangar(json_str_output out clob);
--  --tloaninf2
  procedure get_tloaninf2(json_str_input in clob, json_str_output out clob);
  procedure gen_tloaninf2( json_str_output out clob);

end std_loandetail;

/
