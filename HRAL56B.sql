--------------------------------------------------------
--  DDL for Package HRAL56B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL56B" is

  param_msg_error           varchar2(4000 char);
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;
  
  global_v_batch_codapp     varchar2(100 char)  := 'HRAL56B';
  global_v_batch_codalw     varchar2(100 char)  := 'HRAL56B';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;

  v_chken                   varchar2(10 char);
  v_zupdsal                 varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  p_codempid                varchar2(100 char);
  p_codcomp                 varchar2(100 char);
  p_stdate                  date;
  p_endate                  date;

  procedure process_data(json_str_input in clob, json_str_output out clob);
  
  function check_index_batchtask(json_str_input clob) return varchar2;

end HRAL56B;

/
