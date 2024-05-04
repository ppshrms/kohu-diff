--------------------------------------------------------
--  DDL for Package HRRC3CX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC3CX" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json_object_t;

    p_codcomp               tcenter.codcomp%type;
    p_codpos                tapplinf.codpos1%type;
    p_dteapplst             tapplinf.dteappl%type;
    p_dteapplen             tapplinf.dteappl%type;
    p_numappl               tapplinf.numappl%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_drilldown(json_str_input in clob, json_str_output out clob);

    procedure get_drilldown_status(json_str_input in clob, json_str_output out clob);

END HRRC3CX;


/
