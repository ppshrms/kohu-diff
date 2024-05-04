--------------------------------------------------------
--  DDL for Package HRESH1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRESH1X" is
  -- last update: 11/11/2016 16:47
  param_msg_error   varchar2(4000 char);

  v_chken           varchar2(10 char) := hcm_secur.get_v_chken;
  v_zyear           number;
  global_v_codempid varchar2(100 char);
  global_v_coduser  varchar2(100 char);
  global_v_codpswd  varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  global_v_lrunning varchar2(10 char);

  b_index_codcomp   varchar2(4000 char);
  b_index_codempmt  varchar2(4000 char);
  b_index_dtestrt   date;
  b_index_dteend    date;
  b_index_total     varchar2(4000 char);

  b_index_dteeffec  date;
  b_index_codpunsh  varchar2(4000 char);

  procedure initial_value(json_clob in clob);
  function get_index(json_clob in clob) return clob;
  function hresh1x_detail_tab1(json_clob in clob) return clob;
  function hresh1x_detail_tab2(json_clob in clob) return clob;
  function hresh1x_detail_tab3(json_clob in clob) return clob;
  function hresh1x_detail_tab3_table(json_clob in clob) return clob;
  Function Get_Amt_Func(P_Amt In Varchar2) Return Varchar2;
  function get_amt_percentage(p_amtincom in varchar2, p_amtincded in varchar2) return varchar2;

end; -- Package spec

/
