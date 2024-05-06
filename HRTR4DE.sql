--------------------------------------------------------
--  DDL for Package HRTR4DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR4DE" AS 

    param_msg_error     varchar2(4000 char);
    global_v_coduser    varchar2(100 char);
    global_v_codempid   varchar2(100 char);
    global_v_lang       varchar2(10 char) := '102';

    param_json          JSON;

    p_codcompy    tcompny.codcompy%type;
    p_year       ttrnbudg.dteyear%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure save_index(json_str_input in clob, json_str_output out clob);

END HRTR4DE;

/
