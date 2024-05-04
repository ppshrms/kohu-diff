--------------------------------------------------------
--  DDL for Package HRALS1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRALS1X" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal   		        varchar2(4 char);

    p_codapp                tempaprq.codapp%type := 'HRALS1X';
    p_codleave_arr          tleavecd.codleave%type;
    p_codcalen_arr          tcodwork.codcodec%type;

    p_year                  varchar2(4 char);
    p_monthst               number;
    p_monthen               number;
    p_typhr                 varchar2(4000 char);
    p_typleave              json_object_t;
    p_codcalen              varchar2(4000 char);
    p_syncond               varchar2(4000 char);
    p_codleave              varchar2(4000 char);
    type t_codleave is table of varchar2(4000 char);
    p_codleave2             t_codleave;
    p_codleave2_size        number := 0;
    p_codleave3             varchar2(4000 char);

    json_codleave_arr       json_object_t;
    json_codcalen_arr       json_object_t;
    isInsertReport          boolean := false;

    type arr_1d is table of varchar2(4000 char) index by binary_integer;

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index(json_str_output out clob);
    procedure gen_report(json_str_input in clob, json_str_output out clob);
    procedure clear_ttemprpt;
    procedure insert_ttemprpt(obj_data in json_object_t);
    procedure gen_graph(obj_row in json_object_t);
    procedure get_label(json_str_input in clob,json_str_output out clob);
    
end HRALS1X;

/
