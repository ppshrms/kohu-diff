--------------------------------------------------------
--  DDL for Package HRALS3X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRALS3X" as
-- last update: 03/04/2018 10:40:00

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
  p_codleave                varchar2(4000 char);
  p_dtestrt                 date;
  p_dteend                  date;
  p_codapp                  varchar2(100 char) := 'HRALS3X';
  p_codleave_array          json_object_t;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_index_choose (json_str_input in clob, json_str_output out clob);
  procedure gen_index_choose (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);

  function cal_hour_unlimited (p_min number, p_null boolean := false) return varchar2;
  function cal_times (p_tim number) return varchar2;

end hrals3x;

/
