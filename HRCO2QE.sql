--------------------------------------------------------
--  DDL for Package HRCO2QE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2QE" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  json_params       json_object_t;
  json_params2      json_object_t;
  -- index
  p_codapp          tappprof.codapp%type;
  p_codproc         tappprof.codproc%type;
  p_codcompy        varchar2(4000);

  p_codcust         tcust.codcust%type;


  TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  p_text        data_error;
  p_error_code  data_error;
  p_numseq      data_error;

 procedure get_index(json_str_input in clob, json_str_output out clob);
 procedure gen_index(json_str_output out clob) ;
 procedure save_tcust (json_str_input in clob, json_str_output out clob);
 procedure get_tcust_detail (json_str_input in clob, json_str_output out clob);
 procedure gen_tcust_detail (json_str_output out clob);
 procedure save_index (json_str_input in clob, json_str_output out clob);
 procedure get_import_process(json_str_input in clob, json_str_output out clob) ;
 procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number) ;

end HRCO2QE;

/
