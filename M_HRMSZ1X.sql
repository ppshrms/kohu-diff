--------------------------------------------------------
--  DDL for Package M_HRMSZ1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRMSZ1X" is
/* Cust-Modify: KOHU-HR2301 */
-- last update: 17/10/2023 16:16
  param_msg_error   varchar2(4000 char);

  global_v_coduser  varchar2(1000 char);
  global_v_codpswd  varchar2(1000 char);
  global_v_lang     varchar2(1000 char);
  global_v_zminlvl  number;
  global_v_zwrklvl  number;
  global_v_numlvlsalst number;
  global_v_numlvlsalen number;
  v_zupdsal            varchar2(4 char);

  p_codcomp  varchar2(1000 char);
  p_month    varchar2(2 char);
  p_year     varchar2(4 char);
  p_report   varchar2(1 char);


  procedure initial_value(json_str_input in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
end;


/
