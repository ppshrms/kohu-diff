--------------------------------------------------------
--  DDL for Package HRRC14X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC14X" AS
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
    param_json_numreqst     json_object_t;
--  get_index parameter
    p_codcomp               treqest1.codcomp%type;
    p_dtereqst              treqest1.dtereq%type;
    p_dtereqen              treqest1.dtereq%type;
    p_codemprc              treqest1.codemprc%type;
    p_stareq                treqest1.stareq%type;
--  get_drilldown parameter
    p_numreqst              treqest1.numreqst%type;
    p_codpos                treqest2.codpos%type;
    p_codapp                ttemprpt.codapp%type;
    p_index_rows            json_object_t;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_drilldown_tab1(json_str_input in clob, json_str_output out clob);

    procedure get_drilldown_tab2(json_str_input in clob, json_str_output out clob);

    procedure get_report(json_str_input in clob, json_str_output out clob);

END HRRC14X;

/
