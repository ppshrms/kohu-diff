--------------------------------------------------------
--  DDL for Package HRAL4KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL4KE" as
  param_msg_error         varchar2(4000 char);
  global_v_coduser        varchar2(100 char);
  global_v_codempid       varchar2(100 char);
  global_v_lang           varchar2(10 char);
  global_v_chken          varchar2(100 char);
  global_v_zminlvl        number;
  global_v_zwrklvl        number;
  global_v_numlvlsalst    number;
  global_v_numlvlsalen    number;
  v_zupdsal               varchar2(4 char);
  v_dteupd_log            date;
  p_flgtypot              varchar2(4 char);

  p_codapp                varchar2(100 char) := 'HRAL4KE';

  p_codcomp               temploy1.codcomp%type;
  p_codcalen              temploy1.codcalen%type;
  p_codempid              temploy1.codempid%type;
  p_codempid_index        temploy1.codempid%type;
  p_dtestr                date;
  p_dteend                date;
--    p_flg                   varchar2(1 char);
  p_date                  date;
  p_dtework               date;
  p_typot                 tovrtime.typot%type;
  p_dtein                 date;
  p_dteout                date;
  p_timin                 tattence.timin%type;
  p_timout                tattence.timout%type;
  p_dtestrt               date;
  p_timstrt               tovrtime.timstrt%type;
--    p_dteend                date;
  p_timend                tovrtime.timend%type;
  p_qtyminreq             number;
  p_codshift              tshifcom.codshift%type;
  p_dteappr               date;
  p_codappr               tovrtime.codappr%type;
  p_codcompw              tovrtime.codcompw%type;
  p_flgappr               varchar2(4000 char);
  p_flg                   varchar2(4000 char);
  p_codrem                tovrtime.codrem%type;
  p_qtyotmin              number;
  p_rate1                 totpaydt.qtyminot%type;
  p_rate1_5               totpaydt.qtyminot%type;
  p_rate2                 totpaydt.qtyminot%type;
  p_rate3                 totpaydt.qtyminot%type;
  p_amtmeal               tovrtime.amtmeal%type;
  p_qtyleave              tovrtime.qtyleave%type;
  p_flgmeal               tovrtime.flgmeal%type;
  param_json              json_object_t;

  p_rateotcount              number;

  procedure initial_value(json_str_input in clob);

  procedure get_daywork(json_str_input in clob,json_str_output out clob);
  procedure check_daywork;
  procedure gen_daywork(json_str_output out clob);

  procedure get_employee(json_str_input in clob,json_str_output out clob);
  procedure check_employee;
  procedure gen_employee(json_str_output out clob);

  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure check_index;
  procedure gen_index(json_str_output out clob);

  procedure get_OT(json_str_input in clob,json_str_output out clob);
  procedure check_OT;
  procedure gen_OT(json_str_output out clob);

  procedure post_save(json_str_input in clob,json_str_output out clob);
--  procedure check_save(v_dtestr date,v_timstr varchar2,v_dteend date,v_timend varchar2);
  procedure save_data(json_str_output out clob);

  procedure gen_st_index_by_codempid(v_i_codempid in varchar2, json_str_output out clob);
  procedure gen_st_index_by_date(v_date in date, json_str_output out clob);

  function timeformat_to_number(v_time varchar2)return number;
  procedure edit_tattence (v_codempid in varchar2 ,v_dtework in date    ,v_codshift in varchar2,
                           v_dtein    in date     ,v_timin   in varchar2,
                           v_dteout   in date     ,v_timout  in varchar2);
  procedure edit_OT (v_codempid in varchar2 ,v_dtework  in date     ,v_typot    in varchar2 ,
                     v_dtestr   in date     ,v_timstr   in varchar2 ,v_dteend   in date     ,
                     v_timend   in varchar2 ,v_qtyminot in number   ,v_rate     json_object_t        ,
                     v_ratex    in number   ,v_amtmeal  in number   ,v_qtyleave in number   ,
                     v_codrem   in varchar2 ,v_codcompw in varchar2);
  procedure insert_tlogot2  (v_codempid varchar2,v_dtework date,v_typot varchar2,v_rate json_object_t);
  procedure insert_totpaydt (v_codempid varchar2,v_dtework date,v_typot varchar2,v_rate json_object_t);
  procedure cancel_ot (v_codempid in varchar2,v_dtework in date,v_typot in varchar2);

  procedure get_ot_head (json_str_input in clob, json_str_output out clob);
  procedure gen_ot_head (json_str_output out clob);

  procedure get_cost_center(json_str_input in clob, json_str_output out clob);
  procedure get_TimeAttendant (json_str_input in clob,json_str_output out clob);
  procedure check_TimeAttendant;
  procedure gen_TimeAttendant (json_str_output out clob);
  function gen_codcenter (v_codcomp in varchar2) return varchar2;
end HRAL4KE;

/
