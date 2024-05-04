--------------------------------------------------------
--  DDL for Package HRRC3BE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC3BE" as

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4 char);

    param_json          json_object_t;
    json_input_obj      json_object_t;

    -- index
    p_numappl           varchar2(100 char);
    p_codpos            varchar2(100 char);
    p_datest            date;
    p_dateen            date;

    p_codcompy          varchar2(4 char);
    p_dteeffec          number(4,0);

    isInsertReport      boolean := false;
    p_codapp            varchar2(10 char) := 'HRRRC3BE';
    v2_numappl          varchar2(100 char);

    procedure get_data (json_str_input in clob, json_str_output out clob);
    procedure gen_data (json_str_output out clob);
    procedure get_detail (json_str_input in clob, json_str_output out clob);
    procedure save_detail(json_str_input in clob, json_str_output out clob);

end HRRC3BE;

/
