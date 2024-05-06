--------------------------------------------------------
--  DDL for Package M_HRESZ1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRESZ1E" AS

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;
  global_v_zupdsal          varchar2(100 char);

  p_codcomp                 VARCHAR2(40 char);
  p_budget_month            number;
  p_budget_year             number;

  p_dtestrt                 date;
  p_dteend                  date;
  p_qtymanpw                number := 0;
  p_qtyhwork                varchar2(10 char);
  p_qtyhworkall             number := 0;
  p_pctbudget               number := 0;
  p_pctabslv                number := 0;
  p_qtybudget               number := 0;
  param_json                json_object_t;

  p_qtyhwork_hour           varchar2(10 char);  -- issue(4449#1467) 10/11/2023
  p_qtybudget_hour          varchar2(10 char);  -- issue(4449#1467) 10/11/2023

  procedure get_detail_data(json_str_input in clob, json_str_output out clob);
  procedure get_man_pw_data(json_str_input in clob, json_str_output out clob);
  procedure get_ot_budget_data(json_str_input in clob, json_str_output out clob);
  procedure save_detail_data(json_str_input in clob, json_str_output out clob);
  procedure save_data_table(json_str_output out clob);

END M_HRESZ1E;

/
