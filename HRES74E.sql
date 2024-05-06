--------------------------------------------------------
--  DDL for Package HRES74E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES74E" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    p_query_codempid        temploy1.codempid%type;
    p_dtereqst              tobfreq.dtereq%type;
    p_dtereqen              tobfreq.dtereq%type;
    p_numseq                tobfreq.numseq%type;
    p_dtereq                tobfreq.dtereq%type;
    p_codrel                varchar2(10 char);
    p_flg                   varchar2(10 char);

    p_numvcher              tobfinf.numvcher%type;
    p_codobf                tobfcde.codobf%type;
    p_amtvalue              tobfcde.amtvalue%type;
    p_codcomp               temploy1.codcomp%type;
    p_typrelate             tobfcde.typrelate%type;
    p_nameobf               tobfreq.nameobf%type;
    p_numtsmit              tobfreq.numtsmit%type;
    p_qtywidrw              tobfreq.qtywidrw%type;
    p_amtwidrw              tobfreq.amtwidrw%type;
    p_typepay               tobfreq.typepay%type;
    p_codempid              tobfreq.codempid%type;
    p_desnote               tobfreq.desnote%type;
    p_typebf                tobfcde.typebf%type;

    p_list_file             json_object_t;
    param_detail            json_object_t;
    param_json              json_object_t;
    p_filename              tobfreqf.filename%type;
    p_descattch             tobfreqf.descfile%type;

    --
    p_approvno    tobfreq.approvno%type;
    p_routeno     tobfreq.routeno%type;
    p_staappr     tobfreq.staappr%type;
    p_codappr     tobfreq.codappr%type;
    p_dteappr     tobfreq.dteappr%type;
    p_remarkap    tobfreq.remarkap%type;
    --
    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_detail_table(json_str_input in clob, json_str_output out clob);
    procedure get_relation(json_str_input in clob, json_str_output out clob);
    procedure get_tobfcde(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    function benefit_secure return varchar2;

end hres74e;

/
