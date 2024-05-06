--------------------------------------------------------
--  DDL for Package HRES88E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES88E" is

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


  p_dtereqst        tjobreq.dtereq%type;
  p_dtereqen        tjobreq.dtereq%type;
  p_codempid        tjobreq.codempid%type;
  p_dtereq          tjobreq.dtereq%type;
  p_numseq          tjobreq.numseq%type;
  p_codjob          tjobcode.codjob%type;


  tjobreq_codappr   tjobreq.codappr%type ;
  tjobreq_staappr   tjobreq.staappr%type;
  tjobreq_dteappr   tjobreq.dteappr%type;
  tjobreq_remarkap  tjobreq.remarkap%type;
  tjobreq_approvno  tjobreq.approvno%type;
  tjobreq_routeno   tjobreq.routeno%type;

  p_amtincom        tjobreq.amtincom%type;
  p_codbrlc         tjobreq.codbrlc%type;
  p_codcomp         tjobreq.codcomp%type;
  p_codempr         tjobreq.codempr%type;
  p_codempmt        tjobreq.codempmt%type;
  p_codpos          tjobreq.codpos%type;
  p_codrearq        tjobreq.codrearq%type;
  p_flgcond         tjobreq.flgcond%type;
  p_flgjob          tjobreq.flgjob%type;
  p_flgrecut        tjobreq.flgrecut%type;
  p_qtyreq          tjobreq.qtyreq%type;
  p_remarkap        tjobreq.remarkap%type;
  p_syncond         tjobreq.syncond%type;
  p_statement       tjobreq.statement%type;

  b_sdate           varchar2(4000 char);
  b_amtintaccu      varchar2(4000 char);
  v_amtintaccu      varchar2(4000 char);
  v_amtinteccu      varchar2(4000 char);
  v_view_codapp     varchar2(100 char);
  global_v_codapp   varchar2(100 char);

  procedure initial_value(json_str in clob);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure get_job_remark(json_str_input in clob, json_str_output out clob);
  procedure post_detail_save(json_str_input in clob, json_str_output out clob);
  procedure post_delete(json_str_input in clob, json_str_output out clob);

  procedure check_index;

END;

/
