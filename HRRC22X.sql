--------------------------------------------------------
--  DDL for Package HRRC22X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC22X" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json_object_t;

    p_codcomp               tcenter.codcomp%type;
    p_dtereqst              treqest1.dtereq%type;
    p_dtereqen              treqest1.dtereq%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

END HRRC22X;


/
