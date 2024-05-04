--------------------------------------------------------
--  DDL for Package HRES19X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES19X" is

  param_msg_error   varchar2(4000 char);

  global_v_coduser  varchar2(1000 char);
  global_v_codpswd  varchar2(1000 char);
  global_v_lang     varchar2(1000 char);
  global_v_zminlvl  number;
  global_v_zwrklvl  number;
  global_v_numlvlsalst number;
  global_v_numlvlsalen number;
  v_zupdsal            varchar2(4 char);
  b_index_codempid  varchar2(1000 char);
--  b_index_codcomp   varchar2(1000 char);
--  b_index_codcalen  varchar2(1000 char);
  b_index_dtestr    date;
  b_index_dteend    date;
  p_codempid        varchar2(100 char);
  p_codcomp         varchar2(100 char);
  v_text_key        varchar2(100 char);
  v_rateot_length   number := 4;

  parameter_qtylate   number;
  parameter_qtyearly  number;
  parameter_qtyabsent number;
  parameter_qtyleave  number;
  parameter_before    number;
  parameter_during    number;
  parameter_after     number;

  ttemfilt_date01		date;
  ttemfilt_date01d	date;
  ttemfilt_item01		varchar2(4000 char);
  ttemfilt_item02		varchar2(4000 char);
  ttemfilt_item03		varchar2(4000 char);
  ttemfilt_item04		varchar2(4000 char);
  ttemfilt_item05		varchar2(4000 char);
  ttemfilt_item06		varchar2(4000 char);
  ttemfilt_item07		varchar2(4000 char);
  ttemfilt_item08		varchar2(4000 char);
  ttemfilt_item09		varchar2(4000 char);
  ttemfilt_item10		varchar2(4000 char);
  ttemfilt_item11		varchar2(4000 char);
  ttemfilt_item12		varchar2(4000 char);
  ttemfilt_item13		varchar2(4000 char);
  ttemfilt_item14		varchar2(4000 char);
  ttemfilt_item15		varchar2(4000 char);
  ttemfilt_item16		varchar2(4000 char);
  ttemfilt_item17		varchar2(4000 char);
  ttemfilt_item18		varchar2(4000 char);
  ttemfilt_item19		varchar2(4000 char);
  ttemfilt_item20		varchar2(4000 char);
  ttemfilt_item21		varchar2(4000 char);
  ttemfilt_item22		varchar2(4000 char);
  ttemfilt_item23		varchar2(4000 char);
  ttemfilt_temp01 	number;
  ttemfilt_temp02 	number;
  ttemfilt_temp03 	number;
  ttemfilt_temp04 	number;
  ttemfilt_temp05 	number;
  ttemfilt_temp06 	number;
  ttemfilt_temp07 	number;
  ttemfilt_codcomp	varchar2(4000 char);

  procedure initial_value(json_str_input in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_ot_head (json_str_input in clob, json_str_output out clob);
  procedure gen_ot_head (json_str_output out clob);
  procedure check_ot_head;
end;

/
