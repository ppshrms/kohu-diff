--------------------------------------------------------
--  DDL for Package HRRC19X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC19X" AS

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

  b_index_codcomp           temploy1.codcomp%type;
  b_index_dtereqst          date;
  b_index_dtereqen          date;
  b_index_flgrecut          varchar2(100 char);

  procedure initial_value(json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

END HRRC19X;

/
