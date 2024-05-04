--------------------------------------------------------
--  DDL for Package HRPM61E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM61E" is
--user37 NXP-HR2101 18/11/2021-- last update: 18/11/2021 16:58 
    global_v_coduser        varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_codempid       varchar2(100 char);
    param_msg_error         varchar2(4000 char);
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    global_v_zupdsal      varchar2(10 char);
    obj_data                json_object_t;
    obj_row                 json_object_t;
    obj_child_row           json_object_t;
    p_legalexd              json_object_t;
    param_json_row          json_object_t;
    v_chken                 varchar2(10 char);

    p_codpay                varchar2(4 char);
    p_codpay_hidden         varchar2(4 char);
    p_codcompy              tcenter.codcompy%type;
    p_numcaselw             tlegalexd.numcaselw%type;
    p_codlegald             tlegalexe.codlegald%type;
    p_namlegalb             tlegalexe.namlegalb%type;
    p_namplntiff            tlegalexe.namplntiff%type;
    p_numprdded             number;
    p_flg                   varchar2(10 char);
    p_codcomp               varchar2(100 char);
    p_codempid              varchar2(100 char);
    p_stacaselw             varchar2(1 char);
    p_dtestr                date;
    p_dteend                date;
    p_dteyrded              number;
    p_dtemthded             number;
    p_qtyperd               varchar2(100 char);
    p_amtfroze              number;
    p_amtmin                number;
    p_amtdmin               number;
    p_pctded                number;
    p_pctded_h              tlegalexe.pctded%type;
    json_codshift           json_object_t;
    json_numcaselw          json_object_t;
    isinsertreport          boolean := false;
    v_numseq                number := 0;
    numyearreport           number;
    v_codempid              tloaninf.codempid%type;
    v_zupdsal               varchar2(10 char);

    --<<user37 NXP-HR2101 18/11/2021 
    p_civillaw              tlegalexe.civillaw%type;
    p_banklaw               tlegalexe.banklaw%type;
    -->>user37 NXP-HR2101 18/11/2021 
    --<<user46 NXP-HR2101 20/12/2021 
    p_numbanklg             tlegalexe.numbanklg%type;
    p_numkeep               tlegalexe.numkeep%type;
    -->>user46 NXP-HR2101 20/12/2021 

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure initial_value(json_str in clob);
    procedure check_getindex;
    procedure gen_data(json_str_output out clob);
    procedure get_index_legal_detail(json_str_input in clob, json_str_output out clob);
    procedure get_legal_detail(json_str_output out clob);
    procedure get_index_legal_detail_sub(json_str_input in clob, json_str_output out clob);
    procedure get_legal_detail_sub(json_str_output out clob);
    procedure save_data(json_str_input in clob,json_str_output out clob);
    procedure get_json_obj(json_str_input in clob);
    procedure check_save;
    procedure save_tlegalexe;
    procedure delete_index(json_str_input in clob,json_str_output out clob);
    procedure gen_report(json_str_input in clob, json_str_output out clob);
    procedure clear_ttemprpt;
    procedure get_codpay_all(json_str_input in clob, json_str_output out clob);
end HRPM61E;

/
