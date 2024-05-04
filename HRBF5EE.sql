--------------------------------------------------------
--  DDL for Package HRBF5EE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5EE" AS
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
  p_zupdsal                 varchar2(100 char);

  p_additional_year         number := 0;
  p_codempid_query          tloaninf.codempid%type;
  p_numcont                 tloaninf.numcont%type;
  p_typtran                 varchar2(10 char);
  p_dteadjust               date;
  p_dteeffec                date;
  p_codappr                 tloaninf.codappr%type;
  p_dteappr                 tloaninf.dteappr%type;
  p_codcomp                 tcenter.codcomp%type;
  p_codlon                  tloaninf.codlon%type;
  p_typintr                 tloaninf.typintr%type;
  p_amttotpay               tloaninf.amttotpay%type;
  p_amtnpfin                tloaninf.amtnpfin%type;
  p_amtintovr               tloaninf.amtintovr%type;
  p_amtpflat                tloaninf.amtpflat%type;
  p_amtlon                  tloaninf.amtlon%type;
  p_rateilon                tloaninf.rateilon%type;
  p_qtyperiod               tloaninf.qtyperiod%type;
  p_qtyperip                tloaninf.qtyperip%type;
  p_formula                 tloaninf.formula%type;
  p_dtelpay                 tloaninf.dtelpay%type;
  p_dtestcal                tloaninf.dtestcal%type;
  p_amtitotflat             tloaninf.amtitotflat%type := 0;
  p_qtypayn                 tloanadj.qtypayn%type;
  p_typpayroll              tloanpay.typpayroll%type;
  p_dtestrt                 tdtepay.dtestrt%type;
  type arr_1d is table of clob index by binary_integer;
  -- save index
  json_params               json_object_t;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_tab1 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab1 (json_str_output out clob);
  procedure get_tab2 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab2 (json_str_output out clob);
  procedure get_tab3 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab3 (json_str_output out clob);
  procedure get_tab4 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab4 (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure get_cal_tab3 (json_str_input in clob, json_str_output out clob);
  procedure gen_cal_tab3 (json_str_output out clob);
END HRBF5EE;

/
