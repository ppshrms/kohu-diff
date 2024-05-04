--------------------------------------------------------
--  DDL for Package HRTR52X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR52X" AS
-- last update: 17/08/2022 12:13

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_chken          varchar2(10 char) := hcm_secur.get_v_chken;
    global_chken            varchar2(100 char);
    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;

    p_codapp                varchar2(10 char) := 'HRTR52X';
    p_codcomp               thistrnn.codcomp%type;
    p_dteyear               thistrnn.dteyear%type;
    p_dtemonthfr            thistrnn.dtemonth%type;
    p_dtemonthto            thistrnn.dtemonth%type;
    p_breaklevel            varchar2(2 char);
    p_typrep                varchar2(1 char);

    procedure initial_value(json_str_input in clob);

    procedure get_index_codcomp (json_str_input in clob, json_str_output out clob);
    procedure gen_index_codcomp (json_str_output out clob);
    procedure get_index_codcours (json_str_input in clob, json_str_output out clob);
    procedure gen_index_codcours (json_str_output out clob);
    procedure get_index_month (json_str_input in clob, json_str_output out clob);
    procedure gen_index_month (json_str_output out clob);
    procedure get_dropdowns (json_str_input in clob, json_str_output out clob);
    procedure gen_dropdowns (json_str_output out clob);

    procedure gen_graph(obj_row in json);

END HRTR52X;

/
