--------------------------------------------------------
--  DDL for Package HRPM88X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM88X" is
    param_msg_error		    varchar2(4000 char);
	global_v_coduser	    varchar2(100 char);
	global_v_codpswd	    varchar2(100 char);
    global_v_codempid       varchar2(100 char);
	global_v_lang		    varchar2(10 char) := '102';
	global_v_zyear		    number := 0;
	global_v_lrunning	    varchar2(10 char);
	global_v_zminlvl	    number;
	global_v_zwrklvl	    number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	global_v_zupdsal	    number;
	global_v_chken		    varchar2(10 char) := hcm_secur.get_v_chken;
	v_zupdsal		        varchar2(10 char);
	p_codempid		        varchar2(100 char);
	p_codempid_query		thismist.codempid%type;
	startdate		        number;
	enddate			        number;
	p_startdate		        number;
	p_enddate			    number;
    numyearreport           number;

  procedure initial_value (json_str in clob);

  procedure getDetail(json_str_input in clob, json_str_output out clob);

  procedure genDetail(json_str_output out clob);

  procedure getIndex(json_str_input in clob, json_str_output out clob);

  procedure genIndex(json_str_output out clob);

  procedure get_insert_report(json_str_input in clob, json_str_output out clob);

  procedure gen_insert_report;

  procedure vadidate_variable_getindex(json_str_input in clob);
END HRPM88X;

/
