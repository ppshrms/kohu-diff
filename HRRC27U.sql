--------------------------------------------------------
--  DDL for Package HRRC27U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC27U" AS
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
  p_codemprc                treqest2.codemprc%type;

  -- save detail
  json_params               json_object_t;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_search_index (json_str_input in clob, json_str_output out clob);
  procedure gen_search_index (json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
END HRRC27U;

/
