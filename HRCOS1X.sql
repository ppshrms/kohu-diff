--------------------------------------------------------
--  DDL for Package HRCOS1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCOS1X" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  json_params       json_object_t;

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);
  global_v_chken            varchar2(100 char);
  v_zupdsal         varchar2(4 char);

  p_codempid        varchar2(4000);
  p_codcompy        varchar2(4000);
  p_codcomp         varchar2(4000);
  p_table_name      varchar2(200);
  p_rep_id          tquery.rep_id%type;
  p_rep_table       tqtable.rep_table%type;

  FUNCTION check_updsal  ( p_codempid in varchar2,p_numlvlst in number ,p_numlvlen in number)  RETURN  NUMBER ;

  procedure search_n_create_tquery (json_str_input in clob, json_str_output out clob) ;
  procedure get_tqtable_index(json_str_input in clob, json_str_output out clob) ;
  procedure gen_tqtable_index (json_str_output out clob);

  procedure get_column_table(json_str_input in clob, json_str_output out clob);
  procedure gen_column_table(json_str_output out clob) ;
  procedure get_tqwhere_index(json_str_input in clob, json_str_output out clob) ;
  procedure gen_tqwhere_index(json_str_output out clob);

  procedure get_tqfield_index(json_str_input in clob, json_str_output out clob);
  procedure gen_tqfield_index(json_str_output out clob);

  procedure get_tqsort_index(json_str_input in clob, json_str_output out clob) ;
  procedure gen_tqsort_index(json_str_output out clob) ;

  procedure get_tqsecur_index(json_str_input in clob, json_str_output out clob) ;
  procedure gen_tqsecur_index(json_str_output out clob) ;

  procedure get_user_indexes_index(json_str_input in clob, json_str_output out clob) ;
  procedure gen_user_indexes_index(json_str_output out clob);
  procedure get_user_tab_columns_index(json_str_input in clob, json_str_output out clob);
  procedure gen_user_tab_columns_index(json_str_output out clob);

  procedure delete_all_detail (json_str_input in clob, json_str_output out clob) ;
  procedure save_all_detail (json_str_input in clob, json_str_output out clob) ;
  procedure save_tquery_detail (json_tquery_obj in json_object_t  , param_msg_error out varchar2);
  procedure save_tqtable_index (json_tqtable_obj in json_object_t , param_msg_error out varchar2) ;
  procedure save_tqwhere_index (json_tqwhere_obj in json_object_t , param_msg_error out varchar2) ;
  procedure save_tqfield_index (json_tqfield_obj in json_object_t , param_msg_error out varchar2) ;
  procedure save_tqsort_index  (json_tqsort_obj in json_object_t , param_msg_error out varchar2) ;
  procedure save_tqsecur_index (json_tqsecur_obj in json_object_t , param_msg_error out varchar2) ;

  procedure save_step_1 (json_str_input in clob, json_str_output out clob) ;
  procedure save_step_2 (json_str_input in clob, json_str_output out clob) ;
  procedure save_step_3 (json_str_input in clob, json_str_output out clob) ;
  procedure save_step_4 (json_str_input in clob, json_str_output out clob) ;

  procedure create_treportq (v_rep_id in varchar2) ;
  procedure create_view (v_rep_id in varchar2) ;
  procedure check_view (v_rep_id in varchar2) ;
  procedure gen_report (json_str_input in clob, json_str_output out clob) ;
  procedure gen_report_rec (json_str_output out clob) ;
  procedure gen_header_report (json_str_input in clob, json_str_output out clob) ;
  procedure header_report (json_str_output out clob) ;
  procedure check_secure (json_str_input in clob, json_str_output out clob);
  procedure gen_check_secure (json_str_output out clob);

end HRCOS1X;

/
