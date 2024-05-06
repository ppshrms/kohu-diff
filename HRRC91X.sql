--------------------------------------------------------
--  DDL for Package HRRC91X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC91X" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              json_object_t;

    p_codcomp               tapplinf.codcomp%type;
    p_year                  varchar(4 char);
    p_monthst               varchar(2 char);
    p_monthen               varchar(2 char);

    p_dtestr                tjobpost.dtepost%type;
    p_dteend                tjobpost.dtepost%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

END HRRC91X;

/
