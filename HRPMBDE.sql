--------------------------------------------------------
--  DDL for Package HRPMBDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMBDE" is
  param_msg_error         varchar2(4000 char);
  global_v_coduser        varchar2(100 char);
  global_v_codempid       varchar2(100 char);
  global_v_lang           varchar2(10 char) := '102';

  global_v_chken          varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_zminlvl  	    number;
  global_v_zwrklvl  	    number;
  global_v_numlvlsalst 	  number;
  global_v_numlvlsalen 	  number;

  b_index_codcompy        tcompny.codcompy%type;
  b_index_dteeffec        date;

	procedure get_error_msg(json_str_input in clob,json_str_output out clob); 
	procedure get_index(json_str_input in clob,json_str_output out clob); 
  procedure save_index(json_str_input in clob,json_str_output out clob);
  procedure process_cal(json_str_input in clob,json_str_output out clob);
end;

/
