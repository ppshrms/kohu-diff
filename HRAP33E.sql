--------------------------------------------------------
--  DDL for Package HRAP33E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP33E" is

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  p_codapp                  varchar2(10 char) := 'HRAP33E';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen    	number;
  global_v_zupdsal          varchar2(10 char);
  p_codempid                       temploy1.codempid%type;
  p_dteyreap                TAPPEMP.DTEYREAP%type;
  p_numtime                 TAPPEMP.NUMTIME%type;
  p_codcomp                 TAPPEMP.CODCOMP%type;
  p_flgimport               varchar2(10 char) := 'N';

  p_table                   json_object_t;
  p_params                  json_object_t;
  p_dteupd        date;
  p_coduser        tusrprof.coduser%type;
  json_obj    json_object_t;

  p_flgconfemp    tappemp.flgconfemp%type;
  p_dteconfemp    tappemp.dteconfemp%type;
  p_flgconfhd    tappemp.flgconfhd%type;
  p_dteconfhd    tappemp.dteconfhd%type;
  p_flgconflhd    tappemp.flgconflhd%type;
  p_dteconflhd    tappemp.dteconflhd%type;

  p_dtest       date; --<< user25 Date : 16/09/2021 3. AP Module #4302
  p_dteen       date; --<< user25 Date : 16/09/2021 3. AP Module #4302

  v_global_dteapend     tstdisd.dteapend%type;
  v_taplvl_codcomp      taplvl.codcomp%type;
  v_taplvl_dteeffec     taplvl.dteeffec%type;


  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure get_index (json_str_input in clob,json_str_output out clob);
  procedure get_detail_header (json_str_input in clob,json_str_output out clob);
  procedure get_detail_table (json_str_input in clob,json_str_output out clob);
  procedure get_detail_meaasge (json_str_input in clob,json_str_output out clob);
  procedure get_detail_competency_table (json_str_input in clob,json_str_output out clob);
  procedure get_detail_competency_course (json_str_input in clob,json_str_output out clob);
  procedure get_detail_competency_develop (json_str_input in clob,json_str_output out clob);
  procedure get_detail_approve (json_str_input in clob,json_str_output out clob);
  procedure get_punishment (json_str_input in clob,json_str_output out clob);
  procedure get_leavegroup (json_str_input in clob,json_str_output out clob);
  procedure get_comingwork (json_str_input in clob,json_str_output out clob);
  procedure get_behavior (json_str_input in clob,json_str_output out clob);
  procedure get_competency (json_str_input in clob,json_str_output out clob);
  procedure get_kpi (json_str_input in clob,json_str_output out clob);
  procedure post_save_index(json_str_input in clob,json_str_output out clob);
  procedure post_save_detail(json_str_input in clob,json_str_output out clob);

  procedure get_taplvl_where(p_codcomp_in in varchar2,p_codaplvl in varchar2,p_codcomp_out out varchar2,p_dteeffec out date);

end hrap33e;

/
