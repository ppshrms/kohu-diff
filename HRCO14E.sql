--------------------------------------------------------
--  DDL for Package HRCO14E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO14E" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';

    param_json          json_object_t;

    p_codform           tfrmmail.codform%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_parameter_detail(json_str_input in clob, json_str_output out clob);
    procedure save_parameter_detail(json_str_input in clob, json_str_output out clob);
    procedure get_list_params(json_str_input in clob, json_str_output out clob);
    procedure get_list_columns(json_str_input in clob, json_str_output out clob);
    procedure get_list_tables(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
    procedure get_list_copy(json_str_input in clob, json_str_output out clob);

end HRCO14E;

/
