--------------------------------------------------------
--  DDL for Package HRRP2FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP2FX" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal   		    varchar2(4 char);

    b_index_codcomp         tcenter.codcomp%type;
    b_index_dteyear         tmanpwd.dteyear%type;
    b_index_comlevel        tcenter.comlevel%type;
    b_index_group           varchar2(20 char);

    procedure initial_value(json_str_input in clob);
    procedure check_index;
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure get_list_comlevel(json_str_input in clob, json_str_output out clob);
    procedure get_list_group(json_str_input in clob, json_str_output out clob);
end HRRP2FX;

/
