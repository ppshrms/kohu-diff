--------------------------------------------------------
--  DDL for Package HRPY57X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY57X" as
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
  global_v_chken            varchar2(4000 char);
  v_zupdsal                 varchar2(4 char);

  p_codcomp                 varchar2(4000 char);
  p_year                    number;
  p_month                   number;
  p_numperiod               number;
  p_codcompy                varchar2(4000 char);
  v_rateot_length           number := 4;
  v_text_key                varchar2(100 char);
  p_flgcodcomp              varchar2(10 char);

  function zero_number (v_number number) return varchar2;
  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);

  procedure check_codcomp;
  procedure get_rteotpay (json_str_input in clob, json_str_output out clob);
  procedure gen_rteotpay (json_str_output out clob);
  procedure get_currency (json_str_input in clob, json_str_output out clob);
  procedure gen_currency (json_str_output out clob);
  function get_ot_col (v_codcompy varchar2) return json_object_t;

--  function char_time_to_format_time (p_tim varchar2) return varchar2;
  function  convert_minute_to_hour(p_minute in number) return varchar2;--User37 Final Test Phase 1 V11 #2930 15/10/2020
end HRPY57X;

/
