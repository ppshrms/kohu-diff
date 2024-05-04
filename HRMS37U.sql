--------------------------------------------------------
--  DDL for Package HRMS37U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS37U" is
-- last update: 27/09/2022 10:44

  --param error warning
  param_sqlerrm       varchar2(4000 char);
  param_code_error    varchar2(4000 char);
  param_flgwarn       varchar2(4000 char);
  param_httpcode      varchar2(4000 char);
  v_chken             varchar2(10 char) := hcm_secur.get_v_chken;

  param_msg_error           varchar2(1000 char);
  param_msg_error_mail      varchar2(4000 char);
  global_v_coduser          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  global_v_codpswd    varchar2(100 char);
  global_v_lang       varchar2(10 char) := '102';
  global_v_codapp     varchar2(4000 char);
  b_index_codempid    varchar2(4000 char);
  b_index_codcomp     varchar2(4000 char);

  p_message           varchar2(4000 char);
  p_codempid          varchar2(4000 char);
  p_dtest             varchar2(4000 char);
  p_dteen             varchar2(4000 char);
  p_staappr           varchar2(4000 char);
  p_dtereq             varchar2(4000 char);
  p_numseq               varchar2(4000 char);
  v_codappr           varchar2(4000 char);

  -- sendApprove
  p_remark_appr         varchar2(4000 char);
  p_remark_not_appr     varchar2(4000 char);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure process_approve(json_str_input in clob, json_str_output out clob);
  procedure datatest(json_str in clob);
end; -- Package spec

/
