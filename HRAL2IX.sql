--------------------------------------------------------
--  DDL for Package HRAL2IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL2IX" is
-- last update: 07/12/2017 11:23
  param_msg_error     varchar2(4000 char);

  v_chken             varchar2(10 char);
  global_v_coduser    varchar2(100 char);
  global_v_codpswd    varchar2(100 char);
  global_v_lang       varchar2(10 char) := '102';
  global_v_lrunning   varchar2(10 char);
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	number;
  global_v_numlvlsalen 	number;
  v_zupdsal   			    varchar2(4 char);
  p_codempid          varchar2(4000 char);
  p_codcomp           varchar2(4000 char);
  p_dtestrt           date;
  p_dteend            date;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure get_tleavecd (json_str_input in clob, json_str_output out clob);
  procedure gen_tleavecd (json_str_output out clob);

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure get_index_summary (json_str_input in clob, json_str_output out clob);

  function calHour (p_min number) return varchar2;
  function get_ot_col (v_codcompy varchar2) return json_object_t;

end HRAL2IX;

/
