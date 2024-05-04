--------------------------------------------------------
--  DDL for Package HRPMS8X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMS8X" is
-- last update: 09/02/2021 17:30 redmine3020

  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  param_msg_error       varchar2(4000 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  numYearReport         number;
  obj_data              json_object_t;
  obj_row               json_object_t;

  param_json_row        json_object_t;
  p_codcomp_array       json_object_t;

  p_dteyrbug          TMANPW.DTEYRBUG%TYPE;
  p_syncond           varchar2(4000 char);

  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure get_treppms8x(json_str_input in clob, json_str_output out clob);
  procedure gen_treppms8x(json_str_output out clob);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_json_obj(json_str_input in clob);
  procedure check_getindex;
  procedure insert_treppms8x;
  procedure delete_treppms8x;
  procedure gen_data(json_str_output out clob);

end HRPMS8X;

/
