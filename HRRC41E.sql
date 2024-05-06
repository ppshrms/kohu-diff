--------------------------------------------------------
--  DDL for Package HRRC41E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC41E" AS
-- last update: 03/11/2022 18:17

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    v_chken                   varchar2(10 char);

    param_json              json_object_t;

--  get index parameter
    p_codcomp               tapplinf.codcomp%type;
    p_dteempmtst            tapplinf.dteempmt%type;
    p_dteempmten            tapplinf.dteempmt%type;
--  gen id parameter
    p_numappl               tapplinf.numappl%type;
    p_dteempmt              tapplinf.dteempmt%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_id(json_str_input in clob, json_str_output out clob);

    procedure get_html_message(json_str_input in clob, json_str_output out clob);

    procedure send_email(json_str_input in clob, json_str_output out clob);

END HRRC41E;

/
