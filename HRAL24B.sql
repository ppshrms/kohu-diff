--------------------------------------------------------
--  DDL for Package HRAL24B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL24B" is
  p_coduser   temploy1.coduser%type := 'AUTO';
--  p_chken     varchar2(4) := check_emp(get_emp);
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          temploy1.coduser%type;
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          number;

  global_v_batch_codapp     varchar2(100 char)  := 'HRAL24B';
  global_v_batch_dtestrt    date;
  global_v_batch_count      number := 3;
  type a_varchar2 is table of varchar2(100 char) index by binary_integer;
  global_v_batch_codalw    a_varchar2;
  global_v_batch_flgproc   a_varchar2;
  global_v_batch_qtyproc   a_varchar2;
  global_v_batch_qtyerror  a_varchar2;

  p_codcomp                 varchar2(1000 char);
  p_dtework                 date;
  p_dteeffec                date;
  p_dteeffec_en          date;

  procedure check_index;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_data_process(json_str_input in clob, json_str_output out clob);
  procedure gen_data_process(json_str_output out clob);

  function check_index_batchtask(json_str_input clob) return varchar2;

end HRAL24B;

/
