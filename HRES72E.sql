--------------------------------------------------------
--  DDL for Package HRES72E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES72E" as

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_v_zminlvl	        number;
  global_v_zwrklvl	        number;
  global_v_numlvlsalst	    number;
  global_v_numlvlsalen	    number;
  global_v_zupdsal		      varchar2(4 char);

  param_json                json_object_t;
  p_codempid                temploy1.codempid%type;
  p_dteyear                 varchar2(100 char);
  p_dteeffec                date;
  p_limit     	            number;
  p_balance 	              number;

  procedure initial_value(json_str in clob);
  procedure check_detail;
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);

end hres72e;

/
