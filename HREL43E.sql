--------------------------------------------------------
--  DDL for Package HREL43E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HREL43E" is

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  p_codapp                  varchar2(10 char) := 'HREL43E';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  global_v_zupdsal          varchar2(10 char);

  p_dteyreap                TAPPEMP.DTEYREAP%type;
  p_numtime                 TAPPEMP.NUMTIME%type;
  p_codcomp                 TAPPEMP.CODCOMP%type;
  p_codempid                ttestemp.codempid%type;
  p_flgtest                 varchar2(10 char);

  p_codlogin                tappoinf.codlogin%type;
  p_codpwd                  tappoinf.codpwd%type;

  p_codexam                 ttestemp.codexam%type;
  p_dtetest                 ttestemp.dtetest%type;
  p_namtest                 ttestemp.namtest%type;
  p_dtetestst               ttestemp.dtetestst%type;
  p_numappl                 ttestemp.numappl%type;
  p_numreql                 ttestemp.numreql%type;
  p_codcompl                ttestemp.codcompl%type;
  p_codposl                 ttestemp.codposl%type;
  p_typtest                 ttestemp.typtest%type;
  p_flglogin                ttestemp.flglogin%type;
  p_codpos                  ttestemp.codpos%type;
  p_codempidc               ttestemp.codempidc%type;
  p_typeexam                tvquest.typeexam%type;

  p_dteyear                 ttestemp.dteyear%type;
  p_numclseq                ttestemp.numclseq%type;
  p_codcours                ttestemp.codcours%type;
  p_codsubj                 ttestemp.codsubj%type;
  p_chaptno                 ttestemp.chaptno%type;
  p_dtetrain                ttestemp.dtetrain%type;
  p_codpswd                 ttestemp.codpswd%type;
  p_typetest                ttestemp.typetest%type;
  p_dtecourst               tlrncourse.dtecourst%type;
  p_numapseq                tappoinf.numapseq%type;
  p_codposrq                tappoinf.codposrq%type;
  p_numreqrq                tappoinf.numreqrq%type;
  p_codquest                ttestempd.codquest%type;

  p_flg_send_exam            varchar2(1 char) := 'N';


  json_obj                  json_object_t;

  procedure initial_value (json_str in varchar2);
  procedure check_index;
  procedure get_index_emp (json_str_input in clob,json_str_output out clob);
  procedure get_index (json_str_input in clob,json_str_output out clob);
  procedure get_detail (json_str_input in clob,json_str_output out clob);
  procedure get_detail_exam (json_str_input in clob,json_str_output out clob);
  procedure post_save_exam (json_str_input in clob,json_str_output out clob);
  procedure post_send_exam (json_str_input in clob,json_str_output out clob);

end hrel43e;

/
