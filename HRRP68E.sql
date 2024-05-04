--------------------------------------------------------
--  DDL for Package HRRP68E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP68E" as
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

  p_codapp              varchar2(10 char) := 'HRRP1IE';
  b_index_codempid      temploy1.codempid%type;
  b_index_codcomp       ttalent.codcomp%type;
  b_index_dteselect     date;
  b_index_codselect     temploy1.codempid%type;
  p_code                ttalent.syncond%type;
  params_syncond        json_object_t;
  params_json           json_object_t;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_detail_data(json_str_input in clob, json_str_output out clob);
  procedure get_detail_table(json_str_input in clob, json_str_output out clob);
  procedure get_detail_codemp(json_str_input in clob, json_str_output out clob);
  procedure get_list_codemp(json_str_input in clob, json_str_output out clob);
  procedure delete_detail(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure send_mail (json_str_input in clob, json_str_output out clob);
end hrrp68e;

/
