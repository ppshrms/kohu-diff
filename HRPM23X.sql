--------------------------------------------------------
--  DDL for Package HRPM23X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM23X" AS

  param_msg_error           varchar2(4000 char);
  global_v_lang           varchar2(10 char) := '102';
  p_numoffid              varchar2(50 char);
  global_v_coduser          varchar2(100 char);
  global_v_codempid varchar2(100 char);

  global_v_zminlvl  	    number;
  global_v_zwrklvl  	    number;
  global_v_numlvlsalst 	  number;
  global_v_numlvlsalen 	  number;
  v_zupdsal   		        varchar2(4 char);
  global_v_chken		      varchar2(10 char) := hcm_secur.get_v_chken;
  p_codcomp               temploy1.codcomp%type;
  p_codmov                ttmovemt.codtrn%type;
  p_dtestr                date;
  global_v_zupdsal	      number;
  p_dteend                date;
  p_codmovdetail          varchar2(500 char);
  p_codempid              temploy1.codempid%type;
  p_detail_codempid       ttrehire.codempid%type;
  p_codempmt              varchar2(100 char);
  p_idp                   temploy1.codempid%type;
  p_codcompindex          temploy1.codcomp%type;
  p_dtereemp              ttrehire.dtereemp%type;
  
  --Report
  p_datarows json_object_t;
  p_codapp  ttemprpt.codapp%type;


  procedure initial_value (json_str in clob);
  
  procedure get_index (json_str_input in clob, json_str_output out clob);
  
  procedure gen_index (json_str_output out clob);
  
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  
  procedure gen_detail (json_str_output out clob);
  
  procedure init_report(json_str_input in clob);
  
  procedure get_report(json_str_input in clob, json_str_output out clob);
  
  procedure gen_report ;
  
  function get_tlistval (global_v_lang in varchar2, v_where_value in varchar2, v_codapp in varchar2 ) return varchar2;
  
  function get_dteempmt (global_v_lang in varchar2,v_codempid in varchar2) return varchar2;
  
  function display_year(global_v_lang in varchar2,v_date in date) return varchar2;

END HRPM23X;

/
