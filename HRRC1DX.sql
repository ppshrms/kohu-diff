--------------------------------------------------------
--  DDL for Package HRRC1DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC1DX" AS 

  param_msg_error           varchar2(4000 char);
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;
  global_v_codempid         varchar2(100 char);

  v_chken                   varchar2(10 char);
  v_zupdsal                 varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;

  b_index_codcomp           varchar2(1000 char);
  b_index_dteopenst         date;
  b_index_dteopenen         date;

  p_numreqst                varchar2(1000 char);
  p_codpos                  varchar2(1000 char);
  p_codjob                  varchar2(1000 char);

  procedure initial_value(json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail_jobdesc(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);

END HRRC1DX;

/
