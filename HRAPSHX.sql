--------------------------------------------------------
--  DDL for Package HRAPSHX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAPSHX" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal   		        varchar2(4 char);
    v_chken                 varchar2(4000 char) := hcm_secur.get_v_chken;

    b_index_codcomp         tcenter.codcomp%type;
    b_index_dteyreap        number;      
    b_index_numtime         number;

    p_codtency              tappcmpf.codtency%type;
    p_codskill              tappcmpf.codskill%type;
    p_desc_codskill         tcodskil.definitt%type;

    isInsertReport          boolean := false;
    json_index_rows         json_object_t;
    p_codapp                varchar2(10 char) := 'HRAPSHX';

    procedure initial_value(json_str_input in clob);
    procedure check_index;
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure gen_index(json_str_output out clob);
    procedure get_index_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_index_detail(json_str_output out clob);
    procedure get_detail(json_str_input in clob,json_str_output out clob);
    procedure gen_detail(json_str_output out clob);
    --Report--
--    procedure initial_value(json_str in clob);
    procedure gen_report (json_str_input in clob,json_str_output out clob);
    procedure clear_ttemprpt;
    procedure insert_ttemprpt(obj_data in json_object_t); 
    procedure insert_ttemprpt_table(obj_data in json_object_t);
end HRAPSHX;

/
