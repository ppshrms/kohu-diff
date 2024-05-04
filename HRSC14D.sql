--------------------------------------------------------
--  DDL for Package HRSC14D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC14D" is

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
  p_codapp                  tappprof.codapp%type;
  p_codproc                 tappprof.codproc%type;
  -- index
  p_dtestrt                 date;
  p_dteend                  date;

  json_params               json_object_t;
  p_lrunning                tlogin.lrunning%type;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure initial_value (json_str in clob);
  procedure gen_index (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob) ;

end HRSC14D;

/
