--------------------------------------------------------
--  DDL for Package M_HRES6KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRES6KE" is
/* Cust-Modify: KOHU-HR2301 */
-- last update: 08/12/2023 16:40

  v_file              utl_file.file_type;
  v_file_name         varchar2 (4000 char);

  obj_row             json_object_t;
  json_long           long;

  type arr is table of varchar2(600) index by binary_integer;

--  type a_dtestr is table of varchar2(10) index by binary_integer;
--  type a_qtyotstr is table of varchar2(10) index by binary_integer;

  v_data_type_arr   arr;
  v_column_name_arr arr;
  v_type_arr        arr;
  --block b_index
  b_index_codempid      ttotreq.codempid%type; --varchar2
  b_index_dtereq        ttotreq.dtereq%type;   --date
  b_index_numseq        ttotreq.numseq%type;    --number
  b_index_codcomp   	  varchar2(4000 char);
  b_index_dtereq_st 	  date;
  b_index_dtereq_en 	  date;

  --block ttotreq
  ttotreq_codempid      ttotreq.codempid%type; --varchar2 8
  ttotreq_dtereq        ttotreq.dtereq%type;   --date
  ttotreq_numseq        ttotreq.numseq%type;   --number
  ttotreq_numotreq      ttotreq.numotreq%type; --varchar2 12
  ttotreq_codcomp       ttotreq.codcomp%type;  --varchar2 21
  ttotreq_dtestrt       ttotreq.dtestrt%type;  --date
  ttotreq_dteend        ttotreq.dteend%type;   --date
  ttotreq_timbstr       ttotreq.timbstr%type;  --varchar2 4
  ttotreq_timbend       ttotreq.timbend%type;  --varchar2 4
  ttotreq_timdstr       ttotreq.timdstr%type;  --varchar2 4
  ttotreq_timdend       ttotreq.timdend%type;  --varchar2 4
  ttotreq_timastr       ttotreq.timastr%type;  --varchar2 4
  ttotreq_timaend       ttotreq.timaend%type;  --varchar2 4
  ttotreq_codrem        ttotreq.codrem%type;   --varchar2 4
  ttotreq_staappr       ttotreq.staappr%type;  --varchar2 1
  ttotreq_codappr       ttotreq.codappr%type;  --varchar2 8
  ttotreq_dteappr       ttotreq.dteappr%type;  --date
  ttotreq_dteupd        ttotreq.dteupd%type;   --date
  ttotreq_coduser       ttotreq.coduser%type;  --varchar2 8
  ttotreq_remarkap      ttotreq.remarkap%type; --varchar2 500
  ttotreq_approvno      ttotreq.approvno%type; --number
  ttotreq_routeno       ttotreq.routeno%type;  --varchar2 10
  ttotreq_remark        ttotreq.remark%type;   --varchar2 200
  --ttotreq_flgsend       ttotreq.flgsend%type;  --varchar2 1
  --ttotreq_dtesnd        ttotreq.dtesnd%type;   --date
  ttotreq_codinput      ttotreq.codinput%type; --varchar2 8
  --ttotreq_numotgen      ttotreq.numotgen%type; --varchar2 20
  ttotreq_dtecancel     ttotreq.dtecancel%type; --date
  ttotreq_dteinput      ttotreq.dteinput%type; --date
  --ttotreq_dteapph       ttotreq.dteapph%type;  --date
  --ttotreq_flgagency     ttotreq.flgagency%type;--varchar2 1
  -- /*user3*/ new requirement --
  ttotreq_flgchglv      ttotreq.flgchglv%type;
  ttotreq_codcompw      ttotreq.codcompw%type;
  ttotreq_qtyminb       varchar2(50 char);
  ttotreq_qtymind       varchar2(50 char);
  ttotreq_qtymina       varchar2(50 char);
  ttotreq_qtyotreq      ttotreq.qtyotreq%type; --user36 ST11 16/09/2023
  --para
  param_msg_error       varchar2(600);
  param_v_summin        number;
  param_qtyavgwk        number;
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
  v_rcnt                varchar2(100);  -- total
  v_rcn                 varchar2(100);  -- record number
  --<< user18 ST11 03/08/2021 change std detail cumulative overtime for week period
  p_dtestrt             date;
  p_dteend              date;
  p_codcomp             ttotreq.codcomp%type;
  p_codempid_query      ttotreq.codempid%type;
  p_timbstr             ttotreq.timbstr%type; 
  p_timbend             ttotreq.timbend%type; 
  p_qtyminb             ttotreq.qtyminb%type; 

  p_timdstr             ttotreq.timdstr%type; 
  p_timdend             ttotreq.timdend%type; 
  p_qtymind             ttotreq.qtymind%type; 

  p_timastr             ttotreq.timastr%type; 
  p_timaend             ttotreq.timaend%type; 
  p_qtymina             ttotreq.qtymina%type; 
  p_numseq              ttotreq.numseq%type; 
  p_numotreq            ttotreq.numotreq%type; 
  p_dtereq              ttotreq.dtereq%type; 

  p_dtestrtwk           date;
  p_dteendwk            date;
  p_qtydaywk            number;
  p_qtyot_reqoth        number;
  p_qtyot_req           number;
  p_qtyot_total         number;
  p_qtytotal            number;
  ttotreq_staovrot      ttotreq.staovrot%type;
  v_msgerror            varchar2(4000);
  p_flgconfirm          varchar2(1);

  a_dtestweek           std_ot.a_dtestr;
  a_dteenweek           std_ot.a_dtestr;
  a_sumwork             std_ot.a_qtyotstr;
  a_sumotreqoth         std_ot.a_qtyotstr;
  a_sumotreq            std_ot.a_qtyotstr;
  a_sumot               std_ot.a_qtyotstr;
  a_totwork             std_ot.a_qtyotstr;
  v_qtyperiod           number;
  p_obj_cumulative      json_object_t;

  -->> user18 ST11 03/08/2021 change std detail cumulative overtime for week period
  -- mo surachai
  p_dtework         ttotreq.dtereq%type;
  p_codcompw        ttotreq.codcomp%type;
  p_codcompbg        VARCHAR2(4000);
  p_departmentbudget VARCHAR2(4000);
  p_wkbudgetdate     VARCHAR2(4000);
  p_wkbudget         number;
  p_requesthr        number;
  p_otherrequesthr   number;
  p_totalhr          number;
  p_remainhr         number;
  p_percentused      number;
  p_overbudgetstatus VARCHAR2(4000);
  p_reconfirm          VARCHAR2(4000);
  p_staappr_ot          VARCHAR2(4000);
  type array_t is table of varchar2(4000) index by binary_integer;
  p_pageEdit        varchar2(5);
  p_flgPageEdit     varchar2(1);

  procedure select_ttotreq(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure ess_save_ttotreq(json_str in clob, resp_json_str out clob);
  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure insert_next_step;
  procedure save_ttotreq;
  function get_resp_json_str return clob;
  function var_dump_json_obj(json_obj json_object_t) return json_object_t;
  procedure ess_cancel_ttotreq(json_str in clob, resp_json_str out clob);
  procedure get_tcodotrq(json_str_input in clob, json_str_output out clob);
  procedure get_costcenter(json_str_input in clob, json_str_output out clob);
  procedure get_detail_create(json_str_input in clob, json_str_output out clob);
  -- << mo surachai | 13/09/2023
  procedure ot_budget(json_str_input in clob, json_str_output out clob);
  procedure list_of_app(json_str_input in clob, json_srt_output out clob);
  -- >>
  --<< user18 ST11 03/08/2021 change std detail cumulative overtime for week period
  function get_qtydaywk(v_codempid varchar2, v_dtestrtwk date, v_dteendwk date) return number;
  function get_qtyminotOth(v_codempid varchar2, v_dtestrtwk date, v_dteendwk date, v_dtereq date, v_numseq number, v_numotreq varchar2,v_addby varchar2 default null) return number;
  function get_qtyminot(p_codempid varchar2, v_dtestrt date, v_dteend date,
                        v_qtyminb number,v_timbend varchar2,v_timbstr varchar2,
                        v_qtymind number,v_timdend varchar2,v_timdstr varchar2,
                        v_qtymina number,v_timaend varchar2,v_timastr varchar2) return number;
  procedure get_cumulative_hours(json_str_input in clob, json_str_output out clob);
  -->> user18 ST11 03/08/2021 change std detail cumulative overtime for week period  

end M_HRES6KE; -- Package spec

/
