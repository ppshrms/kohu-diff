--------------------------------------------------------
--  DDL for Package HRMS6KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS6KE" is
  v_file              utl_file.file_type;
  v_file_name         varchar2 (4000 char);

  obj_row             json_object_t;
  json_long           json_object_t;

  type arr is table of varchar2(600) index by binary_integer;
  v_data_type_arr   arr;
  v_column_name_arr arr;
  v_type_arr        arr;
  --block b_index
  b_index_numotgen      varchar2(100 char);
  b_index_codempid      varchar2(100 char);
  b_index_dtereq        date;
  b_index_numseq        number;
  b_index_codcomp   	varchar2(4000 char);
  b_index_dtestrt 	    date;
  b_index_dteend 	    date;

  v_dtework             date;
  v_dtereq              date;
  v_codcomp             varchar2(100 char);
  v_codcalen            varchar2(100 char);
  v_codshift            varchar2(100 char);
  v_dtestrt             date;
  v_dteend              date;
  v_timbstr             varchar2(100 char);
  v_timbend             varchar2(100 char);
  v_timdstr             varchar2(100 char);
  v_timdend             varchar2(100 char);
  v_timastr             varchar2(100 char);
  v_timaend             varchar2(100 char);
  v_codrem              varchar2(100 char);
  v_remark              varchar2(500 char);
  -- /*user3*/ new requirement --
  v_codempid            varchar2(100 char);
  v_codinput            varchar2(100 char);
  v_numotgen            varchar2(100 char);
  v_flgchglv            varchar2(100 char);
  v_codcompw            varchar2(100 char);
  v_qtyminb             varchar2(100 char);
  v_qtymind             varchar2(100 char);
  v_qtymina             varchar2(100 char);

  --block ttotreqst
  --ttotreqst_codempid      ttotreqst.codempid%type; --varchar2 8
  ttotreqst_numotgen      ttotreqst.numotgen%type;
  ttotreqst_codcomp       ttotreqst.codcomp%type;  --varchar2 21
  ttotreqst_codcalen      ttotreqst.codcalen %type;
  ttotreqst_codshift      ttotreqst.codshift%type;
  ttotreqst_dtestrt       ttotreqst.dtestrt%type;  --date
  ttotreqst_dteend        ttotreqst.dteend%type;   --date
  ttotreqst_timbstr       ttotreqst.timbstr%type;  --varchar2 4
  ttotreqst_timbend       ttotreqst.timbend%type;  --varchar2 4
  ttotreqst_timdstr       ttotreqst.timdstr%type;  --varchar2 4
  ttotreqst_timdend       ttotreqst.timdend%type;  --varchar2 4
  ttotreqst_timastr       ttotreqst.timastr%type;  --varchar2 4
  ttotreqst_timaend       ttotreqst.timaend%type;  --varchar2 4
  ttotreqst_codrem        ttotreqst.codrem%type;   --varchar2 4
  ttotreqst_remark        ttotreqst.remark%type;   --varchar2 200
  ttotreqst_codinput      ttotreqst.codinput%type; --varchar2 8
  ttotreqst_dtereq        ttotreqst.dtereq%type;   --date
  ttotreqst_codempid      varchar2(4000 char);     -- user4 || 15/08/2018 || for add codempid only [requirement from NEO]
  ttotreqst_codcompw      varchar2(1000 char);
  ttotreqst_flgchglv      varchar2(1000 char);
  ttotreqst_qtyminb       varchar2(1000 char);
  ttotreqst_qtymind       varchar2(1000 char);
  ttotreqst_qtymina       varchar2(1000 char);
  ttotreqst_costcent      varchar2(1000 char);

  --block ttotreq
  ttotreq_dtestrt       date;
  ttotreq_dteend        date;
  ttotreq_dtereq        date;
  ttotreq_codempid      varchar2(1000 char);
  ttotreq_typot         varchar2(1000 char);
  ttotreq_codshift      varchar2(1000 char);
  ttotreq_timstrt       varchar2(1000 char);
  ttotreq_timend        varchar2(1000 char);
  ttotreq_staappr       varchar2(1000 char);
  ttotreq_codcomp       varchar2(1000 char);
  ttotreq_seqno         number;
  ttotreq_timbstr       varchar2(1000 char);
  ttotreq_timbend       varchar2(1000 char);
  ttotreq_timdstr       varchar2(1000 char);
  ttotreq_timdend       varchar2(1000 char);
  ttotreq_timastr       varchar2(1000 char);
  ttotreq_timaend       varchar2(1000 char);
  ttotreq_codappr       varchar2(1000 char);
  ttotreq_dteappr       date;
  ttotreq_remarkap      varchar2(1000 char);
  ttotreq_approvno      number;
  ttotreq_routeno       varchar2(1000 char);
  ttotreq_codempap      varchar2(1000 char);
  ttotreq_codcompap     varchar2(1000 char);
  ttotreq_codposap      varchar2(1000 char);
  ttotreq_numotreq      varchar2(1000 char);
  ttotreq_numotgen      varchar2(1000 char);
  ttotreq_codrem        varchar2(1000 char);
  ttotreq_remark        varchar2(1000 char);
  ttotreq_codinput      varchar2(1000 char);
  ttotreq_coduser       varchar2(1000 char);
  ttotreq_dtecancel     date;
  ttotreq_dteinput      date;
  ttotreq_dteupd        date;
  --
  ttotreq_qtyminr       varchar2(1000 char);
  ttotreq_codcompw      varchar2(1000 char);
  ttotreq_flgchglv      varchar2(1000 char);
  ttotreq_qtyminb       varchar2(1000 char);
  ttotreq_qtymind       varchar2(1000 char);
  ttotreq_qtymina       varchar2(1000 char);
  --param
  param_msg_error       varchar2(4000 char);
