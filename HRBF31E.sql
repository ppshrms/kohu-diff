--------------------------------------------------------
--  DDL for Package HRBF31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF31E" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json_object_t;
    param_json2              json_object_t;

    p_flag                  varchar2(50 char);
    p_flgDelete             boolean;
    p_codcompy              tcenter.codcompy%type;
    p_codcompyCopy          tcenter.codcompy%type;
    p_numisr                tisrinf.numisr%type;
    p_numisrCopy            tisrinf.numisr%type;
    p_namisre               tisrinf.namisre%type;
    p_namisrt               tisrinf.namisrt%type;
    p_namisr3               tisrinf.namisr3%type;
    p_namisr4               tisrinf.namisr4%type;
    p_namisr5               tisrinf.namisr5%type;
    p_codisrp               tisrpinf.codisrp%type;
    p_namisrco              tisrinf.namisrco%type;
    p_descisr               tisrinf.descisr%type;
    p_dtehlpst              tisrinf.dtehlpst%type;
    p_dtehlpen              tisrinf.dtehlpen%type;
    p_flgisr                tisrinf.flgisr%type;
    p_filename              tisrinf.filename%type;

    p_descisrp              tisrpinf.descisrp%type;
    p_amtisrp               tisrpinf.amtisrp%type;
    p_codecov               tisrpinf.codecov%type;
    p_codfcov               tisrpinf.codfcov%type;
    p_condisrp              tisrpinf.condisrp%type;
    p_statement             tisrpinf.statement%type;
    p_table                 json_object_t;

    p_coddepen              tisrpre.coddepen%type;
    p_amtpmium              tisrpre.amtpmiummt%type;
    p_amtpmiummt            tisrpre.amtpmiummt%type;
    p_amtpmiumyr            tisrpre.amtpmiumyr%type;
    p_pctpmium              tisrpre.pctpmium%type;
    p_flgcopy               varchar2(10);
    p_flgemp                varchar2(10);

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_detail(json_str_input in clob, json_str_output out clob);

    procedure get_detail_table(json_str_input in clob, json_str_output out clob);

    procedure get_detail2(json_str_input in clob, json_str_output out clob);

    procedure get_detail2_table(json_str_input in clob, json_str_output out clob);
    procedure gen_detail2_table(json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure save_detail(json_str_input in clob, json_str_output out clob);

    procedure save_detail2(json_str_input in clob, json_str_output out clob);

    procedure get_popup_copylist(json_str_input in clob, json_str_output out clob);

    procedure get_call_table(json_str_input in clob, json_str_output out clob);
    procedure gen_call_table(json_str_output out clob);
END HRBF31E;

/
