--------------------------------------------------------
--  DDL for Package HREL11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HREL11E" as
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
  global_v_codcomp      tcenter.codcomp%type;

  b_index_dteyear       tpotentp.dteyear%type;
  b_index_dtemonth      varchar2(10);

  procedure initial_value(json_str in clob);
  procedure get_graph_learning(json_str_input in clob,json_str_output out clob);
  procedure get_calendar(json_str_input in clob,json_str_output out clob);
  procedure get_open_el(json_str_input in clob,json_str_output out clob);
  procedure get_course_study(json_str_input in clob,json_str_output out clob);
  procedure get_learn_history(json_str_input in clob,json_str_output out clob);
  procedure get_top_rank(json_str_input in clob,json_str_output out clob);
end;

/
