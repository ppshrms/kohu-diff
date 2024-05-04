--------------------------------------------------------
--  DDL for Package HRPY7AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY7AX" as

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_chken        varchar2(4000 char);
  v_zupdsal     		varchar2(4 char);

  p_codcomp             varchar2(4000 char);
  p_month               number;
  p_year                number;
  p_typpayroll          varchar2(4000 char);

  procedure initial_value (json_str_input in clob);
  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure save_data(json_str_input in clob,json_str_output out clob);

end HRPY7AX;

/
