--------------------------------------------------------
--  DDL for Package HRAL75X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL75X" is
-- last update: 27/03/2018 14:16

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
  global_v_zupdsal          varchar2(100 char);

  p_codcomp                 varchar2(4000 char);
  p_typpayroll              varchar2(10 char);
  p_codempid                varchar2(4000 char);
  p_numperiod               number;
  p_dtemthpay               number;
  p_dteyrepay               number;

  p_qtyavgwk                number;

  procedure initial_value(json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

end HRAL75X;

/
