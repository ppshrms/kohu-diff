--------------------------------------------------------
--  DDL for Package HRAL5LE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL5LE" is
-- last update: 27/03/2018 14:16

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

  p_codcomp                 varchar2(4000 char);
  p_typpayroll              varchar2(4 char);
  p_codempid                varchar2(4000 char);
  p_dteyear                 number;
  p_codleave                varchar2(1000 char);
  p_staleave                varchar2(1 char);
  p_typleave                varchar2(1000 char);
  p_flgdlemx                varchar2(1000 char);
  p_qtyavgwk                number;

  p_day11                   number;
  p_hour11                  number;
  p_min11                   number;
  p_day22                   number;
  p_hour22                  number;
  p_min22                   number;
  p_day33                   number;
  p_hour33                  number;
  p_min33                   number;
  p_day44                   number;
  p_hour44                  number;
  p_min44                   number;
  p_day55                   number;
  p_hour55                  number;
  p_min55                   number;
  p_day66                   number;
  p_hour66                  number;
  p_min66                   number;
  p_day77                   number;
  p_hour77                  number;
  p_min77                   number;
  p_day88                   number;
  p_hour88                  number;
  p_min88                   number;
  p_qtytleav                number;
  p_dtelastle               date;
  p_remark                  varchar(500 char);
  p_day1                   number;
  p_hour1                  number;
  p_min1                   number;
  p_day2                   number;
  p_hour2                  number;
  p_min2                   number;
  p_day3                   number;
  p_hour3                  number;
  p_min3                   number;
  p_day4                   number;
  p_hour4                  number;
  p_min4                   number;
  p_day5                   number;
  p_hour5                  number;
  p_min5                   number;
  p_day6                   number;
  p_hour6                  number;
  p_min6                   number;
  p_day7                   number;
  p_hour7                  number;
  p_min7                   number;
  p_day8                   number;
  p_hour8                  number;
  p_min8                   number;
  p_o_qtytleav             number;
  p_o_dtelastle            date;

  p_qtydayle                tleavsum.qtydayle%type;
  p_qtylepay                tleavsum.qtylepay%type;
  p_qtyadjvac               tleavsum.qtyadjvac%type;
  v_staleave                TLEAVECD.STALEAVE%TYPE;

  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure gen_staleave (v_codleave in TLEAVECD.CODLEAVE%TYPE, flg_staleave out TLEAVECD.STALEAVE%TYPE);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_config_data(json_str_input in clob, json_str_output out clob);

  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure ins_tleavsum;
  procedure ins_tloglvsm;

end HRAL5LE;


/
