--------------------------------------------------------
--  DDL for Package HRBF4HE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF4HE" AS
--user14:24/01/2023 redmine695
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              JSON;

    p_codcomp               tobfcft.codcomp%type;
    p_dtestart              tobfcft.dtestart%type;
    p_query_codempid        tobfcft.codempid%type;
    p_codobf                tobfcde.codobf%type;
    p_codappr               tobfcft.codappr%type;
    p_dteappr               tobfcft.dteappr%type;
    p_dteend                tobfcft.dteend%type;
    p_amtalwyr              tobfcft.amtalwyr%type;
    p_sumQtymonyer          number;
    p_sumQtymony            number;
    p_flag                  varchar(10 char);
    p_table                 json;
    p_codunit               tobfcde.codunit%type;
    p_flglimit              tobfcde.flglimit%type;
    p_amtvalue              tobfcde.amtvalue%type;
    p_qtyalw                tobfcdet.qtyalw%type;
    p_qtytalw               tobfcdet.qtytalw%type;
    p_amtalw                tobfcftd.amtalw%type;
    p_flag2                 varchar(10 char);

procedure get_index(json_str_input in clob, json_str_output out clob);

procedure get_detail(json_str_input in clob, json_str_output out clob);

procedure get_detail_table(json_str_input in clob, json_str_output out clob);

procedure get_data_from_tobfcde(json_str_input in clob, json_str_output out clob);

procedure save_index(json_str_input in clob, json_str_output out clob);


END HRBF4HE;

/
