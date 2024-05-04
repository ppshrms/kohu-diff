--------------------------------------------------------
--  DDL for Package STD_TJOBCODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_TJOBCODE" as 

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
  p_jobcode                 tjobcode.codjob%type; 

  procedure initial_value (json_str in clob);    
  --tjobcode1
  procedure get_tjobcode(json_str_input in clob, json_str_output out clob);
  procedure gen_tjobcode(json_str_output out clob);
  --tjobdet
  procedure get_tjobdet(json_str_input in clob, json_str_output out clob);
  procedure gen_tjobdet(json_str_output out clob);
  --tjobresp
  procedure get_tjobresp(json_str_input in clob, json_str_output out clob);
  procedure gen_tjobresp(json_str_output out clob);
end std_tjobcode;

/
