--------------------------------------------------------
--  DDL for Package HRRC5BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC5BX" AS
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

    p_dtetrnjost            tapplinf.dtetrnjo%type;
    p_dtetrnjoen            tapplinf.dtetrnjo%type;
    p_codemprc              tapplinf.codemprc%type;
    p_codcomp               treqest2.codcomp%type;
    p_numreqst              treqest2.numreqst%type;
    p_codpos                tapplinf.codposl%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

END HRRC5BX;


/
