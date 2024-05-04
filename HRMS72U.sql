--------------------------------------------------------
--  DDL for Package HRMS72U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS72U" is 
-- last update: 13/02/2023 19:18 //STT-SS2101-redmine-752

  param_msg_error       varchar2(4000 char);
  param_msg_error_mail  varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_chken               varchar2(10);
  v_zyear               number;

  -- param index
  p_codcomp           varchar2(100 char);
  p_dtest             varchar2(100 char);
  p_dteen             varchar2(100 char);
  p_staappr           varchar2(100 char);
  p_codempid          varchar2(100 char);
  -- param detail
  p_dtereq            varchar2(100 char);
  p_seqno             varchar2(100 char);
  p_approvno          varchar2(100 char);
  p_dtereqr           varchar2(100 char);

  -- sendApprove
  p_remark_appr         varchar2(4000 char);
  p_remark_not_appr     varchar2(4000 char);

  procedure initial_value (json_str in clob);
  procedure hrms72u(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure get_detail_table(json_str_input in clob, json_str_output out clob);
  procedure get_approve(json_str_input in clob, json_str_output out clob);
--  procedure hrms72u_detail_tab1(json_str_input in clob, json_str_output out clob);
  procedure process_approve(json_str_input in clob, json_str_output out clob);
end; -- Package spec

/
