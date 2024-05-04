--------------------------------------------------------
--  DDL for Package HRESS4E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRESS4E" is

  param_msg_error   varchar2(4000 char);

  v_chken           varchar2(10 char) := hcm_secur.get_v_chken;
  v_zyear           number;
  global_v_coduser  varchar2(100 char);
  global_v_codpswd  varchar2(100 char);
  global_v_lrunning varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  v_file            utl_file.file_type;
  v_file_name       varchar2 (4000 char);

  obj_row           json_object_t;
  json_long         varchar2(4000 char);
  b_index_codempid  varchar2(4000 char);


  p_dtereqst           tircreq.dtereq%type;
  p_dtereqen           tircreq.dtereq%type;
  p_codempid           tircreq.codempid%type;
  p_dtereq             tircreq.dtereq%type;
  p_numseq             tircreq.numseq%type;



  tircreq_codappr    tircreq.codappr%type ;
  tircreq_staappr    tircreq.staappr%type;
  tircreq_dteappr    tircreq.dteappr%type;
  tircreq_remarkap   tircreq.remarkap%type;
  tircreq_approvno   tircreq.approvno%type;
  tircreq_routeno   tircreq.routeno%type;


  p_codbrlc     tircreq.codbrlc%type;
  p_codcomp      tircreq.codcomp%type;
  p_remarks   tircreq.remarks%type;
  p_dtestart   tircreq.dtestart%type;


  -----------------------------------------
  p_dtest           tircreq.dtereq%type;
  p_dteen           tircreq.dtereq%type;
  p_codjob          treqest2.codjob%type; 
  p_codpos          treqest2.codpos%type;
  p_numreqst          treqest2.numreqst%type;



  procedure initial_value(json_str in clob);



  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure get_job_app(json_str_input in clob, json_str_output out clob);
  procedure get_popup_info(json_str_input in clob, json_str_output out clob);
  procedure post_detail_save(json_str_input in clob, json_str_output out clob);
  procedure post_delete(json_str_input in clob, json_str_output out clob);


  procedure check_index;

END;


/
