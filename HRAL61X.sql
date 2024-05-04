--------------------------------------------------------
--  DDL for Package HRAL61X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL61X" as
-- last update: 05/03/2018 11:05

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

  p_codapp                  varchar2(10 char) := 'HRAL61X';
  p_index_head              varchar2(8 char);
  p_codempid_query          varchar2(100 char);
  p_codempid                varchar2(100 char);
  p_codcomp                 varchar2(100 char);
  p_codcalen                varchar2(100 char);
  p_dtestrt                 date;
  p_dteend                  date;
  -- special
  v_text_key                varchar2(100 char);
  v_rateot_length           number := 4;

  isInsertReport            boolean := false;
  type arr_1d is table of varchar2(4000 char) index by binary_integer;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_employee (json_str_input in clob, json_str_output out clob);
  procedure gen_employee (json_str_output out clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure check_ot_head;
  procedure get_ot_head (json_str_input in clob, json_str_output out clob);
  procedure gen_ot_head (json_str_output out clob);

  procedure get_codcalen (json_str_input in clob, json_str_output out clob);
  procedure gen_codcalen (json_str_output out clob);

  procedure get_codempid_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_codempid_detail (json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
--  procedure insert_ttemprpt_head(obj_data in json);
  procedure insert_ttemprpt(obj_data in json_object_t);

  function char_time_to_format_time (p_tim varchar2) return varchar2;
  function cal_hour_unlimited (p_min number, p_null boolean := false) return varchar2;
  function get_ot_col (v_codcompy varchar2) return json_object_t;
end HRAL61X;

/
