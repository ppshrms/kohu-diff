--------------------------------------------------------
--  DDL for Package HRBFA3E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFA3E" AS
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
    param_detail            json_object_t;

    p_dteyear               thealinf.dteyear%type;
    p_codcomp               thealinf.codcomp%type;
    p_codprgheal            thealinf.codprgheal%type;
    p_codempid_query        thealinf1.codempid%type;

    p_codcln                thealinf1.codcln%type;
    p_dteheal               thealinf1.dteheal%type;
    p_namdoc                thealinf1.namdoc%type;
    p_numcert               thealinf1.numcert%type;
    p_namdoc2               thealinf1.namdoc2%type;
    p_numcert2              thealinf1.numcert2%type;
    p_descheal              thealinf1.descheal%type;
    p_dtefollow             thealinf1.dtefollow%type;
    p_amtheal               thealinf1.amtheal%type;
    p_flag                  varchar2(10 char);
--  list heal parameters
    p_list_codheal          json_object_t;
    p_codheal               thealinf2.codheal%type;
    p_descheck              thealinf2.descheck%type;
    p_chkresult             thealinf2.chkresult%type;
    p_descheal2             thealinf2.descheal%type;
    p_flag2                 varchar2(10 char);

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_index_table(json_str_input in clob, json_str_output out clob);

    procedure get_detail(json_str_input in clob, json_str_output out clob);

    procedure get_detail_table(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);
    
    procedure save_detail(json_str_input in clob, json_str_output out clob);

    procedure get_codheal(json_str_input in clob, json_str_output out clob);

END HRBFA3E;

/
