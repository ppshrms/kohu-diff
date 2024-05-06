--------------------------------------------------------
--  DDL for Package HRPY46B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY46B" as
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_chken        varchar2(4000 char);
  v_zupdsal     		    varchar2(4 char);

  global_v_batch_codapp     varchar2(100 char)  := 'HRPY46B';
  global_v_batch_codalw     varchar2(100 char)  := 'HRPY46B';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;
  global_v_batch_descproc   varchar2(1000 char);

  p_month               number;
  p_year                number;
  p_codcomp             tcenter.codcomp%type;
  p_typpayroll          temploy1.typpayroll%type;
  p_codempid            temploy1.codempid%type;
  procedure initial_value (json_str_input in clob);

  procedure check_process;
  procedure get_process(json_str_input in clob,json_str_output out clob);
  procedure gen_process(json_str_output out clob);

  function check_index_batchtask(json_str_input clob) return varchar2;
end hrpy46b;

/
