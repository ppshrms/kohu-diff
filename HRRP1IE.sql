--------------------------------------------------------
--  DDL for Package HRRP1IE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP1IE" is

  param_msg_error           varchar2(4000 char);

  b_index_codcompy          tcenter.codcompy%type;
  b_index_codposg           tcodgpos.codcodec%type;

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_detail_data(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_data(json_str_output out clob);

  procedure get_detail_table(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_table(json_str_output out clob);

  procedure get_codpos_all(json_str_input in clob, json_str_output out clob);

  procedure post_detail(json_str_input in clob, json_str_output out clob);
  procedure save_detail_codpos(json_str_input in clob);

end hrrp1ie;

/
