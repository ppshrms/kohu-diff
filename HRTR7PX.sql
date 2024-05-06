--------------------------------------------------------
--  DDL for Package HRTR7PX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR7PX" AS
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

  p_codcompy                thisclss.codcompy%type;
  p_dteyear                 thisclss.dteyear%type;
  p_dtemonthst              thisclss.dtemonth%type;
  p_dtemonthen              thisclss.dtemonth%type;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
END HRTR7PX;

/
