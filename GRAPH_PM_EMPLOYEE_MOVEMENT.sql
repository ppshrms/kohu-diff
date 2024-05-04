--------------------------------------------------------
--  DDL for Package GRAPH_PM_EMPLOYEE_MOVEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "GRAPH_PM_EMPLOYEE_MOVEMENT" AS
  conf_display_codcomp  boolean;
  conf_defalut_complvl  varchar2(10 char);
  
  global_v_coduser      varchar2(4000 char);
  global_v_codpswd      varchar2(4000 char);
  global_v_lang         varchar2(4000 char) := '102';
  global_v_codempid     varchar2(4000 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4 char);
  param_msg_error       varchar2(4000 char);

  b_index_year          varchar2(100 char);
  b_index_month         varchar2(100 char);
  b_index_comgrp        varchar2(100 char);
  b_index_codcomp       varchar2(100 char);
  b_index_complvl       varchar2(100 char);
  b_index_codtrn        varchar2(100 char);
  b_index_codsex        varchar2(100 char);

  function get_employee_movement_summary(json_str_input clob) return clob;
  function get_employee_movement_by_movement(json_str_input clob) return clob;
  function get_employee_movement_by_department(json_str_input clob) return clob;
end;

/
