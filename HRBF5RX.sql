--------------------------------------------------------
--  DDL for Package HRBF5RX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5RX" AS

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4 char);

    p_codapp                varchar2(10 char) := 'HRBF5RX';
    p_codcompy              tloaninf.codcomp%type;
    p_dtelonst              varchar2(4 char);
    p_dtelonen              varchar2(4 char);
    p_typrep                varchar2(1 char);

    procedure initial_value(json_str_input in clob);

    procedure get_index_loan (json_str_input in clob, json_str_output out clob);
    procedure gen_index_loan (json_str_output out clob);

END HRBF5RX;


/
