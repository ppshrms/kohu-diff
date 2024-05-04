--------------------------------------------------------
--  DDL for Package HRBF44E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF44E" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen 	number;
    v_zupdsal               varchar2(4000 char);

    p_codempid              tobfinf.codempid%type;
    p_numvcomp              tobfcomp.numvcomp%type;
    p_numvcher              tobfinf.numvcher%type;
    p_codcomp               tobfcomp.codcomp%type;
    p_codpos                tpostn.codpos%type;
    p_staemp                temploy1.staemp%type;
    p_dtestr                tobfcomp.dtereq%type;
    p_dteend                tobfcomp.dtereq%type;
    p_dteappr               tobfcomp.dteappr%type;
    p_codobf                tobfinf.codobf%type;
    p_dteempmtst            tobfcomp.dteempmtst%type;
    p_dteempmten            tobfcomp.dteempmten%type;
    p_dtereq                tobfinf.dtereq%type;
    p_flglimit              tobfcfpd.flglimit%type;
    p_qtyalw                number;
    p_amtwidrw              number;
    p_input_qtyalw          number;
    p_qtytalw               tobfcfpd.qtytalw%type;
    p_qtyemp                number;
    p_total_qtyalw          number;
    p_dteefpos              temploy1.dteefpos%type;
    p_condition             tobfcfp.syncond%type;
    p_qtyalwm               number;
    p_qtytalwm              number;
    p_qtywidrw              number;
    p_qtyempwidrw           number;
    p_numtsmit              number;
    p_qtytwidrw             number;

    param_json              json_object_t;
    param_detail            json_object_t;
    param_emp               json_object_t;
    param_send              json_object_t;

    json_obj    json_object_t;


    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_detail_table(json_str_input in clob, json_str_output out clob);
    procedure get_process(json_str_input in clob, json_str_output out clob);
    procedure get_emp(json_str_input in clob, json_str_output out clob);
    procedure check_emp(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    function benefit_secure_man return varchar2;
    function benefit_secure_comp return varchar2;

END HRBF44E;

/
