--------------------------------------------------------
--  DDL for Package HRBF5BX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5BX" AS
    param_msg_error   varchar2(4000 char);
    global_v_coduser  varchar2(100 char);
    global_v_codempid varchar2(100 char);
    global_v_lang     varchar2(10 char) := '102';
    global_v_zminlvl      number;
    global_v_zwrklvl      number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal             varchar2(4000 char);

    param_json          JSON;
    p_codapp             ttemprpt.codapp%type;

    p_codempid      temploy1.codempid%type;
    p_numcont       tloaninf.numcont%type;

    procedure get_index(json_str_input in clob, json_str_output out clob);
    procedure get_detail(json_str_input in clob, json_str_output out clob);
    procedure get_detail_tab2(json_str_input in clob, json_str_output out clob);
    procedure get_detail_tab3(json_str_input in clob, json_str_output out clob);
    procedure get_report(json_str_input in clob, json_str_output out clob);

END HRBF5BX;


/
