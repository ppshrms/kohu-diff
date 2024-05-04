--------------------------------------------------------
--  DDL for Package HRSC11X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC11X" as
-- last update: 14/11/2018 22:31

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  -- index
  p_dtestrt                 thislogin.ldteacc%type;
  p_dteend                  thislogin.ldteacc%type;
  p_coduser                 temploy1.coduser%type;
  p_codempid                temploy1.codempid%type;
  p_codapp                  thislogin.lcodrun%type;
  p_timstrt                 varchar2(4 char);
  p_timend                  varchar2(4 char);

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  function get_funcnam_sc (v_codapp IN VARCHAR2 ,v_flag   IN VARCHAR2, v_select_language IN VARCHAR2) RETURN VARCHAR2;--user37 #5783 6.SC Module 29/04/2021 

end HRSC11X;

/
