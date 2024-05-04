--------------------------------------------------------
--  DDL for Package HRPY3BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY3BX" as

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';

    p_codcompy        tlogap.codcompy%type;
    p_apcode          tlogap.apcode%type;
    p_dtestr          tlogap.dteupd%type;
    p_dteend          tlogap.dteupd%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

end HRPY3BX;

/
