--------------------------------------------------------
--  DDL for Package HRPMATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMATE" is

  param_msg_error		    varchar2(4000 char);

	v_chken			        varchar2(10 char);
	global_v_coduser	    varchar2(100 char);
	global_v_codpswd	    varchar2(100 char);
	global_v_codempid	    varchar2(100 char);
	global_v_lang		    varchar2(10 char) := '102';
	global_v_zyear		    number := 0;
	global_v_lrunning	    varchar2(10 char);
	global_v_zminlvl	    number;
	global_v_zwrklvl	    number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	global_v_zupdsal	    number;

    p_codcompy              tpmalert.codcompy%type;
	p_mailalno		        tpmalert.mailalno%type;
	p_dteeffec		        tpmalert.dteeffec%type;
    p_typsubj               varchar2(100 char);
	g_typsubj		        varchar2(100 char);
	g_mailalno		        tpmalert.mailalno%type;
	g_dteeffec		        varchar2(100 char);

    p_syncond		        tpmalert.syncond%type;
	p_table			        varchar2(4000 char);

	p_codtable		        tcoldesc.codtable%type;

	p_date			        varchar2(100 char);
	p_message		        tpmalert.message%type;
	p_subject		        tpmalert.subject%type;

	procedure initial_value (json_str in clob);

	procedure get_index(json_str_input in clob, json_str_output out clob);
	procedure gen_index(json_str_output out clob);

	procedure getDetail(json_str_input in clob, json_str_output out clob);
	procedure genDetail(json_str_output out clob);    

	procedure getDestroy(json_str_input in clob, json_str_output out clob);

	procedure saveData(json_str_input in clob, json_str_output out clob);

	procedure post_save_new_holiday (json_str_input in clob, json_str_output out clob);
	procedure get_holiday (json_str_input in clob, json_str_output out clob);
	procedure post_delete_holiday (json_str_input in clob, json_str_output out clob);

	procedure post_report_format (json_str_input in clob, json_str_output out clob);
	procedure post_delete_report_format (json_str_input in clob, json_str_output out clob);

	procedure get_define_reciver (json_str_input in clob, json_str_output out clob);
	procedure gen_define_reciver (json_str_output out clob);

	procedure get_list_detail_param (json_str_input in clob, json_str_output out clob);
	procedure gen_list_detail_param(json_str_output out clob);

	procedure get_list_detail_table (json_str_input in clob, json_str_output out clob);
	procedure gen_list_detail_table(json_str_output out clob);

	procedure post_send_mail (json_str_input in clob, json_str_output out clob);

    procedure post_test_syntax (json_str_input in clob, json_str_output out clob);

    function get_seqno (v_codcompy varchar2, v_mailalno varchar2, v_dteeffec date) return number;

	procedure getParams(json_str_input in clob, json_str_output out clob);
	procedure genParams(json_str_output out clob);        
	procedure getAssign(json_str_input in clob, json_str_output out clob);
	procedure genAssign(json_str_output out clob);         
	procedure getBirthdayCard(json_str_input in clob, json_str_output out clob);
	procedure genBirthdayCard(json_str_output out clob);        
end HRPMATE;

/
