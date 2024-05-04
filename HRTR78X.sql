--------------------------------------------------------
--  DDL for Package HRTR78X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR78X" is

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

    p_codapp                varchar2(10 char) := 'HRTR78X';
    p_codcompy              thisclss.codcompy%type;
    p_monthst               thisclss.dtemonth%type;
    p_yearst                thisclss.dteyear%type;
    p_monthen               thisclss.dtemonth%type;
    p_yearen                thisclss.dteyear%type;
    p_flgreport             varchar2(1 char);

    procedure initial_value(json_str_input in clob);

    procedure get_index_codcours (json_str_input in clob, json_str_output out clob);
    procedure gen_index_codcours (json_str_output out clob);
    procedure get_index_codexpn (json_str_input in clob, json_str_output out clob);
    procedure gen_index_codexpn (json_str_output out clob);
    procedure get_index_month (json_str_input in clob, json_str_output out clob);
    procedure gen_index_month (json_str_output out clob);

    procedure gen_graph(obj_row in json);

end HRTR78X;


/
