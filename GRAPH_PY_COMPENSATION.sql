--------------------------------------------------------
--  DDL for Package GRAPH_PY_COMPENSATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "GRAPH_PY_COMPENSATION" AS
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
  v_chken               varchar2(10 char);

  b_index_year          varchar2(100 char);
  b_index_month         varchar2(100 char);
  b_index_comgrp        varchar2(100 char);
  b_index_codcomp       varchar2(100 char);
  b_index_complvl       varchar2(100 char);
  b_index_typpayroll    varchar2(100 char);
  b_index_codpay        varchar2(100 char);
  b_index_codtypemp     varchar2(100 char);

  function get_compensation_summary(json_str_input clob) return clob;
  function get_compensation_by_typpayroll(json_str_input clob) return clob;
  function get_compensation_by_department(json_str_input clob) return clob;
  function get_compensation_by_month(json_str_input clob) return clob;
end;

/
