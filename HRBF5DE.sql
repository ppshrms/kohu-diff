--------------------------------------------------------
--  DDL for Package HRBF5DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5DE" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json_object_t;

    p_codcompy              tcenter.codcompy%type;
    p_codlon                ttyploan.codlon%type;
    p_dteeffec              tintrteh.dteeffec%type;
    p_dteeffecquery         tintrteh.dteeffec%type;

    p_codpayc               tintrteh.CODPAYC%type;
    p_codpayd               tintrteh.CODPAYD%type;
    p_codpaye               tintrteh.CODPAYE%type;
    p_rateilon              tintrteh.RATEILON%type;
    p_typintr               tintrteh.TYPINTR%type;
    p_formula               json_object_t;
    p_code                  tintrteh.FORMULA%type;
    p_description           tintrteh.STATEMENT%type;
    p_flag                  varchar(50 char);

    p_table                 json_object_t;
    p_amtlon                tintrted.amtlon%type;
    p_amtlonOld             tintrted.amtlon%type;  

    v_flgDisabled               boolean;  

    isEdit                      boolean := true;
    isAdd                       boolean := false;
    v_flgadd                    boolean := false;
    v_indexdteeffec             date;
    param_detail                json_object_t;
    param_table                 json_object_t;

    procedure get_index(json_str_input in clob,json_str_output out clob);

    procedure get_index_table(json_str_input in clob,json_str_output out clob);

    procedure save_index(json_str_input in clob,json_str_output out clob);

    procedure get_flg_status (json_str_input in clob, json_str_output out clob);
    procedure gen_flg_status;

END HRBF5DE;

/
