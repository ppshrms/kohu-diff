--------------------------------------------------------
--  DDL for Package HRAL3TB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL3TB" is
  p_coduser   temploy1.coduser%type := 'AUTO';
  p_chken     varchar2(4) := check_emp(get_emp);
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(1000 char);
  global_v_coduser          varchar2(1000 char);
  global_v_codpswd          varchar2(1000 char);
  global_v_codempid         varchar2(1000 char);
  global_v_lang             varchar2(1000 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(1000 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  global_v_batch_codapp     varchar2(100 char)  := 'HRAL3TB';
  global_v_batch_codalw     varchar2(100 char)  := 'HRAL3TB';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;

  p_codcomp                 varchar2(4000 char);
  p_codempid                varchar2(4000 char);
  p_timtran                 number;
  p_stdate                  date;
  p_endate                  date;
  p_filetype                varchar2(1 char);
  p_typmatch                varchar2(4000 char);
  p_filename                varchar2(4000 char);
  p_dayetrn                 date;


  p_rec_tran                number;
  p_rec_error               number;
--  p_text                    varchar2(4000 char);
--  p_error_code              varchar2(4000 char);
--  p_numseq                  number;
  p_path_file               varchar2(50)  := '';

  TYPE data_error IS TABLE OF VARCHAR2(6000) INDEX BY BINARY_INTEGER;
  p_text        data_error;
  p_error_code  data_error;
  p_numseq      data_error;

  procedure check_index;
  function  check_date (p_date in varchar2) return boolean;
  function  check_time (p_time in varchar2) return boolean;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure data_process(json_str_input in clob, json_str_output out clob);
  procedure gen_file_of_time(json_str_input in clob, json_str_output out clob);
  procedure gen_text_file(json_str_input in clob, json_str_output out clob);
  procedure gen_transfer_time(json_str_output out clob);

  procedure get_transfer_report(json_str_input in clob, json_str_output out clob);

  procedure get_list_ttexttrn(json_str_input in clob, json_str_output out clob);

  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);

  function check_index_batchtask(json_str_input clob) return varchar2;

end HRAL3TB;

/
