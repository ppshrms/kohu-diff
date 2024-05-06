--------------------------------------------------------
--  DDL for Package HRTR72X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR72X" AS
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  p_codcomp                 thistrnn.codcomp%type;
  p_codempid                thistrnn.codempid%type;
  p_dteyearst               thistrnn.dteyear%type;
  p_dteyearen               thistrnn.dteyear%type;
  p_dteyear                 thistrnn.dteyear%type;
  p_codcours                thistrnn.codcours%type;
  p_numclseq                thistrnn.numclseq%type;
  p_codtparg                thistrnn.codtparg%type;

  -- report
  v_additional_year         number := to_number(hcm_appsettings.get_additional_year);
  json_params               json_object_t;
  isInsertReport            boolean := false;
  p_codapp                  varchar2(10 char) := 'HRTR72X';

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_thistrnn (json_str_input in clob, json_str_output out clob);
  procedure gen_thistrnn (json_str_output out clob);
  procedure get_tknowleg (json_str_input in clob, json_str_output out clob);
  procedure gen_tknowleg (json_str_output out clob);
  procedure get_thistrnb (json_str_input in clob, json_str_output out clob);
  procedure gen_thistrnb (json_str_output out clob);
  procedure get_thisclsss (json_str_input in clob, json_str_output out clob);
  procedure gen_thisclsss (json_str_output out clob);
  procedure get_thistrnf (json_str_input in clob, json_str_output out clob);
  procedure gen_thistrnf (json_str_output out clob);
  procedure get_thiscost (json_str_input in clob, json_str_output out clob);
  procedure gen_thiscost (json_str_output out clob);
  procedure get_thistrnp (json_str_input in clob, json_str_output out clob);
  procedure gen_thistrnp (json_str_output out clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure insert_ttemprpt(obj_data in json_object_t);
  procedure insert_ttemprpt_tknowleg(obj_data in json_object_t);
  procedure insert_ttemprpt_thistrnb(obj_data in json_object_t);
  procedure insert_ttemprpt_thisclsss(obj_data in json_object_t);
  procedure insert_ttemprpt_thistrnf(obj_data in json_object_t);
  procedure insert_ttemprpt_thiscost(obj_data in json_object_t);
  procedure insert_ttemprpt_thistrnp(obj_data in json_object_t);
END HRTR72X;

/
