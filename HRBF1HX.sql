--------------------------------------------------------
--  DDL for Package HRBF1HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1HX" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4 char);

    p_codapp                varchar2(10 char) := 'HRBF1HX';
    p_codcomp               taccmexp.codcomp%type;
    p_syncond               varchar2(4000 char);
    p_dteyear               number;
    p_dtemonthfr            varchar2(2 char);
    p_dteyearfr             number;
    p_dtemonthto            varchar2(2 char);
    p_dteyearto             number;
    p_typamt                taccmexp.codcomp%type;

    procedure initial_value(json_str_input in clob);
    procedure get_index (json_str_input in clob, json_str_output out clob);
    procedure gen_index (json_str_output out clob);

end HRBF1HX;


/
