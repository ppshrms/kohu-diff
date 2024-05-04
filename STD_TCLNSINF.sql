--------------------------------------------------------
--  DDL for Package STD_TCLNSINF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_TCLNSINF" as

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  v_zupdsal                 varchar2(10 char);

  p_codempid                temploy1.codempid%type;
  p_numvcher                tclnsinf.numvcher%type;

  procedure initial_value (json_str in clob);

  procedure get_tclnsinf_detail (json_str_input in clob, json_str_output out clob);
  procedure get_tclnsinf_table (json_str_input in clob, json_str_output out clob);
end std_tclnsinf;

/
