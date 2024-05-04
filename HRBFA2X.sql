--------------------------------------------------------
--  DDL for Package HRBFA2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFA2X" AS
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(100 char) := '102';

    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    param_json              JSON;

    p_codprgheal            thealcde.codprgheal%type;
    p_codcomp               temploy1.codcomp%type;
    p_dteyear               thealinf1.dteyear%type;
    p_query_codempid        temploy1.codempid%type;
    p_dtehealst             thealinf.dteheal%type;
    p_dtehealen             thealinf.dtehealen%type;

procedure get_index(json_str_input in clob,json_str_output out clob);

procedure send_mail(json_str_input in clob,json_str_output out clob);

END HRBFA2X;


/
