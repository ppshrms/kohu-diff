--------------------------------------------------------
--  DDL for Package HRAL42U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL42U" as

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
  global_v_lrunning         number;
  v_zupdsal                 varchar2(400 char);
  v_date			              date := sysdate;

  p_codempid                varchar2(1000 char);
  p_codcomp                 varchar2(1000 char);
  p_dtestrt                 date;
  p_dteend                  date;
  p_dtework                 date;
  p_typot                   varchar2(1000 char);

  p_codshift                varchar2(1000 char);
  p_typwork                 varchar2(1000 char);

--  post_detail
  p_sumot                   varchar2(1000 char);
  p_typpayroll              varchar2(1000 char);
  p_codcalen                varchar2(1000 char);
  p_qtyminot                number;

  p_dteupd                  varchar2(1000 char);  --default condition
  p_coduser                 varchar2(1000 char);  --default condition

  p_flgmeal                 varchar2(1 char);
  p_flgadj                  varchar2(1 char);

-- detail
  p_amtmealn                number;
  p_qtyleaven               number;
  p_codcompn                varchar2(1000 char);
  p_codcompo                varchar2(1000 char);
  p_codcostn                varchar2(1000 char);
  p_codrem                  varchar2(1000 char);
  p_remark                  varchar2(4000 char);
  p_codappr                 varchar2(1000 char);
  p_dteappr                 date;

  p_amtmealo                number;
  p_qtyleaveo               number;

  --cal overtime
  p_timstrt                 varchar2(1000 char);
  p_timend                  varchar2(1000 char);
  p_rteotpay                number;
  --
  param_dteeffec            date;
  param_condot              varchar2(1000 char);
  param_condextr            varchar2(1000 char);
  --
  p_codleave                varchar2(1000 char);
  p_dtestrle                varchar2(1000 char);

  p_flgtypot                varchar2(1);


  procedure initial_value (json_str in clob);
  procedure initial_value_detail (json_obj in json_object_t);

  procedure check_index;
  procedure check_save;
  procedure check_detail;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure get_query_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_query_detail (json_str_output out clob);

  procedure get_tovrtime_table(json_str_input in clob, json_str_output out clob);
  procedure gen_tovrtime_table (json_str_output out clob);

  procedure get_cal_overtime(json_str_input in clob, json_str_output out clob);
  procedure get_cal_pay_overtime(json_str_input in clob, json_str_output out clob);

  procedure get_totpaydt_table (json_str_input in clob, json_str_output out clob);
  procedure gen_totpaydt_table (json_str_output out clob);

  procedure get_tovrtime_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tovrtime_detail (json_str_output out clob);

  procedure save_delete (json_str_input in clob, json_str_output out clob);
  procedure post_detail (json_str_input in clob, json_str_output out clob);

  procedure upd_totpaydt(json_str_input in json_object_t);

  procedure upd_tovrtime(json_str_input_detail in json_object_t, json_str_input_table1 in json_object_t);

  procedure get_codcenter(json_str_input in clob, json_str_output out clob);

end HRAL42U;

/
