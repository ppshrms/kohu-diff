--------------------------------------------------------
--  DDL for Package HRRC21E3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC21E3" is
-- last update: 07/8/2018 11:40

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

  ---hisname tab---
  type education_type is table of teducatn%ROWTYPE index by binary_integer;
    education_tab     education_type;
  type flg_del_edu_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_edu     flg_del_edu_type;

  ---work_exp tab---
  type work_exp_type is table of tapplwex%ROWTYPE index by binary_integer;
    work_exp_tab     work_exp_type;
  type flg_del_work_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_work     flg_del_work_type;

  ---training tab---
  type training_type is table of ttrainbf%ROWTYPE index by binary_integer;
    training_tab    training_type;
  type flg_del_trn_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_trn   flg_del_trn_type;
  type amtincome_type is table of number index by binary_integer;
    p_amtincome        amtincome_type;

  procedure get_education_table(json_str_input in clob, json_str_output out clob);
  procedure gen_education_table(json_str_output out clob);
  procedure get_sta_submit_edu(json_str_input in clob, json_str_output out clob);

  procedure get_work_exp_table(json_str_input in clob, json_str_output out clob);
  procedure gen_work_exp_table(json_str_output out clob);

  procedure get_training_table(json_str_input in clob, json_str_output out clob);
  procedure gen_training_table(json_str_output out clob);

  procedure save_edu_work(json_str_input in clob, json_str_output out clob);

end;

/
