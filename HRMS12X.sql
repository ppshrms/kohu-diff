--------------------------------------------------------
--  DDL for Package HRMS12X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS12X" is
  --global
  global_v_coduser    varchar2(100 char);
  global_v_codpswd    varchar2(100 char);
  global_v_lang       varchar2(10 char);
  global_v_zminlvl  	  number;
  global_v_zwrklvl  	  number;
  global_v_numlvlsalst 	number;
  global_v_numlvlsalen 	number;
  v_zupdsal   			    varchar2(4 char);

  --value
  obj_row             json_object_t;
  obj_data            json_object_t;

  p_page              number;
  p_limit             number;
  param_msg_error     varchar2(4000);

  procedure get_path(json_str_input in clob, json_str_output out clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure send_email(json_str_input in clob, global_json_str in clob, json_str_output out clob);

end;

/
