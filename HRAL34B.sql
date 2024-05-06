--------------------------------------------------------
--  DDL for Package HRAL34B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL34B" is
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

  global_v_batch_codapp     varchar2(100 char)  := 'HRAL34B';
  global_v_batch_codalw     varchar2(100 char)  := 'HRAL34B';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;

  v_zupdsal                 varchar2(4 char);

  p_codcomp                 varchar2(4000 char);
  p_codempid                varchar2(4000 char);
  p_stdate                  date;
  p_endate                  date;

  p_numrec                  number;

  procedure check_index;
  procedure get_data_process(json_str_input in clob, json_str_output out clob);
  function check_index_batchtask(json_str_input clob) return varchar2;

end HRAL34B;

/
