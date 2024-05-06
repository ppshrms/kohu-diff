--------------------------------------------------------
--  DDL for Package HRPYB1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPYB1E" as

    param_msg_error             varchar2(4000 char);
    global_v_coduser            varchar2(100 char);
    global_v_codempid           varchar2(100 char);
    global_v_lang               varchar2(10 char) := '102';

    param_json                  json_object_t;

    p_codcompy                  tpfhinf.codcompy%type;
    p_dteeffec                  tpfhinf.dteeffec%type;
    p_dteeffecquery             tpfhinf.dteeffec%type;
    p_flgresign                 tpfhinf.flgresign%type;
    p_qtyremth                  tpfhinf.qtyremth%type;
    p_flgedit                   varchar2(10 char);
    p_mode                      varchar2(10 char);--user37 #2349 Final Test Phase 1 V11 02/03/2021  
    v_flgDisabled               boolean;  

    isEdit                      boolean := true;
    isAdd                       boolean := false;
    v_flgadd                    boolean := false;
    v_indexdteeffec             date;
    param_detail                json_object_t;
    param_table                 json_object_t;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

    procedure get_flg_status (json_str_input in clob, json_str_output out clob);
    procedure gen_flg_status;

end HRPYB1E;

/
