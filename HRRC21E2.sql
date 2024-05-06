--------------------------------------------------------
--  DDL for Package HRRC21E2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC21E2" is
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

  b_index_numappl           tapplinf.numappl%type;

  procedure get_applinf_step(json_str_input in clob, json_str_output out clob);

  procedure get_applinf_history(json_str_input in clob, json_str_output out clob);

  procedure save_applinf_step(json_str_input in clob, json_str_output out clob);
end;

/
