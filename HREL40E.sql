--------------------------------------------------------
--  DDL for Package HREL40E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HREL40E" as
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
  numYearReport             number;

  p_dtestrt     date;
  p_dteend      date;
  p_codcomp     tcenter.codcomp%type;
  p_codcatexm   tcodcatexm.codcodec%type;
  p_codexam     tcodexam.codcodec%type;
  p_remark      ttestset.remark%type;
  p_syncond     json_object_t;
  b_index_codempid      temploy1.codempid%type;
  -- save
  json_params           json_object_t;
  params_syncond        json_object_t;

  procedure initial_value (json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure get_detail_codemp(json_str_input in clob, json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure post_process(json_str_input in clob,json_str_output out clob);
end hrel40e;

/
