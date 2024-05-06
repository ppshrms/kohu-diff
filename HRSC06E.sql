--------------------------------------------------------
--  DDL for Package HRSC06E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC06E" as
-- last update: 15/05/2022 21:33

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
  global_v_zupdsal          varchar2(100 char);

  -- index
  b_index_codcompy          tcontrusr.codcompy%type;
  b_index_dteeffec          tcontrusr.dteeffec%type;

  -- save index
  p_typecodusr              tcontrusr.typecodusr%type;
  p_typepwd                 tcontrusr.typepwd%type;

  procedure initial_value (json_str in clob);

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);

end HRSC06E;

/
