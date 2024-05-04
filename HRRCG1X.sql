--------------------------------------------------------
--  DDL for Package HRRCG1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRCG1X" as
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
  b_index_codpos        tpostn.codpos%type;
  b_index_typdata       varchar2(1000);

  procedure initial_value(json_str in clob);
  procedure get_cost_of_rc_by_dept(json_str_input in clob,json_str_output out clob);
  procedure get_cost_of_rc_by_position(json_str_input in clob,json_str_output out clob);
  procedure get_average_cost_of_hire(json_str_input in clob,json_str_output out clob);
  procedure get_source_of_hire(json_str_input in clob,json_str_output out clob);
  procedure get_time_per_stage(json_str_input in clob,json_str_output out clob);
end;

/
