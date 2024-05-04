--------------------------------------------------------
--  DDL for Package HRRP32X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP32X" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal   		    varchar2(4 char);

    b_index_codcompe        tcenter.codcomp%type;
    b_index_codpose         tpostn.codpos%type;

    p_codcompe              varchar2(100 char);
    p_codpose               varchar2(10 char);
    p_dteeffec              date;
    p_gen                   varchar2(10 char);

    procedure initial_value(json_str_input in clob);
    procedure check_index;
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure get_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_detail(json_str_output out clob);
    procedure get_index_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_index_detail(json_str_output out clob);
end HRRP32X;

/
