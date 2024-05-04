--------------------------------------------------------
--  DDL for Package HRAL48X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL48X" as

    v_chken                 varchar2(10 char);
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal   		    varchar2(4 char);

    p_codcomp               varchar2(40 char);
    p_codempid              varchar2(10 char);
    p_dtestr                date;
    p_dteend                date;

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index(json_str_output out clob);

end HRAL48X;

/
