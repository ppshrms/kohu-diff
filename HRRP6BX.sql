--------------------------------------------------------
--  DDL for Package HRRP6BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP6BX" AS 
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
  b_index_year          number;
  p_dteeffec            date;
  p_code                ttalent.syncond%type;
  p_codgroup            tninebox.codgroup%type;
  p_codcomp             tnineboxe.codcomp%type;
  p_year                number;
  params_syncond        json_object_t;
  params_json           json_object_t;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);  
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);  
  procedure get_data_box(v_year in varchar2,v_codcomp in varchar2, v_codcompy in tninebox.codcompy%type, v_codgroup in tninebox.codgroup%type,
                         v_amountemp out varchar, 
                         v_percntemp out varchar);

END HRRP6BX;

/
