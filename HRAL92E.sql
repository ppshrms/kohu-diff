--------------------------------------------------------
--  DDL for Package HRAL92E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL92E" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  p_codapp                  varchar2(100 char):= 'HRAL92E';
  p_codempid                varchar2(4000 char);
  p_codcompy                varchar2(100 char);
  p_dteeffec                date;
  p_dteeffecOld             date;
  p_codcompyQuery           varchar2(4000 char);
  p_dteeffecQuery           date;
  p_flg                     varchar2(100 char);

  p_numapprot               number;
--  tcontrot_otcalflg         varchar2(100 char);
  p_codot                   varchar2(100 char);
  p_codrtot                 varchar2(100 char);
  p_codotalw                varchar2(100 char);

  p_numseq                  number;
  p_syncond                 varchar2(4000 char);
  p_statement               clob;
  p_qtyminst                number;
  p_qtyminen                number;
  p_amtmeal                 varchar2(4000 char);

  p_typrate                 varchar2(4000 char);
  p_numseq2                 number;
  p_timstrt                 varchar2(4000 char);
  p_timend                  varchar2(4000 char);
  p_str_timstrt             TOTBREAK2.TIMSTRT%TYPE;
  p_str_timend              TOTBREAK2.TIMEND%TYPE;
  p_rteotpay                number;

  p_typbreak                varchar2(4000 char);

  p_qtyminmx                number;
  p_qtyminbk                number;

  p_qtymstot                number;
  p_qtymenot                number;
  p_qtymacot                number;

  p_flgchglv                varchar2(1 char);
  p_qtymincal               number;
  --<< user25 Date: 02/08/2021 TDKU-SS-2101
  p_typalert                varchar2(1 char);
  p_qtymxotwk               number;
  p_qtymxallwk              number;
  p_startday                tcontrot.startday%type;
  p_otcalflg                tcontrot.otcalflg%type;
  -->> user25 Date: 02/08/2021 TDKU-SS-2101 
  p_condot                  varchar2(4000 char);
  p_condextr                varchar2(4000 char);
  p_flgrateot               varchar2(100 char) := '1';
  p_flgcopyot               varchar2(100 char) := 'N';
  p_flgcopy                 varchar2(100 char) := 'N';

  isEdit                    boolean := true;
  isAdd                     boolean := false;
  isCopy                    varchar2(1 char) := 'N';
  forceAdd                  varchar2(1 char) := 'N';
  v_rowid                   varchar2(4000 char);
  v_indexdteeffec           date;

  p_statementot             clob;
  p_statementex             clob;

  isInsertReport            boolean := false;
  v_msqerror                varchar2(4000 char);
  v_detailDisabled          boolean;

  procedure chk_tinexinf (p_type in varchar2, v_code in tinexinf.codpay%type);
  procedure get_flg_status (json_str_input in clob, json_str_output out clob);
  procedure gen_flg_status;
  procedure get_copy_list(json_str_input in clob, json_str_output out clob);

  procedure get_upd_data(json_str_input in clob, json_str_output out clob);
  procedure gen_upd_data(json_str_output out clob);

  procedure get_logical_statement(json_str_input in clob, json_str_output out clob);
  procedure gen_logical_statement(json_str_output out clob);

  procedure get_rounding_minutes_tab1(json_str_input in clob, json_str_output out clob);
  procedure gen_rounding_minutes_tab1(json_str_output out clob);

  procedure get_time_analysis_tab1(json_str_input in clob, json_str_output out clob);
  procedure gen_time_analysis_tab1(json_str_output out clob);

  procedure get_payment_rate_labr_law_tab2(json_str_input in clob, json_str_output out clob);
  procedure gen_payment_rate_labr_law_tab2(json_str_output out clob);

  procedure get_payment_rate_tab2(json_str_input in clob, json_str_output out clob);
  procedure gen_payment_rate_tab2(json_str_output out clob);

  procedure get_special_allowance_tab3(json_str_input in clob, json_str_output out clob);
  procedure gen_special_allowance_tab3(json_str_output out clob);

  procedure get_revenue_code_tab4(json_str_input in clob, json_str_output out clob);
  procedure gen_revenue_code_tab4(json_str_output out clob);

  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure clear_ttemprpt;
  procedure insert_ttemprpt_tab1_detail(obj_data in json_object_t);
  procedure insert_ttemprpt_tab1_table1(obj_data in json_object_t);
  procedure insert_ttemprpt_tab1_table2(obj_data in json_object_t);
  procedure insert_ttemprpt_tab2_table1(obj_data in json_object_t);
  procedure insert_ttemprpt_tab2_table2(obj_data in json_object_t);
  procedure insert_ttemprpt_tab3(obj_data in json_object_t);
  procedure update_ttemprpt_user_updte(obj_data in json_object_t);

  procedure post_detail(json_str_input in clob, json_str_output out clob);

  procedure post_rounding_minutes_tab1(json_str_input in json_object_t);
  procedure post_time_analysis_tab1(json_str_input in json_object_t);
  procedure post_payment_rate_tab2(json_str_input in json_object_t);
  procedure post_special_allowance_tab3(json_str_input in json_object_t);

  procedure save_revenue_code;
  procedure save_payment_rate_labr_law;

  procedure rounding_minutes_tab1_update (json_current in out json_object_t);
  procedure rounding_minutes_tab1_insert (json_current in out json_object_t);

end HRAL92E;

/
