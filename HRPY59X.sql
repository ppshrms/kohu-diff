--------------------------------------------------------
--  DDL for Package HRPY59X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY59X" AS 
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

  p_period          tothded.numperiod%type;
  p_dtemthpay       tothded.dtemthpay%type;
  p_dteyrepay       tothded.dteyrepay%type;
  p_codcomp         tothded.codcomp%type;
  p_codempid_query  tothded.codempid%type;
  p_typpayroll      tothded.typpayroll%type;
  
  procedure get_index(json_str_input in clob, json_str_output out clob);
  
END HRPY59X;

/
