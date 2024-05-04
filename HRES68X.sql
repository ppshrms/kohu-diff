--------------------------------------------------------
--  DDL for Package HRES68X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES68X" is
-- last update: 26/02/2020 10:39

  --param error warning
  param_msg_error       varchar2(4000 char);

  v_chken               varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_coduser      varchar2(100 char);
  global_v_codpswd      varchar2(100 char);
  global_v_codempid      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  b_index_codempid      varchar2(4000 char);
  p_year                number;

  procedure initial_value(json_str in clob);
  procedure get_data_emp(json_str_input in clob, json_str_output out clob);
  procedure gen_data_emp(json_str_output out clob);
  procedure get_calendar(json_str_input in clob, json_str_output out clob);
  procedure gen_calendar(json_str_output out clob);
  procedure get_shift(json_str_input in clob,json_str_output out clob);
END HRES68X; -- Package spec

/
