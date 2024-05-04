--------------------------------------------------------
--  DDL for Package HRRC2EE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC2EE" AS 

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

  b_index_codcomp           temploy1.codcomp%type;
  b_index_mthpost           number;
  b_index_yrepost           number;
  b_index_dtepost           date;

  p_codcomp                 temploy1.codcomp%type;
  p_codjobpost              temploy1.codjob%type;
  p_dtepost                 date;
  p_dtepay                  date;
  p_remark                  tjobpost.remark%type;
  p_amtpay                  number;
  p_qtypos                  number;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure initial_value(json_str in clob);
  procedure gen_index(json_str_output out clob);
  procedure get_detail_reqjob(json_str_input in clob, json_str_output out clob);
  procedure post_index(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure check_insupd;

END HRRC2EE;

/
