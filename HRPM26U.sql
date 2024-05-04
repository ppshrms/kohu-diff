--------------------------------------------------------
--  DDL for Package HRPM26U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM26U" AS
    param_msg_error             varchar2(4000 char);
    global_v_coduser            varchar2(100 char);
    global_v_codempid           varchar2(100 char);
    global_v_lang               varchar2(10 char) := '102';

    global_v_zminlvl  	        number;
    global_v_zwrklvl  	        number;
    global_v_numlvlsalst 	    number;
    global_v_numlvlsalen 	    number;
    global_v_zupdsal 	        varchar2(100 char);

	p_codcomp		            ttrehire.codcomp%type;
	p_codmov		            ttrehire.FLGMOVE%type;
	p_dtestr		            date;
	p_dteend		            date;

	p_codempid		            ttrehire.codempid%type;
	p_codcompindex		        ttrehire.codcomp%TYPE;
	p_codempmt		            ttrehire.CODEMPMT%type;
	detail_codempid		        ttrehire.CODEMPID%type;
    userid			            tasetinf.CODCREATE%TYPE;
    v_zupdsal   		        varchar2(4 char);

	procedure initial_value (json_str in clob);

	procedure get_index (json_str_input in clob, json_str_output out clob);

	procedure gen_index (json_str_output out clob);

	procedure getUpdate (json_str_input in clob, json_str_output out clob);

	procedure get_detail (json_str_input in clob, json_str_output out clob);

	procedure gen_detail (json_str_output out clob);

END HRPM26U;

/
