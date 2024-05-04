--------------------------------------------------------
--  DDL for Package HRPM93X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM93X" is

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
  global_v_zupdsal          number;
  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;
  v_zupdsal                 varchar2(10 char);

  pa_codempid               thismove.codempid%type;
  pa_dtestr                 thismove.dteeffec%type;
  pa_dteend                 thismove.dteeffec%type;
  p_dteeffecchar            varchar2(50 char);
  p_codempid                thismove.codempid%type;
  p_numseq                  thismove.numseq%type;
  p_codtrn                  thismove.codtrn%type;
  p_dteeffec                date;
  v_numseq                  number := 0;
  p_dtestr                  varchar2(100 char);
  p_dteend                  varchar2(100 char);
  numyearreport             number;
  r_numseq                  number := 0;
  param_json                json_object_t;


  procedure initial_value (json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_insert_report(json_str_input in clob, json_str_output out clob);
  procedure gen_insert_report;
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure get_detail_table(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_table(json_str_output out clob);
  procedure vadidate_variable_getindex(json_str_input in clob);


end HRPM93X;

/
