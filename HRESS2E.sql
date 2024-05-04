--------------------------------------------------------
--  DDL for Package HRESS2E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRESS2E" AS
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

  p_dtestrt                  tpfmemrq.dtereq%type;
  p_dteend                   tpfmemrq.dtereq%type;

  -- save & detail
  p_dtereq                   tpfmemrq.dtereq%type;
  p_dtereq2save              tpfmemrq.dtereq%type;
  p_numseq                   tpfmemrq.seqno%type;
  p_staappr                  tpfmemrq.staappr%type;
  p_codpfinf                 tpfpcinf.codpfinf%type;
  p_codplan                  tpfpcinf.codplan%type;
  p_dteeffec                 tpfpcinf.dteeffec%type;

  json_tab2                  json_object_t;
  tpfmemrq_codempid          tpfmemrq.codempid%type;
  tpfmemrq_dtereq            tpfmemrq.dtereq%type;
  tpfmemrq_codappr           tpfmemrq.codappr%type;
  tpfmemrq_staappr           tpfmemrq.staappr%type;
  tpfmemrq_dteappr           tpfmemrq.dteappr%type;
  tpfmemrq_remarkap          tpfmemrq.remarkap%type;
  tpfmemrq_approvno          tpfmemrq.approvno%type;
  tpfmemrq_routeno           tpfmemrq.routeno%type;
  tpfmemrq_codempap          temploy1.codempid%type;
  tpfmemrq_codcompap         temploy1.codcomp%type;
  tpfmemrq_codposap          temploy1.codpos%type;
  tpfmemrq_dteinput          tpfmemrq.dteinput%type;
  tpfmemrq_codplann          tpfmemrq.codplann%type;
  tpfmemrq_nummember         tpfmemrq.nummember%type;
  tpfmemrq_codpfinf          tpfmemrq.codpfinf%type;
  tpfmemrq_dtechg            tpfmemrq.dtechg%type;
  tpfmemrq_remark            tpfmemrq.remark%type;
  tpfmemrq_ratereta          tpfmemrq.ratereta%type;
  tpfmemrq_codcomp           tpfmemrq.codcomp%type;
  tpfmemrq_dteplann          tpfmemrq.dteplann%type;
  tpfmemrq_dteupd            tpfmemrq.dteupd%type;
  tpfmemrq_flgsend           tpfmemrq.flgsend%type;
  tpfmemrq_codinput          tpfmemrq.codinput%type;
  tpfmemrq_dtecancel         tpfmemrq.dtecancel%type;
  tpfmemrq_dtesnd            tpfmemrq.dtesnd%type;
  tpfmemrq_dteapph           tpfmemrq.dteapph%type;
  tpfmemrq_flgagency         tpfmemrq.flgagency%type;
  tpfmemrq_codplano          tpfmemrq.codplano%type;
  tpfmemrq_dteplano          tpfmemrq.dteplano%type;
  tpfmemrq_dteeffec          tpfmemrq.dteeffec%type;
  tpfmemrq_dtereti           tpfmemrq.dtereti%type;
  tpfmemrq_flgemp            tpfmemrq.flgemp%type;
  tpfmemrq_seqno             tpfmemrq.seqno%type;
  tpfmemrq_codreti           tpfmemrq.codreti%type;

  tpfmemrq2_dtereq           tpfmemrq2.dtereq%type;
  tpfmemrq2_codempid         tpfmemrq2.codempid%type;
  tpfmemrq2_seqno            tpfmemrq2.seqno%type;
  tpfmemrq2_dteupd           tpfmemrq2.dteupd%type;
  tpfmemrq2_coduser          tpfmemrq2.coduser%type;
  tpfmemrq2_codplan          tpfmemrq2.codplan%type;
  tpfmemrq2_codpolicy        tpfmemrq2.codpolicy%type;
  tpfmemrq2_dteeffec         tpfmemrq2.dteeffec%type;
  tpfmemrq2_qtycompst        tpfmemrq2.qtycompst%type;

  tprofreq_codempid          tprofreq.codempid%type;
  tprofreq_dtereq            tprofreq.dtereq%type;
  tprofreq_seqno             tprofreq.seqno%type;
  tprofreq_dteupd            tprofreq.dteupd%type;
  tprofreq_coduser           tprofreq.coduser%type;
  tprofreq_numseq            tprofreq.numseq%type;
  tprofreq_nampfic           tprofreq.nampfic%type;
  tprofreq_adrpfic           tprofreq.adrpfic%type;
  tprofreq_desrel            tprofreq.desrel%type;
  tprofreq_ratepf            tprofreq.ratepf%type;
  p_codempid_query           varchar2(100 char);--User37 #675 4.ES.MS Module 28/04/2021  

  procedure initial_value (json_str in clob);
  function gen_numseq(v_dtereq date) return number;
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
  procedure cancel_request (json_str_input in clob, json_str_output out clob);
  function get_codcodec(json_str_input in clob) return clob;
  procedure get_tpfirinf (json_str_input in clob, json_str_output out clob);
  procedure gen_tpfirinf (json_str_output out clob);
  procedure get_tpfpcinf (json_str_input in clob, json_str_output out clob);
  procedure gen_tpfpcinf (json_str_output out clob);
  procedure get_tpficinf (json_str_input in clob, json_str_output out clob);
  procedure gen_tpficinf (json_str_output out clob);
END HRESS2E;

/
