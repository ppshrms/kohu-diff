--------------------------------------------------------
--  DDL for Package HRBF4RX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF4RX" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal               varchar2(4000 char);

    p_codcomp               ttravinf.codcomp%type;
    p_numtravrq             ttravinf.numtravrq%type;
    p_dtereq_start          ttravinf.dtereq%type;
    p_dtereq_end            ttravinf.dtereq%type;
    p_dtestrt_start         ttravinf.dtestrt%type;
    p_dtestrt_end           ttravinf.dtestrt%type;
    p_codapp                ttemprpt.codapp%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_detail_attach(json_str_input in clob, json_str_output out clob);
    procedure get_detail_expense(json_str_input in clob, json_str_output out clob);
    procedure get_report(json_str_input in clob, json_str_output out clob);

END HRBF4RX;


/
