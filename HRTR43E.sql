--------------------------------------------------------
--  DDL for Package HRTR43E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR43E" AS
--01/08/2022
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';
    global_v_zyear          number := 0;
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json          json_object_t;

    p_codcate           tyrtrsch.codcate%type;
    p_dteyear           tyrtrsch.dteyear%type;
    p_codcompy          tyrtrsch.codcompy%type;
    p_numclseq          tyrtrsch.numclseq%type;
    p_codcours          tyrtrsch.codcours%type;
    p_codempid          temploy1.codempid%type;
    p_dtetrst           tpotentp.dtetrst%type;
    p_dtetren           tpotentp.dtetren%type;
    p_stacours          tpotentp.stacours%type;
    p_flgwait           tpotentp.flgwait%type;
    p_dteappr           tpotentp.dteappr%type;
    p_codappr           tpotentp.codappr%type;
    p_status            tpotentp.staappr%type;
    p_flgqlify          tpotentp.flgqlify%type;
    p_flgattend         tpotentp.flgatend%type;
    v_count             number;
    p_remark            tpotentp.remarkap%type;
    v_item_flgedit      varchar2(100 char);
    p_dteregis          tpotentp.dteregis%type;
    p_remarkap          tpotentp.remarkap%type;
    p_stappr            tpotentp.staappr%type;

    p_signature         temploy1.codempid%type;
    p_flgsendmail            varchar2(5 char);

    p_count_empappr     number;

    p_dteyearn          tpotentp.dteyearn%type;
    p_dteyearo          tpotentp.dteyear%type;
    p_numclsn           tpotentp.numclsn%type;
    p_numclseqo         tpotentp.numclseq%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_data_from_approv(json_str_input in clob, json_str_output out clob);
    procedure save_approve(json_str_input in clob, json_str_output out clob);
    procedure save_data(json_str_input in clob, json_str_output out clob);
    procedure get_send_mail(json_str_input in clob, json_str_output out clob);
    procedure get_employee(json_str_input in clob, json_str_output out clob);

END HRTR43E;

/
