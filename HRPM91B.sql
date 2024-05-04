--------------------------------------------------------
--  DDL for Package HRPM91B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM91B" is
-- last update: 04/02/2021 18:15 redmine #2247

  param_msg_error           varchar2(4000 char);

  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  global_v_batch_codapp     varchar2(100 char)  := 'HRPM91B';
  global_v_batch_dtestrt    date;
  global_v_batch_count      number := 8;
  type a_varchar2 is table of varchar2(100 char) index by binary_integer;
  global_v_batch_codalw    a_varchar2;
  global_v_batch_flgproc   a_varchar2;
  global_v_batch_qtyproc   a_varchar2;
  global_v_batch_qtyerror  a_varchar2;

  v_zupdsal                 varchar2(1);

  p_codcomp           tcenter.codcomp%type;
  p_dteproc           date;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure process_data (json_str_input in clob, json_str_output out clob);

  procedure get_error_list (json_str_input in clob, json_str_output out clob);
  procedure gen_error_list (json_str_output out clob);

  function check_index_batchtask(json_str_input clob) return varchar2;

end HRPM91B;

/
