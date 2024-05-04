--------------------------------------------------------
--  DDL for Package HRAP58X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP58X" is
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
  b_index_dteyear     varchar2(4000 char);
  b_index_numtime     varchar2(4000 char);
  b_index_codcomp     varchar2(4000 char);
  b_index_codbon      varchar2(4000 char);

  --block drilldown
  b_index_codcompd    varchar2(4000 char);

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);

  procedure get_head(json_str_input in clob, json_str_output out clob);
  procedure gen_head(json_str_output out clob);
  procedure get_popup(json_str_input in clob, json_str_output out clob);
  procedure gen_popup(json_str_output out clob);

  procedure get_popup2(json_str_input in clob, json_str_output out clob);
  procedure gen_popup2(json_str_output out clob);

  function count_emp(p_codcomp in varchar2,p_codempid varchar2) return number;

END; -- Package spec

/
