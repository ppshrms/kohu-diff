--------------------------------------------------------
--  DDL for Package HRCO38E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO38E" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    param_json          json_object_t;

    p_codapp          tlistval.codapp%type;
    p_desc            tlistval.desc_label%type;
    p_value           tlistval.list_value%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    procedure get_langcolumn(json_str_input in clob, json_str_output out clob);

end HRCO38E;

/
