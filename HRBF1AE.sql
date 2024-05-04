--------------------------------------------------------
--  DDL for Package HRBF1AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1AE" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json;

    p_codprgheal            thealcde.codprgheal%type;
    p_codheal               thealcde2.codheal%type;
    p_desheale              thealcde.desheale%type;
    p_deshealt              thealcde.deshealt%type;
    p_desheal3              thealcde.desheal3%type;
    p_desheal4              thealcde.desheal4%type;
    p_desheal5              thealcde.desheal5%type;
    p_amtheal               thealcde.amtheal%type;
    p_typpgm                thealcde.typpgm%type;
    p_syncond               thealcde.syncond%type;
    p_statement             thealcde.statement%type;
    p_qtymth                thealcde.qtymth%type;
    p_flag                  varchar2(10 char);
    p_table                 json;
    p_qtysetup              thealcde2.qtysetup%type;
    p_flag2                 varchar2(10 char);


procedure get_index(json_str_input in clob,json_str_output out clob);

procedure get_detail(json_str_input in clob, json_str_output out clob);

procedure get_detail_table(json_str_input in clob, json_str_output out clob);

procedure get_thealcde2(json_str_input in clob,json_str_output out clob);

procedure save_index(json_str_input in clob, json_str_output out clob);

procedure save_delete(json_str_input in clob, json_str_output out clob);

END HRBF1AE;

/
