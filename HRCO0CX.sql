--------------------------------------------------------
--  DDL for Package HRCO0CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO0CX" AS
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char);
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  p_codcomp                 temploy1.codcomp%type;
  p_codpos                  temploy1.codpos%type;
  p_jobgroup                  tjobcode.codjob%type;
  p_codtency                tcomptnc.codtency%type;

  procedure initial_value (json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index ( json_str_output out clob);

end HRCO0CX;

/
