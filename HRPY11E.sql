--------------------------------------------------------
--  DDL for Package HRPY11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY11E" as
  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';

  param_json  json_object_t;
  isEdit      boolean := true;
  isAdd       boolean := true;
  isCopy      varchar2(2 char) := 'N';
  procedure initial_value(json_str_input in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_copy_list(json_str_input in clob, json_str_output out clob);
  procedure get_copy_detail(json_str_input in clob, json_str_output out clob);
  procedure get_flg_status (json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob,json_str_output out clob);
end HRPY11E;

/
