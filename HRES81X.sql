--------------------------------------------------------
--  DDL for Package HRES81X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES81X" as
-- last update: 23/01/2017 17:10

  TYPE arr IS TABLE OF VARCHAR2(600) INDEX BY BINARY_INTEGER;
  income_arr            arr;
  deduc_arr             arr;
  ytd_amount_arr        arr;
  block_amtinc          arr;
  block_amtinc_e        arr;
  block_codinc          arr;
  block1_amtpay         arr;
  block1_amtpay_e       arr;
  block1_codded         arr;
  block2_qtysmot        arr;
  block2_rteot          arr;
  block2_desot          arr;
  block2_hrs            arr;
  block3_suminc         arr;
  block3_sumpay         arr;
  block3_sumnet         arr;
  block3_sumnet_e       arr;
  block3_day1           arr;
  block3_day2           arr;
  block3_vacation       arr;
  block3_qtywrk         arr;
  block3_salary         arr;
  block3_amtcalt        arr;
  block3_amttax         arr;
  block3_amtsoc         arr;
  block3_amtpf          arr;
  /*TYPE arr1d IS TABLE OF VARCHAR2(600) INDEX BY VARCHAR2(600);
  block3                 arr1d;
  TYPE arr2d IS TABLE OF arr1d;
  block0                 arr2d;
  block1                 arr2d;
  block2                 arr2d;*/

  v_codcompny           varchar2(4000 char);    -- Modify MER 23/09/2017
  v_desc_codcompny      varchar2(4000 char);    -- Modify MER 23/09/2017

  --b_index
  b_index_codempid      varchar2(4000 char);
  b_index_codcomp       varchar2(4000 char);
  b_index_codpos        varchar2(4000 char);
  b_index_period        varchar2(4000 char);
  b_index_month         varchar2(4000 char);
  b_index_year          varchar2(4000 char);
  b_index_acc_id        varchar2(4000 char);
  b_index_bank          varchar2(4000 char);
  b_index_paymentdate   date;
  b_index_periodal      varchar2(4000 char);
  b_index_periodpy      varchar2(4000 char);
  --ctrl_label
  ctrl_label_di_v240    varchar2(4000 char);
  ctrl_label_di_v250    varchar2(4000 char);
  ctrl_label_di_v260    varchar2(4000 char);
  ctrl_label_lbothinc   varchar2(4000 char);
  ctrl_label_amtothinc  varchar2(4000 char);
  ctrl_label_lbothpay   varchar2(4000 char);
  ctrl_label_amtothpay  varchar2(4000 char);
  --param
  v_row             number;
  param_total_income    number;
  param_total_deduc     number;
  param_total_income_e  number;
  param_total_deduc_e   number;
  parameter_qtyavgwk    number;
  param_msg_error       varchar2(4000 char);
  --global
  global_v_coduser      varchar2(4000 char);
  global_v_codpswd      varchar2(4000 char);
  global_v_codempid     varchar2(4000 char);
  global_v_chken        varchar2(4000 char) := hcm_secur.get_v_chken;
  global_v_lang         number;
  GLOBAL_V_ZYEAR        varchar2(4000 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;

  isInsertReport        boolean := false;
  p_codapp              varchar2(10 char) := 'HRES81X';
  p_dteyrepay           number;
  p_dtemthpay           number;
  p_numperiod           number;
  p_codempid            temploy1.codempid%type;


  procedure get_payslip(json_str_input in clob, json_str_output out clob);
  procedure gen_payslip(json_str_output out clob);
  procedure get_period(json_str_input in clob, json_str_output out clob);
  procedure get_new_period(json_str_input in clob, json_str_output out clob);
  procedure get_latest(json_str_input in clob, json_str_output out clob);
  procedure get_dteyrepay(json_str_input in clob, json_str_output out clob);
  procedure initial_value(json_str in clob);
  procedure get_amtinc(p_codinc in varchar2);
  procedure get_amtded(p_codded in varchar2);
  function cal_dhm_concat (p_qtyday		in  number) return varchar2;
  function resp_json_str return clob;
  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure initial_report(json_str in clob);
  procedure clear_ttemprpt;

  procedure insert_ttemprpt(r_codapp in varchar2, obj_data in json_object_t, obj_data2 in json_object_t, obj_data3 in json_object_t,
                            v_qtywrk in varchar2,v_qtyvacat in varchar2);
  procedure insert_ttemprpt_items(r_codapp in varchar2, v_cod in varchar2, v_des in varchar2, v_unt in varchar2);
end;

/
