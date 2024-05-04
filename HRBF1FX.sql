--------------------------------------------------------
--  DDL for Package HRBF1FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1FX" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;

    v_zupdsal               varchar2(4 char);
    p_codapp                varchar2(10 char) := 'HRBF1FX';
    p_codcomp               tclnsinf.codcomp%type;
    p_dtereqst              varchar2(10 char);
    p_dtereqen              varchar2(10 char);
    p_dtecrest              varchar2(10 char);
    p_dtecreen              varchar2(10 char);
    p_typpatient            tclnsinf.typpatient%type;
    p_codcln                tclnsinf.codcln%type;
    p_typpay                tclnsinf.typpay%type;
    p_numvcher              tclnsinf.numvcher%type;
    isInsertReport          boolean := false;
    v_numseq                number;
    p_codempid_query        tclnsinf.codempid%type;

    procedure initial_value(json_str_input in clob);

    procedure get_index_withdraw (json_str_input in clob, json_str_output out clob);
    procedure gen_index_withdraw (json_str_output out clob);
    procedure get_data_withdraw (json_str_input in clob, json_str_output out clob);
    procedure gen_data_withdraw (json_str_output out clob);
    procedure get_table_withdraw (json_str_input in clob, json_str_output out clob);
    procedure gen_table_withdraw (json_str_output out clob);
    
    procedure clear_ttemprpt;
    procedure get_report(json_str_input in clob, json_str_output out clob);
END HRBF1FX;

/
