--------------------------------------------------------
--  DDL for Package HRAL4EX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL4EX" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    global_v_chken          varchar2(4000 char);
    v_zupdsal   		        varchar2(4 char);
    p_codcomp               varchar2(4000 char);
    p_dtestr                date;
    p_dteend                date;

    -- special
    v_text_key                varchar2(100 char);
    v_rateot_length           number := 4;

    function get_ot_col (v_codcompy varchar2) return json_object_t;
    procedure initial_value(json_str_input in clob);
    procedure check_index;
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);

    procedure get_header(json_str_input in clob,json_str_output out clob);
    procedure gen_header (json_str_output out clob);

    function  convert_minute_to_hour(p_minute in number) return varchar2;--User37 Final Test Phase 1 V11 14/10/2020  
end HRAL4EX;

/
