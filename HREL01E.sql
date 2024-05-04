--------------------------------------------------------
--  DDL for Package HREL01E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HREL01E" as

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  p_codapp                  varchar2(10 char) := 'HREL41E';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  global_v_zupdsal          varchar2(10 char);

  p_codcours    tcourse.codcours%type;
  p_codcate     tcodcate.codcodec%type;
  p_codsubject  tvsubject.codsubj%type;
  p_chaptno     tvchapter.chaptno%type;

  json_obj        json_object_t;
  p_coursDetail   json_object_t;
  p_subjectDetail json_object_t;
  p_lessonDetail  json_object_t;
  p_tcourse       json_object_t;
  p_tcoursub      json_object_t;
  p_tvchapter     json_object_t;

  procedure initial_value (json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_detail_tcourse(json_str_input in clob,json_str_output out clob);
  procedure get_detail_subject(json_str_input in clob,json_str_output out clob);
  procedure get_lesson_detail(json_str_input in clob,json_str_output out clob);
  procedure post_save_detail(json_str_input in clob,json_str_output out clob);
  procedure post_save_subject(json_str_input in clob,json_str_output out clob);
  procedure post_save_lesson(json_str_input in clob,json_str_output out clob);

end hrel01e;

/
