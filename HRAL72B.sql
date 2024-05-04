--------------------------------------------------------
--  DDL for Package HRAL72B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL72B" as

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
  p_codcompw                varchar2(1000 char);
  p_typpayroll              varchar2(1000 char);
  p_dteyrepay               number;
  p_dtemthpay               number;
  p_numperiod               number;

  p_codpay                  varchar2(1000 char);
  p_status                  varchar2(1000 char);
  p_numrec                  number;
  p_qtyavgwk                number;

  procedure get_status (v_codpay varchar2);

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure post_transfer_data (json_str_input in clob, json_str_output out clob);
  procedure transfer_data;

  procedure upd_tothinc (p_codempid in varchar2, p_codpay in varchar2, p_codcomp in varchar2,
                         p_typpayroll in varchar2, p_typemp in varchar2, p_qtypayda in number,
                         p_qtypayhr in number, p_qtypaysc in number, p_ratepay  in varchar2,
                         p_amtpay  in varchar2,/* p_codcurr in varchar2,*/ p_codalw varchar2);

  procedure upd_totsum (p_codempid in varchar2, p_codcomp in varchar2, p_typpayroll in varchar2,
                        p_typemp   in varchar2,/* p_codcurr in varchar2,*/ p_amtothr in varchar2);

end HRAL72B;

/
