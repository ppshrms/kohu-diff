--------------------------------------------------------
--  DDL for Package HRPY58X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY58X" as
  param_msg_error       varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_chken        varchar2(4000 char);
  v_zupdsal     		    varchar2(4 char);

  p_numperiod           number;
  p_month               number;
  p_year                number;
  p_codcomp             tcenter.codcomp%type;
  p_typpayroll          temploy1.typpayroll%type;
  p_comlevel            number;
  p_sysdate             date;
  p_label_all           varchar2(4000 char) := '190'; -- tapplscr
  p_codapp              varchar2(100 char) := 'HRPY58X';
  isInsertReport        boolean := false;


  procedure initial_value (json_str_input in clob);

  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_list_tsetcomp(json_str_input in clob, json_str_output out clob);
  procedure insert_temp(v_index in varchar2,v_codempid in varchar2,v_codcomp in varchar2);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);

end hrpy58x;

/
