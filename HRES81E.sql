--------------------------------------------------------
--  DDL for Package HRES81E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES81E" as 

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              json_object_t;
    obj_ttravreq            json_object_t;
    obj_tcontrbf            json_object_t;

    p_codempid              ttravreq.codempid%type;
    p_dtereq                ttravreq.dtereq%type;
    p_numseq                ttravreq.numseq%type;
    p_dtereq_start          ttravreq.dtereq%type;
    p_dtereq_end            ttravreq.dtereq%type;
    p_dtestrt_start         ttravreq.dtestrt%type;
    p_dtestrt_end           ttravreq.dtestrt%type;
    p_codprov               ttravreq.codprov%type;
    p_codcnty               ttravreq.codcnty%type;
    p_codexp                ttravexp.codexp%type;
    p_staappr	    ttravreq.staappr%type;
    p_typetrav	  ttravreq.typetrav%type;
    p_location	  ttravreq.location%type;
    p_timstrt	    ttravreq.timstrt%type;
    p_timend	    ttravreq.timend%type;
    p_qtyday	    ttravreq.qtyday%type;
    p_qtydistance	ttravreq.qtydistance%type;
    p_remark	    ttravreq.remark%type;
    p_typepay	    ttravreq.typepay%type;
    --
    p_numtravrq             ttravinf.numtravrq%type;
    p_codcomp               ttravinf.codcomp%type;
    --
    p_approvno    ttravreq.approvno%type;
    p_routeno     ttravreq.routeno%type;
    p_codappr     ttravreq.codappr%type;
    p_dteappr     ttravreq.dteappr%type;
    p_remarkap    ttravreq.remarkap%type;
    --
    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_detail_attach(json_str_input in clob, json_str_output out clob);
    procedure get_detail_expense(json_str_input in clob, json_str_output out clob);
    procedure get_codexp(json_str_input in clob, json_str_output out clob);
    procedure get_codprov(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
end hres81e;

/
