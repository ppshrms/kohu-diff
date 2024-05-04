--------------------------------------------------------
--  DDL for Package HRPMS6X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMS6X" AS

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	  number;
    global_v_zwrklvl  	  number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;

    p_choose        varchar2(10 char);
    p_condition     clob;
    p_statement     varchar2(4000 char);
    p_codcomp       varchar2(1000 char);
    p_logic         json_object_t;
    p_param_json    json_object_t;
    size_comp       number;
    size_cond       number;

    type tmp is table of varchar2(2000);
    codcomp     tmp := tmp();
    cond        tmp := tmp();
    statmt      tmp := tmp();

    procedure initial_value(json_str_input in clob);
    procedure get_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_detail(json_str_output out clob);
    procedure vadidate_variable_getindex(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);
END HRPMS6X;

/
