--------------------------------------------------------
--  DDL for Package M_HRES6ME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRES6ME" AS
/* Cust-Modify: KOHU-SM2301 */
-- last update: 06/12/2023 11:30

  -- global
  global_v_coduser       temploy1.coduser%type;
  global_v_codpswd       varchar2(100 char);
  global_v_codempid      temploy1.codempid%type;
  global_v_lang          varchar2(100 char);
  global_v_zyear         number;
  global_v_chken         varchar2(10 char);
  v_rcnt                 varchar2(100 char);  -- total
  v_rcn                  varchar2(100 char);  -- record number

  tleaverq_v_codempid   temploy1.codempid%type;
  tleaverq_v_seqno      varchar2(1000 char);
  tleaverq_v_dtereq     date;
  tleaverq_v_staappr    varchar2(1000 char);
  tleaverq_v_codleave   tleavecd.codleave%type;
  tleaverq_v_flgleave   varchar2(1000 char);
  tleaverq_v_dteleave   date;
  tleaverq_v_dtestrt    date;
  tleaverq_v_dteend     date;
  tleaverq_v_timstrt    varchar2(1000 char);
  tleaverq_v_timend     varchar2(1000 char);
  tleaverq_v_deslereq   varchar2(1000 char);
  tleaverq_v_dteappr    date;
  tleaverq_v_codappr    temploy1.codappr%type;
  tleaverq_v_remarkap   varchar2(1000 char);
  tleaverq_v_approvno   varchar2(1000 char);
  tleaverq_v_codempap   varchar2(1000 char);
  tleaverq_v_codcompap  tcenter.codcomp%type;
  tleaverq_v_codposap   tpostn.codpos%type;
  tleaverq_v_flgsend    varchar2(1000 char);
  tleaverq_v_dteupd     date;
  tleaverq_v_coduser    temploy1.coduser%type;
  tleaverq_v_codinput   varchar2(1000 char);
  tleaverq_v_flgagency  varchar2(1000 char);
  tleaverq_v_dteinput   date;
  tleaverq_v_dtesnd     date;
  tleaverq_v_dteapph    date;
  tleaverq_v_dtecancel  date;
  tleaverq_v_routeno    varchar2(1000 char);
  tleaverq_v_codshift   tshiftcd.codshift%type;
  tleaverq_v_codcomp    tcenter.codcomp%type;
  tleaverq_v_filenam1   varchar2(1000 char);
  tleaverq_v_numlereq   varchar2(1000 char);
  tleaverq_v_desleave   varchar2(1000 char);
  --b_index
  b_index_codempid      temploy1.codempid%type;
  b_index_dtereq        date;
  b_index_seqno         number;
  b_index_dtereqr       date;
  b_index_seqnor        number;
  b_index_codinput      tleavecc.codinput%type;
  b_index_codcomp   	  tcenter.codcomp%type;
  b_index_dtereq_st 	  date;
  b_index_dtereq_en 	  date;
  --block tleavecc
  tleavecc_codempid     tleavecc.codempid%type;
  tleavecc_desc_codleave varchar2(500 char);
  tleavecc_seqno        tleavecc.seqno%type;
  tleavecc_dtereq       tleavecc.dtereq%type;
  tleavecc_codleave     tleavecc.codleave%type;
  tleavecc_dtestrt      tleavecc.dtestrt%type;
  tleavecc_dteend       tleavecc.dteend%type;
  tleavecc_desreq       tleavecc.desreq%type;
  tleavecc_seqnor       tleavecc.seqnor%type;
  tleavecc_dtereqr      tleavecc.dtereqr%type;
  tleavecc_numlereq     tleavecc.numlereq%type;
  tleavecc_codcomp      tleavecc.codcomp%type;
  tleavecc_codappr      tleavecc.codappr%type;
  tleavecc_staappr      tleavecc.staappr%type;
  tleavecc_dteupd       tleavecc.dteupd%type;
  tleavecc_coduser      tleavecc.coduser%type;
  tleavecc_approvno     tleavecc.approvno%type;
  tleavecc_remarkap     tleavecc.remarkap%type;
  tleavecc_dteappr      tleavecc.dteappr%type;
  tleavecc_routeno      tleavecc.routeno%type;
  tleavecc_codinput     tleavecc.codinput%type;
  tleavecc_dteinput     tleavecc.dteinput%type;
  tleavecc_dtecancel    tleavecc.dtecancel%type;
  tleavecc_codempap     varchar2(4000 char);
  tleavecc_flgsend      tleavecc.flgsend%type;
  tleavecc_flgcanc      tleavecc.flgcanc%type;
  tleavecc_dtesnd       tleavecc.dtesnd%type;
  tleavecc_dteapph      tleavecc.dteapph%type;
  tleavecc_flgagency    tleavecc.flgagency%type;
  --param
  param_msg_error       varchar2(4000 char);

  procedure initial_value(json_str in clob);
  procedure get_index (json_str_input in clob,json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob,json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure cancel_tleavecc (json_str_input in clob, json_str_output out clob);
  procedure check_data;
  procedure insert_next_step;
  procedure save_tleavecc;
  function gen_numseq RETURN number;

END M_HRES6ME;

/
