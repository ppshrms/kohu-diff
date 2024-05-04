--------------------------------------------------------
--  DDL for Package HRPY27E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY27E" as

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

  -- get parameter search index
  p_codcomp                 temploy1.codcomp%type;
  p_typpayroll              temploy1.typpayroll%type;

  -- get parameter json table
  p_codempid                ttyppymt.codempid%type;
  p_dteyrepay_st            ttyppymt.dteyrepay_st%type;
  p_dtemthpay_st            ttyppymt.dtemthpay_st%type;
  p_numperiod_st            ttyppymt.numperiod_st%type;
  p_dteyrepay_en            ttyppymt.dteyrepay_en%type;
  p_dtemthpay_en            ttyppymt.dtemthpay_en%type;
  p_numperiod_en            ttyppymt.numperiod_en%type;
  p_flgpaymt                ttyppymt.flgpaymt%type;
  p_remark                  ttyppymt.remark%type;

  procedure initial_value (json_str in clob);
  procedure check_date;
  procedure check_index;
  --
  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  --
  procedure save_index(json_str_input in clob, json_str_output out clob);
end HRPY27E;

/
