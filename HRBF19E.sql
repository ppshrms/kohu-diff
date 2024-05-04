--------------------------------------------------------
--  DDL for Package HRBF19E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF19E" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    json_params             json;

    p_codapp                varchar2(10 char) := 'HRBF19E';
    p_codcompy              tlmedexh.codcompy%type;
    p_numseq                number;

    procedure initial_value(json_str_input in clob);
    procedure get_index (json_str_input in clob, json_str_output out clob);
    procedure gen_index (json_str_output out clob);
    procedure get_detail (json_str_input in clob, json_str_output out clob);
    procedure gen_detail (json_str_output out clob);
    procedure get_table (json_str_input in clob, json_str_output out clob);
    procedure gen_table (json_str_output out clob);
    procedure delete_index(json_str_input in clob, json_str_output out clob);
    procedure save_data(json_str_input in clob, json_str_output out clob);

end HRBF19E;

/
