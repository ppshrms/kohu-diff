--------------------------------------------------------
--  DDL for Package HRPY6CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY6CE" as

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  p_dteyear                 number;
  p_codcomp                 varchar2(100 char);
  p_codempid                varchar2(100 char);
  v_codempid                varchar2(100 char);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_position(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);

end HRPY6CE;

/
