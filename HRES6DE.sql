--------------------------------------------------------
--  DDL for Package HRES6DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES6DE" AS
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
  p_codapp                  varchar2(10 char) := 'HRES6DE';

  p_codcomp                 tworkreq.codcomp%type;
  p_codempid_query          tworkreq.codempid%type;
  p_dtestrt                 tworkreq.dtereq%type;
  p_dteend                  tworkreq.dtereq%type;

  -- save & detail
  p_dtereq                  tworkreq.dtereq%type;
  p_dtework                 tworkreq.dtework%type;
  p_dtereq2save             tworkreq.dtereq%type;
  p_dtework2save            tworkreq.dtework%type;
  p_numseq                  tworkreq.seqno%type;
  p_staappr                 tworkreq.staappr%type;

  tworkreq_codempid         tworkreq.codempid%type;
  tworkreq_dtereq           tworkreq.dtereq%type;
  tworkreq_dtework          tworkreq.dtework%type;
  tworkreq_seqno            tworkreq.seqno%type;
  tworkreq_staappr          tworkreq.staappr%type;
  tworkreq_coduser          tworkreq.coduser%type;
  tworkreq_codinput         tworkreq.codinput%type;
  tworkreq_routeno          tworkreq.routeno%type;
  tworkreq_approvno         tworkreq.approvno%type;
  tworkreq_remarkap         tworkreq.remarkap%type;

  tworkreq_typwrko          tworkreq.typwrko%type;
  tworkreq_typwrkn          tworkreq.typwrkn%type;
  tworkreq_codshifto        tworkreq.codshifto%type;
  tworkreq_codshiftn        tworkreq.codshiftn%type;
  tworkreq_typwrkro         tworkreq.typwrkro%type;
  tworkreq_typwrkrn         tworkreq.typwrkrn%type;
  tworkreq_codshifro        tworkreq.codshifro%type;
  tworkreq_codshifrn        tworkreq.codshifrn%type;
  tworkreq_remark           tworkreq.remark%type;
  tworkreq_codcomp          tworkreq.codcomp%type;
  tworkreq_codappr          tworkreq.codappr%type;
  tworkreq_dteappr          tworkreq.dteappr%type;
  tworkreq_dteupd           tworkreq.dteupd%type;
  tworkreq_flgsend          tworkreq.flgsend%type;
  tworkreq_dtecancel        tworkreq.dtecancel%type;
  tworkreq_dteinput         tworkreq.dteinput%type;
  tworkreq_dtesnd           tworkreq.dtesnd%type;
  tworkreq_dteapph          tworkreq.dteapph%type;
  tworkreq_flgagency        tworkreq.flgagency%type;
  
  p_dteworkst               tworkreq.dtework%type;
  p_dteworken               tworkreq.dtework%type;
  
  p_table                   json_object_t;
  p_flgAfterSave            varchar2(1);
  v_tmp_numseq              number;

  procedure initial_value (json_str in clob);
  function gen_numseq(v_dtereq date) return number;
  procedure get_numseq (json_str_input in clob, json_str_output out clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
  procedure cancel_request (json_str_input in clob, json_str_output out clob);
  function get_codshift(json_str_input in clob) return clob;
  procedure get_calendar(json_str_input in clob,json_str_output out clob);
  procedure gen_calendar (json_str_output out clob);
  
  procedure get_create (json_str_input in clob, json_str_output out clob);
  procedure gen_create (json_str_output out clob);
END HRES6DE;

/
