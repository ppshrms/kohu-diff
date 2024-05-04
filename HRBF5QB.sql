--------------------------------------------------------
--  DDL for Package HRBF5QB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5QB" AS
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  p_zupdsal                 varchar2(100 char);

  global_v_batch_codapp     varchar2(100 char)  := 'HRBF5QB';
  global_v_batch_codalw     varchar2(100 char)  := 'HRBF5QB';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;

  p_codempid                temploy1.codempid%type;
  p_codcomp                 temploy1.codcomp%type;
  p_typpayroll              temploy1.typpayroll%type;
  p_codlon                  ttyploan.codlon%type;
  p_dteyrepay               tclnsinf.dteyrepay%type;
  p_dtemthpay               tclnsinf.dtemthpay%type;
  p_numperiod               tclnsinf.numperiod%type;
  p_dtepaymt                tdtepay.dtepaymt%type;

  procedure process_data (json_str_input in clob, json_str_output out clob);
  function check_index_batchtask(json_str_input clob) return varchar2;
END HRBF5QB;


/
