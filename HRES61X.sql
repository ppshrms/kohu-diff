--------------------------------------------------------
--  DDL for Package HRES61X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES61X" as
-- last update: 20/04/2018 10:30:00
  param_msg_error           varchar2(4000 char);
  global_v_coduser          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  p_codempid                varchar2(1000 char);
  p_codcomp                 varchar2(1000 char);
  p_codcalen                varchar2(1000 char);
  p_month                   varchar2(2 char);
  b_month                   varchar2(2 char);
  p_month_insert            varchar2(2 char);
  p_year                    varchar2(4 char);

  -- special
  v_text_key                varchar2(100 char) := '';
  v_fd_key                  varchar2(100 char) := 'HRES61X';
  -- report
  p_codapp                  varchar2(10 char) := 'HRES61X';
  b_codapp                  varchar2(10 char) := 'HRES61X';
  isInsertReport            boolean := false;
  TYPE typ_char_number IS
    TABLE OF VARCHAR2(4000 CHAR) INDEX BY BINARY_INTEGER;

  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_groupplan(json_str_input in clob,json_str_output out clob);
  procedure get_groupemp(json_str_input in clob,json_str_output out clob);
  procedure gen_groupemp(json_str_output out clob);
  procedure get_calendar(json_str_input in clob,json_str_output out clob);
  procedure get_shift(json_str_output out clob);
  procedure gen_report(json_str_input in clob,json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_report_comp(obj_row in json_object_t);
  procedure insert_ttemprpt_comp(v_numseq in number, obj_data in json_object_t);
  procedure insert_ttemprpt_emp(arr_week_day in typ_char_number, arr_week_codshift in typ_char_number, arr_week_desc in typ_char_number, arr_week_typwork in typ_char_number);
  procedure insert_ttemprpt_emp_main(obj_data in json_object_t);

end HRES61X;

/
