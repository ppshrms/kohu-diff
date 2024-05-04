--------------------------------------------------------
--  DDL for Package HRES17E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES17E" is
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

  p_dteyear                 tkpireq.dteyreap%type;
  p_numtime                 tkpireq.numtime%type;
  p_dtestr                  tkpireq.dtereq%type;
  p_dteend                  tkpireq.dtereq%type;
  
  p_codcours                ttrncanrq.codcours%type;
  p_numclseq                ttrncanrq.numclseq%type;
  p_dtereq                  tkpireq.dtereq%type;
  p_numseq                  tkpireq.numseq%type;
  p_codempid_query          tkpireq.codempid%type;
  

  p_staappr                 tkpireq.staappr%type;
  p_dtereq2save             tkpireq.dtereq%type;

  p_dtecancel               tkpireq.dtecancel%type;
  p_codappr                 tkpireq.codappr%type;
  p_dteappr                 tkpireq.dteappr%type;
  p_remarkap                tkpireq.remarkap%type;
  p_approvno                tkpireq.approvno%type;
  p_routeno                 tkpireq.routeno%type;
  p_codkpi                  tkpireq2.codkpi%type;

  p_codtparg                tpotentp.codtparg%type;
--  p_accuracy                

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_index_data(json_str_input in clob, json_str_output out clob);
  procedure gen_index_data (json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_detail_create(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_create (json_str_output out clob);
  procedure get_lov(json_str_input in clob, json_str_output out clob);
  procedure gen_lov(json_str_output out clob);
  procedure get_jobKpi(json_str_input in clob, json_str_output out clob);
  procedure gen_jobKpi(json_str_output out clob);
  procedure post_save(json_str_input in clob,json_str_output out clob);
  procedure post_savekpi(json_str_input in clob,json_str_output out clob);

  procedure post_cancel(json_str_input in clob,json_str_output out clob);

END; -- Package spec

/
