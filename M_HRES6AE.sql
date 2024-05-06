--------------------------------------------------------
--  DDL for Package M_HRES6AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRES6AE" AS
/* Cust-Modify: KOHU-SM2301 */
-- last update: 07/12/2023 15:00

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

  p_codcomp                  trefreq.codcomp%type;
  p_codempid_query           trefreq.codempid%type;
  p_dtestrt                  trefreq.dtereq%type;
  p_dteend                   trefreq.dtereq%type;

  p_dtereq                   ttimereq.dtereq%type;
  p_dtework                  ttimereq.dtework%type;
  p_numseq                   ttimereq.numseq%type;
  -- save & detail
  json_params                json_object_t;
  p_dtereq2save              ttimereq.dtereq%type;
  p_dtework2save             ttimereq.dtework%type;
  p_staappr                  ttimereq.staappr%type;

  ttimereq_codempid          ttimereq.codempid%type;
  ttimereq_dtereq            ttimereq.dtereq%type;
  ttimereq_numseq            ttimereq.numseq%type;
  ttimereq_dtework           ttimereq.dtework%type;
  ttimereq_dtein             ttimereq.dtein%type;
  ttimereq_dteout            ttimereq.dteout%type;
  ttimereq_codreqst          ttimereq.codreqst%type;
  ttimereq_remark            ttimereq.remark%type;
  ttimereq_timin             ttimereq.timin%type;
  ttimereq_timout            ttimereq.timout%type;
  ttimereq_remarkap          ttimereq.remarkap%type;
  ttimereq_dteinput          ttimereq.dteinput%type;
  ttimereq_dtecancel         ttimereq.dtecancel%type;
  ttimereq_staappr           ttimereq.staappr%type;
  ttimereq_codappr           ttimereq.codappr%type;
  ttimereq_dteappr           ttimereq.dteappr%type;
  ttimereq_approvno          ttimereq.approvno%type;
  ttimereq_routeno           ttimereq.routeno%type;
  ttimereq_codshift          ttimereq.codshift%type;
  ttimereq_codcomp           ttimereq.codcomp%type;
  ttimereq_numlvl            ttimereq.numlvl%type;

  procedure initial_value (json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_detail_search (json_str_input in clob, json_str_output out clob);
  procedure gen_detail_search (json_str_output out clob);
  procedure get_atten (json_str_input in clob, json_str_output out clob);
  procedure gen_atten (json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
  procedure cancel_request (json_str_input in clob, json_str_output out clob);
  function get_codcodec(json_str_input in clob) return clob;
END M_HRES6AE;


/
