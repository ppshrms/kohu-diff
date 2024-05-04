--------------------------------------------------------
--  DDL for Package HRES77E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES77E" as

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

  p_codcomp                 temploy1.codcomp%type;
  p_dtestrt                 date;
  p_dteend                  date;
  p_codempid                tloanreq.codempid%type;
  p_dtereq                  tloanreq.dtereq%type;
  p_numseq                  tloanreq.numseq%type;
  p_numcont                 tloaninf.numcont%type;
  p_codlon                  tintrteh.codlon%type;
  p_textCal                 clob;
  p_codempgar               tloangar.codempgar%type;
  p_sendmail                varchar2(1 char) := 'N';
  -- save
  json_params               json_object_t;
  p_typpayroll              temploy1.typpayroll%type;
  p_typintr                 tloaninf.typintr%type;
  p_rateilon                tloaninf.rateilon%type;
  p_yrenumlon               number;
  p_mthnumlon               number;
  p_numlon                  tloaninf.numlon%type;
  p_amtlon                  tloaninf.amtlon%type;
  obj_formula               json_object_t;
  p_formula                 tloaninf.formula%type;
  p_statement               tloaninf.statementf%type;
  p_dtelonst                tloaninf.dtelonst%type;
  p_dtelonen                tloaninf.dtelonen%type;
  p_dteissue                tloaninf.dteissue%type;
  p_dtestcal                tloaninf.dtestcal%type;
  p_typpayamt               tloaninf.typpayamt%type;
  p_dteyrpay                tloaninf.dteyrpay%type;
  p_mthpay                  tloaninf.mthpay%type;
  p_prdpay                  tloaninf.prdpay%type;
  p_reaslon                 tloaninf.reaslon%type;
  p_typpay                  tloaninf.typpay%type;
  p_amtiflat                tloaninf.amtiflat%type;
  p_amttlpay                tloaninf.amttlpay%type;
  p_amtitotflat             tloaninf.amtitotflat%type;
  p_amtpaybo                tloaninf.amtpaybo%type;
  p_qtyperiod               tloaninf.qtyperiod%type;
  p_codreq                  tloaninf.codreq%type;
  p_amtnpfin                tloaninf.amtnpfin%type;
  p_dteaccls                tloaninf.dteaccls%type;
  p_dtelpay                 tloaninf.dtelpay%type;
  p_desaccls                tloaninf.desaccls%type;
  p_dteeffec                tloaninf.dteeffec%type;
  p_amtasgar                ttyploan.amtasgar%type;
  p_qtygar                  ttyploan.qtygar%type;
  p_amtguarntr              ttyploan.amtguarntr%type;
  p_condgar                 ttyploan.condgar%type;
  obj_tloancol              json_object_t;
  obj_tloangar              json_object_t;
  p_additional_year         number := 0;
  --
  tloanreq_approvno    tloanreq.approvno%type;
  tloanreq_routeno     tloanreq.routeno%type;
  tloanreq_staappr     tloanreq.staappr%type;
  tloanreq_codappr     tloanreq.codappr%type;
  tloanreq_dteappr     tloanreq.dteappr%type;
  tloanreq_remarkap    tloanreq.remarkap%type;
  --
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_tloancol (json_str_input in clob, json_str_output out clob);
  procedure gen_tloancol (json_str_output out clob);
  procedure get_tloangar (json_str_input in clob, json_str_output out clob);
  procedure gen_tloangar (json_str_output out clob);
  procedure get_tloaninf (json_str_input in clob, json_str_output out clob);
  procedure gen_tloaninf (json_str_output out clob);
  procedure get_tintrteh (json_str_input in clob, json_str_output out clob);
  procedure gen_tintrteh (json_str_output out clob);
  procedure get_codempgar (json_str_input in clob, json_str_output out clob);
  procedure gen_codempgar (json_str_output out clob);
  procedure get_loan_condition (json_str_input in clob, json_str_output out clob);
  procedure cal_loan (json_str_input in clob, json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
  --
  procedure get_tloangar_info (json_str_input in clob, json_str_output out clob);
  procedure gen_tloangar_info (json_str_output out clob);
  procedure get_detail_descpay (json_str_input in clob, json_str_output out clob);
  procedure gen_detail_descpay (json_str_output out clob);
end hres77e;

/
