--------------------------------------------------------
--  DDL for Package HRES80X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES80X" as

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  p_codempid                thisheal.codempid%type;
  p_dteyear                 thealinf1.dteyear%type;

  -- report
  p_additional_year         number := 0;
  isInsertReport            boolean := false;
  p_codapp                  varchar2(10 char) := 'HRBFB3X';

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure get_thisheal (json_str_input in clob, json_str_output out clob);
  procedure gen_thisheal (json_str_output out clob);
  procedure get_thisheald (json_str_input in clob, json_str_output out clob);
  procedure gen_thisheald (json_str_output out clob);
  procedure get_thishealf (json_str_input in clob, json_str_output out clob);
  procedure gen_thishealf (json_str_output out clob);
  procedure get_thealinfx (json_str_input in clob, json_str_output out clob);
  procedure gen_thealinfx (json_str_output out clob);
  procedure get_thealinfl (json_str_input in clob, json_str_output out clob);
  procedure gen_thealinfl (json_str_output out clob);
  procedure get_thealinf1 (json_str_input in clob, json_str_output out clob);
  procedure gen_thealinf1 (json_str_output out clob);
  procedure get_thealinf2 (json_str_input in clob, json_str_output out clob);
  procedure gen_thealinf2 (json_str_output out clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure insert_ttemprpt (json_str_input clob);
  procedure insert_ttemprpt_thisheald (json_str_input clob);
  procedure insert_ttemprpt_thishealf (json_str_input clob);
  procedure insert_ttemprpt_thealinf1 (json_str_input clob);
end hres80x;

/
