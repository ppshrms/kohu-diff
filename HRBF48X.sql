--------------------------------------------------------
--  DDL for Package HRBF48X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF48X" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              JSON_object_t;

    p_codcomp               temploy1.codcomp%type;
    p_dtemthst              integer;
    p_dteyrest              integer;
    p_dtemthen              integer;
    p_dteyreen              integer;

    p_codobf1               tobfcde.codobf%type;
    p_codobf2               tobfcde.codobf%type;
    p_codobf3               tobfcde.codobf%type;
    p_codobf4               tobfcde.codobf%type;
    p_codobf5               tobfcde.codobf%type;

procedure get_index(json_str_input in clob, json_str_output out clob);

END HRBF48X;

/
