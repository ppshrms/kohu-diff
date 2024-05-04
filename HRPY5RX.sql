--------------------------------------------------------
--  DDL for Package HRPY5RX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5RX" as

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
  p_codempid                varchar2(100 char);
  p_flgrep                  varchar2(1 char);
  p_codpay                  varchar2(100 char);

  v_lastyear                number;
  v_lastmth                 number;
  v_lastperiod              number;
  v_yrmtn                   number;
  v_dtestrt 		            date;
  v_dteend			            date;
  v_lastdtestrt             date;
  v_lastdteend	            date;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_ttaxcur(json_str_output out clob);
  procedure gen_tsincexp(json_str_output out clob);

end HRPY5RX;

/
