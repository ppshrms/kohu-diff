--------------------------------------------------------
--  DDL for Package HREL52X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HREL52X" as 
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
  
  p_dtestrt     date;
  p_dteend      date;
  p_codcomp     tcenter.codcomp%type;
  p_codcatexm   tcodcatexm.codcodec%type;  
  p_codexam     tcodexam.codcodec%type;  
  p_codcours    ttestemp.codcours%type;  
  p_typtest     varchar2(10 char);  
--  p_remark      ttestset.remark%type;  
  p_obj_data    json_object_t;  
  p_obj_search  json_object_t;  
  
  procedure initial_value (json_str in varchar2);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob); 
end hrel52x;

/
