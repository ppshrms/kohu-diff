--------------------------------------------------------
--  DDL for Package HRCO28X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO28X" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';

    p_dtestr            tpostnlog.dtechg%type;
    p_dteend            tpostnlog.dtechg%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

end hrco28x;

/
