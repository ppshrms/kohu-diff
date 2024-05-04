--------------------------------------------------------
--  DDL for Package HRRP2PB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP2PB" is
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
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
  v_zupdsal                 varchar2(4 char);

  global_v_batch_codapp     varchar2(100 char)  := 'HRRP2PB';
  global_v_batch_codalw     varchar2(100 char)  := 'HRRP2PB';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;

  p_dtestrt                 date;
  p_dteend                  date;
  p_codcomp                 tcenter.codcomp%TYPE;
  p_dteyrbug                tmanpwm.dteyrbug%TYPE;
  p_dtemthbugstr            tmanpwm.dtemthbug%TYPE;
  p_dtemthbugend            tmanpwm.dtemthbug%TYPE;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure process_data (json_str_input in clob, json_str_output out clob);

  function check_index_batchtask(json_str_input clob) return varchar2;

end HRRP2PB;

/
