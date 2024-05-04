--------------------------------------------------------
--  DDL for Package HRSC10X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC10X" as
-- last update: 14/11/2018 22:31

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

  -- index
  p_dtestrt                 date;
  p_dteend                  date;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  function get_description(p_table in varchar2,p_field in varchar2,p_code in varchar2) RETURN VARCHAR2;

end HRSC10X;

/
