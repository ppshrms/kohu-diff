--------------------------------------------------------
--  DDL for Package HRBFA4X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFA4X" AS
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

    v_codapp                varchar2(20 char);
    p_dteyear               thealinf1.dteyear%type;
    p_codcomp               thealinf1.codcomp%type;
    p_query_codempid        thealinf1.codempid%type;
    p_dtehealst             thealinf1.dteheal%type;
    p_dtehealen             thealinf1.dteheal%type;
    p_codprgheal            thealinf1.codprgheal%type;

procedure get_index(json_str_input in clob, json_str_output out clob);

procedure get_detail(json_str_input in clob, json_str_output out clob);

procedure get_report(json_str_input in clob, json_str_output out clob);

END HRBFA4X;

/
