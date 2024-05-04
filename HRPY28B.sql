--------------------------------------------------------
--  DDL for Package HRPY28B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY28B" as

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
  p_typpay                  number;
  p_typtran                 number;

  p_complete                number := 0;
  p_error                   number := 0;

  procedure initial_value (json_str in clob);
  procedure check_number (p_number in out varchar2,p_case in varchar2,v_error3 out varchar2);
  procedure check_is_number (p_number in varchar2, isnumber out boolean, v_amtpay2 out number);
  --
  function check_dup_tothinc2 (v_codempid in varchar2,v_dteyrepay in number,v_dtemthpay in number,
                               v_numperiod in number,v_codpay in varchar2,v_codcompw in varchar2) return boolean;
  function check_dup_tothinc (v_codempid in varchar2,v_dteyrepay in number,v_dtemthpay in number,
                              v_numperiod in number, v_codpay in varchar2) return boolean;
  function check_dup_totsumd (v_codempid in varchar2,v_dteyrepay in number,v_dtemthpay in number,
                              v_numperiod in number,v_rtesmot in number,v_codcompw in varchar2) return boolean;
  function check_dup_totsum (v_codempid in varchar2, v_dteyrepay in number, v_dtemthpay in number,
                             v_numperiod in number) return boolean;
  function chk_emp_processed(p_codempid in varchar2) return varchar2;
  function get_amtotpay (v_rtesmot number,v_qtysmot number,v_amtothr number) return number;
  --
  procedure get_ratepay (p_codempid temploy1.codempid%type,
                         p_rateday out number,
                         p_ratehr out number);
  procedure get_process(json_str_input in clob, json_str_output out clob);
  --
  procedure save_index(json_str_input in clob, json_str_output out clob);
  --
  procedure check_tothpay(v_codempid in varchar2, v_codpay in varchar2, v_dtepaystr in varchar2, v_dtepay out date,
                          v_amtpay in out varchar2, v_flgpyctax in varchar2, v_status out varchar2, v_reason out varchar2,
                          v_failcolumn out varchar2, v_codcompw in varchar2);
  procedure check_tothinc(v_codempid in varchar2, v_codpay in varchar2, v_qtypayda in out varchar2, v_qtypayhr in out varchar2,
                          v_qtypaysc in out varchar2, v_ratepay in out varchar2, v_amtpay in out varchar2, v_codcompw in varchar2,
                          v_complete out number,v_error out number,v_status out varchar2,v_reason out varchar2, v_failcolumn out varchar2);
  procedure check_totsum(v_codempid in varchar2,v_rtesmot in out varchar2,v_qtysmot in out varchar2,
                         v_amtspot in out varchar2,v_codcompw in varchar2,
                         v_complete out number,v_error out number,v_status out varchar2,v_reason out varchar2, v_failcolumn out varchar2);
  --
  procedure transfer_tothpay(json_str_input in clob, json_str_output out clob);
  procedure transfer_tothinc(json_str_input in clob, json_str_output out clob);
  procedure transfer_totsum(json_str_input in clob, json_str_output out clob);

end HRPY28B;

/
