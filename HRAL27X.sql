--------------------------------------------------------
--  DDL for Package HRAL27X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL27X" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  tusrprof.coduser%type;
  global_v_codempid temploy1.codempid%type;
  global_v_lang     varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(10 char);

  p_codcomp         temploy1.codcomp%type;
  p_codshift        tattence.codshift%type;
  p_codcalen        temploy1.codcalen%type;
  p_dtestrt         date;
  p_dteend          date;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
end HRAL27X;

/
