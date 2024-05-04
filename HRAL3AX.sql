--------------------------------------------------------
--  DDL for Package HRAL3AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL3AX" as

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal   		    varchar2(4 char);

  p_codcomp    varchar(4000 char);
  p_dteyear    varchar(4 char);
  p_stmonth    varchar(2 char);
  p_enmonth    varchar(2 char);

  procedure initial_value (json_str_input in clob);
  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);

end HRAL3AX;

/
