--------------------------------------------------------
--  DDL for Package HRALS5X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRALS5X" as
-- last update: 30/03/2018 16:30:00

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

  p_codcomp                 varchar2(100 char);
  p_yearstrt                varchar2(4 char);
  p_monthstrt               varchar2(2 char);
  p_yearend                 varchar2(4 char);
  p_monthend                varchar2(2 char);
  p_codleave                varchar2(4000 char);

  p_dtestrt                 varchar2(10 char);
  p_dteend                  varchar2(10 char);

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_index_choose (json_str_input in clob, json_str_output out clob);
  procedure gen_index_choose (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);

end hrals5x;

/
