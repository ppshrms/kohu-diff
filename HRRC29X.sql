--------------------------------------------------------
--  DDL for Package HRRC29X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC29X" is

  param_msg_error           varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    json_params             json;

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    v_zupdsal   		        varchar2(4 char);

    p_numoffid              temploy2.numoffid%type;
    p_codempid              temploy1.codempid%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure get_tbcklst_detail(json_str_input in clob, json_str_output out clob);
    procedure gen_tbcklst_detail(json_str_output out clob);
    procedure get_list_mist(json_str_input in clob, json_str_output out clob);
    procedure gen_list_mist(json_str_output out clob);
    procedure get_list_mist_all(json_str_input in clob, json_str_output out clob);
    procedure gen_list_mist_all(json_str_output out clob);

end HRRC29X;

/
