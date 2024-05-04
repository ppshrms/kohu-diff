--------------------------------------------------------
--  DDL for Package HRAL71B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL71B" is

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal   			    varchar2(4 char);
  global_v_codcurr      varchar2(100 char);

  global_v_batch_codapp     varchar2(100 char)  := 'HRAL71B';
  global_v_batch_dtestrt    date;
  global_v_batch_count      number := 22;
  type a_varchar2 is table of varchar2(100 char) index by binary_integer;
  global_v_batch_codalw    a_varchar2;
  global_v_batch_flgproc   a_varchar2;
  global_v_batch_qtyproc   a_varchar2;
  global_v_batch_qtyerror  a_varchar2;

  p_codempid            varchar2(100 char);
  p_codcomp             varchar2(100 char);
  p_typpayroll          varchar2(10 char);
  p_numperiod           number;
  p_dtemthpay           number;
  p_dteyrepay           number;
  p_codcompy            varchar2(100 char);
  p_codpay              varchar2(100 char);
  p_flgretprd           varchar2(1 char);

  v_codcomp             varchar2(100 char);
  v_typpayroll          varchar2(10 char);
  v_codpay              varchar2(100 char);
  v_dteeffec            date;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_reperiod(json_str_input in clob, json_str_output out clob);
  procedure process_data(json_str_input in clob, json_str_output out clob);

--  function check_index_batchtask(json_str_input clob) return varchar2;

end HRAL71B;

/
