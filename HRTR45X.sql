--------------------------------------------------------
--  DDL for Package HRTR45X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR45X" AS 

    param_msg_error          varchar2(4000 char);
    global_v_coduser         varchar2(100 char);
    global_v_codempid        varchar2(100 char);
    global_v_lang            varchar2(10 char) := '102';
    global_v_zminlvl         number;
    global_v_zwrklvl         number;
    global_v_numlvlsalst 	 number;
    global_v_numlvlsalen 	 number;
    v_zupdsal                varchar2(4000 char);

    param_json               JSON;

    p_year                   ttrsubjd.dteyear%type;
    p_codcompy               tcompny.codcompy%type;
    p_codcours               ttrsubjd.codcours%type;
    p_numclseq               ttrsubjd.numclseq%type;
    p_codapp                 ttemprpt.codapp%type;
    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_report(json_str_input in clob, json_str_output out clob);

END HRTR45X;

/
