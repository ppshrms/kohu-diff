--------------------------------------------------------
--  DDL for Package HRAPG1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAPG1X" as
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

  b_index_dteyreap      tappfm.dteyreap%type;
  b_index_codcomp       tcenter.codcomp%type;
  b_index_codcompy      tcompny.codcompy%type;
  b_index_comlevel      tcenter.comlevel%type;
  b_index_numtime       tappfm.numtime%type;
  b_index_codbon        tbonus.codbon%type;
  b_index_syncond       varchar2(2000);
  b_index_codtency      tappcmpf.codtency%type;
  b_index_typdata       varchar2(1);

  procedure initial_value(json_str in clob);
  procedure get_last_kpi_org(json_str_input in clob,json_str_output out clob);
  procedure get_kpi_organize(json_str_input in clob,json_str_output out clob);
  procedure get_last_kpi_department(json_str_input in clob,json_str_output out clob);
  procedure get_kpi_department(json_str_input in clob,json_str_output out clob);
  procedure get_annual_salary_increase(json_str_input in clob,json_str_output out clob);
  procedure get_bonus_expense(json_str_input in clob,json_str_output out clob);
  procedure get_last_kpi_gap(json_str_input in clob,json_str_output out clob);
  procedure get_gap_competency(json_str_input in clob,json_str_output out clob);
  procedure get_performance_grade(json_str_input in clob,json_str_output out clob);
  procedure get_performance_grade_by_jobgrade(json_str_input in clob,json_str_output out clob);
end;

/
