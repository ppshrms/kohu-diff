--------------------------------------------------------
--  DDL for Package GRAPH_PM_HEADCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "GRAPH_PM_HEADCOUNT" AS  
  global_v_coduser      varchar2(4000 char);
  global_v_codpswd      varchar2(4000 char);
  global_v_lang         varchar2(4000 char) := '102';
  global_v_codempid     varchar2(4000 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4 char);

  b_index_year          varchar2(100 char);
  b_index_month         varchar2(100 char);
  b_index_comgrp        varchar2(100 char);
  b_index_codcomp       varchar2(100 char);
  b_index_complvl       varchar2(100 char);
  b_index_codempmt      varchar2(100 char);
  b_index_codjobgrade   varchar2(100 char);
  b_index_codpos        varchar2(100 char);
  b_index_codsex        varchar2(100 char);

  function get_headcount_summary(json_str_input clob) return clob;
  function get_headcount_by_jobgrade(json_str_input clob) return clob;
  function get_headcount_by_gender(json_str_input clob) return clob;
  function get_headcount_by_range_age(json_str_input clob) return clob;
  function get_headcount_by_company(json_str_input clob) return clob;
  function get_headcount_by_branch(json_str_input clob) return clob;
  function get_headcount_by_department(json_str_input clob) return clob;
  function get_headcount_by_service_year(json_str_input clob) return clob;
end;

/
