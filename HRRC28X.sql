--------------------------------------------------------
--  DDL for Package HRRC28X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC28X" AS
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  p_zupdsal                 varchar2(100 char);

  p_codcomp                 treqest2.codcomp%type;
  p_codpos                  treqest2.codpos%type;
  p_numreqst                treqest2.numreqst%type;
  p_dtestrt                 treqest2.dteopen%type;
  p_dteend                  treqest2.dteopen%type;
  p_flgrecut                treqest2.flgrecut%type;
  p_statappl                tapplinf.statappl%type;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_qtyappl_group (json_str_input in clob, json_str_output out clob);
  procedure gen_qtyappl_group (json_str_output out clob);
  procedure get_qtyappl_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_qtyappl_detail (json_str_output out clob);
  procedure get_qtyappl_approve (json_str_input in clob, json_str_output out clob);
  procedure gen_qtyappl_approve (json_str_output out clob);
  procedure get_qtyappl_reject (json_str_input in clob, json_str_output out clob);
  procedure gen_qtyappl_reject (json_str_output out clob);
END HRRC28X;

/
