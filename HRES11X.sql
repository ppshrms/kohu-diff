--------------------------------------------------------
--  DDL for Package HRES11X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES11X" as 
  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  p_codapp                  varchar2(10 char) := 'HREL41E';
  v_zupdsal   		          varchar2(4 char);

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  global_v_zupdsal          varchar2(10 char);
  p_zyear                   number;

  p_codcomp         tjobpos.codcomp%type;
  p_codpos          tjobpos.codpos%type;
  p_codkpi          tjobkpi.codkpi%type;
  p_codtency        tjobposskil.codtency%type;
  p_codskill        tjobposskil.codskill%type;

  procedure initial_value (json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_detail_codpos(json_str_input in clob,json_str_output out clob);
  procedure get_detail_kpi(json_str_input in clob,json_str_output out clob);
  procedure get_detail_competency(json_str_input in clob,json_str_output out clob);
  procedure get_drildown_kpi(json_str_input in clob,json_str_output out clob);
  procedure get_drildown_competency(json_str_input in clob,json_str_output out clob);

end hres11x;

/
