--------------------------------------------------------
--  DDL for Package HRPMSAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMSAX" as
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

    p_yearstrt              varchar2(4 char);
    p_monthstrt             varchar2(2 char);
    p_yearend               varchar2(4 char);
    p_monthend              varchar2(2 char);
    p_codcomp               thismist.codcomp%type;
    p_typreport             varchar2(100);
    p_codcodec              thismist.codmist%type;
    dataselect              json_object_t;

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure vadidate_variable_getindex(json_str_input in clob);
    procedure get_label(json_str_input in clob,json_str_output out clob);
end HRPMSAX;

/
