--------------------------------------------------------
--  DDL for Package HRPY1KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY1KE" as

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';

    param_json        json_object_t;

    -- index
    p_codcompy        varchar2(4 char);
    iscopy            varchar2(10 char);

    procedure get_index (json_str_input in clob,json_str_output out clob);

    procedure get_copy_list(json_str_input in clob,json_str_output out clob);

    procedure save_data (json_str_input in clob,json_str_output out clob);

    procedure static_report (json_str_input in clob,json_str_output out clob);

    procedure get_coddeduct_all(json_str_input in clob, json_str_output out clob);
    procedure get_codpay_all(json_str_input in clob, json_str_output out clob);
    procedure get_codaccdr_all(json_str_input in clob, json_str_output out clob);
end HRPY1KE;

/
