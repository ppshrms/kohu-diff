--------------------------------------------------------
--  DDL for Package HRAPSGX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAPSGX" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal   		    varchar2(4 char);
    v_chken                 varchar2(4000 char) := hcm_secur.get_v_chken;

    b_index_dteyreap        number;
    b_index_codcomp         tcenter.codcomp%type;

    procedure initial_value(json_str_input in clob);
    procedure check_index;
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure gen_graph;
end HRAPSGX;

/
