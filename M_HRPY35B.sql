--------------------------------------------------------
--  DDL for Package M_HRPY35B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRPY35B" as

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  global_v_batch_codapp     varchar2(100 char)  := 'M_HRPY35B';
  global_v_batch_codalw     varchar2(100 char)  := 'M_HRPY35B';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;
  global_v_batch_filename   varchar2(100 char);
  global_v_batch_pathfile   varchar2(100 char);

  p_numperiod               number;
  p_dtemthpay               number;
  p_dteyrepay               number;
  p_codcompy                varchar2(100 char);
  p_typpayroll              varchar2(100 char);
  p_file_dir                varchar2(4000 char) := 'UTL_FILE_DIR';
  p_file_path               varchar2(4000 char) := get_tsetup_value('PATHEXCEL');
  p_filename		        varchar2(4000 char);
  v_numrec	                number;
  v_numerr	                number;

  p_typetext                varchar2(4000 char);

  procedure get_process(json_str_input in clob, json_str_output out clob);

  procedure process_data(json_str_output out clob);

  procedure get_lastperiod(json_str_input in clob, json_str_output out clob);

  function check_index_batchtask(json_str_input clob) return varchar2;

  procedure gen_text_file(json_str_output out clob);

end m_hrpy35b;

/
