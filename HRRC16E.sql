--------------------------------------------------------
--  DDL for Package HRRC16E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC16E" AS
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

--  get index parameter
    p_codcomp               tapplinf.codcomp%type;
    p_numreqst              treqest1.numreqst%type;
    p_codpos                treqest2.codpos%type;
    p_syncond               treqest2.syncond%type;
--  get drilldown parameter
    p_query_codempid        temploy1.codempid%type;
--  save index parameter
    p_dtereq                tappeinf.dtereq%type;
    p_typelogical           varchar2(1 char);
    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_drilldown(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure send_email(json_str_input in clob, json_str_output out clob);

    procedure get_index_syncond(json_str_input in clob, json_str_output out clob);

    procedure get_index_codbrlc(json_str_input in clob, json_str_output out clob);

END HRRC16E;

/
