--------------------------------------------------------
--  DDL for Package HRRC21E6
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC21E6" is
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
  b_index_codempid          varchar2(100);

  ---reference---
  type reference_type is table of tapplref%ROWTYPE index by binary_integer;
    reference_tab    reference_type;
  type flg_del_ref_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_ref     flg_del_ref_type;

  procedure get_reference(json_str_input in clob, json_str_output out clob);
  procedure get_emp_detail(json_str_input in clob, json_str_output out clob);
  procedure save_reference(json_str_input in clob, json_str_output out clob);
end;

/
