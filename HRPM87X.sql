--------------------------------------------------------
--  DDL for Package HRPM87X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM87X" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(10 char);

  pa_codempid               thisrewd.codempid%type;
  pa_dtestr                 date;
  pa_dteend                 date;


  procedure initial_value (json_str in clob);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure vadidate_variable_getindex(json_str_input in clob);

end HRPM87X;

/
