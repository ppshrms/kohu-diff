--------------------------------------------------------
--  DDL for Package HRRP6AB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP6AB" as 
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

  p_year                    number;
  p_codcomp                 tcenter.codcomp%type;         
  p_dteeffec                date;
  p_codselect               temploy1.codempid%type;
  p_codcompy                tninebox.codcompy%type;
  p_codgroup                tninebox.codgroup%type;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail1(json_str_input in clob, json_str_output out clob);
  procedure post_process(json_str_input in clob, json_str_output out clob);
  procedure gen_emp9box(p_codcomp varchar, p_dteyear number, p_dteappr date, p_codappr varchar);
  procedure get_after_process(json_str_input in clob, json_str_output out clob);
end hrrp6ab;

/
