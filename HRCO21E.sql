--------------------------------------------------------
--  DDL for Package HRCO21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO21E" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char);

    param_json          json_object_t;

    p_codjob            tjobcode.codjob%type;
    p_codapp            ttemprpt.codapp%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    procedure get_report(json_str_input in clob, json_str_output out clob);
end HRCO21E;

/
