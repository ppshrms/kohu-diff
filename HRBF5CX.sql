--------------------------------------------------------
--  DDL for Package HRBF5CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5CX" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4 char);

    p_codapp                varchar2(10 char) := 'HRBF5CX';
    p_codcomp               tothinc.codcomp%type;
    p_typpayroll            tothinc.typpayroll%type;
    p_numperiod             tothinc.numperiod%type;
    p_dtemthpay             tothinc.dtemthpay%type;
    p_dteyrepay             tothinc.dteyrepay%type;
    p_typloan               varchar2(1 char);
    v_chken                 varchar2(4000 char);

    procedure initial_value(json_str_input in clob);
    procedure get_index (json_str_input in clob, json_str_output out clob);
    procedure gen_index (json_str_output out clob);

end HRBF5CX;

/
