--------------------------------------------------------
--  DDL for Package HRTR54X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR54X" AS

    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    global_v_zyear            number := 0;
    param_json          JSON;

    p_year           TYRTRSCH.dteyear%type;
    p_codcompy       TYRTRSCH.codcompy%type;
    p_codcate        TYRTRSCH.codcate%type;
    p_codcours       TYRTRSCH.codcours%type;
    p_numclseq       TYRTRSCH.numclseq%type;
    p_month          number;
    p_date           varchar2(100 char);
    p_mode           varchar2(50 char);
    p_codapp    ttemprpt.codapp%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_detail_calender(json_str_input in clob, json_str_output out clob);
    procedure get_report(json_str_input in clob, json_str_output out clob);

END HRTR54X;


/
