--------------------------------------------------------
--  DDL for Package HRPMB2E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMB2E" is
-- last update: 20/05/2020 16:40

  param_msg_error           varchar2(4000 char);
  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := hcm_appsettings.get_additional_year;

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  p_zupdsal                 varchar2(1 char);

  p_codempid_query          temploy1.codempid%type;
  p_yearst                  number;
  p_yearen                  number;

  p_codcomp                 thismove.codcomp%type;
  p_codempmt                thismove.codempmt%type;
  p_dteeffec                thismove.dteeffec%type;
  p_numseq                  thismove.numseq%type;
  p_codtrn                  thismove.codtrn%type;

  is_report                 boolean := false;
  r_numseq                  number;
  v_probation               number;

  type t_amt is table of number index by binary_integer;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_move_detail(json_str_input in clob, json_str_output out clob);
  procedure get_adj_income_detail(json_str_input in clob, json_str_output out clob);
  procedure get_adj_income_table(json_str_input in clob, json_str_output out clob);
  procedure get_cal_adj_income(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure delete_index(json_str_input in clob, json_str_output out clob);
  procedure gen_report(json_str_input in clob,json_str_output out clob);
end;

/
