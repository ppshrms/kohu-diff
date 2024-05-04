--------------------------------------------------------
--  DDL for Package HRAP4BE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP4BE" as
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

  b_index_dteyreap      tkpiemp.dteyreap%type;
  b_index_numtime       tkpiemp.numtime%type;
  b_index_codempid      tkpiemp.codempid%type;
  b_index_codreview     tappkpimth.codreview%type;
  b_index_dtereview     tappkpimth.dtereview%type;

  type t_arr_number is table of number index by binary_integer;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure get_act_plan(json_str_input in clob,json_str_output out clob);
  procedure save_review(json_str_input in clob,json_str_output out clob);
end;

/
