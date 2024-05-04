--------------------------------------------------------
--  DDL for Package HRRC51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC51E" AS
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

  p_codcomp                 temploy1.codcomp%type;
  p_codpos                  temploy1.codpos%type;
  p_codjob                  temploy1.codjob%type;
  p_codempid                tguarntr.codempid%type;
  p_numseq                  tguarntr.numseq%type;

  -- save detail
  json_params               json_object_t;
  p_warning                 varchar(10 char);--<<#7684
  param_flgwarn             varchar2(100 char) := ''; -- softberry || 24/02/2023 || #8764
  
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_detail_codempid (json_str_input in clob, json_str_output out clob);
  procedure gen_detail_codempid (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
END HRRC51E;

/
