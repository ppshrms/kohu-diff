--------------------------------------------------------
--  DDL for Package HRAL57X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL57X" is
-- last update: 27/03/2018 14:16

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4000 char);

  p_codcomp                 tcenter.codcomp%type;
  p_codempid                temploy1.codempid%type;
  p_dteyear                 number;

  procedure initial_value(json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  function cal_dhm(v_qtymin number,v_qtyavgwk number) return varchar2;
end hral57x;

/
