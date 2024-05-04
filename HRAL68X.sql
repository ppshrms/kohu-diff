--------------------------------------------------------
--  DDL for Package HRAL68X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL68X" as

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

  p_codapp                  varchar2(10 char) := 'HRAL68X';
  p_index_rows              varchar2(8 char);

  p_codcomp                 varchar2(100 char);
  p_codcompy                varchar2(100 char);
  p_codaward                varchar2(100 char);
  p_stmonth                 number;
  p_enmonth                 number;
  p_styear                  number;
  p_enyear                  number;

  p_codempid                varchar2(100 char);
  p_codpay                  varchar2(100 char);

  json_index_rows           json_object_t;
  isInsertReport            boolean := false;

  param_qtyavgwk            number; -- param function calculate_dhm

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure check_detail;

  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);

end HRAL68X;

/
