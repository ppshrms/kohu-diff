--------------------------------------------------------
--  DDL for Package HRRC1JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC1JE" AS
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
    p_numreqst              treqest1.numreqst%type;
    p_codpos                treqest2.codpos%type;
--  save index parameter
    p_query_codempid        tappeinf.codempid%type;
    p_dtereq                tappeinf.dtereq%type;
    p_codappchse            treqest1.codappchse%type;
    p_codtran               tappeinf.codtran%type;
    p_dteeffec              tappeinf.dteeffec%type;
    p_staappr               tappeinf.staappr%type;
    p_codconfrm             tappeinf.codconfrm%type;
    p_dteconfrm             tappeinf.dteconfrm%type;
    p_flgduepr              tappeinf.flgduepr%type;
    p_qtyduepr              tappeinf.qtyduepr%type;
    p_desnote               tappeinf.desnote%type;
    p_codcompe              tappeinf.codcompe%type;
--  parameter from drilldown tab2
    p_codjob                treqest2.codjob%type;
    p_codempmt              treqest2.codempmt%type;
    p_codbrlc               treqest2.codbrlc%type;
    p_mailto                varchar2(100 char);

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_drilldown_tab1(json_str_input in clob, json_str_output out clob);

    procedure get_drilldown_tab2(json_str_input in clob, json_str_output out clob);

    procedure get_mail_to(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

END HRRC1JE;



/
