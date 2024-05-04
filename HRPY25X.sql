--------------------------------------------------------
--  DDL for Package HRPY25X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY25X" as
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

  p_numperiod               number;
  p_dtemthpay               number;
  p_dteyrepay               number;
  p_codcomp                 temploy1.codcomp%type;
  p_typpayroll              temploy1.typpayroll%type;
  p_codempid                temploy1.codempid%type;

  v_text_key                varchar2(100 char) := 'otrate';
  v_rateot_length           number := 4;


  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_ot_head;
  procedure get_ot_head (json_str_input in clob, json_str_output out clob);
  procedure gen_ot_head (json_str_output out clob);
  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  procedure get_index_head(json_str_input in clob, json_str_output out clob);
  function get_ot_col (v_codcompy varchar2) return json_object_t;
end HRPY25X;

/
