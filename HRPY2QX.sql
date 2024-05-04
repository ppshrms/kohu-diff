--------------------------------------------------------
--  DDL for Package HRPY2QX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY2QX" as

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

  p_codcomp   varchar2(4000 char); -- tcenter.codcomp%type;
  p_codempmt  varchar2(4000 char); -- temploy1.codempmt%type; tcodempl
  p_month     number;
  p_year      number;
  p_rate      number;
  p_typretmt  varchar2(4000 char); -- tretirmt.typretmt%type; TCODRETM
  p_myr       number;
  p_fyr       number;

  procedure initial_value (json_str_input in clob);
  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_yearretire (json_str_input in clob, json_str_output out clob);


end hrpy2qx;

/
