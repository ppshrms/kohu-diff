--------------------------------------------------------
--  DDL for Package HRMS85U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS85U" is
-- last update: 27/09/2022 10:44

  param_msg_error       varchar2(4000 char);
  param_msg_error_mail  varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  v_chken               varchar2(10);
  v_zyear               number;

  p_dtest               varchar2(100 char);
  p_dteen               varchar2(100 char);
  p_staappr             varchar2(100 char);
  p_codempid            varchar2(100 char);
  p_dtereq              date;
  p_numseq              number;
  p_approvno            number;
  -- sendApprove
  p_remark_appr       varchar2(4000 char);
  p_remark_not_appr   varchar2(4000 char);

  function call_formattime(ptime varchar2) return varchar2;
  procedure hrms85u(json_str_input in clob, json_str_output out clob);
  procedure hrms85u_detail(json_str_input in clob, json_str_output out clob);
  procedure hrms85u_detail_table_file(json_str_input in clob, json_str_output out clob);
  procedure hrms85u_detail_table_exp(json_str_input in clob, json_str_output out clob);
  procedure get_approve(json_str_input in clob, json_str_output out clob);
  procedure process_approve(json_str_input in clob, json_str_output out clob);
end; -- Package spec

/
