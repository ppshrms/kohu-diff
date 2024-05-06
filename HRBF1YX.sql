--------------------------------------------------------
--  DDL for Package HRBF1YX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1YX" AS
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
  p_additional_year   number := 0;

  p_dtestrt                 date;
  p_dteend                  date;
  p_codcomp                 temploy1.codcomp%type;
  p_codempid_query          temploy1.codempid%type;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
END HRBF1YX;

/
