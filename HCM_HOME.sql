--------------------------------------------------------
--  DDL for Package HCM_HOME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_HOME" AS
-- update 21/09/2022 14:29

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_prefix_emp   varchar2(10 char);

  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4 char);

  p_year                number;
  p_month               number;
  p_codcomp             tcenter.codcomp%type;
  p_comlevel            tcenter.comlevel%type;
  p_img                 tusrconfig.value%type;

  v_stmt              	varchar2(5000 char);

  p_grpseq              tusrconth.numseq%type;
  p_grpnam              tusrconth.namgrp%type;
  p_grpempid            tusrcontd.codempid%type;

  p_flgused             twidgetusr.flgused%type;
  p_layoutcol           twidgetusr.layoutcol%type;
  p_layoutrow           twidgetusr.layoutrow%type;
  p_layoutposition      twidgetusr.layoutposition%type;
  p_codwg            		twidgetusr.codwg%type;
  p_temphead_codempid   clob;
  p_codcomp_level       varchar2(100 char);
  p_codapp              tapplscr.codapp%type;
  p_dtestrt             date;
  p_dteend              date;
  
  type arr_1d is table of varchar2(4000 char) index by binary_integer;

  function get_calendar(json_str_input in clob) return clob;

  function get_calendar_manager(json_str_input in clob) return clob;

  function get_announcement(json_str_input in clob) return clob;

  function get_knowledge(json_str_input in clob) return clob;

  function get_warning(json_str_input in clob) return clob;

  function get_news(json_str_input in clob) return clob;

  function get_banner(json_str_input in clob) return clob;

  function get_profile_img(json_str_input in clob) return clob;

  function change_profile_img(json_str_input in clob) return clob;

  function get_group_contact(json_str_input in clob) return clob;

  function create_group_contact(json_str_input in clob) return clob;

  function rename_group_contact(json_str_input in clob) return clob;

  function remove_group_contact(json_str_input in clob) return clob;

  function add_member_group_contact(json_str_input in clob) return clob;

  function remove_member_group_contact(json_str_input in clob) return clob;

  function get_empcontact_all(json_str_input in clob) return clob;

  function get_all_emp(json_str_input in clob) return clob;

  function get_wg_adj_flg(json_str_input in clob) return clob;

  function delete_all_wg(json_str_input in clob) return clob;
  function change_position_wg(json_str_input in clob) return clob;

  function get_wg_usr_by_codusr(json_str_input in clob) return VARCHAR2;

  function get_labels(json_str_input in clob) return clob;

  procedure get_atktest(json_str_input in clob, json_str_output out clob);
  procedure get_atktest_department(json_str_input in clob, json_str_output out clob);

END HCM_HOME;

/
