--------------------------------------------------------
--  DDL for Package HRBF5MX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5MX" AS
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

    p_codcomp               tcenter.codcomp%type;
    p_codlon                tintrted.codlon%type;

procedure get_index(json_str_input in clob, json_str_output out clob);

END HRBF5MX;


/
