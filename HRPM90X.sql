--------------------------------------------------------
--  DDL for Package HRPM90X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM90X" is

	param_msg_error		    varchar2(4000 char);

	v_chken			          varchar2(10 char);
	global_v_coduser	    varchar2(100 char);
	global_v_codpswd	    varchar2(100 char);
	global_v_codempid	    varchar2(100 char);
	global_v_lang		      varchar2(10 char) := '102';
	global_v_zyear		    number := 0;
	global_v_zminlvl	    number;
	global_v_zwrklvl	    number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	v_zupdsal		          varchar2(10 char);
  numYearReport         number;

	pa_codcomp		ttrehire.CODCOMP%type;
	pa_codempid		ttrehire.CODEMPID%type;
	pa_typmove		ttrehire.CODEMPID%type;
	pa_dtestr		  date;
	pa_dteend		  date;

  v_codempid		tloaninf.codempid%type;
	v_dteeff		  varchar2(100 char);
  str_dteeff    date;
	-- tab 8
	v_dteyrepay		varchar2(100 char);
	v_dtemthpay		varchar2(100 char);
	v_numperiod		varchar2(100 char);

	json_codshift	    json_object_t;
  json_dteeff		    json_object_t;
	isInsertReport		boolean := false;
	v_numseq		      number := 0;

	procedure initial_value (json_str in clob);
	procedure get_index(json_str_input in clob, json_str_output out clob);
	procedure gen_index(json_str_output out clob);
	procedure gen_report(json_str_input in clob, json_str_output out clob);
	procedure clear_ttemprpt;

end HRPM90X;

/
