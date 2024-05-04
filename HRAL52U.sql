--------------------------------------------------------
--  DDL for Package HRAL52U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL52U" is

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal   			    varchar2(4 char);
  global_v_zyear        varchar2(4 char);
  v_dteupd_log          date;

  p_codempid            temploy1.codempid%type;
  p_codcomp             temploy1.codcomp%type;
  p_stdate              date;
  p_endate              date;
  p_dtework             date;
  p_timstrt             varchar2(10 char);
  p_timend              varchar2(10 char);
  p_codleave            tleavetr.codleave%type;
  p_numlereq            tleavetr.numlereq%type;

  v_codcomp             tleavetr.codcomp%type;
  v_dtework             date;
  v_codshift            tleavetr.codshift%type;
  v_codleave            tleavetr.codleave%type;
  v_timstrt             varchar2(10 char);
  v_timstrt_o           varchar2(10 char);
  v_timend              varchar2(10 char);
  v_timend_o            varchar2(10 char);
  v_qtymin              number := 0;
  v_qtymin_o            number := 0;
  v_qtyday              number := 0;
  v_qtyday_o            number := 0;
  v_flgwork             varchar2(1 char);
  v_numlereq            tleavetr.numlereq%type;
  -- paternity leave --
  v_dteprgntst	        tlereqst.dteprgntst%type;
  v_dteprgntst_o	      tlereqst.dteprgntst%type;
  v_timprgnt            varchar2(20 char);
  v_timprgnt_o          varchar2(20 char);
  --
  v_typleave            tleavetr.typleave%type;
  v_staleave            tleavetr.staleave%type;
  v_yrecycle            number;
  v_typpayroll          tleavetr.typpayroll%type;
  v_qtymins             varchar2(10 char);
  v_qtymins_o           varchar2(10 char);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_codshift(json_str_input in clob, json_str_output out clob);
  procedure get_showleave(json_str_input in clob, json_str_output out clob);
  procedure get_info(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure get_flgtype_leave(json_str_input in clob, json_str_output out clob);
end HRAL52U;

/
