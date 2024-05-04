--------------------------------------------------------
--  DDL for Package HRPY26X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY26X" as

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

  p_codapp                  varchar2(10 char) := 'HRPY26X';

  p_dteyrepay               number;
  p_dtemthpay               number;
  p_numperiod               number;
  p_codcomp                 temploy1.codcomp%type;
  p_typpayroll              temploy1.typpayroll%type;
  p_codempid                temploy1.codempid%type;
  p_codpay                  tothinc.codpay%type;

  json_input_obj                    json_object_t;
  json_param_break                  json_object_t;
  json_param_json                   json_object_t;
  json_break_params                 json_object_t;
  json_break_output                 json_object_t;
  json_break_output_row             json_object_t;
  json_param_break_payment          json_object_t;
  json_param_json_payment           json_object_t;
  json_break_params_payment         json_object_t;
  json_break_output_payment         json_object_t;
  json_break_output_row_payment     json_object_t;
  isInsertReport            boolean := false;

  procedure initial_value (json_str in clob);
  procedure check_index;
  --
  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  --
  procedure get_data_tab2 (json_str_input in clob, json_str_output out clob);
  procedure gen_data_tab2 (json_str_output out clob);
--  procedure get_index_head(json_str_input in clob, json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt_tab1(obj_data in json_object_t);
  procedure insert_ttemprpt_tab2(obj_data in json_object_t);

end HRPY26X;

/
