--------------------------------------------------------
--  DDL for Package HRBF3XU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF3XU" is
-- last update: 16/09/2020 11:25

  v_chken      varchar2(100 char);

  param_msg_error           varchar2(4000 char);

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  v_zupdsal                 varchar2(4000 char);

  p_codcomp             varchar2(100 char);
  p_numpolicyo          varchar2(100 char);
  p_numpolicyn          varchar2(100 char);
  p_calculat            varchar2(100 char);
  p_numinsur            number;

  p_coduser          tinsrer.coduser%type;
  p_codlang          varchar2(20 char);
  p_type             varchar2(20 char);

  procedure initial_value(json_str in clob);

  procedure get_process(json_str_input in clob, json_str_output out clob);
--  procedure gen_data (json_str_output out clob);

--  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob);
--  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob);
--  procedure gen_detail_tab1 (json_str_output out clob);
--  procedure gen_detail_tab2 (json_str_output out clob);
--  procedure save_detail(json_str_input in clob, json_str_output out clob);
----  procedure get_process_detail (json_str_input in clob, json_str_output out clob);
--  procedure gen_process_detail (json_str_output out clob);
--  procedure get_process_table (json_str_input in clob, json_str_output out clob);
--  procedure gen_process_table (json_str_output out clob);

END; -- Package spec

/
