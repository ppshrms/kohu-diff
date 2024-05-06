--------------------------------------------------------
--  DDL for Package HRRC3KX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC3KX" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              json_object_t;

    p_codemprc              treqest1.codemprc%type;
    p_codcomp               tcenter.codcomp%type;
    p_dtereqst              treqest1.dtereq%type;
    p_dtereqen              treqest1.dtereq%type;
    p_poststatus            varchar(1 char);

    procedure get_index(json_str_input in clob, json_str_output out clob);

END HRRC3KX;

/
