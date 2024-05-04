--------------------------------------------------------
--  DDL for Package HRTR1DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR1DE" is

  param_msg_error   varchar2(4000 char);

  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';

  p_codapp          varchar2(10 char) := 'HRTR1DE';
  p_coduser         varchar2(50 char);

  b_index_codinsts  varchar2(4 char);

  json_params       json;
  json_codinsts     json;

  isInsertReport    boolean := false;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure get_service_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_service_detail(json_str_output out clob);
  procedure delete_data(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure save_tab1(json_str_output out clob);
  procedure save_tab2(json_str_output out clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt(obj_data in json);

end HRTR1DE;


/
