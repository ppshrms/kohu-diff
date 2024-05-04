--------------------------------------------------------
--  DDL for Package HRRC5GE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC5GE" AS
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
    p_codcomp               treqest2.codcomp%type;
    p_codcompe               treqest2.codcomp%type;
    p_numreqst              treqest1.numreqst%type;
    p_numreqst_emp              treqest1.numreqst%type;
    p_codpos                treqest2.codpos%type;
    p_codpose                treqest2.codpos%type;
--  save index parameter
    p_query_codempid        temploy1.codempid%type;
    p_dtereq                tappeinf.dtereq%type;
    p_dteappoi              tappeinf.dteappoi%type;
    p_codempts              tappeinf.codempts%type;
    p_numscore              tappeinf.numscore%type;
    p_perscore              tappeinf.perscore%type;
    p_codasapl              tappeinf.codasapl%type;
    p_dtestrt               tappeinf.dtestrt%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure send_email(json_str_input in clob, json_str_output out clob);

END HRRC5GE;

/
