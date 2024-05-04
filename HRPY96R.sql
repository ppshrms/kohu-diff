--------------------------------------------------------
--  DDL for Package HRPY96R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY96R" as
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_chken        varchar2(4000 char);
  global_v_zyear        number := 0;
  v_zupdsal     		    varchar2(4 char);

  p_dteyrepay   number;
  p_codcomp     tcenter.codcomp%type;
  p_codempid    temploy1.codempid%type;
  p_typrep      number;


  procedure initial_value (json_str_input in clob);

  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);
--
  procedure check_detail;
  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure gen_detail(json_str_output out clob);

  procedure save_detail(json_str_input in clob, json_str_output out clob);
--  procedure gen_data_report;

end HRPY96R;

/
