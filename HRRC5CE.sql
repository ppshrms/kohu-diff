--------------------------------------------------------
--  DDL for Package HRRC5CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC5CE" AS
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
  p_dtechg                  tcollchg.dtechg%type;

  -- save detail
  json_params               json_object_t;
  p_warning                 varchar(10 char);--<<#7684
  param_flgwarn           varchar2(100 char) := ''; -- softberry || 13/02/2023 || #9091
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
END HRRC5CE;

/
