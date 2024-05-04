--------------------------------------------------------
--  DDL for Package HRPM75X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM75X" as
-- last update: 06/02/2021 17:15 redmine #3249

    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal   		        varchar2(4 char);

    p_year                  varchar2(4 char);
    p_monthst               varchar2(2 char);
    p_monthen               varchar2(2 char);
    p_typleave              json_object_t;

    p_yearstrt              varchar2(4 char);
    p_monthstrt             varchar2(2 char);
    p_yearend               varchar2(4 char);
    p_monthend              varchar2(2 char);
    p_codcomp               thismist.codcomp%type;
    p_codcodec              varchar2(10 char);
    p_typreport             varchar2(100);
    dataselect              json_object_t;

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure vadidate_variable_getindex(json_str_input in clob);
    procedure get_label(json_str_input in clob,json_str_output out clob);
    procedure insert_graph(list_json in json_object_t,data_select in json_object_t);
--    procedure gen_graph(obj_row in json);

end HRPM75X;

/
