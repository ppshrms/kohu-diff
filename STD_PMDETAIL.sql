--------------------------------------------------------
--  DDL for Package STD_PMDETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_PMDETAIL" as
  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  v_zupdsal                 varchar2(10 char);
  v_dteeffex                date;
  v_dteyrepay               ttaxcur.dteyrepay%TYPE;
  v_dtemthpay               ttaxcur.dtemthpay%TYPE;
  v_numperiod               ttaxcur.numperiod%TYPE;

  p_codempid                temploy1.codempid%type;
  p_codcomp                 temploy1.codcomp%type;
  p_codapp                  ttemprpt.codapp%type;

  p_intwno                  tresreq.intwno%type;
  p_dtereq                  tresreq.dtereq%type;
  p_numseq                  tresreq.numseq%type;

  v_numseq		            number := 0;
  numYearReport		        number := 0;
  v_item1                   ttemprpt.item1%type;

  procedure initial_value (json_str in clob);
  procedure clear_ttemprpt;
  --head info
  procedure get_emp_info (json_str_input in clob, json_str_output out clob);
  procedure vadidate_variable_get_emp_info(json_str_input in clob);
  procedure gen_emp_info (json_str_output out clob);
  --tab1
  procedure get_approve_remain (json_str_input in clob, json_str_output out clob);
  procedure vadidate_gen_approve_remain(json_str_input in clob);
  procedure gen_approve_remain (json_str_output out clob);
  --tab2
  procedure get_tloaninf_info(json_str_input in clob, json_str_output out clob);
  procedure validate_tloaninf_info(json_str_input in clob);
  procedure gen_tloaninf_info( json_str_output out clob);
  --tab3
  procedure get_trepay_info (json_str_input in clob, json_str_output out clob);
  procedure validate_trepay_info(json_str_input in clob);
  procedure gen_trepay_info (json_str_output out clob);
  --tab4
  procedure get_tfunddet_info (json_str_input in clob, json_str_output out clob);
  procedure validate_tfunddet_info(json_str_input in clob);
  procedure gen_tfunddet_info ( json_str_output out clob);
  --tab5
  procedure get_tassets_info (json_str_input in clob, json_str_output out clob);
  procedure validate_tassets_info(json_str_input in clob);
  procedure gen_tassets_info (json_str_output out clob);
  --tab6
  procedure get_tleavsum_info (json_str_input in clob, json_str_output out clob);
  procedure validate_tleavsum_info(json_str_input in clob);
  procedure gen_tleavsum_info (json_str_output out clob);
  --tab7
  procedure get_tempinc_info (json_str_input in clob, json_str_output out clob);
  procedure validate_tempinc_info(json_str_input in clob);
  procedure gen_tempinc_info (json_str_output out clob);
  --tab8
  procedure get_tothinc_info (json_str_input in clob, json_str_output out clob);
  procedure validate_tothinc_info(json_str_input in clob);
  procedure gen_tothinc_info (json_str_output out clob);
  --tab9
  procedure get_tguarntr_info (json_str_input in clob, json_str_output out clob);
  procedure validate_tguarntr_info(json_str_input in clob);
  procedure gen_tguarntr_info (json_str_output out clob);
  --tab10
  procedure get_tcolltrl_info (json_str_input in clob, json_str_output out clob);
  procedure validate_tcolltrl_info (json_str_input in clob);
  procedure gen_tcolltrl_info (json_str_output out clob);

  procedure get_tresintw_info (json_str_input in clob, json_str_output out clob);
  procedure validate_tresintw_info (json_str_input in clob);
  procedure gen_tresintw_info (json_str_output out clob);


  procedure get_exintw_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_exintw_detail (json_str_output out clob);

  procedure get_texintw (json_str_input in clob, json_str_output out clob);
  procedure gen_texintw (json_str_output out clob);

  function get_formula_name(v_formula in varchar2,v_lang in varchar2) return varchar2;
  function get_resintw(v_numcate texintwd.numcate%type, v_numseq texintwd.numseq%type) return varchar2;
  function get_exintws(v_intwno texintws.intwno%type, v_numcate texintws.numcate%type) return varchar2;

end std_pmdetail;

/
