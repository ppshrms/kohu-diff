--------------------------------------------------------
--  DDL for Package HRRC21E5
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC21E5" is
  param_msg_error           varchar2(4000 char);
  param_flgwarn             varchar2(10 char);
  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  b_index_numappl           tapplinf.numappl%type;
  b_index_codempid          temploy1.codempid%type;

  --- relatives tab ---
  type relatives_type is table of tapplrel%ROWTYPE index by binary_integer;
    relatives_tab    relatives_type;
  type flg_del_relatives_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_relatives   flg_del_relatives_type;

  procedure get_spouse(json_str_input in clob, json_str_output out clob);
  procedure get_relative(json_str_input in clob, json_str_output out clob);
  procedure get_emp_detail(json_str_input in clob, json_str_output out clob);

  procedure save_family(json_str_input in clob, json_str_output out clob);
end;

/
