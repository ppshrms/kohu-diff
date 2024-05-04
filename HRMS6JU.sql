--------------------------------------------------------
--  DDL for Package HRMS6JU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS6JU" is
-- last update: 27/09/2022 10:44

  param_msg_error           varchar2(4000 char);
  param_msg_error_mail      varchar2(4000 char);

  v_chken                   varchar2(10 char) := hcm_secur.get_v_chken;
  v_zyear                   number;
  global_v_coduser          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codcomp          tcenter.codcomp%type ;
  global_v_codpaypy1        tinexinf.codpay%type;
  global_v_lrunning         varchar2(10 char);
  global_v_key              varchar2(4000 char);

  param_json                json_object_t;

  p_codempid_query          temploy1.codempid%type;
  p_registeren              varchar2(10 char);
  p_registerst              varchar2(10 char);
  p_latitude                thotelif.latitude%type;
  p_longitude               thotelif.longitude%type;
  p_dtereqst                ttrnreq.dtereq%type;
  p_dtereqen                ttrnreq.dtereq%type;

  p_dteyear                 tpotentp.dteyear%type;
  p_codcompy                tpotentp.codcompy%type;
  p_numclseq                tpotentp.numclseq%type;
  p_codcours                tpotentp.codcours%type;
  p_numseq                  ttrnreq.numseq%type;
  p_dtereq                  ttrnreq.dtereq%type;
  p_flgConfirm              varchar2(1 char);
  p_staappr                 ttrnreq.staappr%type;
  p_dtereq2save             ttrnreq.dtereq%type;

  p_dtecancel               ttrnreq.dtecancel%type;
  p_codappr                 ttrnreq.codappr%type;
  p_dteappr                 ttrnreq.dteappr%type;
  p_remarkap                ttrnreq.remarkap%type;
  p_approvno                ttrnreq.approvno%type;
  p_routeno                 ttrnreq.routeno%type;
  p_codtparg              ttrnreq.codtparg%type;
--  p_accuracy                

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_tyrtrsch(json_str_input in clob, json_str_output out clob);
  procedure gen_tyrtrsch (json_str_output out clob);
  procedure approve(json_str_input in clob,json_str_output out clob);

  procedure notapprove(json_str_input in clob,json_str_output out clob);

END; -- Package spec

/
