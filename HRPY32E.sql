--------------------------------------------------------
--  DDL for Package HRPY32E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY32E" as

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_empname  varchar2(100 char);

    param_json        json_object_t;

    p_codcompy        varchar2(4 byte);
    p_apcode          varchar2(4 char);
    p_typpaymt        varchar2(4 char);
    p_typpaymt_old    varchar2(4 char);

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_index_table(json_str_input in clob, json_str_output out clob);
    procedure save_data(json_str_input in clob, json_str_output out clob);
    procedure delete_gl (json_str_input in clob, json_str_output out clob);
    procedure get_codpay_all(json_str_input in clob, json_str_output out clob);
    procedure get_report_data (json_str_input in clob, json_str_output out clob);

end HRPY32E;

/
