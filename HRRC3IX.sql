--------------------------------------------------------
--  DDL for Package HRRC3IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC3IX" is

  param_msg_error           varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    json_params             json_object_t;

    p_dtestrt               varchar2(100 char);
    p_dteend                varchar2(100 char);

    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure gen_detail(json_str_output out clob);

end HRRC3IX;


/
