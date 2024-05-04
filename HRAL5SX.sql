--------------------------------------------------------
--  DDL for Package HRAL5SX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL5SX" is
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
  v_zupdsal                 varchar2(4 char);

  v_qtyavgwk                number;
  p_codcomp                 varchar2(4000 char);
  p_codempid                varchar2(4000 char);
  p_dteyear                 number;
  p_staappr                 varchar2(10 char);

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  function display_currency (p_amtcur number) return varchar2;

end HRAL5SX;

/
