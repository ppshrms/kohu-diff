--------------------------------------------------------
--  DDL for Package HRAL36X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL36X" as
-- last update: 21/02/2018 12:02

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  p_codcomp                 varchar2(100 char);
  p_codempid                varchar2(100 char);
  p_codcalen                varchar2(10 char);
  p_dtestrt                 date;
  p_dteend                  date;
  p_flginput                varchar2(100 char);

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);

  function char_time_to_format_time (p_tim varchar2) return varchar2;

end HRAL36X;

/
