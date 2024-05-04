--------------------------------------------------------
--  DDL for Package HRBF1QX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1QX" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              JSON;

    p_codcomp               tclnsinf.codcomp%type;
    p_mthst                 INTEGER;
    p_dteyear1              INTEGER;
    p_mthen                 INTEGER;
    p_dteyear2              INTEGER;
    p_flgdocmt              tclnsinf.flgdocmt%type;

procedure get_index(json_str_input in clob, json_str_output out clob);

END HRBF1QX;


/
