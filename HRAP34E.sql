--------------------------------------------------------
--  DDL for Package HRAP34E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP34E" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4000 char);

  b_index_dteyreap          tappfm.dteyreap%type;
  b_index_numtime           tappfm.numtime%type;
  b_index_codapman          tappfm.codapman%type;
  b_index_dteapman          tappfm.dteapman%type;
  b_index_codcomp           tappfm.codcomp%type;
  b_index_codpos            tappfm.codpos%type;
  b_index_flgappr           tappfm.flgappr%type;
  b_index_flgtypap          tappfm.flgtypap%type; -- Beh, Cmp
  b_index_codaplvl          tappfm.codaplvl%type;

  v_global_codform          tappfm.codform%type;
  v_global_codempid_query   tappfm.codempid%type;
  v_global_flgapman         tappfm.flgapman%type;
  v_global_numseq           tappfm.numseq%type;
  v_global_dteapstr         tstdisd.dteapstr%type;
  v_global_dteapend         tstdisd.dteapend%type;
  v_global_flgtypap         tstdisd.flgtypap%type; -- C = 360, T = Bottom Up
  v_total_numtime           number;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_behavior_form_popup(json_str_input in clob, json_str_output out clob);
  procedure gen_behavior_form_popup(json_str_output out clob);

  procedure get_competency_popup(json_str_input in clob, json_str_output out clob);
  procedure gen_competency_popup(json_str_output out clob);

  procedure get_assessors_popup(json_str_input in clob, json_str_output out clob);
  procedure gen_assessors_popup(json_str_output out clob);

  procedure post_detail(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob);

  procedure get_employee_data(json_str_input in clob, json_str_output out clob);
  procedure gen_employee_data(json_str_output out clob);

  procedure get_all_score(json_str_input in clob, json_str_output out clob);
  procedure gen_all_score(json_str_input in clob, json_str_output out clob);

  -- internal
  procedure get_taplvl_where(p_codcomp_in in varchar2,p_codaplvl in varchar2,p_codcomp_out out varchar2,p_dteeffec out date);
  procedure get_taplvld_where(p_codcomp_in in varchar2,p_codaplvl in varchar2,p_codcomp_out out varchar2,p_dteeffec out date);
  function get_competency_score(p_codcomp varchar2,p_codpos varchar2,p_codtency varchar2,p_codskill varchar2,p_grade number) return number;
  procedure cal_all_score(
            p_codempid        in varchar2,
            p_dteyreap        in varchar2,
            p_numtime         in number,
            p_numseq          in number,
            p_codform         in varchar2,
            p_codcomp         in varchar2,
            p_codpos          in varchar2,
            p_codaplvl        in varchar2,
            obj_beh           in out json_object_t,
            obj_cmp           in out json_object_t,
            p_qtyscornet      out number,  -- net score of beh or cmp
            p_qtyta           out number,  -- time attendance score          (score/fscore*100)
            p_qtypuns         out number,  -- punish score                   (score/fscore*100)
            p_qtyta_puns      out number,  -- time attendance + punish score (score/fscore*100)
            p_qtybeh          out number,  -- behavior score                 (score/fscore*100)
            p_qtycmp          out number,  -- competency score               (score/fscore*100)
            p_qtykpi          out number,  -- kpi score                      (score/fscore*100)
            p_qtytot          out number,  -- total of all score weight 100%
            p_total_numitem   out number,  -- amount of beh or cmp item
            obj_numtime       out json_object_t,
            obj_numtime_label out json_object_t
  );

end hrap34e;

/
