--------------------------------------------------------
--  DDL for Package HCM_BATCHTASK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_BATCHTASK" is
  -- last update: 31/05/2020 23:23

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  v_flgquery            varchar2(10 char);
  v_limit               number;
  v_codapp              tbackproc.codapp%type;
  v_codalw              tbackproc.codalw%type;
  v_flgproc             tbackproc.flgproc%type;
  v_start               number;
  v_dtestrt             date;
  v_dteend              date;
  v_timstrt             varchar2(100 char);
  v_dtetimstrt          date;
  v_procname            varchar2(100 char);
  v_amt_process         number;
  v_param_input         clob;
  v_dtetim              date;

  function gen_filename(p_filename in varchar2, p_extension in varchar2, p_chk in date default null) return varchar2;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_total_complete(json_str_input in clob, json_str_output out clob);
  procedure delete_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail_hrpm91b(json_str_input in clob, json_str_output out clob);
  procedure get_detail_hral3tb(json_str_input in clob, json_str_output out clob);
  procedure get_detail_hrpy41b(json_str_input in clob, json_str_output out clob);
  procedure get_detail_hrpy44b(json_str_input in clob, json_str_output out clob);
  procedure get_detail_hrpy70b(json_str_input in clob, json_str_output out clob);

  procedure call_batch(json_str_input in clob, json_str_output out clob);
  procedure start_batch_process(p_codapp varchar2,p_coduser varchar2,p_codalw varchar2,p_param_search clob default null,p_jobno number default null,p_dtestrt in out date);
  procedure finish_batch_process(p_codapp varchar2,p_coduser varchar2,p_codalw varchar2,p_dtestrt date,
                                 p_flgproc varchar2 default 'Y',
                                 p_qtyproc number default 0,
                                 p_qtyerror number default 0,
                                 p_oracode varchar2 default null,
                                 p_typefile varchar2 default null,
                                 p_descproc varchar2 default null,
                                 p_filename1 varchar2 default null,p_pathfile1 varchar2 default null,
                                 p_filename2 varchar2 default null,p_pathfile2 varchar2 default null,
                                 p_filename3 varchar2 default null,p_pathfile3 varchar2 default null,
                                 p_filename4 varchar2 default null,p_pathfile4 varchar2 default null,
                                 p_filename5 varchar2 default null,p_pathfile5 varchar2 default null);
  procedure insert_batch_detail(p_codapp varchar2,p_coduser varchar2,p_codalw varchar2,p_dtestrt date,
                                p_item01 varchar2 default null,p_item02 varchar2 default null,p_item03 varchar2 default null,
                                p_item04 varchar2 default null,p_item05 varchar2 default null,p_item06 varchar2 default null,
                                p_item07 varchar2 default null,p_item08 varchar2 default null,p_item09 varchar2 default null,
                                p_item10 varchar2 default null,p_item11 varchar2 default null,p_item12 varchar2 default null,
                                p_item13 varchar2 default null,p_item14 varchar2 default null,p_item15 varchar2 default null,
                                p_item16 varchar2 default null,p_item17 varchar2 default null,p_item18 varchar2 default null,
                                p_item19 varchar2 default null,p_item20 varchar2 default null);
  procedure run_job(p_codapp varchar2,p_coduser varchar2,p_runno varchar2);

end;

/
