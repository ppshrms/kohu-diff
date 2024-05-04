--------------------------------------------------------
--  DDL for Package HRPY2BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY2BX" as
    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_empname  varchar2(100 char);

    param_json              json_object_t;

    procedure get_index(json_str_input in clob, json_str_output out clob);

end HRPY2BX;

/
