--------------------------------------------------------
--  DDL for Package HRPYS4X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPYS4X" as
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

    p_year             tytdinc.dteyrepay%type;
    p_report           varchar2(1 char);
    p_amtpay_count     number := 0;
    json_codpay        json_object_t;
    json_codgrbug      json_object_t;
    json_month         json_object_t;

    procedure get_index(json_str_input in clob, json_str_output out clob);
end HRPYS4X;

/
