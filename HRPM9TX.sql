--------------------------------------------------------
--  DDL for Package HRPM9TX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM9TX" is

  global_v_coduser	varchar2(100 char);
	global_v_zyear		varchar2(100 char);
	global_chken		varchar2(100 char);
	global_v_lang		varchar2(10 char) := '102';
	param_msg_error		varchar2(4000 char);
	global_v_zminlvl	number;
	global_v_zwrklvl	number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	obj_data		json_object_t;
	obj_row			json_object_t;

	p_codcomp		varchar2(100 char);
	p_typedit		varchar2(100 char);
	p_dteedit_st		date;
	p_dteedit_en		date;

	procedure get_index(json_str_input in clob, json_str_output out clob);

	procedure initial_value(json_str in clob);

	procedure check_getindex;

	procedure gen_data(json_str_output out clob);

	function checkNull(str in varchar2) RETURN varchar2 ;

	function get_description(p_table in varchar2,p_field in varchar2,p_code in varchar2) RETURN VARCHAR2;

    function get_date(p_date in varchar2) RETURN VARCHAR2;
end HRPM9TX;

/
