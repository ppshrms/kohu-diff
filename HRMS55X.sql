--------------------------------------------------------
--  DDL for Package HRMS55X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS55X" is
-- last update: 15/04/2019 20:13

  param_msg_error           varchar2(4000 char);
  v_zyear                   number := 0;
  global_v_coduser          varchar2(4000 char);
  global_v_codpswd          varchar2(4000 char);
  global_v_lang             varchar2(4000 char) := '102';
  global_v_codempid         varchar2(4000 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal             varchar2(4 char);
  global_v_zupdsal          varchar2(100 char);

  b_index_codempid          varchar2(4000 char);
  b_index_codcomp           varchar2(4000 char);
  b_index_dtestrt           date;
  b_index_dteend            date;
  b_index_typleave          varchar2(4000 char);

  procedure get_index(json_str_input in clob, json_str_output out clob);

end; -- package spec

/
