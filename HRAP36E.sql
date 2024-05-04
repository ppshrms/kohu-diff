--------------------------------------------------------
--  DDL for Package HRAP36E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP36E" as
  --para
  param_msg_error       varchar2(4000);

  --global
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_zupdsal      varchar2(4 char);

  global_v_coduser      varchar2(100);
  global_v_codempid     varchar2(100);
  global_v_lang         varchar2(100);
  global_v_zyear        number  := 0;
  global_v_chken        varchar2(10) := hcm_secur.get_v_chken;

  b_index_dteyreap      tkpidph.dteyreap%type;
  b_index_codcompy      tkpidph.codcomp%type;

  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_kpi_detail(json_str_input in clob,json_str_output out clob);
  procedure get_action_plan(json_str_input in clob,json_str_output out clob);
  procedure get_score_condition(json_str_input in clob,json_str_output out clob);
  procedure save_kpi(json_str_input in clob,json_str_output out clob);
  procedure save_index(json_str_input in clob,json_str_output out clob);
end;

/
