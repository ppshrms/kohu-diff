--------------------------------------------------------
--  DDL for Package HRPY1JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY1JE" as

    param_msg_error       varchar2(4000 char);
    global_v_coduser      varchar2(100 char);
    global_v_codempid     varchar2(100 char);
    global_v_lang         varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal             varchar2(4000 char);

    param_json        json_object_t;

    -- param search
    p_codcomp   varchar2(40 char);
    p_codempid   varchar2(10 char);

    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure get_detail(json_str_input in clob,json_str_output out clob);
    procedure get_detail_table(json_str_input in clob,json_str_output out clob);
    procedure save_index(json_str_input in clob,json_str_output out clob);
    procedure save_detail(json_str_input in clob,json_str_output out clob);
    procedure get_name_costcent(json_str_input in clob,json_str_output out clob);

end HRPY1JE;

/
