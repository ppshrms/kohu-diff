--------------------------------------------------------
--  DDL for Package HRPM35X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM35X" is
-- last update: 09/02/2021 18:01 #2768

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
  global_v_zupdsal          number;


  p_codcomp         tcenter.codcomp%type;
  p_typreport       tcenter.comlevel%type;
  p_nameval         ttprobat.codrespr%type;
  p_yearstrt        varchar2(10 char);
  p_monthstrt       varchar2(10 char);
  p_yearend         varchar2(10 char);
  p_monthend        varchar2(10 char);



  procedure initial_value (json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_month(json_str_input in clob, json_str_output out clob);
  procedure gen_month(json_str_output out clob);
  procedure vadidate_variable_getindex(json_str_input in clob);

end HRPM35X;

/
