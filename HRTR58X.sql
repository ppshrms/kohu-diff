--------------------------------------------------------
--  DDL for Package HRTR58X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR58X" AS
    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';
    global_v_zyear      number := 0;

    param_json          JSON;
    p_codcompy          tcompny.codcompy%type;
    p_dteyear           tyrtrsch.dteyear%type;
    p_monthst           varchar2(100 char);
    p_monthend          varchar2(100 char);

    procedure get_index(json_str_input in clob, json_str_output out clob);

END HRTR58X;


/
