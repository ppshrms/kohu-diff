--------------------------------------------------------
--  DDL for Package HCM_HELP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_HELP" as 

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  v_zupdsal                 varchar2(10 char);
  p_codmodule               thelp.codmodule%type; 
  p_search                  clob; 

  v_path_filename           clob; 
  v_path_vdoname            clob; 

  numYearReport		        number := 0;

  procedure initial_value (json_str in clob);  
  --help info
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure get_help_module (json_str_input in clob, json_str_output out clob);
  procedure get_help_search (json_str_input in clob, json_str_output out clob);
  procedure get_help_module_search (json_str_input in clob, json_str_output out clob);

end HCM_HELP;

/
