--------------------------------------------------------
--  DDL for Package HRAL13E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL13E" is

  param_msg_error           varchar2(4000 char);

  p_codapp                  varchar2(10 char) := 'HRAL13E';
  b_index_codcompy          tcenter.codcompy%type;

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          number;

  p_codcompy                tcenter.codcompy%type;
  p_codcompyCopy            tcenter.codcompy%type;
  p_codshift                tshiftcd.codshift%type;
  p_codleave                tleavecd.codleave%type;
  p_typleave                tleavecd.codleave%type;
  p_typleaveOld             varchar2(1000 char);
  p_flgess                  varchar2(100 char);
  p_flgCopy                 varchar(1 char);

  json_codcompy             json_object_t;
  isInsertReport            boolean := false;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_detail;

  procedure get_index_shift(json_str_input in clob, json_str_output out clob);
  procedure gen_index_shift(json_str_output out clob);

  procedure get_index_leave(json_str_input in clob, json_str_output out clob);
  procedure gen_index_leave(json_str_output out clob);

  procedure get_detail_leave(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_leave(json_str_output out clob);

  procedure post_index(json_str_input in clob, json_str_output out clob);
  procedure save_index_shift(json_str_input in clob);
  procedure save_index_leave(json_str_input in clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt_codshift(obj_data in json_object_t);
  procedure insert_ttemprpt_codleave(obj_data in json_object_t);
  procedure insert_ttemprpt_typleave(obj_data in json_object_t);

  procedure get_codshift_all(json_str_input in clob, json_str_output out clob);
  procedure get_codleave_all(json_str_input in clob, json_str_output out clob);
  procedure get_typleave_all(json_str_input in clob, json_str_output out clob);
  procedure get_codleave_bytype(json_str_input in clob, json_str_output out clob);

  procedure get_copylist(json_str_input in clob, json_str_output out clob);
  procedure gen_copylist(json_str_output out clob);


end HRAL13E;

/
