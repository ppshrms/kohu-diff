--------------------------------------------------------
--  DDL for Package HRBF1ZX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1ZX" AS

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;

    v_zupdsal               varchar2(4 char);
    p_codapp                varchar2(10 char) := 'HRBF1ZX';
    json_params             json;
    --index
    p_codcomp               varchar2(40 char);
    p_codcln                tclndoc.codcln%type;
    p_codempid              tclndoc.codempid%type;
    p_dtestrt               varchar2(10 char);
    p_dteend                varchar2(10 char);
    p_typamt                varchar2(4 char);
    --detail
    d_codcln                tclndoc.codcln%type;
    d_dtedocmt              varchar2(10 char);
    d_codempid              tclndoc.codempid%type;
    --relation
    p_codrel                tclndoc.codrel%type;
    p_numdocmt              tclndoc.numdocmt%type;
    -- credit
    c_typamt                varchar2(4 char);
    c_codempid              tclndoc.codempid%type;
    c_dtedocmt              varchar2(10 char);
    c_dtereq                varchar2(10 char);
    c_dtestart              varchar2(10 char);
    c_typrel                tclndoc.codrel%type;

    json_report             json;
    isInsertReport          boolean := false;

    procedure initial_value(json_str_input in clob);

    procedure get_index_docmt (json_str_input in clob, json_str_output out clob);
    procedure gen_index_docmt (json_str_output out clob);
    procedure get_detail_docmt (json_str_input in clob, json_str_output out clob);
    procedure gen_detail_docmt (json_str_output out clob);
    procedure get_relation_docmt (json_str_input in clob, json_str_output out clob);
    procedure gen_relation_docmt (json_str_output out clob);
    procedure get_credit_docmt (json_str_input in clob, json_str_output out clob);
    procedure gen_credit_docmt (json_str_output out clob);
    procedure save_data_docmt(json_str_input in clob, json_str_output out clob);
    procedure delete_index_docmt(json_str_input in clob, json_str_output out clob);

    procedure gen_report(json_str_input in clob, json_str_output out clob);
    procedure clear_ttemprpt;
    procedure insert_ttemprpt(obj_data in json);

END HRBF1ZX;

/
