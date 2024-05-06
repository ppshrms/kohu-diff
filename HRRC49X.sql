--------------------------------------------------------
--  DDL for Package HRRC49X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC49X" AS
    param_msg_error         varchar2(4000 char);
	v_chken			          varchar2(10 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

	global_v_codpswd	    varchar2(100 char);
    global_v_zyear		    number := 0;

    param_json              json_object_t;

    p_codcomp               tapplinf.codcomp%type;
    p_codpos                tapplinf.codposc%type;
    p_dteempmtst            tapplinf.dteempmt%type;
    p_dteempmten            tapplinf.dteempmt%type;

    p_codform               tfmrefr2.codform%type;
    p_dteprint              tapplinf.dteempmt%type;

    obj_data		          json_object_t;
    obj_row			          json_object_t;
    p_codempid_list		    json_object_t;
    param_json_row		    json_object_t;
    p_resultfparam        json_object_t;
    p_details             json_object_t;

    p_detail_obj	            json_object_t;
	p_dataSelectedObj	        json_object_t;
	p_dateprint_str		        varchar2(10 char);
	p_dateprint_date	        date;
	p_url		          varchar2(1000 char);
    type arr_1d is table of varchar2(4000 char) index by binary_integer;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);

    procedure get_probation_form(json_str_input in clob, json_str_output out clob);
    procedure get_html_message(json_str_input in clob, json_str_output out clob);

    procedure printreport(json_str_input in clob, json_str_output out clob);

END HRRC49X;

/
