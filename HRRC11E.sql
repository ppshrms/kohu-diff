--------------------------------------------------------
--  DDL for Package HRRC11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC11E" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);
    v_chken                 varchar2(10 char);

--get index parameter
    p_codcomp               tcenter.codcomp%type;
    p_dtereqst              treqest1.dtereq%type;
    p_dtereqen              treqest1.dtereq%type;
    p_codemprc              treqest1.codemprc%type;
    p_stareq                treqest1.stareq%type;
--get detail paramters
    p_numreqst              treqest1.numreqst%type;
    p_numreqstCopy          treqest1.numreqst%type;
    p_codpos                treqest2.codpos%type;

    param_json              json_object_t;

    p_codjob                treqest2.codjob%type;

    p_flgrecut              varchar(20 char);

    p_flag                  varchar(20 char);
    p_status                tapplinf.statappl%type;

    v_treqest1              treqest1%rowtype;
    v_treqest2              treqest2%rowtype;

    p_tab1                  json_object_t;
    p_tab2                  json_object_t;
    p_tab2_sub              json_object_t;

    isAdd                   boolean;
    isEdit                  boolean;
    isCopy                  varchar2(1);

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure get_detail(json_str_input in clob,json_str_output out clob);
    procedure get_detailtab2_sub(json_str_input in clob,json_str_output out clob);

    procedure save_index(json_str_input in clob,json_str_output out clob);
    procedure get_copy_list(json_str_input in clob,json_str_output out clob);

    procedure get_codjob_syncond(json_str_input in clob,json_str_output out clob);
    function qtyappl(p_numreqst varchar2, p_codpos varchar2, p_flgrecut varchar2) return number;
    procedure get_qtyappl(json_str_input in clob,json_str_output out clob);
    procedure get_drilldown_qtyappl(json_str_input in clob,json_str_output out clob);
    procedure get_drilldown_qtyappl_popup(json_str_input in clob,json_str_output out clob);
    procedure get_drilldown_qtyact(json_str_input in clob,json_str_output out clob);

    procedure save_detail(json_str_input in clob,json_str_output out clob);

END HRRC11E;

/
