--------------------------------------------------------
--  DDL for Package HRRC44E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC44E" AS
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

  p_codcomp                 tnempaset.codcomp%type;
  p_codpos                  tnempaset.codpos%type;

  -- save detail
  obj_tnempaset             json_object_t;
  obj_tnempdoc              json_object_t;

  procedure get_tnempaset (json_str_input in clob, json_str_output out clob);
  procedure gen_tnempaset (json_str_output out clob);
  procedure get_tnempdoc (json_str_input in clob, json_str_output out clob);
  procedure gen_tnempdoc (json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
END HRRC44E;

/
