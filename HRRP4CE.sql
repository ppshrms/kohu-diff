--------------------------------------------------------
--  DDL for Package HRRP4CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP4CE" as
  --para
  param_msg_error       varchar2(4000);
  param_msg_error_mail  varchar2(4000 char);

  --global
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_zupdsal      varchar2(4 char);

  global_v_coduser      varchar2(100);
  global_v_codempid     varchar2(100);
  global_v_lang         varchar2(100);
  global_v_zyear        number  := 0;
  global_v_chken        varchar2(10) := hcm_secur.get_v_chken;

  b_index_year          number;
  b_index_numtime       tsuccpln.numtime%type;
  b_index_codcomp       tsuccpln.codcomp%type;
  b_index_codpos        tsuccpln.codpos%type;
  p_dteappr             tsuccpln.dteappr%type;
  p_codappr             tsuccpln.codappr%type;
  p_codempid_query      temploy1.codempid%type;
  p_typcond             varchar2(10);
  p_stmt                clob;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_index_detail(json_str_input in clob,json_str_output out clob);
  procedure gen_index_detail(json_str_output out clob);

  procedure save_index(json_str_input in clob,json_str_output out clob);
  procedure process_save_index(json_str_input in clob,json_str_output out clob);

  procedure get_data_codempid(json_str_input in clob, json_str_output out clob);
  procedure gen_data_codempid(json_str_output out clob);
  procedure get_list_codemp(json_str_input in clob, json_str_output out clob);
  procedure gen_list_codemp(json_str_output out clob);

  procedure get_detail_course(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_course(json_output out json_object_t);

  procedure get_detail_develop(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_develop(json_output out json_object_t);

  procedure send_email(json_str_input in clob,json_str_output out clob);
  procedure process_send_email(json_str_input in clob,json_str_output out clob);
end;

/
