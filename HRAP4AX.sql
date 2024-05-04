--------------------------------------------------------
--  DDL for Package HRAP4AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP4AX" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal   		        varchar2(4 char);

    b_index_codcomp         tcenter.codcomp%type;
    b_index_syncond         varchar2(4000 char);
    b_index_grade           varchar2(10 char);
    b_index_qtygrade        number;
    b_index_score           tappemp.qtyadjtot%type;
    b_index_qtyscore        number;
    b_index_yearst          tappemp.dteyreap%type;
    b_index_yearen          tappemp.dteyreap%type;

    p_codempid_detail       temploy1.codempid%type;


    procedure initial_value(json_str_input in clob);
    procedure check_index;
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure get_dropdown (json_str_input in clob, json_str_output out clob);
end HRAP4AX;

/
