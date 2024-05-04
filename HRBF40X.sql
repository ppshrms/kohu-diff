--------------------------------------------------------
--  DDL for Package HRBF40X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF40X" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4 char);

    p_codapp                varchar2(10 char) := 'HRBF40X';
    p_codcomp               tinsdinf.codcomp%type;
    p_numisr                tinsdinf.numisr%type;
    p_dtemonth              tinsdinf.dtemonth%type;
    p_dteyear               tinsdinf.dteyear%type;
    p_typpayroll            tinsdinf.typpayroll%type;
    p_numprdpay             tinsdinf.numprdpay%type;
    p_dtemthpay             tinsdinf.dtemthpay%type;
    p_dteyrepay             tinsdinf.dteyrepay%type;

    procedure initial_value(json_str_input in clob);
    procedure get_index (json_str_input in clob, json_str_output out clob);
    procedure gen_index (json_str_output out clob);

end HRBF40X;


/
