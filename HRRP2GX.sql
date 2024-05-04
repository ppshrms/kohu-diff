--------------------------------------------------------
--  DDL for Package HRRP2GX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP2GX" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal   		        varchar2(4 char);

    b_index_compgrp   		  tcenter.compgrp%type;
    b_index_group   		    varchar2(10 char);

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure get_index_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_index_detail(json_str_output out clob);
    procedure gen_graph;
    procedure get_list_group(json_str_input in clob, json_str_output out clob);
end HRRP2GX;

/
