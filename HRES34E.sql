--------------------------------------------------------
--  DDL for Package HRES34E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES34E" is
-- last update: 22/06/2016 11:20
  v_file            utl_file.file_type;
  v_file_name       varchar2 (4000 char);
  --
  obj_row           json;
  list_row          json_list;
  list_content      json_list;
  json_long         long;
  --
  global_v_coduser  varchar2(100 char);
  global_v_codpswd  varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  global_v_codapp   varchar2(4000 char);
  p_message         varchar(4000 char);
  b_index_codempid  varchar2(4000 char);
  b_index_codcomp  varchar2(4000 char);
  b_index_emp_id    varchar2(4000 char);
  b_index_dtereq    date;
  b_index_seqno     varchar2(4000 char);
  b_index_numseq    varchar2(4000 char);
  p_start           varchar2(4000 char);
  p_limit           varchar2(4000 char);
  p_dtereq_st       varchar2(4000 char);
  p_dtereq_en       varchar2(4000 char);
  p_dteeffec        varchar2(4000 char);
  p_seqno           varchar2(4000 char);
  p_staappr         varchar2(4000 char);
  param_msg_error   varchar2(600);
  --
  tab1_dtemov       date;
  tab1_codcomp      tcenter.codcomp%type;
  tab1_codpos       tpostn.codpos%type;
  tab1_codjob       varchar2(4000 char);
  tab1_codloca      varchar2(4000 char);
  tab1_remark       varchar2(4000 char);
  --
  v_approvno          number := 0;
  v_codempid_next     temploy1.codempid%type;
  v_codempap          temploy1.codempid%type;
  v_codcompap         tcenter.codcomp%type;
  v_codposap          tpostn.codpos%type;
  b_index_dteinput    date;
  v_routeno           varchar2(15);
  tmovereq_staappr    varchar2(100 char);
  tmovereq_dtecancel  date;
  tmovereq_dteinput   date;
  tmovereq_codappr    varchar2(100 char);
  tmovereq_dteappr    date;
  tmovereq_remarkap   varchar2(100 char);
  tmovereq_approvno   varchar2(100 char);
  v_remark            varchar2(100 char);
  tab1_routeno        varchar2(100 char);
  tab1_codempap       varchar2(100 char);
  tab1_codcompap      varchar2(100 char);
  tab1_codbrlc        varchar2(100 char);
  tab1_codposap       varchar2(100 char);
  tab1_dtecancel      varchar2(100 char);
  tab1_codappr        varchar2(100 char);
  tab1_dteappr        varchar2(100 char);
  tab1_remarkap       varchar2(100 char);
  tab1_approvno       varchar2(100 char);
  tab1_dteinput       varchar2(100 char);
  --
  procedure get_index_table1(json_str_input in clob, json_str_output out clob);
  procedure get_data_create(json_str_input in clob, json_str_output out clob);
  procedure get_check_status(json_str_input in clob, json_str_output out clob);
  procedure get_data_tab1(json_str_input in clob, json_str_output out clob);
  procedure ess_cancel_tmovereq(json_str_input in clob, json_str_output out clob);
  procedure ess_save_detail(json_str_input in clob, json_str_output out clob);

  procedure check_index;
  procedure check_index_detail;
  procedure insert_next_step;
  procedure save_detail;
  procedure initial_value(json_str in clob);
end; -- package spec

/
