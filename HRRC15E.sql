--------------------------------------------------------
--  DDL for Package HRRC15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC15E" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json_object_t;

    p_codcomp               treqest2.codcomp%type;
    p_codpos                treqest2.codpos%type;
    p_numreqst              treqest2.numreqst%type;
    p_codbrlc               treqest2.codbrlc%type;

    p_numappl               tapplinf.numappl%type;

    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure get_detail(json_str_input in clob,json_str_output out clob);
    procedure save_detail(json_str_input in clob,json_str_output out clob);
    procedure send_email(json_str_input in clob,json_str_output out clob);

end HRRC15E;

/
