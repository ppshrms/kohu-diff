--------------------------------------------------------
--  DDL for Package HRCO3AB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO3AB" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  json_params               json;
  -- index
  p_codapp                  tappprof.codapp%type;
  p_codapp_rep              tappprof.codapp%type;

  procedure get_index_tautoexe(json_str_input in clob, json_str_output out clob);
  procedure gen_index_tautoexe(json_str_output out clob);
  procedure save_job_tautoexe (json_str_input in clob, json_str_output out clob);
  procedure remove_job_tautoexe (json_str_input in clob, json_str_output out clob);
  procedure get_tautoexe_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_tautoexe_detail (json_str_output out clob);
  procedure get_dba_jobs_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_dba_jobs_detail (json_str_output out clob);
  procedure remove_job_other (json_str_input in clob, json_str_output out clob) ;
  procedure test;
  procedure test_drop;

end HRCO3AB;

/
