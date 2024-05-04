--------------------------------------------------------
--  DDL for Package HRRPSBX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRPSBX" is
-- last update: 07/08/2020 09:40

  v_chken      varchar2(100 char);

  param_msg_error     varchar2(4000 char);

  global_v_coduser      varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_codempid     temploy1.codempid%type;
  global_v_lang         varchar2(10 char) := '102';

  p_codcompy            tcompny.codcompy%type;
  p_comlevel            tcompnyc.comlevel%type;
  b_index_codcompy      varchar2(4000 char);
  b_index_codcomp       varchar2(4000 char);
  b_index_codwork       varchar2(4000 char);
  b_index_splitrow      varchar2(4000 char);
  b_index_splitcol      varchar2(4000 char);

  p_logic1              json_object_t;
  p_logic2              json_object_t;
  p_logic3              json_object_t;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_date(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);
  procedure getDropdowns(json_str_input in clob, json_str_output out clob);
  procedure genDropdowns(json_str_output out clob);
  procedure check_index;

END; -- Package spec

/
