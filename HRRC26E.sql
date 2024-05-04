--------------------------------------------------------
--  DDL for Package HRRC26E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC26E" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json_object_t;
--  get detail paramter
    p_codcomp               tapplinf.codcomp%type;
    p_codpos                tapplinf.codpos1%type;
    p_dteapplst             tapplinf.dteappl%type;
    p_dteapplen             tapplinf.dteappl%type;
    p_statappl              tapplinf.statappl%type;
    p_syncond               tposcond.syncond%type;
    p_list_syncond          json_object_t;
--  save index parameter
    p_numreqst              treqest2.numreqst%type;
    p_qtyscore              tapplinf.qtyscore%type;
    p_numappl               tapplinf.numappl%type;

    procedure get_detail(json_str_input in clob, json_str_output out clob);

    procedure get_index_syncond(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure send_email(json_str_input in clob, json_str_output out clob);

END HRRC26E;

/
