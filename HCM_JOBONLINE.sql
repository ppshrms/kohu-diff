--------------------------------------------------------
--  DDL for Package HCM_JOBONLINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_JOBONLINE" is
-- last update: 10/01/2021 11:23

  type arr is table of varchar2(4000 char) index by binary_integer;
--  appl_arr                arr;
  edu_arr                 arr;
  train_arr               arr;
  exp_arr                 arr;
  spouse_arr              arr;
  rel_arr                 arr;
  ref_arr                 arr;
  lng_arr                 arr;
  doc_arr                 arr;
  arr_json_str            arr;

  global_v_zyear          number;
  param_msg_error         varchar2(4000 char);
  global_v_lang           varchar2(10 char) := '102';
  global_chken            varchar2(4 char); 
  global_v_coduser        varchar2(100 char); 
  param_v_inapplinf       number;
  param_v_inbcklst        number;
  param_v_chk             number;
  param_v_numappl         varchar2(100 char);
  param_v_codpos          varchar2(10 char);

  param_flg_error1        varchar2(1 char); -- appl
  param_flg_error2        varchar2(1 char); -- edu
  param_flg_error3        varchar2(1 char); -- exp
  param_flg_error4        varchar2(1 char); -- train
  param_flg_error5        varchar2(1 char); -- spouse
  param_flg_error6        varchar2(1 char); -- rel
  param_flg_error7        varchar2(1 char); -- ref
  param_flg_error8        varchar2(1 char); -- lng
  param_flg_error9        varchar2(1 char); -- doc

  param_flg_tran1         varchar2(1 char);
  param_flg_tran2         varchar2(1 char);
  param_flg_tran3         varchar2(1 char);
  param_flg_tran4         varchar2(1 char);
  param_flg_tran5         varchar2(1 char);
  param_flg_tran6         varchar2(1 char);
  param_flg_tran7         varchar2(1 char);
  param_flg_tran8         varchar2(1 char);
  param_flg_tran9         varchar2(1 char);

  param_detail_error1     varchar2(4000 char);
  param_detail_error2     varchar2(4000 char);
  param_detail_error3     varchar2(4000 char);
  param_detail_error4     varchar2(4000 char);
  param_detail_error5     varchar2(4000 char);
  param_detail_error6     varchar2(4000 char);
  param_detail_error7     varchar2(4000 char);
  param_detail_error8     varchar2(4000 char);
  param_detail_error9     varchar2(4000 char);

  --sub
  param_sub2_json_str     varchar2(4000 char);
  param_sub3_json_str     varchar2(4000 char);
  param_sub4_json_str     varchar2(4000 char);
  param_sub5_json_str     varchar2(4000 char);
  param_sub6_json_str     varchar2(4000 char);
  param_sub7_json_str     varchar2(4000 char);
  param_sub8_json_str     varchar2(4000 char);
  param_sub9_json_str     varchar2(4000 char);

  param_count2            number;
  param_count3            number;
  param_count4            number;
  param_count5            number;
  param_count6            number;
  param_count7            number;
  param_count8            number;
  param_count9            number;
  --
  param_flg_tran          varchar2(1 char);
  param_flg_error         varchar2(1 char);
  param_flg_remark1       varchar2(1 char);
  param_flg_remark2       varchar2(1 char);
  param_flg_remark3       varchar2(1 char);
  param_flg_remark4       varchar2(1 char);

  param_flg_success       varchar2(1 char);

  param_detail_remark1    varchar2(600 char);
  param_detail_remark2    varchar2(600 char);
  param_detail_remark3    varchar2(600 char);
  param_detail_remark4    varchar2(600 char);
  param_detail_remark5    varchar2(600 char);

  procedure initial_value;
  function get_license_jo(json_str_input clob) return clob;
  function get_commoncode(json_str_input clob) return clob;
  function check_blacklist(json_str_input clob) return clob;
  function transfer_applicant(json_str_input clob) return clob;
  procedure save_applicant(json_obj in json_object_t);
  function get_resp_clob return clob;

  procedure check_param_flg_success;
  procedure conv_appl(json_obj in json_object_t);
  procedure conv_edu(json_obj in json_object_t);
  procedure conv_exp(json_obj in json_object_t);
  procedure conv_train(json_obj in json_object_t);
  procedure conv_spouse(json_obj in json_object_t);
  procedure conv_rel(json_obj in json_object_t);
  procedure conv_ref(json_obj in json_object_t);
  procedure conv_lng(json_obj in json_object_t);
  procedure conv_doc(json_obj in json_object_t);

  function escapenewline(v_str in varchar2) return varchar2;
  function change_date(p_date in varchar2) return date;
  function chk_import(p_group varchar2,p_id_type varchar2, p_numoffid varchar2, p_dteapplac date) return varchar2;
  function chk_import_sub(p_id_type varchar2, p_numoffid varchar2, p_dteapplac date) return varchar2;
  function gen_id(p_dteyear in number,p_typgen in varchar2,p_length in number,p_table in varchar2,p_column in varchar2) return varchar2;
  function gen_detail_error(p_value in varchar2,p_table in varchar2,p_column  in varchar2,p_mode in varchar2,p_table_setup in varchar2 default null) return varchar2;
  function check_data_struc(p_value varchar2,p_table in varchar2,p_column in varchar2,p_data_type in varchar2,p_data_length in number) RETURN varchar2;
  function check_number(p_number in varchar2)return boolean;
  function check_date(p_date in varchar2, p_zyear in number) return boolean;
  function check_time(p_time in varchar2)return boolean;
  procedure check_update (p_numofid in varchar2,p_onumappl out varchar2);
  procedure upd_id(p_dteyear in number,p_typgen in varchar2,p_code in varchar2,p_coduser in varchar2); 

  procedure check_appl(appl_arr in arr);
  procedure check_error_tapplinf(appl_arr in arr, o_error out varchar2);

  procedure check_edu(edu_arr in arr);
  procedure check_error_teducatn(edu_arr in arr, o_error out varchar2);

  procedure check_exp(exp_arr in arr);
  procedure check_error_tapplwex(exp_arr in arr, o_error out varchar2);

  procedure check_train(train_arr in arr);
  procedure check_error_ttrainbf(train_arr in arr, o_error out varchar2);

  procedure check_spouse(spouse_arr in arr);
  procedure check_error_tapplfm(spouse_arr in arr, o_error out varchar2);

  procedure check_rel(rel_arr in arr);
  procedure check_error_tapplrel(rel_arr in arr, o_error out varchar2);

  procedure check_ref(ref_arr in arr);
  procedure check_error_tapplref(ref_arr in arr, o_error out varchar2);

  procedure check_lng(lng_arr in arr);
  procedure check_error_tlangabi(lng_arr in arr, o_error out varchar2); 

  procedure check_doc(doc_arr in arr);
  procedure check_error_tappldoc(doc_arr in arr, o_error out varchar2); 

  procedure save_appl(appl_arr in arr, v_numoffid in varchar2, v_dteapplac in date);
  procedure save_edu(edu_arr in arr, v_numoffid in varchar2, v_dteapplac in date);
  procedure save_exp(exp_arr in arr, v_numoffid in varchar2, v_dteapplac in date);
  procedure save_train(train_arr in arr, v_numoffid in varchar2, v_dteapplac in date);
  procedure save_spouse(spouse_arr in arr, v_numoffid in varchar2, v_dteapplac in date);
  procedure save_rel(rel_arr in arr, v_numoffid in varchar2, v_dteapplac in date);
  procedure save_ref(ref_arr in arr, v_numoffid in varchar2, v_dteapplac in date);
  procedure save_lng(lng_arr in arr);
  procedure save_doc(doc_arr in arr);
end;

/
