--------------------------------------------------------
--  DDL for Package HRBF51E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF51E" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json;

    p_codlon                ttyploan.codlon%type;
    p_deslone               ttyploan.deslone%type;
    p_deslont               ttyploan.deslont%type;
    p_deslon3               ttyploan.deslon3%type;
    p_deslon4               ttyploan.deslon4%type;
    p_deslon5               ttyploan.deslon5%type;
    p_amtmxlon              ttyploan.amtmxlon%type;
    p_ratelon               ttyploan.ratelon%type;
    p_nummxlon              ttyploan.nummxlon%type;
    p_condlon               ttyploan.condlon%type;
    p_statementl            ttyploan.statementl%type;
    p_amtasgar              ttyploan.amtasgar%type;
    p_qtygar                ttyploan.qtygar%type;
    p_condgar               ttyploan.condgar%type;
    p_statementg            ttyploan.statementg%type;
    p_amtguarntr            ttyploan.amtguarntr%type;
    p_flag                  varchar2(50 char);

procedure get_index(json_str_input in clob,json_str_output out clob);

procedure get_detail(json_str_input in clob,json_str_output out clob);

procedure save_index(json_str_input in clob,json_str_output out clob);

END HRBF51E;


/
