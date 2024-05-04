--------------------------------------------------------
--  DDL for Package HRCO39E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO39E" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  json_params               json;

  p_codapp                  tappprof.codapp%type;
  p_codproc                 tappprof.codproc%type;
  p_codapp_rep              tappprof.codapp%type;
  p_codempid                trepappm.codempid%type;

  procedure get_trepapp_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_trepapp_detail (json_str_output out clob);
  procedure save_trepapp (json_str_input in clob, json_str_output out clob) ;
  procedure get_index_trepappm (json_str_input in clob, json_str_output out clob);
  procedure gen_index_trepappm(json_str_output out clob);
  procedure save_index_trepappm (json_str_input in clob, json_str_output out clob) ;
  procedure get_email_by_codempid (json_str_input in clob, json_str_output out clob) ;

end HRCO39E;

/
