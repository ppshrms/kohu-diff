--------------------------------------------------------
--  DDL for Package HRAL74D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL74D" as

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

  p_codempid                varchar2(1000 char);
  p_codcomp                 varchar2(1000 char);
  p_codcompy                varchar2(1000 char);
  p_typpayroll              varchar2(1000 char);
  p_dteyrepay               number;
  p_dtemthpay               number;
  p_numperiod               number;

  p_codpay                  varchar2(1000 char);
  p_numrec                  number;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure post_transfer_data (json_str_input in clob, json_str_output out clob);
  procedure cancel_data;
  procedure del_totsum (v_codempid in varchar2);
  procedure del_tothinc (v_codempid in varchar2, v_codpay in varchar2);

end HRAL74D;

/
