--------------------------------------------------------
--  DDL for Package HRRC2HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC2HX" is

  param_msg_error           varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    json_params             json;

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal   		        varchar2(4 char);

    p_codcomp               temploy1.codcomp%type;
    p_dtestrt               varchar2(100 char);
    p_dteend                varchar2(100 char);
    p_codcomp_record        temploy1.codcomp%type;
    p_codpos_record         temploy1.codpos%type;
    p_numlvl_record   		  varchar2(4 char);

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure gen_detail(json_str_output out clob);

end HRRC2HX;


/
