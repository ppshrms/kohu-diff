--------------------------------------------------------
--  DDL for Package HRAP13E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP13E" as 
  v_chken                   varchar2(100 char);

  param_msg_error           varchar2(4000 char);

  global_v_coduser          varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  v_zupdsal                 varchar2(4000 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  
  p_codcompy                tgradekpi.codcompy%type;
  p_codcompyQuery           tgradekpi.codcompy%type;
  p_dteyreap                tgradekpi.dteyreap%type;
  p_dteyreapQuery           tgradekpi.dteyreap%type;

  p_isCopy              varchar2(2 char) := 'N';
  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_copy_list(json_str_input in clob, json_str_output out clob);
  procedure post_save(json_str_input in clob, json_str_output out clob);
end HRAP13E;

/
