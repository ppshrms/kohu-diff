--------------------------------------------------------
--  DDL for Package HRMS94U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS94U" is
-- last update: 27/09/2022 10:44

  param_msg_error       varchar2(4000 char);
  param_msg_error_mail  varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_codpswd     varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_chken               varchar2(10);
  v_zyear               number;

  param_httpcode        varchar2(4000 char);
  param_sqlerrm         varchar2(4000 char);
  param_code_error      varchar2(4000 char);
  param_flgwarn         varchar2(4000 char);

  p_codcomp             varchar2(100);
  p_dtest               varchar2(100);
  p_dteen               varchar2(100);
  p_staappr             varchar2(100);
  p_codempid            varchar2(100);
  p_start               varchar2(100);
  p_end                 varchar2(100);
  v_codappr             varchar2(100);
  -- param detail
  p_dtereq              varchar2(100);
  p_seqno               varchar2(100);
  p_dtereqr             varchar2(100);
  p_numseq              varchar2(100);
  -- sendApprove
  p_remark_appr         varchar2(4000 char);
  p_remark_not_appr     varchar2(4000 char);

  procedure initial_value (json_str in clob);
  procedure hrms94u(json_str_input in clob, json_str_output out clob);
  procedure hrms94u_detail_tab1(json_str_input in clob, json_str_output out clob);
  procedure process_approve(json_str_input in clob, json_str_output out clob);
end; -- Package spec

/
