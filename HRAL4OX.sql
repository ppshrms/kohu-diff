--------------------------------------------------------
--  DDL for Package HRAL4OX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL4OX" as
-- last update: 06/03/2018 09:40

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

  p_codapp                  varchar2(10 char) := 'HRAL4OX';
  p_index_rows              varchar2(8 char);

  p_codempid                varchar2(100 char);
  p_codcomp                 varchar2(100 char);
  p_typabs                  varchar2(100 char);
  p_inquir                  varchar2(5 char);
  p_overlimit_tim           number;
  p_overlimit_hou           number;
  p_overlimit_min           number;
  p_continuation_d          number;
  p_dtestrt                 date;
  p_dteend                  date;

  p_tot_min                 number;
  v_min_dtework             date;
  v_max_dtework             date;

  json_index_rows           json;
  isInsertReport            boolean := false;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  function char_time_to_format_time (p_tim varchar2) return varchar2;
  function cal_hour_unlimited (p_min number, p_null boolean := false) return varchar2;
  function cal_times_count (p_tim number) return varchar2;

end HRAL4OX;

/
