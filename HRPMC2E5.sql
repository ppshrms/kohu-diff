--------------------------------------------------------
--  DDL for Package HRPMC2E5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMC2E5" is
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

  ---competency---
  type competency_type is table of tcmptncy%ROWTYPE index by binary_integer;
    competency_tab     competency_type;
  type flg_del_cmp_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_cmp     flg_del_cmp_type;

  ---langabi---
  type langabi_type is table of tlangabi%ROWTYPE index by binary_integer;
    langabi_tab     langabi_type;
  type flg_del_lng_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_lng    flg_del_lng_type;

  ---hisreward---
  type hisreward_type is table of thisrewd%ROWTYPE index by binary_integer;
    hisreward_tab    hisreward_type;
  type flg_del_rew_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_rew     flg_del_rew_type;

  procedure get_competency_table(json_str_input in clob, json_str_output out clob);
  procedure gen_competency_table(json_str_output out clob);

  procedure get_langabi_table(json_str_input in clob, json_str_output out clob);
  procedure gen_langabi_table(json_str_output out clob);

  procedure get_hisreward_table(json_str_input in clob, json_str_output out clob);
  procedure gen_hisreward_table(json_str_output out clob);
  procedure get_sta_submit_reward(json_str_input in clob, json_str_output out clob);

  procedure get_popup_change_talent(json_str_input in clob, json_str_output out clob);
  procedure gen_popup_change_talent(json_str_input in clob, json_str_output out clob);

  procedure save_talent(json_str_input in clob, json_str_output out clob);

end;

/
