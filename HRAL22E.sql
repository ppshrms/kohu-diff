--------------------------------------------------------
--  DDL for Package HRAL22E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL22E" is

  param_msg_error           varchar2(4000 char);
  global_v_zminlvl  	    number;
  global_v_zwrklvl  	    number;
  global_v_numlvlsalst 	  number;
  global_v_numlvlsalen 	  number;
  v_zupdsal   		        varchar2(4 char);
  v_zyear                 varchar2(4 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  b_index_codempid          varchar2(500 char);

  p_codempid                varchar2(500 char);
  p_dtestrt                 date;
  p_dteend                  date;

  p_codcompo                varchar2(1000 char);
  p_codcomp                 varchar2(1000 char);
  p_codcaleno               varchar2(1000 char);
  p_codcalen                varchar2(1000 char);
  p_codshifto               varchar2(1000 char);
  p_codshift                varchar2(1000 char);
  p_timoutst                varchar2(1000 char);
  p_timouten                varchar2(1000 char);
  p_flghead                 varchar2(1000 char);
  p_codempidh               varchar2(1000 char);
  p_deschhr                 varchar2(1000 char);
  p_codappr                 varchar2(1000 char);
  p_dteappr                 date;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);

  procedure get_index_head(json_str_input in clob, json_str_output out clob);

  procedure get_worktime_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_worktime_detail(json_str_output out clob);

  procedure post_worktime_detail(json_str_input in clob, json_str_output out clob);
  procedure save_worktime_detail;

  procedure delete_index(json_str_input in clob, json_str_output out clob);
  procedure get_codcenter(json_str_input in clob, json_str_output out clob);

  procedure update_tattence(p_codempid varchar2, p_dtewoek varchar2, p_coduser varchar2, p_type varchar2);

end HRAL22E;

/
