--------------------------------------------------------
--  DDL for Package HRPY36X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY36X" as
-- last update: 12/09/2018 16:30

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

  p_codcompy                varchar2(100 char);
  p_numperiod               number;
  p_dtemthpay               number;
  p_dteyrepay               number;
  p_typpayroll              varchar2(100 char);
  p_codgrpgl                varchar2(100 char);

  v_codcomp                 varchar2(100 char);

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);

end HRPY36X;

/
