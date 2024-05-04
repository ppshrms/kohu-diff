--------------------------------------------------------
--  DDL for Package HRMS6BU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS6BU" is
-- last update: 27/09/2022 10:44

  -- param error warning
  param_msg_error           varchar2(4000 char);
  param_msg_error_mail      varchar2(4000 char);

  -- global value parameter
  global_v_coduser          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char);
  global_v_zyear            number := pdk.check_year(global_v_lang);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);
  global_v_chken            varchar2(10) := hcm_secur.get_v_chken;

  -- parameter block
  p_codempid            varchar2(100);
  p_stdate              varchar2(100);
  p_endate              varchar2(100);

  -- detail tab1
  p_codcomp             varchar2(100);
  p_dtest               varchar2(100);
  p_dteen               varchar2(100);
  p_staappr             varchar2(100);
  p_dtereq              varchar2(100);
  p_numseq              number;
  p_dtework             varchar2(100);

  -- submit approve
  p_remark_appr         varchar2(4000 char);
  p_remark_not_appr     varchar2(4000 char);

  procedure initial_value(json_str in clob);
  procedure hrms6bu(json_str_input in clob, json_str_output out clob);
  procedure hrms6bu_detail_tab1(json_str_input in clob, json_str_output out clob);
  procedure hrms6bu_detail_tab2_table(json_str_input in clob, json_str_output out clob);
  procedure process_approve(json_str_input in clob, json_str_output out clob);
end; -- Package spec

/
