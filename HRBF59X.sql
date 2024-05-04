--------------------------------------------------------
--  DDL for Package HRBF59X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF59X" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4 char);

    param_json              json_object_t;

    p_dtemthst              integer;
    p_dteyrest              integer;
    p_dtemthen              integer;
    p_dteyreen              integer;

    p_codobf1               tobfcde.codobf%type;
    p_codobf2               tobfcde.codobf%type;
    p_codobf3               tobfcde.codobf%type;
    p_codobf4               tobfcde.codobf%type;
    p_codobf5               tobfcde.codobf%type;

    p_dteyrepay             tloanpay.dteyrepay%type;
    p_dtemthpay             tloanpay.dtemthpay%type;
    p_numperiod             tloanpay.numperiod%type;
    p_typpayroll            tloanpay.typpayroll%type;
    p_codcomp               tloanpay.codcomp%type;
    p_typpay                tloanpay.typpay%type;


procedure get_index(json_str_input in clob, json_str_output out clob);

END HRBF59X;

/
