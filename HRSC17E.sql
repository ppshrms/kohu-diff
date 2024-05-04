--------------------------------------------------------
--  DDL for Package HRSC17E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC17E" is
-- last update: 12/11/2018 21:12

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  -- p_codapp                  varchar2(100 char) := 'HRSC17E';
  -- index
  p_dtestrt                 tfunclock.dtestrt%type;
  p_dteend                  tfunclock.dteend%type;
  p_codapp                  tfunclock.codapp%type;
  p_module                  varchar2(100 char);
  -- save index
  json_params               json_object_t;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
end HRSC17E;

/
