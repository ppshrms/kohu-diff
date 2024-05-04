--------------------------------------------------------
--  DDL for Package HRPY55X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY55X" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          number;
  v_zupdsal                 varchar2(4 char);

  p_codcomp                 varchar2(1000 char);
  p_codempid                varchar2(1000 char);
  p_typpayroll              varchar2(1000 char);
  p_qtyavgwk                number;

  p_dteyrepay               number;
  p_dtemthpay               number;
  p_numperiod               number;
  p_codempst                varchar2(1000 char);
  p_codform                 varchar2(1000 char);
  p_frmtform                varchar2(1000 char) ;
  p_dtepay                  date;
  p_codslip                 varchar2(4 char);
  p_flgslip                 varchar2(4 char);
  p_desslip                 varchar2(150 char);
  p_desslipe                varchar2(150 char);
  p_desslipt                varchar2(150 char);
  p_desslip3                varchar2(150 char);
  p_desslip4                varchar2(150 char);
  p_desslip5                varchar2(150 char);
  p_dtepay_temp             varchar2(150 char);
  p_codempid_temp           varchar2(1000 char);

  p_flgaccinc               varchar2(150 char);
  p_codinc                  json_object_t;
  p_codded                  json_object_t;
  p_tab1                    json_object_t;
  p_tab2                    json_object_t;

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_detail;
--  procedure check_save_detail;
--  procedure check_save_detail_table (p_flg varchar2);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
--
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure get_detail_tab1(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_tab1(json_str_output out clob);
  procedure get_detail_tab2(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_tab2(json_str_output out clob);
--
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  function check_lov_codinc (p_codinc varchar2) return varchar2;
  function check_lov_codded (p_codded varchar2) return varchar2;
  procedure check_lov_codpay (p_codcodec varchar2);

  function save_flg_detail (p_flg varchar2) return varchar2;
  function save_flg_table (p_flg boolean) return varchar2;
  function get_flg (p_flg varchar2) return boolean;
  function cal_dhm_concat (p_qtyday		in  number) RETURN varchar2;

  procedure get_formscan(json_str_input in clob, json_str_output out clob);
  procedure get_dtepay(json_str_input in clob, json_str_output out clob);
  PROCEDURE CAL_HM_CONCAT (p_qtymin	in  number,p_hm out varchar2);
  procedure insert_ttemprpt(v_numseq in number,r_codapp in varchar2, obj_data in json_object_t);
  procedure insert_ttemprpt_items(v_numseq in number,r_codapp in varchar2, v_cod in varchar2, v_des in varchar2, v_unt in varchar2);

  	procedure get_codincome_all(json_str_input in clob, json_str_output out clob);
	procedure gen_codincome_all(json_str_output out clob);

  	procedure get_coddeduct_all(json_str_input in clob, json_str_output out clob);
	procedure gen_coddeduct_all(json_str_output out clob);
end HRPY55X;

/
