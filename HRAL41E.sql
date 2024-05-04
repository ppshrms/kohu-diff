--------------------------------------------------------
--  DDL for Package HRAL41E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL41E" is
-- last update: 10/11/2022 15:17  error NMT: redmine415
  param_msg_error           varchar2(4000 char);
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(1000 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);
  v_chken                   varchar2(10 char);

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);

  p_flg                     varchar2(100 char);
  p_flgProcess              varchar2(100 char);
  p_codempid                varchar2(4000 char);
--  p_codempid_query          varchar2(4000 char);
  p_codcomp                 varchar2(4000 char);
  p_codcalen                varchar2(4000 char);
--  p_dtestr                  date;
--  p_dteend                  date;

  p_codshift                varchar2(4000 char);
  p_numotreq                varchar2(4000 char);
  p_typot                   varchar2(4000 char);
  p_dtewkreq                date;
  p_timstrt                 varchar2(4000 char);
  p_timend                  varchar2(4000 char);
  p_dtestrt                 date;
  p_dteend                  date;
  p_dtestrt_ot              date;
  p_dteend_ot               date;
  p_dtereq                  date;
  p_typotreq                varchar2(4000 char);
  p_timstrta                varchar2(4000 char);
  p_timstrtb                varchar2(4000 char);
  p_timstrtd                varchar2(4000 char);
  p_timenda                 varchar2(4000 char);
  p_timendb                 varchar2(4000 char);
  p_timendd                 varchar2(4000 char);
  p_codrem                  varchar2(4000 char);
  p_codappr                 varchar2(4000 char);
  p_staotreq                varchar2(4000 char);
  p_dteappr                 date;
  p_dtecancl                date;
  p_remark                  varchar2(4000 char);
  p_dayeupd                 date;
  p_codcompw                varchar2(4000 char);
  p_flgchglv                varchar2(4000 char);
  p_qtymin                  number;
  p_qtymina                 number;
  p_qtyminb                 number;
  p_qtymind                 number;

  p_typwork                 varchar2(4000 char);
  p_qtyminr                 number;

  -- FORMAT_TEXT
--  p_item02                  number;
--  p_item01                  varchar2(4000 char);
--  p_numseq                  number;
--  p_codapp                  varchar2(4000 char);
--  p_coduser                 varchar2(4000 char);
--  p_temp01                  number;

  TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  p_text        data_error;
  p_error_code  data_error;
  p_numseq      data_error;

  -->> user18 ST11 05/08/2021 change std
  v_report_numseq       number;

  v_qtyot_total         number;
  v_qtytotal            number;

  v_dtestrtwk           date;
  v_dteendwk            date;

  v_dtestrtwk2           date;
  v_dteendwk2            date;

  v_qtyminot            number;
  v_qtyminotOth         number;
  v_qtydaywk            number;
  v_qtymxotwk           tcontrot.qtymxotwk%type;
  v_qtymxallwk          tcontrot.qtymxallwk%type; 

  v_qtyminotb     number;
  v_qtyminotd     number;
  v_qtyminota     number;

  v_codcomp       varchar2(100 char);
  v_dtestrt       date;
  v_dteend        date;
  v_staovrot      varchar2(1);  
  v_msgerror      varchar2(4000 char);
  p_flgconfirm    varchar2(1);
  v_typalert      tcontrot.typalert%type;
  
  a_dtestweek           std_ot.a_dtestr;
  a_dteenweek           std_ot.a_dtestr;
  a_sumwork             std_ot.a_qtyotstr;
  a_sumotreqoth         std_ot.a_qtyotstr;
  a_sumotreq            std_ot.a_qtyotstr;
  a_sumot               std_ot.a_qtyotstr;
  a_totwork             std_ot.a_qtyotstr;
  v_qtyperiod           number;
  v_numseq_tmp          number;

  --<< user18 ST11 05/08/2021 change std


  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);

  function check_date (p_date in varchar2, p_zyear in number) return boolean;
  function check_dteyre (p_date in varchar2) return date;
  function check_times (p_time in varchar2) return boolean;

  procedure get_overtime_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_overtime_detail(json_str_output out clob);

  procedure get_employee_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_employee_detail(json_str_output out clob);

  procedure get_process(json_str_input in clob, json_str_output out clob);
  procedure gen_process(json_str_output out clob);

  procedure get_cost_center(json_str_input in clob, json_str_output out clob);
--  procedure gen_cost_center(json_str_output out clob);

  procedure post_detail(json_str_input in clob, json_str_output out clob);
  procedure save_overtime_detail;
  procedure save_employee_detail;
  procedure delete_employee_detail;

  procedure delete_index(json_str_input in clob, json_str_output out clob);
  procedure get_ot_change (json_str_input in clob, json_str_output out clob);
  procedure get_codshift_ot (json_str_input in clob, json_str_output out clob);
  procedure get_import_process(json_str_input in clob, json_str_output out clob);
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);
  procedure get_codcompw (json_str_input in clob, json_str_output out clob);

  -->> user18 ST11 05/08/2021 change std
  procedure get_ChkDtereq (json_str_input in clob, json_str_output out clob);
  procedure get_cumulative_hours (json_str_input in clob, json_str_output out clob);
  procedure update_temp (json_str_input in clob, json_str_output out clob); 
--  function get_qtyminotOth(v_codempid varchar2, v_dtestrtwk date, v_dteendwk date, v_dtereq date, v_typot varchar2, v_numotreq varchar2,v_addby varchar2 default null) return number;

  --<< user18 ST11 05/08/2021 change std
END HRAL41E;

/
