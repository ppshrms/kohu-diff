--------------------------------------------------------
--  DDL for Package HRAL1LB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL1LB" is
-- last update: 13/02/2018 10:13

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  global_v_batch_codapp     varchar2(100 char)  := 'HRAL1LB';
  global_v_batch_codalw     varchar2(100 char)  := 'HRAL1LB';
  global_v_batch_dtestrt    date;
  global_v_batch_flgproc    varchar2(1 char)    := 'N';
  global_v_batch_qtyproc    number              := 0;
  global_v_batch_qtyerror   number              := 0;

  p_codcomp                 varchar2(100 char);
  p_codcalen                varchar2(100 char);
  p_dteyear                 number;
  p_codcompy_clone          varchar2(100 char);
  p_year_clone              varchar2(100 char);
  p_dtewrkst                date;
  p_dtewrken                date;
  p_index_recs              number := 0;

  procedure initial_value(json_str in clob);
  procedure check_index_save;

  procedure get_holiday(json_str_input in clob, json_str_output out clob);
  procedure gen_holiday(json_str_output out clob);

  procedure set_holiday(json_str_input in clob, json_str_output out clob);
  procedure set_tgholidy(json_str_input in clob);
  procedure gen_data (b_codcomp in varchar2, b_dtework in date, b_typwork in varchar2, b_codshift in varchar2);

  procedure get_list_codcompy(json_str_input in clob, json_str_output out clob);
  procedure gen_list_codcompy(json_str_output out clob);

  procedure get_last_dtework(json_str_input in clob, json_str_output out clob);
  procedure gen_tattence;

end HRAL1LB;

/
