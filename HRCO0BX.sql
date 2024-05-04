--------------------------------------------------------
--  DDL for Package HRCO0BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO0BX" as

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';

    p_codpos            tlogjobpos.codpos%type;
    p_codcomp           tlogjobpos.codcomp%type;
    p_dtestr            tlogjobpos.dtechg%type;
    p_dteend            tlogjobpos.dtechg%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

end HRCO0BX;

/
