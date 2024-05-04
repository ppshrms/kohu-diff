--------------------------------------------------------
--  DDL for Package HRPM1HE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM1HE" is
-- last update: 10/10/2019

    param_msg_error		    varchar2(4000 char);

	v_chken			        varchar2(10 char);
	global_v_coduser	    varchar2(100 char);
	global_v_codpswd	    varchar2(100 char);
	global_v_lang		    varchar2(10 char) := '102';
	global_v_zyear		    number := 0;
	global_v_lrunning	    varchar2(10 char);
	global_v_zminlvl	    number;
	global_v_zwrklvl	    number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	global_v_codempid	    varchar2(100 char);
	p_memono		        varchar2(100 char);
	p_dteeffec		        varchar2(100 char);
	-- save
	p_codempid		        temploy2.codempid%type;
	p_flgeffec		        tmailalert.FLGEFFEC%type;
	p_subject		        tmailalert.SUBJECT%type;
	p_message		        tmailalert.MESSAGE%type;
	p_qtydayr		        tmailalert.QTYDAYR%type;
	p_syncond		        tmailalert.SYNCOND%type;
	p_table			        varchar2(1000 char);

	g_typsubj		        varchar2(4000 char);
	g_codtable		        varchar2(4000 char);

	p_date			        varchar2(100 char);
	p_mailalno		        varchar2(100 char);
	p_pfield		        varchar2(100 char);
	p_pdesct		        varchar2(100 char);
	p_flgdesc		        varchar2(100 char);

	procedure get_index (json_str_input in clob, json_str_output out clob);

	procedure gen_index (json_str_output out clob);

	procedure getDetail (json_str_input in clob, json_str_output out clob);

	procedure genDetail (json_str_output out clob);

	procedure getTable (json_str_input in clob, json_str_output out clob);

	procedure genTable (json_str_output out clob);

	procedure post_save (json_str_input in clob, json_str_output out clob);

	procedure post_delete (json_str_input in clob, json_str_output out clob);

	procedure get_list_detail_param (json_str_input in clob, json_str_output out clob);

	procedure gen_list_detail_param(json_str_output out clob);

	procedure get_list_detail_table (json_str_input in clob, json_str_output out clob);

	procedure gen_list_detail_table(json_str_output out clob);

	procedure post_report_format (json_str_input in clob, json_str_output out clob);

	procedure post_send_mail (json_str_input in clob, json_str_output out clob);

	procedure post_test_syntax (json_str_input in clob, json_str_output out clob);

	procedure post_delete_report_format (json_str_input in clob, json_str_output out clob);

	procedure get_people (json_str_input in clob, json_str_output out clob);

	procedure gen_people (json_str_output out clob);

	procedure get_table (json_str_input in clob, json_str_output out clob);

	procedure gen_table (json_str_output out clob);

	procedure post_save_people (json_str_input in clob, json_str_output out clob);

	procedure post_report_error (json_str_input in clob, json_str_output out clob);

  function get_clob(str_json in clob, key_json in varchar2) RETURN CLOB ;

  function esc_json(message in clob)return clob;

  function append_clob_json (v_original_json in json_object_t, v_key in varchar2 , v_value in clob  ) return json_object_t;

end HRPM1HE ;

/
