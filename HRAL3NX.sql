--------------------------------------------------------
--  DDL for Package HRAL3NX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL3NX" is
    param_msg_error     varchar2(4000 char); -- error msg

    global_v_coduser        varchar2(100 char);
    global_v_codpswd        varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_lrunning       varchar2(10 char);
    global_v_zminlvl  		number;
    global_v_zwrklvl  		number;
    global_v_numlvlsalst 	number;
    global_v_numlvlsalen 	number;
    v_zupdsal   		    varchar2(4 char);

    p_codempid              varchar2(4000 char);
    b_index_codcomp         varchar2(4000 char);

    p_codcomp		       	varchar2(4000);
    p_codcalen              varchar2(4000);
  	p_flg 			        varchar2(40);
  	p_flgn_in 		        varchar2(40);
  	p_flgn_out 		        varchar2(40);
  	p_flgy_in 		        varchar2(40);
  	p_flgy_out 		        varchar2(40);
  	p_timstrtw 		        varchar2(40);
  	p_dtestr 			    date;
  	p_dteend 			    date;

    procedure initial_value (json_str in clob);
    procedure get_index (json_str_input in clob, json_str_output out clob);
    procedure check_index;
    procedure gen_index (json_str_input in clob, json_str_output out clob);
--    procedure edit_index (json_str_input in clob, json_str_output out clob);
--    procedure edit_data (json_str_input in clob, json_str_output out clob);
end HRAL3NX;

/
