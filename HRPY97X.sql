--------------------------------------------------------
--  DDL for Package HRPY97X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY97X" as
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

  p_year        number;
  p_codcomp     tcenter.codcomp%type;
  p_typpayroll  tcodtypy.codcodec%type;
  p_codempid    temploy1.codempid%type;
  p_codpay      tinexinf.codpay%type;

  procedure initial_value (json_str_input in clob);

  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);
end hrpy97x;

/
