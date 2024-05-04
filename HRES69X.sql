--------------------------------------------------------
--  DDL for Package HRES69X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES69X" AS
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  p_period                  tpaysum2.numperiod%type;
  p_month                   tpaysum2.dtemthpay%type;
  p_year                    tpaysum2.dteyrepay%type;
  p_deduct                  tpaysum2.codpay%type;--nut tpaysum2.codalw%type;
  p_codalw                  tpaysum2.codalw%type;--nut 

  procedure initial_value (json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_pay_other (json_str_input in clob, json_str_output out clob);
  procedure gen_pay_other (json_str_output out clob);
  procedure get_award (json_str_input in clob, json_str_output out clob);
  procedure gen_award (json_str_output out clob);
  procedure get_lov_codalw(json_str_input in clob, json_str_output out clob);
END HRES69X;

/
