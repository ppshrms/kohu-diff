--------------------------------------------------------
--  DDL for Package HRAL3CU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL3CU" is

  param_msg_error           varchar2(4000 char);
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  v_chken                   varchar2(10 char);
  v_zupdsal                 varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;

  p_codempid                varchar2(1000 char);
  p_codcomp                 varchar2(1000 char);
  p_dtestr                  date;
  p_dteend                  date;
  p_dtework                 date;

  -- tattence
  p_typwork                 varchar2(1000 char);
  p_codshift	              varchar2(1000 char);
  p_dteendw                 date;
  p_timin                   varchar2(1000 char);
  p_timout                  varchar2(1000 char);
  p_timstrtw                varchar2(1000 char);
  p_timendw                 varchar2(1000 char);
  p_codchng                 varchar2(1000 char);
  p_qtynostam               number;

  -- tlateabs
  p_qtylate                 number;
  p_qtyearly                number;
  p_qtyabsent               number;

  -- tlogtime
  p_tmp_typwork             varchar2(1000 char);
  p_tmp_codshift            varchar2(1000 char);
  p_tmp_timin               varchar2(1000 char);
  p_tmp_timout              varchar2(1000 char);
  p_tmp_codchng             varchar2(1000 char);
  p_tmp_qtynostam           number;

  -- tloglate
  p_tmp_qtylate             number;
  p_tmp_qtyearly            number;
  p_tmp_qtyabsent           number;

  -- check insert
--  v_timstrtw                varchar2(10) ;
--  v_timendw                 varchar2(10) ;
--	v_codempid	 	            varchar2(1000 char);
	v_date 			 	            date;

  --
  p_date                    date;
  p_dtein                   date;
  p_dteout                  date;
  p_timino                  varchar2(10 char);
  p_timouto                 varchar2(10 char);
  p_timinn                  varchar2(10 char);
  p_timoutn                 varchar2(10 char);
  p_codcompy                TCENTER.CODCOMPY%TYPE;
  p_dteinn                  date;

  -- insert new
  v_codempid                varchar2(500 char);
  v_codcomp                 varchar2(500 char);
  v_codshift                varchar2(500 char);
  v_codshift_o              varchar2(500 char);
  v_codchng                 varchar2(500 char);
  v_codchng_o               varchar2(500 char);
  v_dtein                   date;
  v_dtein_o                 date;
  v_timin                   varchar2(500 char);
  v_timin_o                 varchar2(500 char);
  v_dteout                  date;
  v_dteout_o                date;
  v_timout                  varchar2(500 char);
  v_timout_o                varchar2(500 char);
  v_timstrtw                varchar2(500 char);
  v_timendw                 varchar2(500 char);
  v_dtework                 date;
  v_dteendw                 date;
  v_qtynostam               number;
  v_qtynostam_o             number;
  v_qtyhwork                number;
  v_qtyhwork_o              number;
  v_typwork                 varchar2(500 char);
  v_typwork_o               varchar2(500 char);
  -- chk dup --
  v_qtylate                 number;
  v_qtylate_o               number;
  v_qtyearly                number;
  v_qtyearly_o              number;
  v_qtyabsent               number;
  v_qtyabsent_o             number;
  v_qtydaywk_o              number;
  -- log new
  log_codshift              varchar2(500 char);
  log_codshift_o            varchar2(500 char);
  log_codchng               varchar2(500 char);
  log_codchng_o             varchar2(500 char);
  log_dtein                 date;
  log_dtein_o               date;
  log_timin                 varchar2(500 char);
  log_timin_o               varchar2(500 char);
  log_dteout                date;
  log_dteout_o              date;
  log_timout                varchar2(500 char);
  log_timout_o              varchar2(500 char);
  log_typwork               varchar2(500 char);
  log_typwork_o             varchar2(500 char);
  log_qtynostam             number;
  log_qtynostam_o           number;
  --
  log_qtylate               number;
  log_qtylate_o             number;
  log_qtyearly              number;
  log_qtyearly_o            number;
  log_qtyabsent             number;
  log_qtyabsent_o           number;

  --
  v_flgatten                tattence.FLGATTEN%type;
  v_qtydaywk                number := 0;
  v_qtytlate                number := 0;
  v_qtytearly               number := 0;
  v_qtytabs                 number := 0;
  --
  v_daylate                 number := 0;
  v_dayearly                number := 0;
  v_dayabsent               number := 0;
  v_dteupd_log              date;

  procedure check_index;
--  procedure check_save_index;
  procedure initial_value(json_str in clob);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure post_index(json_str_input in clob, json_str_output out clob);
--  procedure save_index(json_str_input in clob);
  procedure save_tattence_tlateabs;

  procedure check_abnormal_time;
  procedure get_abnormal_time(json_str_input in clob, json_str_output out clob);
  procedure gen_abnormal_time(json_str_output out clob);

  procedure get_default_time(json_str_input in clob, json_str_output out clob);
  procedure gen_default_time(json_str_output out clob);

end HRAL3CU;

/
