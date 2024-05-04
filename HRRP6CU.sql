--------------------------------------------------------
--  DDL for Package HRRP6CU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP6CU" as 

  param_msg_error           varchar2(4000 char);
  param_msg_error_mail      varchar2(4000 char);
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

  p_codapp              varchar2(10 char) := 'HRRP69E';
  b_index_codcomp       tcenter.codcomp%type;
  b_index_year          varchar2(10 char);

  p_dteappr             date;
  p_dteeffec            date;
  p_codappr             varchar2(10 char);
  p_remark              varchar2(1000 char);
  params_syncond        json_object_t;
  params_json           json_object_t;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_drilldown(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure process_approve (json_str_input in clob, json_str_output out clob);
  procedure get_data_box(v_year in varchar2, v_codcompy in tninebox.codcompy%type, v_codgroup in tninebox.codgroup%type,
                         v_amountemp out varchar, 
                         v_percntemp out varchar);
end hrrp6cu;

/
