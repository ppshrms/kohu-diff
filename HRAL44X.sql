--------------------------------------------------------
--  DDL for Package HRAL44X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL44X" is

  param_msg_error           varchar2(4000 char);
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  v_chken                   varchar2(10 char);
  v_zupdsal                 varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;

  p_flg                     varchar2(100);
  p_codempid                varchar2(1000 char);
  p_codcomp                 varchar2(1000 char);
  p_codcalen                varchar2(1000 char);
  p_dtestrt                 date;
  p_dteend                  date;
  -- special
  v_text_key                varchar2(100 char);

  --
  procedure initial_value (json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure get_ot_head (json_str_input in clob, json_str_output out clob);
  procedure gen_ot_head (json_str_output out clob);

  function get_ot_col (v_codcompy varchar2) return json_object_t;
end hral44x;

/
