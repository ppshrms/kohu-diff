--------------------------------------------------------
--  DDL for Package HRMS75U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS75U" is 
-- last update: 02/02/2023 17:16  ||STT-SS-2101 /redmine 661  

  param_msg_error       varchar2(4000 char);
  param_msg_error_mail  varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_chken               varchar2(10);
  v_zyear               number;

  -- param index
  p_codcomp           varchar2(100);
  p_dtest             varchar2(100);
  p_dteen             varchar2(100);
  p_staappr           varchar2(100);
  p_codempid          varchar2(100);
  -- param detail
  p_dtereq            varchar2(100);
  p_seqno             varchar2(100);
  p_dtereqr           varchar2(100);
  p_dteapprp         varchar2(100);
  -- sendApprove
  p_remark_appr         varchar2(4000 char);
  p_remark_not_appr     varchar2(4000 char);

  procedure initial_value (json_str in clob);
  procedure hrms75u_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure get_detail_table(json_str_input in clob, json_str_output out clob);
  procedure process_approve(json_str_input in clob, json_str_output out clob);
  procedure get_period(json_str_input in clob, json_str_output out clob);
end; -- Package spec

/
