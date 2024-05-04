--------------------------------------------------------
--  DDL for Package HRPM4JD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM4JD" is
  param_msg_error           varchar2(4000 char);

  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;
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
  v_zupdsal                 varchar2(1);

  b_index_codempid        temploy1.codempid%type;
  b_index_dteeffec        date;
  b_index_dteeffecen      date;

  b_index_staemp          temploy1.staemp%type;
  b_index_codcomp         temploy1.codcomp%type;
  b_index_codtrn          temploy1.codcomp%type;
  b_index_typpayroll      temploy1.typpayroll%type;
  b_index_dteoccup        temploy1.dteoccup%type;

  procedure initial_value (json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure save_cancel_ttmovemt (json_str_input in clob, json_str_output out clob);
end HRPM4JD;

/
