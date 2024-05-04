--------------------------------------------------------
--  DDL for Package HRPY19E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY19E" as

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';

    param_json        json_object_t;

    -- index
    p_codcompy        varchar2(4 char);
    p_dteyreff        number(4,0);
    p_dteyreff_query  number(4,0);
    p_delete_all      varchar2(1 char) := 'N';
    v_flgDisabled     boolean;
    v_flgAdd          boolean;

    procedure get_index(json_str_input in clob,json_str_output out clob);

    procedure save_index(json_str_input in clob,json_str_output out clob);

    procedure gen_flg_status;

end HRPY19E;

/
