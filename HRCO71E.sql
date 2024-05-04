--------------------------------------------------------
--  DDL for Package HRCO71E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO71E" as
-- last update: 20/04/2018 10:30:00

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);
  
  p_codmodule               thelp.codmodule%type;
  p_numtopic                thelpd.numtopic%type;
  
  param_detail              json_object_t;
  param_json                json_object_t;
  
  obj_detail                json_object_t;

  v_flg                     varchar2(100 char);
  p_filedoc                 thelp.filedoc%type;
  p_filemedia               thelp.filemedia%type;
  p_descmodule              thelp.descmodulee%type;

  procedure initial_value (json_str in clob);
  
  procedure get_topic (json_str_input in clob, json_str_output out clob);
  procedure gen_topic (json_str_output out clob);
  
  procedure get_subtopic (json_str_input in clob, json_str_output out clob);
  procedure gen_subtopic (json_str_output out clob);
--
  procedure post_save_topic (json_str_input in clob, json_str_output out clob);
  procedure post_save_subtopic (json_str_input in clob, json_str_output out clob);
  procedure check_save_subtopic;

end HRCO71E;

/
