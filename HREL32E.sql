--------------------------------------------------------
--  DDL for Package HREL32E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HREL32E" as

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
  v_zupdsal                 varchar2(1);

  p_codcomp     tcenter.codcomp%type;
  p_codcours    tcourse.codcours%type;
  p_codcatexm   tcodcatexm.codcodec%type;
  p_codexam     tcodexam.codcodec%type;
  json_obj      json_object_t;



  procedure initial_value (json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  --> Peerasak || Issue#9295 || 05042023
  procedure check_save(v_codempid in ttestchk.codempidc%type, v_codcomp in ttestchk.codcomp%type, v_codpos in ttestchk.codposc%type);
  --> Peerasak || Issue#9295 || 05042023
  procedure post_save_index(json_str_input in clob,json_str_output out clob);
end hrel32e;

/
