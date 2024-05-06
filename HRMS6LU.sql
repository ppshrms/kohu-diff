--------------------------------------------------------
--  DDL for Package HRMS6LU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS6LU" is
-- last update: 27/09/2022 10:44

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
  p_codcomp           varchar2(100);
  p_dtest             varchar2(100);
  p_dteen             varchar2(100);
  p_staappr           varchar2(100);
  p_codempid          varchar2(100);
  -- param detail
  p_dtereq            varchar2(100);
  p_numseq            varchar2(100);
  p_dtereqr           varchar2(100);

  -- sendApprove
  p_remark_appr         varchar2(4000 char);
  p_remark_not_appr     varchar2(4000 char);
  ttotreq_staovrot      ttotreq.staovrot%type;
  p_qtyot_total         number;
  p_qtytotal            number;
  v_msgerror            varchar2(4000 char);

  a_dtestweek           std_ot.a_dtestr;
  a_dteenweek           std_ot.a_dtestr;
  a_sumwork             std_ot.a_qtyotstr;
  a_sumotreqoth         std_ot.a_qtyotstr;
  a_sumotreq            std_ot.a_qtyotstr;
  a_sumot               std_ot.a_qtyotstr;
  a_totwork             std_ot.a_qtyotstr;
  v_qtyperiod           number;
  v_typalert            tcontrot.typalert%type;

  procedure initial_value (json_str in clob);
  procedure hrms6lu(json_str_input in clob, json_str_output out clob);
  procedure hrms6lu_detail_tab1(json_str_input in clob, json_str_output out clob);
  procedure hrms6lu_detail_tab1_table(json_str_input in clob, json_str_output out clob);
  procedure hrms6lu_detail_tab2(json_str_input in clob, json_str_output out clob);
  procedure hrms6lu_detail_tab2_table(json_str_input in clob, json_str_output out clob);
  procedure hrms6lu_detail_tab3_table(json_str_input in clob, json_str_output out clob);
  procedure process_approve(json_str_input in clob, json_str_output out clob);
end; -- Package spec

/
