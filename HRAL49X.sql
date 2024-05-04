--------------------------------------------------------
--  DDL for Package HRAL49X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL49X" as
-- last update: 20/04/2018 10:30:00

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

  p_codapp                  varchar2(10 char) := 'HRAL49X';
  p_index_rows              varchar2(8 char);

  p_codcomp                 varchar2(100 char);
  p_codcomp_row             varchar2(100 char);
  p_codcalen                varchar2(100 char);
  p_typerep                 varchar2(100 char);
  p_codcomp_index                 varchar2(100 char);
  p_dtestrt                 date;
  p_dteend                  date;
  b_index_codcomp           varchar2(100 char);
  b_index_codcalen          varchar2(100 char);
  v_rateot_length           number := 4;

  json_index_rows           json_object_t;
  isInsertReport            boolean := false;

  -- special
  v_text_key                varchar2(100 char);

  type arr_1d  is table of varchar2(4000 char) index by binary_integer;
  type arr_num is table of number index by binary_integer;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_ot_head;
  procedure check_detail;

  function get_ot_col (v_codcompy varchar2) return json_object_t;

  procedure get_ot_head (json_str_input in clob, json_str_output out clob);
  procedure gen_ot_head (json_str_output out clob);

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure gen_graph(obj_row in json_object_t);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt_head(obj_data in json_object_t);
  procedure insert_ttemprpt_table(obj_data in json_object_t);

  function display_ot_hours (p_min number, p_null boolean := false) return varchar2;
  function display_work_hours (p_hour number, p_null boolean := false) return varchar2;
  function display_currency (p_amtcur number) return varchar2;
end HRAL49X;

/
