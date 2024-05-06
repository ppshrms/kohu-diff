--------------------------------------------------------
--  DDL for Package HRPY17E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY17E" AS 

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  p_codapp          varchar2(10 char) := 'HRPY17E';
  p_codcompy        tcondept.codcompy%type;
  p_dteeffec        tcondept.dteeffec%type;

  function find_dteeffec (v_dteeffec in date) return date;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);

END HRPY17E;

/
