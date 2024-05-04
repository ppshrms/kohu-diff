--------------------------------------------------------
--  DDL for Package HRSC04E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC04E" as
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
  p_codempid                tassignm.codempid%type;
  p_codcomp                 tassignm.codcomp%type;
  p_codpos                  tassignm.codpos%type;
  p_dtestrt                 tassignm.dtestrt%type;
  p_dteend                  tassignm.dteend%type;
  -- save index
  json_params               json_object_t;

  procedure initial_value (json_str in clob);
  procedure check_detail;
  procedure check_save;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
  procedure save_tassignm;
  procedure get_temploy_data (json_str_input in clob, json_str_output out clob);

end HRSC04E;

/
