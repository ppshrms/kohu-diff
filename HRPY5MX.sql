--------------------------------------------------------
--  DDL for Package HRPY5MX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5MX" as
    param_msg_error         varchar2(4000 char);
    global_v_coduser        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';

    global_v_zminlvl  	    number;
    global_v_zwrklvl  	    number;
    global_v_numlvlsalst 	  number;
    global_v_numlvlsalen 	  number;
    v_zupdsal   		        varchar2(4 char);


    p_codbrsoc              varchar2(4 char);
    p_stdate                date;
    p_endate                date;
    p_status                varchar2(1 char);
    p_numbrlvl              varchar2(6 char);

    v_codbrsoc              varchar2(4 char);
    flg_data                varchar2(1 char);
    flg_fecth               varchar2(1 char);
    p_codapp                varchar2(100 char);
    isInsertReport          boolean :=  false;

    procedure initial_value(json_str_input in clob);
    procedure get_index(json_str_input in clob,json_str_output out clob);
    procedure check_index;
    procedure gen_index1(json_str_output out clob);
    procedure gen_index2(json_str_output out clob);
    procedure del_temp (v_codapp varchar2,v_coduser varchar2);
--    procedure insert_head;
    procedure insert_temp(json_header_input in json_object_t, json_detail_input in json_object_t);
    procedure gen_report(json_str_input in clob,json_str_output out clob);

end hrpy5mx;

/
