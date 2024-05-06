--------------------------------------------------------
--  DDL for Package HRMS14X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS14X" is
  --global
  global_v_coduser      varchar2(100 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4 char);

  --value
  obj_row               json_object_t;
  obj_data              json_object_t;
  v_row1                number;
  v_total1              number;

  b_index_codempid      varchar2(1000 char);
  b_index_codapp        varchar2(1000 char);
  b_index_stdate        date;
  b_index_endate        date;
  b_index_codcomp       varchar2(1000 char);
  b_index_staappr       varchar2(1000 char);

  b_index_dtereq        date;
  b_index_numseq        varchar2(1000 char);
  b_index_routeno       varchar2(1000 char);
  b_index_approvno      varchar2(1000 char);
  b_index_typreq        varchar2(1000 char);
  b_index_dtework       date;
  b_index_codlon        varchar2(1000 char);
  b_index_codpos        varchar2(1000 char);
  b_index_seqno         varchar2(1000 char);
  b_index_flg           varchar2(10 char);
  param_msg_error       varchar2(600);

  type arr is table of varchar2(4000 char) index by binary_integer;
  arr_col          arr;
  arr_empty        arr;
  global_v_break   arr;

  procedure check_index;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_table1popup1(json_str_input in clob, json_str_output out clob);
  procedure get_table1popup2(json_str_input in clob, json_str_output out clob);
  procedure get_table1popup1popup1(json_str_input in clob, json_str_output out clob);
  procedure save_table1popup1popup1(json_str_input in clob, json_str_output out clob);

end;


/
