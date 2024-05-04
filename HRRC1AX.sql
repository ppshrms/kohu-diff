--------------------------------------------------------
--  DDL for Package HRRC1AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC1AX" AS

  param_msg_error           varchar2(4000 char);
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  v_chken                   varchar2(10 char);
  v_zupdsal                 varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;

  b_index_codcomp           varchar2(100 char);
  b_index_codemprc          varchar2(100 char);
  b_index_dtereqst          date;
  b_index_dtereqen          date;

  procedure initial_value(json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

END HRRC1AX;

/
