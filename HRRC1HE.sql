--------------------------------------------------------
--  DDL for Package HRRC1HE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC1HE" AS
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

  p_codcomp                 texampos.codcomp%type;
  p_codexam                 texampos.codexam%type;

  -- save detail
  json_params               json_object_t;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_texampos (json_str_input in clob, json_str_output out clob);
  procedure gen_texampos (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
END HRRC1HE;


/
