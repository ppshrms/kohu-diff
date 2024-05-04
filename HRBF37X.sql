--------------------------------------------------------
--  DDL for Package HRBF37X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF37X" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    param_json              JSON;

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    p_codcomp               tinsrer.codcomp%type;
    p_numisr                tinsrer.numisr%type;
    p_codisrp               tinsrer.codisrp%type;

procedure get_index(json_str_input in clob, json_str_output out clob);
--<<nut 
procedure get_detail(json_str_input in clob, json_str_output out clob);
procedure get_detail_table(json_str_input in clob, json_str_output out clob);
procedure gen_detail_table(json_str_output out clob);
-->>nut 

END HRBF37X;

/
