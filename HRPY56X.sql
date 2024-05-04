--------------------------------------------------------
--  DDL for Package HRPY56X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY56X" as

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

  p_numperiod               number;
  p_dtemthpay               number;
  p_dteyrepay               number;
  p_codcomp                 varchar2(100 char);
  p_typpayroll              varchar2(100 char);

  para_result12             number;
  p_flgcoin_other           number;

  type calbank_arr is table of varchar2(4000 char) index by binary_integer;
    p_flgcoin calbank_arr;
    p_calcoin calbank_arr;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure calc_bank(v_amtnet number);

end HRPY56X;

/
