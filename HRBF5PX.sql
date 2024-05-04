--------------------------------------------------------
--  DDL for Package HRBF5PX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5PX" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4 char);

    p_codapp                varchar2(10 char) := 'HRBF5PX';
    p_codcomp               tloanadj.codcomp%type;
    p_dteadjustfr           varchar2(10 char);
    p_dteadjustto           varchar2(10 char);
    p_codlon                tloanadj.codlon%type;

    procedure initial_value(json_str_input in clob);
    procedure get_index (json_str_input in clob, json_str_output out clob);
    procedure gen_index (json_str_output out clob);

end HRBF5PX;


/
