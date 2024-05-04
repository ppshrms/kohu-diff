--------------------------------------------------------
--  DDL for Package HRRC72X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC72X" is

  param_msg_error           varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    v_chken                 varchar2(10 char);
    json_params             json;

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal   		        varchar2(4 char);

    p_codcomp               temploy1.codcomp%type;
    p_codempid              temploy1.codempid%type;
    p_dtestrt               varchar2(100 char);
    p_dteend                varchar2(100 char);
    p_numappl               varchar2(10 char);

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure get_tapplcfm_table(json_str_input in clob, json_str_output out clob);
    procedure gen_tapplcfm_table(json_str_output out clob);
    procedure get_tapplcfm_detail(json_str_input in clob, json_str_output out clob);
    procedure gen_tapplcfm_detail(json_str_output out clob);
    procedure get_welfare(json_str_input in clob, json_str_output out clob);
    procedure gen_welfare(json_str_output out clob);

end HRRC72X;

/
