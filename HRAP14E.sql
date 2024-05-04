--------------------------------------------------------
--  DDL for Package HRAP14E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP14E" as
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

  p_codcomp                 taplvl.codcomp%type;
  p_codaplvl                taplvl.codaplvl%type;
  p_dteeffec                taplvl.dteeffec%type;

  p_codcompQuery            taplvl.codcomp%type;
  p_codaplvlQuery           taplvl.codaplvl%type;
  p_dteeffecQuery           taplvl.dteeffec%type;

  p_condition               VARCHAR2(1000 CHAR);

  p_isCopy              varchar2(2 char) := 'N';

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_copy_list(json_str_input in clob, json_str_output out clob);
  procedure get_emp_list(json_str_input in clob, json_str_output out clob);
  procedure post_save(json_str_input in clob, json_str_output out clob);
end HRAP14E;

/
