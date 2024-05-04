--------------------------------------------------------
--  DDL for Package M_HRES62E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRES62E" is
  /* Cust-Modify: KOHU-SM2301 */
  -- last update: 14/12/2023 12:00
  
  v_file              utl_file.file_type;
  v_file_name         varchar2 (4000 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  obj_row             json_object_t;
  obj_data            json_object_t;
  json_long           long;

  --block b_index
  b_index_codempid      tleaverq.codempid%type; --varchar2
  b_index_seqno         tleaverq.seqno%type;    --number
  b_index_dtereq        tleaverq.dtereq%type;   --date
  p_start               varchar2(1000 char);
  p_end                 varchar2(1000 char);
  p_limit               varchar2(1000 char);
  b_index_codcomp   	  varchar2(4000 char);
  b_index_dtereq_st 	  date;
  b_index_dtereq_en 	  date;
  b_index_dtework 	      date;
  --block tleaverq
  tleaverq_codempid     tleaverq.codempid%type; --varchar2
  tleaverq_seqno        tleaverq.seqno%type;    --number
  tleaverq_dtereq       tleaverq.dtereq%type;   --date
  tleaverq_codleave     tleaverq.codleave%type; --varchar2
  tleaverq_deslereq     tleaverq.deslereq%type; --varchar2
  tleaverq_codshift     tleaverq.codshift%type; --varchar2
  tleaverq_dteleave     tleaverq.dteleave%type; --date
  tleaverq_flgleave     tleaverq.flgleave%type; --varchar2
  tleaverq_dtestrt      tleaverq.dtestrt%type;  --date
  tleaverq_dteend       tleaverq.dteend%type;   --date
  tleaverq_codinput     tleaverq.codinput%type;   --varchar2
  tleaverq_codcomp      tleaverq.codcomp%type;  --varchar2
  tleaverq_v_filenam1   tleaverq.filenam1%type; --varchar2
  tleaverq_filenam1     tleaverq.filenam1%type; --varchar2
  tleaverq_timstrt      tleaverq.timstrt%type;   --varchar2
  tleaverq_timend       tleaverq.timend%type;   --varchar2
  tleaverq_numlereq     tleaverq.numlereq%type; --varchar2
  tleaverq_codappr      tleaverq.codappr%type;  --varchar2
  tleaverq_staappr      tleaverq.staappr%type;  --varchar2
  tleaverq_dteupd       tleaverq.dteupd%type;  --varchar2
  tleaverq_coduser      tleaverq.coduser%type;  --varchar2
  tleaverq_approvno     tleaverq.approvno%type; --number
  tleaverq_remarkap     tleaverq.remarkap%type; --varchar2
  tleaverq_dteappr      tleaverq.dteappr%type;  --date
  tleaverq_routeno      tleaverq.routeno%type;  --varchar2
  tleaverq_dteinput     tleaverq.dteinput%type; --date
  tleaverq_dtecancel    tleaverq.dtecancel%type; --date
  tleaverq_desc_codleave varchar2(400 char);
  tleaverq_desleave     tleavecd.desleave%type; --varchar2
  -- paternity leave --
  tleaverq_dteprgntst   tleaverq.dteprgntst%type;
  tleaverq_timprgnt     tleaverq.timprgnt%type;
  tleaverq_qtyday       tleaverq.qtyday%type;
  tleaverq_qtymin       tleaverq.qtymin%type;
  --
  tleaverq_param_json   json_object_t;
  json_obj2             json_object_t;
  att_flg               varchar2(100 char);
  att_attachname        varchar2(100 char);
  att_codleave          varchar2(100 char);
  att_numseq            number;
  att_flgattach         varchar2(100 char);
  att_filedesc         varchar2(100 char);

  tleaverq_v_codempid   varchar2(1000 char);
  tleaverq_v_seqno      varchar2(1000 char);
  tleaverq_v_dtereq     date;
  tleaverq_v_staappr    varchar2(1000 char);
  tleaverq_v_codleave   varchar2(1000 char);
  tleaverq_v_flgleave   varchar2(1000 char);
  tleaverq_v_dteleave   date;
  tleaverq_v_dtestrt    date;
  tleaverq_v_dteend     date;
  tleaverq_v_timstrt    varchar2(1000 char);
  tleaverq_v_timend     varchar2(1000 char);
  tleaverq_v_deslereq   varchar2(1000 char);
  tleaverq_v_dteappr    date;
  tleaverq_v_codappr    varchar2(1000 char);
  tleaverq_v_remarkap   varchar2(1000 char);
  tleaverq_v_approvno   varchar2(1000 char);
  tleaverq_v_codempap   varchar2(1000 char);
  tleaverq_v_codcompap  varchar2(1000 char);
  tleaverq_v_codposap   varchar2(1000 char);
  tleaverq_v_flgsend    varchar2(1000 char);
  tleaverq_v_dteupd     date;
  tleaverq_v_coduser    varchar2(1000 char);
  tleaverq_v_codinput   varchar2(1000 char);
  tleaverq_v_flgagency  varchar2(1000 char);
  tleaverq_v_dteinput   date;
  tleaverq_v_dtesnd     date;
  tleaverq_v_dteapph    date;
  tleaverq_v_dtecancel  date;
  tleaverq_v_routeno    varchar2(1000 char);
  tleaverq_v_codshift   varchar2(1000 char);
  tleaverq_v_codcomp    varchar2(1000 char);
  tleaverq_v_numlereq   varchar2(1000 char);
  tleaverq_v_desleave   varchar2(1000 char);
  p_timstrt    varchar2(1000 char);
  p_timend     varchar2(1000 char);
  --block details
  details_staleave      tleavecd.STALEAVE%type;
  --block detail2
  detail2_qtyday1       number;
  detail2_qtyday2       number;
  detail2_qtyday3       number;
  detail2_qtyday4       number;
  detail2_qtyday5       number;
  detail2_qtyday6       number;
  detail2_flgdlemx      varchar2(1 char);
  detail2_staleave      tleavecd.STALEAVE%type;
  detail2_typleave      tleavecd.TYPLEAVE%type;
  detail2_destype       varchar2(600 char);
  detail2_qtytime       number;
  detail2_day1          number;
  detail2_day2          number;
  detail2_day3          number;
  detail2_day4          number;
  detail2_day5          number;
  detail2_day6          number;
  detail2_hur1          number;
  detail2_hur2          number;
  detail2_hur3          number;
  detail2_hur4          number;
  detail2_hur5          number;
  detail2_hur6          number;
  detail2_min1          number;
  detail2_min2          number;
  detail2_min3          number;
  detail2_min4          number;
  detail2_min5          number;
  detail2_min6          number;
  --para
  param_msg_error       varchar2(600 char);
  param_warn            varchar2(600 char);
  param_v_summin        number;
  param_qtyavgwk        number;
  param_flgwarn         varchar2(1 char);
  p_codleave        varchar2(1000 char);
  v_msg                 varchar2(4000 char);
  --global
  global_v_coduser      varchar2(1000 char);
  global_v_codpswd      varchar2(1000 char);
  global_v_codempid     varchar2(1000 char);
  global_v_empid        varchar2(100 char);
  global_v_lang         varchar2(100 char);
  global_v_codapp       varchar2(4000 char);
  v_zyear               number;
  global_v_chken        varchar2(10 char);
  v_rcnt                varchar2(100 char);  -- total
  v_rcn                 varchar2(100 char);  -- record number

  tleavecc_staappr      varchar2(4000 char);
  tleavecc_remarkap     varchar2(4000 char);
  tleavecc_dteappr      varchar2(4000 char);
  tleavecc_codappr      varchar2(4000 char);
  tleavecc_codempap     varchar2(4000 char);
  p_dayeupd             date;
  --
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_timework(json_str_input in clob, json_str_output out clob);
  procedure get_popup(json_str_input in clob, json_str_output out clob);
  procedure get_entitlement(json_str in clob, json_str_output out clob);
  procedure save_leave(json_str in clob, json_str_output out varchar2);
  procedure cancel_tleaverq(json_str in clob, json_str_output out varchar2);

  procedure cal_dhm (p_qtyavgwk in  number,
                     p_qtyday   in  number,
                     p_day      out number,
                     p_hour     out number,
                     p_min      out number);
  procedure get_codleave(json_str_input in clob, json_str_output out clob);
  procedure get_datail(json_str_input in clob, json_str_output out clob);
  procedure get_create(json_str_input in clob, json_str_output out clob);
  procedure enable_flgleave(json_str_input in clob, json_str_output out clob);
  procedure get_leaveatt(json_str_input in clob, json_str_output out clob);
  procedure get_flgtype_leave(json_str_input in clob, json_str_output out clob);
  procedure get_paternity_date(json_str_input in clob, json_str_output out clob);
  function check_leave_after(p_codempid varchar2,p_dtereq date,p_dteleave date,p_daydelay number) return varchar2;
  function check_leave_before(p_codempid varchar2,p_dtereq date,p_dteleave date,p_daydelay number) return varchar2;
  
  procedure get_list_appr(json_str_input in clob, json_str_output out clob);
end; -- Package spec

/
