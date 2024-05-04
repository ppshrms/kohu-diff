--------------------------------------------------------
--  DDL for Package HRPMS2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMS2X" AS

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
    p_codcomp               tcenter.codcomp%type;
    p_comlevel              tcenter.comlevel%type;
    p_codtrn                tcodmove.CODCODEC%type;

    p_monthst               varchar2(2 char);
    p_yearst                varchar2(4 char);
    p_monthen               varchar2(2 char);
    p_yearen                varchar2(4 char);
    p_column                varchar2(4 char);
    p_row                   varchar2(4 char);
    p_column_data           json_object_t;
    p_row_data              json_object_t;
    json_graph_col          json_object_t;

    procedure initial_value(json_str_input in clob);
    procedure get_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_detail(json_str_output out clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure insert_graph (json_str_output in json_object_t);

END HRPMS2X;

/
