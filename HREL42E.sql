--------------------------------------------------------
--  DDL for Package HREL42E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HREL42E" is

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  p_codapp                  varchar2(10 char) := 'HREL42E';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  global_v_zupdsal          varchar2(10 char);

  p_dteyreap                TAPPEMP.DTEYREAP%type;
  p_numtime                 TAPPEMP.NUMTIME%type;
  p_codcomp                 TAPPEMP.CODCOMP%type;
  p_codempid                temploy1.codempid%type;
  p_flgtest                 varchar2(10 char);

  p_codlogin                tappoinf.codlogin%type;
  p_codpwd                  tappoinf.codpwd%type;

  p_codexam    ttestemp.codexam%type;
  p_dtetest    ttestemp.dtetest%type;
  p_namtest    ttestemp.namtest%type;
  p_dtetestst   ttestemp.dtetestst%type;
  p_numappl    ttestemp.numappl%type;
  p_numreql    ttestemp.numreql%type;
  p_codcompl   ttestemp.codcompl%type;
  p_codposl    ttestemp.codposl%type;
  p_typtest    ttestemp.typtest%type;
  p_flglogin   ttestemp.flglogin%type;
  p_codpos     ttestemp.codpos%type;

  json_obj    json_object_t;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure get_index_emp (json_str_input in clob,json_str_output out clob);
  procedure get_detail_appl (json_str_input in clob,json_str_output out clob);
  procedure post_forgot_password (json_str_input in clob,json_str_output out clob);


end hrel42e;

/
