--------------------------------------------------------
--  DDL for Package HRCO1DX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO1DX" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';

    p_codcomp           tjobpos.codcomp%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

end hrco1dx;

/
