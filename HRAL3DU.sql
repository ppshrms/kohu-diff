--------------------------------------------------------
--  DDL for Package HRAL3DU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL3DU" is

  param_msg_error       varchar2(4000 char);
  global_v_coduser      temploy1.coduser%type;
  global_v_codempid     temploy1.codempid%type;
  global_v_lang         varchar2(10 char) := '102';

  p_codcomp             tcenter.codcomp%type;
  p_codcalen            varchar2(4000 char);
  p_dtework             date;
  p_codchng             tattence.codchng%type;
  p_timinst             varchar2(8 char);
  p_timinen             varchar2(8 char);
  p_timoutst            varchar2(8 char);
  p_timouten            varchar2(8 char);
  p_timinnew            varchar2(8 char);
  p_timoutnew           varchar2(8 char);

  v_codempid            temploy1.codempid%type;
  v_codcomp             tcenter.codcomp%type;
  v_codshift            tshiftcd.codshift%type;
  v_codshift_o          tshiftcd.codshift%type;
  v_codchng             tattence.codchng%type;
  v_codchng_o           tattence.codchng%type;
  v_dtein               date;
  v_dtein_o             date;
  v_timin               varchar2(8 char);
  v_timin_o             varchar2(8 char);
  v_dteout              date;
  v_dteout_o            date;
  v_timout              varchar2(8 char);
  v_timout_o            varchar2(8 char);
  v_timstrtw            varchar2(8 char);
  v_timendw             varchar2(8 char);
  v_dtework             date;
  v_dteendw             date;
  v_dteupd_log          date;
  v_qtylate             number;
  v_qtylate_o           number;
  v_qtyearly            number;
  v_qtyearly_o          number;
  v_qtyabsent           number;
  v_qtyabsent_o         number;

  log_codshift            tshiftcd.codshift%type;
  log_codshift_o          tshiftcd.codshift%type;
  log_codchng             tattence.codchng%type;
  log_codchng_o           tattence.codchng%type;
  log_dtein               date;
  log_dtein_o             date;
  log_timin               varchar2(8 char);
  log_timin_o             varchar2(8 char);
  log_dteout              date;
  log_dteout_o            date;
  log_timout              varchar2(8 char);
  log_timout_o            varchar2(8 char);


  type aarray             is table of varchar2(1 char) index by TEMPLOY1.CODEMPID%TYPE;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_index_update(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);

end HRAL3DU;

/
