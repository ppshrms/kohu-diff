--------------------------------------------------------
--  DDL for Package HRBF46X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF46X" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              json_object_t;

    p_query_codempid        temploy1.codempid%type;
    v_codapp                varchar(20 char);

procedure get_index(json_str_input in clob, json_str_output out clob);
procedure get_report(json_str_input in clob, json_str_output out clob);


END HRBF46X;

/
