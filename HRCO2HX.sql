--------------------------------------------------------
--  DDL for Package HRCO2HX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2HX" AS
--last update  redmine3208
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          tpostn.coduser%type;
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  json_codempid             json_object_t;
  json_codcomp              json_object_t;
  json_codpos             json_object_t;
  isInsertReport            boolean := false;
  p_detail                  clob;
  obj_detail                json_object_t;
  p_codapp                  varchar2(10 char) := 'HRCO2HX';
  p_codcomp                 temphead.codcomph%type;
  p_codpos                  temphead.codposh%type;
  p_codempid                temphead.codempidh%type;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (v_codcomp varchar2,v_codpos varchar2,v_codempid varchar2, json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure delete_ttemprpt;
  procedure insert_ttemprpt(obj_data in json_object_t);

END HRCO2HX;

/
