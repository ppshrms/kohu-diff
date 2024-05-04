--------------------------------------------------------
--  DDL for Package HRAL4JX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL4JX" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char);

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal   		    varchar2(4 char);

    p_codcomp               varchar2(4000 char);
    p_codcalen              varchar2(4000 char);
    p_dte                   date;
    p_timstr                varchar2(4000 char);
    p_timend                varchar2(4000 char);
    p_timstr2               varchar2(4000 char);
    p_timend2               varchar2(4000 char);
    p_timstr3               varchar2(4000 char);
    p_timend3               varchar2(4000 char);

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index(json_str_output out clob);
    function get_ot_date (p_codempid varchar2,p_dtewkreq date,p_typot varchar2,p_dteend date,p_timend varchar2,p_qtyminr number) return date;
end HRAL4JX;

/
