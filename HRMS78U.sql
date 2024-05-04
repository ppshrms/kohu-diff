--------------------------------------------------------
--  DDL for Package HRMS78U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS78U" as
-- last update: 27/09/2022 10:44

  param_msg_error       varchar2(4000 char);
  param_msg_error_mail  varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  v_chken               varchar2(10);
  v_zyear               number;

  p_dtest               varchar2(100 char);
  p_dteen               varchar2(100 char);
  p_staappr             varchar2(100 char);
  p_codempid            varchar2(100 char);
  p_dtereq              date;
  p_numseq              number;
  p_approvno            number;
  -- sendApprove
  p_remark_appr       varchar2(4000 char);
  p_remark_not_appr   varchar2(4000 char);

  function check_numcont(v_numcont varchar2) return varchar2;
  procedure hrms78u(json_str_input in clob, json_str_output out clob);
  procedure process_approve(json_str_input in clob, json_str_output out clob);
  procedure process_not_approve(json_str_input in clob, json_str_output out clob);
  procedure cal_loan(v_amtlon         in number, v_rateilon in number, v_numlon in number,
                     rq_codempid      in varchar, rq_dtereq in date, rq_numseq  in number,
                     v_amtlon_new     out number,
                     v_rateilon_new   out number,
                     v_numlon_new     out number,
                     v_amtitotflat_new out number,
                     v_amtiflat_new    out number);
end hrms78u;

/
