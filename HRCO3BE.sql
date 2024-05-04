--------------------------------------------------------
--  DDL for Package HRCO3BE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO3BE" AS
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

  p_objectname              user_source.name%type;
  p_objecttype              user_source.text%type;
  p_detail                  clob;
  obj_detail                json_object_t;
  p_flg                     varchar2(100 char);

  v_sourcelength            number;

  procedure initial_value (json_str in clob);
  procedure check_detail;
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);

  procedure compile_invalid_object (json_str_input in clob, json_str_output out clob);

END HRCO3BE;

/
