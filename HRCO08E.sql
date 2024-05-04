--------------------------------------------------------
--  DDL for Package HRCO08E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO08E" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal               varchar2(4000 char);
    global_v_zyear          number := 0;

    param_json          JSON_object_t;

    p_codcompy          tcompny.codcompy%type;
    p_codsys            tcontdel.codsys%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);
end HRCO08E;

/
