--------------------------------------------------------
--  DDL for Package HRRC22R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC22R" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json_object_t;

    p_numapplst             tapplinf.numappl%type;
    p_numapplen             tapplinf.numappl%type;

    procedure get_index(json_str_input in clob,json_str_output out clob);

end HRRC22R;

/
