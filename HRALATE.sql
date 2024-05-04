--------------------------------------------------------
--  DDL for Package HRALATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRALATE" as
-- last update: 20/04/2018 10:30:00

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  p_detail                  clob;
  obj_detail                json_object_t;
  p_codcompy                TALALERT.codcompy%type; --comment by user18
  p_mailalno                varchar2(8 char);
  p_dteeffec                date;
  p_typemail                varchar2(2 char);
  p_subject                 varchar2(100 char);
  p_message                 varchar2(4000 char);
  p_syncond                 json_object_t;
  p_syncond_code            TALALERT.SYNCOND%TYPE;
  p_syncond_statement       TALALERT.STATEMENT%TYPE;
  p_flgeffec                varchar2(1 char);
  p_flgperiod               varchar2(1 char);
  p_dtestrt                 number;
  p_dteend                  number;
  p_qtydayr                 number;
  p_dtelast                 date;
  p_qtytlate                number;
  p_qtytearly               number;
  p_qtytabs                 number;
  p_qtylate                 number;
  p_qtyearly                number;
  p_qtyabsent               number;
  p_dteabsent               number;
  p_codsend                 varchar2(50 char);
  p_pathfile                clob;
  p_assign                  clob;

  v_file1                   varchar2(200 char);
  v_file2                   varchar2(200 char);
  v_file3                   varchar2(200 char);
  v_file4                   varchar2(200 char);

  v_host_attach_file        varchar2(200 char);
  v_path_attach_file        varchar2(200 char);

  v_flg                     varchar2(100 char);
  v_seqno                   number;
  v_flgappr                 varchar2(1 char);
  v_codcompap               varchar2(40 char);
  v_codposap                varchar2(4 char);
  v_codempap                varchar2(50 char);
  v_message                 varchar2(4000 char);

  -- special
  v_text_key                varchar2(100 char) := '';
  v_fd_key                  varchar2(100 char) := 'HRALATE';

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_detail;
  procedure check_assign_exists (json_str_input in clob, json_str_output out clob);

  function get_assign_seqno (v_mailalno varchar2, v_dteeffec varchar2) return number;
  function get_file_attach (v_fullpath varchar2) return varchar2;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure post_delete (json_str_input in clob, json_str_output out clob);
  procedure delete_data (json_str_input in clob, json_str_output out clob);

  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);

  procedure get_assign (json_str_input in clob, json_str_output out clob);
  procedure gen_assign (json_str_output out clob);

  procedure post_save (json_str_input in clob, json_str_output out clob);
  procedure check_save_main;
  procedure save_data_main;
  procedure check_save_assign;
  procedure save_data_assign (param_json in json_object_t);

  procedure post_send_mail (json_str_input in clob, json_str_output out clob);

end HRALATE;

/
