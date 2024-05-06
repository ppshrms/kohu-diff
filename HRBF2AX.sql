--------------------------------------------------------
--  DDL for Package HRBF2AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF2AX" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4 char);

    p_codapp                varchar2(10 char) := 'HRBF2AX';
    p_dteyear               number;
    p_codcomp               tcenter.codcomp%type;
    p_codempid              temploy1.codempid%type;
    p_dtestrt               varchar2(10 char);
    p_dteend                varchar2(10 char);

    procedure initial_value(json_str_input in clob);
    procedure get_header(json_str_input in clob, json_str_output out clob);
    procedure gen_header(json_str_output out clob);
    procedure get_table(json_str_input in clob, json_str_output out clob);
    procedure gen_table(json_str_output out clob);

end HRBF2AX;

/
