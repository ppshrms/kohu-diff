--------------------------------------------------------
--  DDL for Package HRRC48X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC48X" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              json_object_t;

    p_codcomp               treqest1.codcomp%type;
    p_codemprc              treqest1.codemprc%type;
    p_dteempmtst            tapplinf.dteempmt%type;
    p_dteempmten            tapplinf.dteempmt%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure send_email(json_str_input in clob, json_str_output out clob);

END HRRC48X;

/
