--------------------------------------------------------
--  DDL for Package HRCO2KB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2KB" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';

    param_json          json_object_t;

    p_tname          user_tab_comments.table_name%type;
    p_codsys         tcontdel.codsys%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure gen_querytool(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);

end HRCO2KB;

/
