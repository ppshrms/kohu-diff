--------------------------------------------------------
--  DDL for Package HCM_LOV_ES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_ES" is

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
  function get_interview(json_str_input in clob) return clob;            --LOV for ES Interview
  function get_ess_menu(json_str_input in clob) return clob;             --LOV for HRMS14X
  function get_children_list(json_str_input in clob) return clob;        --LOV for List of Children
  function get_reason_canceling_training(json_str_input in clob) return clob;        --LOV Reason For Canceling The Training

END HCM_LOV_ES;

/
