--------------------------------------------------------
--  DDL for Package HRAL4FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL4FX" as
-- last update: 25/08/2021 18:00

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

  p_codapp                  varchar2(10 char) := 'HRAL4FX';
  p_index_rows              varchar2(8 char);

  p_codempid                varchar2(100 char);
  p_codcomp                 varchar2(100 char);
  p_period                  number;
  p_year                    number;
  p_month                   number;
  p_maxperson               number;
  p_sort                    varchar2(1 char);

  json_index_rows           json_object_t;
  isInsertReport            boolean := false;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_index_head;
  procedure check_popup_overtime;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_index_head (json_str_input in clob, json_str_output out clob);
  procedure gen_index_head (json_str_output out clob);
  procedure get_popup_overtime (json_str_input in clob, json_str_output out clob);
  procedure gen_popup_overtime (json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt_head(obj_data in json_object_t);
  procedure insert_ttemprpt_table(obj_data in json_object_t);

  function display_ot_hours (p_min number, p_null boolean := false) return varchar2;
  function display_currency (p_amtcur number) return varchar2;
  /*procedure prg_exchg(code in number, code2 out varchar2);*/
end hral4fx;

/
