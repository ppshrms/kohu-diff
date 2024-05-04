--------------------------------------------------------
--  DDL for Package HRSC03E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC03E" as
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
  p_dteeffec                temploy1.dteempmt%type;
  p_codcomp                 temploy1.codcomp%type;
  p_typeproc                varchar2(10 char);
  p_dtestrt                 temploy1.dteempmt%type;
  p_dteend                  temploy1.dteempmt%type;
  p_syncond                 json_object_t;
  p_userid                  tusrprof.coduser%type;
  p_password                tusrprof.codpswd%type;
  p_qtymistake              tusrprof.timepswd%type;
  p_typeuser                tusrprof.typeuser%type;
  p_typepassword            varchar2(10);
  json_params               json_object_t;

  procedure initial_value (json_str in clob);

  procedure post_process (json_str_input in clob, json_str_output out clob);
  procedure send_mail (json_str_input in clob, json_str_output out clob);
  procedure create_users (json_str_input in clob, json_str_output out clob);
end HRSC03E;

/
