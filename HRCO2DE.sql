--------------------------------------------------------
--  DDL for Package HRCO2DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2DE" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    param_json          json_object_t;
    p_codcomph          temphead.codcomph%type;
    p_codposh           temphead.codposh%type;
    p_codempidh         temphead.codempidh%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure import_data_process(json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);

end HRCO2DE;

/
