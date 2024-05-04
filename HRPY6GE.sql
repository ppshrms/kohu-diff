--------------------------------------------------------
--  DDL for Package HRPY6GE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY6GE" as

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

    p_codempid          temploy1.codempid%type;
    p_dteyrepay         tlastempd.dteyrepay%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

    procedure save_index(json_str_input in clob, json_str_output out clob);

end HRPY6GE;

/
