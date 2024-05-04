--------------------------------------------------------
--  DDL for Package STD_TAPPLSCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_TAPPLSCR" as 
  param_msg_error         varchar2(4000 char);
  global_v_coduser        varchar2(100 char);
  global_v_codempid       varchar2(100 char);
  global_v_lang           varchar2(10 char);

  global_v_zminlvl  	    number;
  global_v_zwrklvl  	    number;
  global_v_numlvlsalst 	  number;
  global_v_numlvlsalen 	  number;

  p_codapp                tapplscr.codapp%type;
  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  procedure initial_value (json_str in clob);  
  --tapplscr info
  procedure get_tapplscr_info (json_str_input in clob, json_str_output out clob);
  procedure get_header_info (json_str_input in clob, json_str_output out clob);
  procedure save_tapplscr (json_str_input in clob, json_str_output out clob);
end std_tapplscr;

/
