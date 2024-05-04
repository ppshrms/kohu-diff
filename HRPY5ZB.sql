--------------------------------------------------------
--  DDL for Package HRPY5ZB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5ZB" as

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  old_global_v_lang         varchar2(10 char) := '102';
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
  p_numlvlst                number;
  p_numlvlen                number;
  p_flgsend                 varchar2(1 char);
  p_flgslip                 varchar2(1 char);
  p_dtepaymt                date;
  p_error                   varchar2(20 char) ;

  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  procedure get_password(json_str_input in clob,json_str_output out clob);
  procedure gen_password(p_codempid in varchar2, p_password out varchar2, p_pwdformat out varchar2);
  procedure post_mail(json_str_input in clob,json_str_output out clob);
  procedure send_mail_payslip (p_codempid varchar2, p_filename varchar2, p_password varchar2, p_pwdformat varchar2);

end HRPY5ZB;

/
