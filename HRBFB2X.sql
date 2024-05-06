--------------------------------------------------------
--  DDL for Package HRBFB2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFB2X" AS
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

    p_codcomp               temploy1.codcomp%type;
    p_dteyear               thealinf1.dteyear%type;
    p_dtefollowst           thealinf1.dtefollow%type;
    p_dtefollowen           thealinf1.dtefollow%type;
    p_codprgheal            thealinf1.codprgheal%type;

procedure get_index(json_str_input in clob, json_str_output out clob);

END HRBFB2X;

/
