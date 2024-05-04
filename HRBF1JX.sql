--------------------------------------------------------
--  DDL for Package HRBF1JX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1JX" AS
    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    p_codcln            tclnsinf.codcln%type;
    p_codcomp           tclnsinf.codcomp%type;
    p_flgdocmt          tclnsinf.FLGDOCMT%type;
    p_numpaymt_st       tclnsinf.numpaymt%type;
    p_numpaymt_en       tclnsinf.numpaymt%type;
    p_dtecrest          tclnsinf.dtecrest%type;
    p_dtecreen          tclnsinf.dtecreen%type;
    p_dtereq_st         tclnsinf.dtereq%type;
    p_dtereq_en         tclnsinf.dtereq%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

END HRBF1JX;

/
