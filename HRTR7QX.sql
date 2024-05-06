--------------------------------------------------------
--  DDL for Package HRTR7QX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR7QX" is
-- last update: 11/08/2020 14:00
  v_chken               varchar2(100 char);
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  --block b_index
  b_index_codcomp     varchar2(4000 char);
  b_index_codpos      varchar2(4000 char);

  --block drilldown
  b_index_dteeffec    varchar2(4000 char);
  b_index_numlevel    varchar2(4000 char);
  b_index_codcompp    varchar2(4000 char);

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_index_data(json_str_input in clob, json_str_output out clob);
  procedure get_total_column(json_str_input in clob, json_str_output out clob);
  procedure gen_head(json_str_output out clob);
  procedure gen_data(json_str_output out clob);
END; -- Package spec

/
