--------------------------------------------------------
--  DDL for Package HRAP3WE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP3WE" is

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  p_codapp                  varchar2(10 char) := 'HRAP3WE';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  global_v_zupdsal          varchar2(10 char);

  p_dteyreap                TAPPEMP.DTEYREAP%type;
  p_numtime                 TAPPEMP.NUMTIME%type;
  p_codcomp                 TAPPEMP.CODCOMP%type;
  p_flgimport               varchar2(10 char) := 'N';

  p_table                   json_object_t;
  p_params                  json_object_t;
  p_dteupd                  date;
  p_coduser                 tusrprof.coduser%type;
  p_score                   tstdis.pctwkstr%type;
  json_obj                  json_object_t;



  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure get_index (json_str_input in clob,json_str_output out clob);
  procedure get_popup (json_str_input in clob,json_str_output out clob);
  procedure save_process (json_str_input in clob,json_str_output out clob);
  procedure post_save_index(json_str_input in clob,json_str_output out clob);
  procedure get_grade (json_str_input in clob,json_str_output out clob);

end hrap3we;

/
