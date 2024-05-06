--------------------------------------------------------
--  DDL for Package HRBF41E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF41E" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json_object_t;
--  tab1 parameters
    p_codobf                tobfcde.codobf%type;
    p_typebf                tobfcde.typebf%type;
    p_typepay               tobfcde.typepay%type;
    p_typegroup             tobfcde.typegroup%type;
    p_namimage              tobfcde.namimage%type;
    p_desobfe               tobfcde.desobfe%type;
    p_desobft               tobfcde.desobft%type;
    p_desobf3               tobfcde.desobf3%type;
    p_desobf4               tobfcde.desobf4%type;
    p_desobf5               tobfcde.desobf5%type;
    p_codunit               tobfcde.codunit%type;
    p_amtvalue              tobfcde.amtvalue%type;
    p_codsize               tobfcde.codsize%type;
    p_descsize              tobfcde.descsize%type;
    p_desnote               tobfcde.desnote%type;
    p_flglimit              tobfcde.flglimit%type;
    p_flgfamily             tobfcde.flgfamily%type;
    p_typrelate             tobfcde.typrelate%type;
    p_dtestart              tobfcde.dtestart%type;
    p_dteend                tobfcde.dteend%type;
    p_filename              tobfcde.filename%type;
    p_syncond               tobfcde.syncond%type;
    p_statement             tobfcde.statement%type;
    p_flag                  varchar(20 char);
--  tab2 parameters
    p_tab2                  json_object_t;
    p_numobf                tobfcdet.numobf%type;
    p_syncond2              tobfcdet.syncond%type;
    p_statement2            tobfcdet.statement%type;--User37 ST11 Recode 25/06/2021
    p_qtyalw                tobfcdet.qtyalw%type;
    p_qtytalw               tobfcdet.qtytalw%type;
    p_flag2                 varchar(20 char);

  procedure get_index(json_str_input in clob, json_str_output out clob);

  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob);

  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob);

  procedure save_index(json_str_input in clob, json_str_output out clob);

  procedure save_detail(json_str_input in clob, json_str_output out clob);--User37 ST11 Recode 25/06/2021

  procedure delete_index(json_str_input in clob, json_str_output out clob);--User37 ST11 Recode 25/06/2021

END HRBF41E;

/
