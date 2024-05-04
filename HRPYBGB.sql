--------------------------------------------------------
--  DDL for Package HRPYBGB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPYBGB" as

-- error pbin 13/01/2023 14:24  
-- last update: 16/12/2021 17:01||redmine#7357 user14

  param_msg_error           varchar2(4000 char);
  global_v_coduser          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  global_v_batch_codapp     varchar2(100 char)  := 'HRPYBGB';
  global_v_batch_codalw     varchar2(100 char)  := 'HRPYBGB';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;

  p_codcompy                varchar2(100 char);
  p_dteeffec                date;

  procedure get_process(json_str_input in clob, json_str_output out clob);
  procedure process_data(json_str_output out clob);

  function check_index_batchtask(json_str_input clob) return varchar2;
--Redmine #2497
  function check_setup(p_codcompy   varchar2,p_codempid  varchar2)return varchar2;
  procedure msg_err2(p_error in varchar2);
--Redmine #2497
end HRPYBGB;

/
