--------------------------------------------------------
--  DDL for Package HRPM94B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM94B" is

-- last update: 19/04/2021 18:01 redmine5670

  param_msg_error           varchar2(4000 char);

  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(1);

  p_numperiod         tothinc.numperiod%type;
  p_dtemthpay         tothinc.dtemthpay%type;
  p_dteyrepay         tothinc.dteyrepay%type;
  p_codcomp           tothinc.codcomp%type;
  p_typpayroll        tothinc.typpayroll%type;
  p_codpay            tothinc.codpay%type;
  -- others ref
  p_codcompy          tcompny.codcompy%type;
  tdtepay_dtestrt     tdtepay.dtestrt%type;
  tdtepay_dteend      tdtepay.dteend%type;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure process_data (json_str_input in clob, json_str_output out clob);

end hrpm94b;

/
