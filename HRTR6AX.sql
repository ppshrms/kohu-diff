--------------------------------------------------------
--  DDL for Package HRTR6AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR6AX" AS

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zyear          number := 0;
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    v_zupdsal               varchar2(4000 char);

    p_dteyear               tpotentp.dteyear%type;
    p_codcompy              tpotentp.codcompy%type;
    p_numclseq              tpotentp.numclseq%type;
    p_codcours              tpotentp.codcours%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);

END HRTR6AX;

/
