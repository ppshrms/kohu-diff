--------------------------------------------------------
--  DDL for Package HRPY92R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY92R" as
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_chken        varchar2(4000 char);
  v_zupdsal     		    varchar2(4 char);

  p_month               number;
  p_year                number;
  p_codcomp             tcenter.codcomp%type;
  p_typpayroll          tcodtypy.codcodec%type;
  p_typeData            varchar2(1 char);
  p_codrevn             tcodrevn.codcodec%type;
  p_dtepay              date;
  p_desc_codempid       varchar2(4000 char); -- temp
  p_desc_position       varchar2(4000 char); -- temp

  procedure initial_value (json_str_input in clob);
  procedure check_detail;
  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure gen_detail(json_str_output out clob);

  procedure check_process1;
  procedure get_process1(json_str_input in clob,json_str_output out clob);
  procedure gen_process1(json_str_output out clob);

  procedure check_process2;
  procedure get_process2(json_str_input in clob,json_str_output out clob);
  procedure gen_process2(json_str_output out clob);

  procedure clear_temp(json_str_input in clob,json_str_output out clob);
end hrpy92r;


/
