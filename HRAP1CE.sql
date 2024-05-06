--------------------------------------------------------
--  DDL for Package HRAP1CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP1CE" as 
  v_chken      varchar2(100 char);

  param_msg_error     varchar2(4000 char);

  global_v_coduser      varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  b_index_dteyreap        number;
  b_index_dteyreapQuery   number;
  b_index_codcomp         tapbudgt.codcomp%type;
  b_index_codcompQuery    tapbudgt.codcomp%type;

  v_msqerror                varchar2(4000 char);--User37 #4130 AP - PeoplePlus 19/02/2021  

  p_isCopy              varchar2(2 char) := 'N';
  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_copy_list(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure get_ninebox(json_str_input in clob, json_str_output out clob);
end hrap1ce;

/
