--------------------------------------------------------
--  DDL for Package HCM_LOV_AP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_AP" is
  global_v_coduser      varchar2(1000 char);
  global_v_codempid     varchar2(1000 char);
  global_v_lang         varchar2(100 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4000 char);
  v_chken               varchar2(10 char);

  v_cursor			        number;
  v_dummy               integer;
  v_stmt			          varchar2(5000 char);

  param_flg_secur       varchar2(4000 char);
  param_where           varchar2(4000 char);

  procedure initial_value(json_str in clob);
  function get_interview_form(json_str_input in clob) return clob;       --LOV for Interview Evaluation Form (LOV_AP.LOV_FORMPM - HRPM38E)
  function get_code_kpi(json_str_input in clob) return clob;             --List of KPI Code
  function get_bonus_type(json_str_input in clob) return clob;           --List of Bonus Type
  function get_grage_tkpicmpg(json_str_input in clob) return clob;       --List of Grade Item (tkpicmpg)
  function get_grage_tkpidpg(json_str_input in clob) return clob;        --List of Grade Item (tkpidpg)
  function get_mail_alert_number_ap(json_str_input in clob) return clob; --LOV for Mail Alert Number AP
  function get_indication_details(json_str_input in clob) return clob;   --LOV for Indication Details
  function get_grage_tkpiempg(json_str_input in clob) return clob;       --List of Grade Item (tkpiempg)
  function get_grage_tstdis(json_str_input in clob) return clob;         --List of Grade Item (tstdis)
  function get_color_grade_kpi(json_str_input in clob) return clob;      --List of Target (color)
end;

/
