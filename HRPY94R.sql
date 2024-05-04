--------------------------------------------------------
--  DDL for Package HRPY94R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY94R" is

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

  p_codcomp                 varchar2(100 char);
  p_codempid                varchar2(100 char);
  p_typpayroll              varchar2(100 char);

  p_dteyrepay               number;
  p_dteprint                date;
  p_numpf                   varchar2(100 char);
  p_typdata                 varchar2(10 char);
  p_mtheffex                number;
  p_yreeffex                number;
  p_typrep                  varchar2(10 char);
  p_typscan                 varchar2(10 char);

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

end HRPY94R;

/
