--------------------------------------------------------
--  DDL for Package HRPMC2E6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMC2E6" is
-- last update: 17/9/2020 19:15

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

  procedure get_others_table(json_str_input in clob, json_str_output out clob);
  procedure gen_others_table(json_str_output out clob);
  procedure get_flg_secure(json_str_input in clob, json_str_output out clob);

  procedure get_submit_alter(json_str_input in clob, json_str_output out clob);

  procedure get_popup_change_others(json_str_input in clob, json_str_output out clob);
  procedure gen_popup_change_others(json_str_input in clob, json_str_output out clob);

  procedure alter_table(json_str_input in clob, json_str_output out clob);
  procedure save_others_data(json_str_input in clob, json_str_output out clob);
end;

/
