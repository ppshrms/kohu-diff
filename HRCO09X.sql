--------------------------------------------------------
--  DDL for Package HRCO09X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO09X" as

    param_msg_error varchar2(4000 char);
    global_v_coduser varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang varchar2(10 char) := '102';

    p_codcomp tcenterlog.codcomp%type;
    p_dtestr  tcenterlog.dteeffec%type;
    p_dteend  tcenterlog.dteeffec%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

end hrco09x;

/
