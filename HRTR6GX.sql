--------------------------------------------------------
--  DDL for Package HRTR6GX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR6GX" is

  param_msg_error         varchar2(4000 char);
  global_v_coduser        varchar2(100 char);
  global_v_codempid       varchar2(100 char);
  global_v_lang           varchar2(10 char) := '102';
  json_params             json;

  global_v_zminlvl        number;
  global_v_zwrklvl        number;
  global_v_numlvlsalst    number;
  global_v_numlvlsalen    number;
  v_zupdsal        varchar2(100 char);

  p_codcomp              thistrnn.codcomp%type;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

end HRTR6GX;

/
