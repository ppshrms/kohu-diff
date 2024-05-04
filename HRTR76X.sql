--------------------------------------------------------
--  DDL for Package HRTR76X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR76X" AS

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
    json_params       json;
    p_codapp                varchar2(10 char) := 'HRTR76X';
    p_codcompy              thistrnn.codcomp%type;
    p_dteyear               thistrnn.dteyear%type;

    procedure initial_value(json_str_input in clob);
    procedure get_index_costcenter (json_str_input in clob, json_str_output out clob);
    procedure gen_index_costcenter (json_str_output out clob);
    procedure get_index_month (json_str_input in clob, json_str_output out clob);
    procedure gen_index_month (json_str_output out clob);

    procedure gen_graph(obj_row in json);

END HRTR76X;


/
