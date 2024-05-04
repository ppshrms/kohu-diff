--------------------------------------------------------
--  DDL for Package HRTR63E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR63E" is

  param_msg_error                 varchar2(4000 char);

  param_msg_error_2               varchar2(4000 char);
  global_v_coduser                varchar2(100 char);
  global_v_codempid               varchar2(100 char);
  global_v_lang                   varchar2(10 char) := '102';
  json_params                     json;

  global_v_zminlvl  	            number;
  global_v_zwrklvl  	            number;
  global_v_numlvlsalst 	          number;
  global_v_numlvlsalen 	          number;

  p_codapp                        tappprof.codapp%type;
  p_codproc                       tappprof.codproc%type;
  p_dteyear                       thisclss.dteyear%type;
  p_codcompy                      thisclss.codcompy%type;
  p_codcours                      thisclss.codcours%type;
  p_numclseq                      number;
  p_codform                       thisclss.codform%type;
  p_codempid                      thistrnn.codempid%type;

  p_codinst                       tinstapg.codinst%type;
  p_codsubj                       tinstapg.codsubj%type;

  TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  p_text                          data_error;
  p_error_code                    data_error;
  p_numseq                        data_error;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_thisclss_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_thisclss_detail(json_str_output out clob);
  procedure gen_tyrtrsch(json_str_output out clob);
  procedure get_tcosttr_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tcosttr_detail(json_str_output out clob);
  procedure get_thistrnn_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_thistrnn_detail(json_str_output out clob);
  procedure gen_tpotentp(json_str_output out clob);
  procedure get_tcoursapg_index(json_str_input in clob, json_str_output out clob);
  procedure gen_tcoursapg_index(json_str_output out clob);
  procedure get_tyrtrsubj_index(json_str_input in clob, json_str_output out clob);
  procedure gen_tyrtrsubj_index(json_str_output out clob);
  procedure get_tknowleg_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tknowleg_detail(json_str_output out clob);
  procedure get_thisclsss_index(json_str_input in clob, json_str_output out clob);
  procedure gen_thisclsss_index(json_str_output out clob);
  procedure get_tcoursugg_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_tcoursugg_detail(json_str_output out clob);
  function check_count_thisclss(p_dteyear in varchar2, p_codcompy in varchar2, p_codcours in varchar2, p_numclseq in varchar2) return number;
  procedure save_all(json_str_input in clob,json_str_output out clob);
  procedure check_validate_save_tab1 (json_thisclss_obj in json);
  procedure save_thisclss(json_thisclss_obj in json);
  procedure save_tcosttr(json_tcosttr_obj in json);
  procedure save_thisclsss(json_thisclsss_obj in json);
  procedure save_tknowleg(json_tknowleg_obj in json);
  procedure delete_index (json_str_input in clob, json_str_output out clob);
  function get_definite_name(p_codform in varchar2, p_numgrup in varchar2, p_numitem in varchar2) return varchar2;
  procedure save_tcoursugg(json_tcoursugg_obj in json);
  procedure get_eval_course(json_str_input in clob, json_str_output out clob);
  procedure gen_eval_course(json_str_output out clob);
  procedure check_codform;
  procedure check_index;
  procedure get_import_process(json_str_input in clob, json_str_output out clob);
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);
  function check_is_number(p_string IN VARCHAR2) return integer;
  procedure check_thisclass_import(json_str_input in clob);
  procedure get_qtytrabs (json_str_input in clob, json_str_output out clob);
  procedure gen_qtytrabs(json_str_output out clob);
  procedure get_des_codcomp(json_str_input in clob, json_str_output out clob);
  procedure gen_des_codcomp(json_str_output out clob);
  procedure save_thistrnn (json_thistrnn_obj in json);
  procedure check_validate_save_tab3 (json_row in json);
  procedure check_validate_score_save_tab3 (v_input_qtyprescr in number, v_input_qtyposscr in number);
  procedure save_tcoursaph(json_tcoursaph_obj in json);
  procedure save_tcoursapg (json_tcoursapg_obj in json);
  procedure save_tcoursapi (json_tcoursapi_obj in json);
  procedure gen_eval_instructor(json_str_output out clob);
  procedure get_eval_instructor(json_str_input in clob, json_str_output out clob);
  procedure gen_tinstapg(json_str_output out clob);
  procedure get_tinstapg(json_str_input in clob, json_str_output out clob);
  procedure save_tinstaph (json_tab5_all_obj in json);
  procedure save_thisinst (json_tab5_all_obj in json);
  procedure save_tinstapg (json_tab5_all_obj in json);
  procedure save_tinstapi (json_tinstapi_obj in json, c_codinst in varchar2, c_codsubj in varchar2);
  procedure save_tinscour;
  procedure save_tcrsinst;
  procedure get_tcontrpy (json_str_input in clob, json_str_output out clob);
  procedure gen_tcontrpy(json_str_output out clob);
  procedure get_tcourse_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_tcourse_detail(json_str_output out clob);

end HRTR63E;


/
