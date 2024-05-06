--------------------------------------------------------
--  DDL for Package PY_TINEXINF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "PY_TINEXINF" AS 

  /* TODO enter package declarations (types, exceptions, methods etc) here */

    param_msg_error VARCHAR2(4000 CHAR);
    global_v_coduser VARCHAR2(100 CHAR);
    global_v_codpswd VARCHAR2(100 CHAR);
    global_v_lang VARCHAR2(10 CHAR) := '102';
    global_v_codempid VARCHAR2(100 CHAR);
    global_v_type_year VARCHAR2(2 CHAR);    
    p_codcomp VARCHAR2(4000 CHAR);

    TYPE data_error IS
        TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

    p_text data_error;
    p_error_code data_error;
    p_numseq data_error;
    v_codcomp VARCHAR2(100 CHAR);
    v_msgerror VARCHAR2(4000 CHAR);
    v_numseq_tmp NUMBER;      

    /*
    FUNCTION check_date (
        p_date  IN VARCHAR2,
        p_zyear IN NUMBER
    ) RETURN BOOLEAN;
    */


    FUNCTION get_result (
        v_rec_tran   IN NUMBER,
        v_rec_err    IN NUMBER
    ) RETURN CLOB;     

    PROCEDURE validate_excel_py_taccodb (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    );

    PROCEDURE validate_excel_py_tempinc (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    );

    PROCEDURE validate_excel_py_tcoscent (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    );

    PROCEDURE validate_excel_py_tpfmemb (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    );

    PROCEDURE validate_excel_py_tinexinf (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    );

    PROCEDURE validate_excel_py_tempded (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    );

    PROCEDURE validate_excel_py_tempded_sp (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    );

    /*
    PROCEDURE validate_excel_py_tsincexp (
        json_str_input IN CLOB,
        v_rec_tran     OUT NUMBER,
        v_rec_error    OUT NUMBER
    );
    */
    PROCEDURE get_process_py_tpfmemb (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    );

    PROCEDURE get_process_py_tinexinf (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    );

    PROCEDURE get_process_py_tempinc (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    );

     PROCEDURE get_process_py_tcoscent (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    );

    PROCEDURE get_process_py_taccodb (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    );

    PROCEDURE get_process_py_tempded (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    );

    PROCEDURE get_process_py_tempded_sp (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    );

     PROCEDURE get_process_py_tsincexp (
        json_str_input  IN CLOB,
        json_str_output OUT CLOB
    );

END py_tinexinf;

/