--  param_v_summin        number;
--  param_qtyavgwk        number;
  v_msg                 varchar2(4000);
  --global
  global_v_coduser      varchar2(100);
  global_v_codpswd      varchar2(100);
  global_v_codempid     varchar2(100);
  global_v_empid        varchar2(100);
  global_v_lang         varchar2(100);
  global_v_zyear        number;
  global_v_chken        varchar2(10) := hcm_secur.get_v_chken;
  global_v_codapp       varchar2(4000 char);
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	number;
  global_v_numlvlsalen 	number;
  v_rcnt                varchar2(100);  -- total
  v_rcn                 varchar2(100);  -- record number
  global_ttotreq_row    json_object_t;
  global_ttotreq_data   json_object_t;
  global_ttotreq_count  number;

  -->> user18 ST11 03/08/2021 change std
  v_report_numseq       number;
  p_flgclear            number;

  v_qtyot_total         number;
  v_qtytotal            number;

  v_dtestrtwk           date;
  v_dteendwk            date;

  v_qtyminot            number;
  v_qtyminotOth         number;
  v_qtydaywk            number;
  ttotreq_staovrot      ttotreq.staovrot%type;
  ttotreq_numseq        ttotreq.numseq%type;
  v_msgerror            varchar2(4000);
  v_error_numseq        number;
  p_error_numseq        number;
  p_flgconfirm          varchar2(1);
  v_staovrot            varchar2(1);
  v_numseq              number;
  p_qtyot_req           number;

  a_dtestweek           std_ot.a_dtestr;
  a_dteenweek           std_ot.a_dtestr;
  a_sumwork             std_ot.a_qtyotstr;
  a_sumotreqoth         std_ot.a_qtyotstr;
  a_sumotreq            std_ot.a_qtyotstr;
  a_sumot               std_ot.a_qtyotstr;
  a_totwork             std_ot.a_qtyotstr;
  v_qtyperiod           number;
  v_numseq_tmp          number;
  --<< user18 ST11 03/08/2021 change std

  procedure check_index;
  procedure check_detail_tab1;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_tab1(json_str_input in clob, json_str_output out clob);
  procedure get_tab2(json_str_input in clob, json_str_output out clob);
  procedure get_tab2_process(json_str_input in clob, json_str_output out clob);
  procedure get_tab2_add_inline(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure initial_value(json_str in clob);
  procedure check_index_save;
  procedure check_data;
  procedure insert_next_step(json_str in clob, p_result out clob);
  procedure save_ttotreq;
  procedure save_ttotreqst;
  procedure delete_index(json_str_input in clob, json_str_output out clob);
  procedure get_tcodotrq(json_str_input in clob, json_str_output out clob);
  procedure get_costcenter(json_str_input in clob, json_str_output out clob);
  procedure get_ot_change (json_str_input in clob, json_str_output out clob);
  procedure get_codshift_ot (json_str_input in clob, json_str_output out clob);

  -->> user18 ST11 03/08/2021 change std
  procedure get_ChkDtereq (json_str_input in clob, json_str_output out clob);
  procedure get_cumulative_hours (json_str_input in clob, json_str_output out clob);
  procedure get_detail_create (json_str_input in clob, json_str_output out clob);
  procedure update_temp (json_str_input in clob, json_str_output out clob);
  procedure check_after_save;
  --<< user18 ST11 03/08/2021 change std
end; -- Package spec

/
