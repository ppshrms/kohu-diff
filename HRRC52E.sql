--------------------------------------------------------
--  DDL for Package HRRC52E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC52E" AS
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

  p_codempid                tcolltrl.codempid%type;
  p_numcolla                tcolltrl.numcolla%type;
  p_codcomp                 temploy1.codcomp%type;
  p_codpos                  temploy1.codpos%type;

  -- save detail
  json_params               json_object_t;
  p_warning                 varchar(10 char);

  p_staded                  tcolltrl.staded%type;--User37 #4383 2. RC Module 04/01/2022
  param_flgwarn           varchar2(100 char) := ''; -- softberry || 14/02/2023 || #9091
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
END HRRC52E;

/
