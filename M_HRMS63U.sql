--------------------------------------------------------
--  DDL for Package M_HRMS63U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRMS63U" is
/* Cust-Modify: KOHU-SM2301 */
-- last update: 04/12/2023 10:30

  --param error warning
  param_msg_error         varchar2(4000 char);
  param_msg_error_mail    varchar2(4000 char);
  param_flgwarn           varchar2(4000 char);

  --global
  global_v_coduser          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char);
  global_v_zyear            number := pdk.check_year(global_v_lang);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);
  --
  global_v_empid        varchar2(100);
  global_v_chken        varchar2(10) := hcm_secur.get_v_chken;
  global_v_codapp       varchar2(4000 char);

  -- param index
  p_codcomp             varchar2(100 char);
  p_dtest               varchar2(100 char);
  p_dteen               varchar2(100 char);
  p_staappr             varchar2(100 char);
  p_codempid            varchar2(100 char);
  -- param detail
  p_dtereq              varchar2(100);
  p_seqno               varchar2(100);
  -- submit approve
  p_remark_appr         varchar2(4000 char);
  p_remark_not_appr     varchar2(4000 char);
  param_qtyavgwk        number;

  procedure initial_value(json_str in clob);
  procedure hrms63u(json_str_input in clob, json_str_output out clob);
  procedure hrms63u_detail_tab1(json_str_input in clob, json_str_output out clob);
  procedure hrms63u_detail_tab2(json_str_input in clob, json_str_output out clob);
  procedure hrms63u_detail_tab3(json_str_input in clob, json_str_output out clob);
  procedure hrms63u_detail_tab3_table(json_str_input in clob, json_str_output out clob);
  procedure process_approve(json_str_input in clob, json_str_output out clob);
  procedure datatest(json_str in clob);
  procedure cal_dhm(p_qtyavgwk     in  number,
                    p_qtyday       in  number,
                    p_day          out number,
                    p_hour         out number,
                    p_min          out number);
  procedure get_leaveatt(json_str_input in clob,json_str_output out clob);

end; -- Package spec


/
