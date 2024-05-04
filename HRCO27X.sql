--------------------------------------------------------
--  DDL for Package HRCO27X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO27X" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';

    param_json          json_object_t;

    p_subsystem         varchar2(2 char);
    p_tname             varchar2(30 char);

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure get_table_detail(json_str_input in clob, json_str_output out clob);

    procedure static_report(json_str_input in clob, json_str_output out clob);
end HRCO27X;

/
