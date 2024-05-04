--------------------------------------------------------
--  DDL for Package HRTR69E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR69E" AS
    param_msg_error       varchar2(4000 char);
    global_v_coduser      varchar2(100 char);
    global_v_codempid     varchar2(100 char);
    global_v_lang         varchar2(100 char) := '102';

    param_json            json_object_t;

    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst  number;
    global_v_numlvlsalen  number;
    v_zupdsal             varchar2(4000 char);

    p_dteyear             varchar2(500 char);
    p_codcompy            varchar2(500 char);
    p_codcours            varchar2(500 char);
    p_numclseq            tpotentp.numclseq%type;
    p_dtetrain            tpotentpd.dtetrain%type;
    p_dtetrain2           tpotentpd.dtetrain%type;
    p_codempid            varchar2(500 char);
    p_codcomp             varchar2(500 char);
    p_codpos              varchar2(500 char);
    p_status              varchar2(500 char);
    p_flgatend            varchar2(500 char);
    p_staemptr            varchar2(500 char);
    p_stacours            varchar2(500 char);

    v_item_flgedit        varchar2(100 char);
    p_remark              long;
    p_timin1              varchar2(500 char);
    p_timin2              varchar2(500 char);
    p_qtytrabs            tpotentpd.qtytrabs%type;
    v_error               varchar2(100 char);
    v_coderror            terrorm.errorno%type;
    v_error_colume        varchar2(100 char);
    p_dtetrain_text       varchar2(500 char) := null;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_employee(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure import_data_process(json_str_input in clob, json_str_output out clob);

END HRTR69E;

/
