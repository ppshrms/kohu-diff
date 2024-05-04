--------------------------------------------------------
--  DDL for Package HRCO19E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO19E" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';

    param_json          json_object_t;
    p_codcodec          tcodskil.codcodec%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure import_data_process(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    procedure get_skill_score(json_str_input in clob, json_str_output out clob);
    procedure import_data_tcomptnh(json_str_input in clob, json_str_output out clob);
    procedure get_tcomptnh(json_str_input in clob, json_str_output out clob);
    procedure get_tcomptcr(json_str_input in clob, json_str_output out clob);
    procedure import_data_tcomptcr(json_str_input in clob, json_str_output out clob);
    procedure get_tcomptdev(json_str_input in clob, json_str_output out clob);
    procedure import_data_tcomptdev(json_str_input in clob, json_str_output out clob);
    procedure save_skill_score(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);

end HRCO19E;

/
