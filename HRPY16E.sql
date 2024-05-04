--------------------------------------------------------
--  DDL for Package HRPY16E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY16E" as

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';

    param_json        json_object_t;

    -- index
    p_codbrsoc        tcodsoc.codbrsoc%type;

    procedure get_index(json_str_input in clob,json_str_output out clob);

    procedure save_index(json_str_input in clob,json_str_output out clob);

    procedure get_detail(json_str_input in clob,json_str_output out clob);
end HRPY16E;

/
