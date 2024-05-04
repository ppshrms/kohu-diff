--------------------------------------------------------
--  DDL for Package HRRP69E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP69E" as 

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

  p_codapp                  varchar2(10 char) := 'HRRP69E';
  b_index_codcompy          tninebox.codcompy%type;
  b_index_dteeffec          date;
  p_dteeffec                date;
  p_isEdit                  varchar2(2 char) := 'Y';

  procedure initial_value (json_str in clob);
  procedure check_index;
  
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure copy_data(json_str_input in clob, json_str_output out clob);
  procedure popup_copy(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure get_data_box(v_codgroup in varchar2, v_codcompy in tninebox.codcompy%type, v_dteeffec in date,
                         v_namgroupt out tninebox.namgroupt%type, 
                         v_descgroup out tninebox.descgroup%type, 
                         v_statement out tninebox.statement%type, 
                         v_syncond out tninebox.syncond%type);
end hrrp69e;

/
