--------------------------------------------------------
--  DDL for Package HRPMC2E4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMC2E4" is
-- last update: 28/8/2018 10:01

  param_msg_error           varchar2(4000 char);
  param_flgwarn             varchar2(10 char);
  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  work_codcomp              varchar2(4000 char);

  p_codempid_query          varchar2(4000 char);

  ---guatantor---
  type guatantor_type is table of tguarntr%ROWTYPE index by binary_integer;
    guarantor_tab     guatantor_type;
  type flg_del_gua_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_gua     flg_del_gua_type;

  ---collateral---
  type collateral_type is table of tcolltrl%ROWTYPE index by binary_integer;
    collateral_tab     collateral_type;
  type flg_del_coll_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_coll    flg_del_coll_type;

  ---reference---
  type reference_type is table of tapplref%ROWTYPE index by binary_integer;
    reference_tab    reference_type;
  type flg_del_ref_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_ref     flg_del_ref_type;

  procedure get_guarantor_table(json_str_input in clob, json_str_output out clob);
  procedure gen_guarantor_table(json_str_output out clob);
  procedure get_sta_submit_grt(json_str_input in clob, json_str_output out clob);

  procedure get_collateral_table(json_str_input in clob, json_str_output out clob);
  procedure gen_collateral_table(json_str_output out clob);
  procedure get_sta_submit_col(json_str_input in clob, json_str_output out clob);
  procedure get_coll_period_popup(json_str_input in clob, json_str_output out clob);

  procedure get_Reference_table(json_str_input in clob, json_str_output out clob);
  procedure gen_Reference_table(json_str_output out clob);
  procedure get_sta_submit_ref(json_str_input in clob, json_str_output out clob);
  
  procedure get_emp_detail(json_str_input in clob, json_str_output out clob);

  procedure get_popup_change_guarantee(json_str_input in clob, json_str_output out clob);
  procedure gen_popup_change_guarantee(json_str_input in clob, json_str_output out clob);

  procedure save_guarantee(json_str_input in clob, json_str_output out clob);

end;

/
