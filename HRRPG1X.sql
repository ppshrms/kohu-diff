--------------------------------------------------------
--  DDL for Package HRRPG1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRPG1X" as
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

  b_index_dteyear       tpotentp.dteyear%type;
  b_index_codcomp       tcenter.codcomp%type;
  b_index_codcompy      tcompny.codcompy%type;
  b_index_comlevel      tcenter.comlevel%type;
  b_index_col_grp       varchar2(1000);

  procedure initial_value(json_str in clob);
  procedure get_type_monthly_access_rate(json_str_input in clob,json_str_output out clob);
  procedure get_existing_manpower_by_criteria(json_str_input in clob,json_str_output out clob);
  procedure get_sum_employee_each_department(json_str_input in clob,json_str_output out clob);
  procedure get_agency_vacancy_summary(json_str_input in clob,json_str_output out clob);
  procedure get_list_of_talent(json_str_input in clob,json_str_output out clob);
  procedure get_9_box(json_str_input in clob,json_str_output out clob);
end;

/
