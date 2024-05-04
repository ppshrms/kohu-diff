--------------------------------------------------------
--  DDL for Package HCM_STD_TYRTRPLN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_STD_TYRTRPLN" is
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

  p_dteyear                 varchar2(4000 char);
  p_codcompy                varchar2(4000 char);
  p_codcours                varchar2(4000 char);

  procedure initial_value(json_str in clob);

  procedure get_std_tyrtrpln_data(json_str_input in clob, json_str_output out clob);
end;

/
