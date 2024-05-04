--------------------------------------------------------
--  DDL for Package HRBF4ME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF4ME" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              json;

    p_codcomp               ttravinf.codcomp%type;
    p_codempid_query        ttravinf.codempid%type;
    p_dtereqstr             ttravinf.dtereq%type;
    p_dtereqend             ttravinf.dtereq%type;
    p_dtestrt               ttravinf.dtestrt%type;
    p_dteend                ttravinf.dtestrt%type;
    p_numtravrq             ttravinf.numtravrq%type;
    p_dtereq                ttravinf.dtereq%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_detail_attach(json_str_input in clob, json_str_output out clob);
    procedure get_detail_expense(json_str_input in clob, json_str_output out clob);
    procedure get_codexp(json_str_input in clob, json_str_output out clob);
    procedure get_codprov(json_str_input in clob, json_str_output out clob);
    procedure get_codcnty(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
END HRBF4ME;

/
