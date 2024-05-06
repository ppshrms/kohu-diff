--------------------------------------------------------
--  DDL for Package HRES91E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES91E" is
-- last update: 26/07/2016 13:16
  param_msg_error     varchar2(4000 char);

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

  p_dtestr                  ttrncanrq.dtereq%type;
  p_dteend                  ttrncanrq.dtereq%type;
  p_codcours                ttrncanrq.codcours%type;
  p_dteyear                 ttrncanrq.dteyear%type;
  p_numclseq                ttrncanrq.numclseq%type;
  p_dtereq                  ttrncanrq.dtereq%type;
  p_numseq                  ttrncanrq.numseq%type;
  p_codempid_query          ttrncanrq.codempid%type;

  p_staappr                 ttrncanrq.stappr%type;
  p_dtereq2save             ttrncanrq.dtereq%type;

  p_dtecancel               ttrncanrq.dtecancel%type;
  p_codappr                 ttrncanrq.codappr%type;
  p_dteappr                 ttrncanrq.dteappr%type;
  p_remarkap                ttrncanrq.remarkap%type;
  p_approvno                ttrncanrq.approvno%type;
  p_routeno                 ttrncanrq.routeno%type;

  p_codtparg                tpotentp.codtparg%type;
--  p_accuracy                

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_detail_create(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_create (json_str_output out clob);
  procedure get_numclseq(json_str_input in clob, json_str_output out clob);
  procedure gen_numclseq(json_str_output out clob);
  procedure post_save(json_str_input in clob,json_str_output out clob);

  procedure post_cancel(json_str_input in clob,json_str_output out clob);

END; -- Package spec

/
