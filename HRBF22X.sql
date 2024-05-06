--------------------------------------------------------
--  DDL for Package HRBF22X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF22X" AS
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

    p_query_codempid        temploy1.codempid%type;
    p_dteacd                thwccase.dteacd%type;
    p_dtesmit               thwccase.dtesmit%type;
    v_codapp                varchar2(100 char);

procedure get_report(json_str_input in clob,json_str_output out clob);

END HRBF22X;

/
