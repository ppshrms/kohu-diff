--------------------------------------------------------
--  DDL for Package HRES85X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES85X" is
-- create: 24/02/2020 15:38

  --param error warning
  param_msg_error       varchar2(4000 char);

  v_chken               varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_zupdsal      number;

  b_index_codempid      varchar2(4000 char);
  p_dteyrepay           number;
  --
  procedure initial_value(json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_data_emp(json_str_input in clob, json_str_output out clob);
  procedure gen_data_emp(json_str_output out clob);



END HRES85X; -- Package spec

/
