--------------------------------------------------------
--  DDL for Package HRAP31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP31E" as
  --para
  param_msg_error       varchar2(4000);

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

  b_index_dteyreap      tobjemp.dteyreap%type;
  b_index_numtime       tobjemp.numtime%type;
  b_index_codempid      tobjemp.codempid%type;

  p_dteyreap            tappfm.dteyreap%type;
  p_numtime             tappfm.numtime%type;
  p_codapman            tappfm.codapman%type;
  p_codcomp             tappfm.codcomp%type;
  p_codaplvl            tappfm.codaplvl%type;
  p_codempid_query      tappfm.codempid%type;
  p_numseq              tappfm.numseq%type;
  p_codcompy            tstdisd.codcomp%type;
  p_codkpi              tappkpimth.codkpi%type;
  p_codskill            tcomptcr.codskill%type;
  p_grade               tcomptcr.grade%type;
  p_expectgrade         tcomptcr.grade%type;
  p_grade1              tcomptcr.grade%type;
  p_grade2              tcomptcr.grade%type;
  p_grade3              tcomptcr.grade%type;
  p_codpos              tappfm.codpos%type;
  p_codform             taplvl.codform%type;
  p_flg_object          boolean := false;
  p_dteapman            tappfm.dteapman%type;
  v_global_dteapend     tstdisd.dteapend%type;
  v_taplvl_codcomp      taplvl.codcomp%type;
  v_taplvl_dteeffec     taplvl.dteeffec%type;

  v_selected_codempid   tappfm.codempid%type;
  v_selected_dteyreap   tappfm.dteyreap%type;
  v_selected_numtime    tappfm.numtime%type;
  v_selected_numseq     tappfm.numseq%type;
  v_global_flgRightDisable   boolean := false;

  type t_arr_number is table of number index by binary_integer;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);

  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure gen_detail_table(json_str_output out clob);
  procedure get_detail_table(json_str_input in clob,json_str_output out clob);
  procedure gen_detail_course_table(json_str_output out clob);
  procedure get_detail_course_table(json_str_input in clob,json_str_output out clob);
  procedure gen_detail_develop_table(json_str_output out clob);
  procedure get_detail_develop_table(json_str_input in clob,json_str_output out clob);

  procedure get_otherassessments(json_str_input in clob,json_str_output out clob);

  procedure get_workingtime_detail(json_str_input in clob,json_str_output out clob);

  procedure get_behavior_detail(json_str_input in clob,json_str_output out clob);
  procedure get_behaviorSub(json_str_input in clob,json_str_output out clob);

  procedure get_competency_detail(json_str_input in clob,json_str_output out clob);
  procedure get_competencysub(json_str_input in clob,json_str_output out clob);

  procedure get_kpi_detail(json_str_input in clob,json_str_output out clob);
  procedure get_kpisub_table1(json_str_input in clob,json_str_output out clob);
  procedure get_kpisub_table2(json_str_input in clob,json_str_output out clob);

  procedure get_popup_coursetrain(json_str_input in clob,json_str_output out clob);

  procedure save_behavior(json_str_input in clob,json_str_output out clob);
  procedure save_behavior_sub(json_str_input in clob,json_str_output out clob);

  procedure save_kpi(json_str_input in clob,json_str_output out clob);

  procedure save_competency(json_str_input in clob,json_str_output out clob);
  procedure save_competency_sub(json_str_input in clob,json_str_output out clob);

  procedure save_detail(json_str_input in clob,json_str_output out clob);
  procedure save_lastapp;

  procedure sendmail(json_str_input in clob,json_str_output out clob);
  procedure get_taplvl_where(p_codcomp_in in varchar2,p_codaplvl in varchar2,p_codcomp_out out varchar2,p_dteeffec out date);
  procedure insert_tappemp(p_codempid_query varchar2, p_dteyreap number,  p_numtime number, p_numseq number);
  procedure upd_tappemp_qtytot(p_codempid_query varchar2, p_dteyreap number,  p_numtime number, p_flgapman varchar2,
                               p_dteapend date, p_flgconf varchar2, p_dteconf date);
end;

/
