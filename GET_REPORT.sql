--------------------------------------------------------
--  DDL for Package GET_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "GET_REPORT" as
  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);
  p_std_font                varchar2(100 char) := 'TH SarabunPSK';
  p_std_codapp              trepapp.codapp%type := 'STD';
  p_codapp                  trepapp.codapp%type;
  p_codempid                temploy1.codempid%type;
  p_disp                    varchar2(1 char);
  p_file_ext                varchar2(5 char);
  p_condition_disp          varchar2(20 char);
  p_summary_disp            varchar2(20 char);
  p_no_header               varchar2(1 char);
  p_bottom_line_disp        varchar2(1 char);
  p_page_size               varchar2(100 char);
  p_parameter               json_object_t;
  p_logo_codempid_query     varchar2(100 char);
  p_logo_codcomp_query      varchar2(100 char);

  p_mailto                  varchar2(1000);
  p_mailsubject             varchar2(200);
  p_mailbody                varchar2(2000);
  p_mailattachfile          varchar2(1000);
  type arr_1d is table of varchar2(4000 char) index by binary_integer;


  procedure initial_value (json_str in clob);
  procedure get_main_setup (json_str_input in clob, json_str_output out clob);
  procedure gen_main_setup (json_str_output out clob);
  procedure get_head_foot_setup (json_str_input in clob, json_str_output out clob);
  procedure gen_head_foot_setup (json_str_output out clob);
  procedure get_style1_setup (json_str_input in clob, json_str_output out clob);
  procedure gen_style1_setup (json_str_output out clob);
  procedure get_style2_setup (json_str_input in clob, json_str_output out clob);
  procedure gen_style2_setup (json_str_output out clob);
  procedure get_style3_setup (json_str_input in clob, json_str_output out clob);
  procedure gen_style3_setup (json_str_output out clob);
  procedure get_summary_setup (json_str_input in clob, json_str_output out clob);
  procedure gen_summary_setup (json_str_output out clob);
  function get_exists_setup (v_codapp varchar2, v_table_use number := 0) return varchar2;
  function get_description_label (v_codapp varchar2, v_numseq number, v_lang varchar2) return varchar2;
  function get_report_title (v_codapp varchar2, v_lang varchar2) return varchar2;
  function get_comp_desc (v_codapp varchar2, v_coduser varchar2, v_codcompy varchar2, v_lang varchar2) return varchar2;
  function get_comp_image (v_codapp varchar2, v_coduser varchar2, v_codcompy varchar2, v_lang varchar2) return varchar2;
  function get_page_orientation (v_codapp varchar2) return varchar2;
  function get_user_codcompy (v_codempid varchar2) return varchar2;
  function get_file_extension (v_codapp varchar2) return varchar2;
  function get_page_size (v_codapp varchar2) return varchar2;
  function get_condition_page (v_codapp varchar2) return varchar2;
  function get_show_header (v_codapp varchar2) return varchar2;
  function get_description_footer (v_codapp varchar2, v_numseq number, v_lang varchar2) return varchar2;
  function get_style_footer (v_codapp varchar2, v_numseq number := 0) return varchar2;
  function get_convert_align (v_align varchar2) return varchar2;
  function get_max_width (v_page_size varchar2, v_orienatation varchar2) return number;
  function get_tfolder_image return varchar2;
  function get_bottom_line_disp return varchar2;
  function get_real_codapp (v_codapp varchar2) return varchar2;
  function get_print_date return varchar2;
  function get_print_time return varchar2;
  function get_file_path return varchar2;
  function get_template_path return varchar2;
  procedure get_setup_template (json_str_input in clob, json_str_output out clob);
  procedure gen_setup_template (json_str_output out clob);
  procedure delete_ttemprpt (json_str_input in clob, json_str_output out clob);
  function get_codcompy_logo(v_codempid varchar2, v_codcomp1 varchar2, v_user_codcompy varchar2, v_lang varchar2) return varchar2;
  procedure get_flag_default (json_str_input in clob, json_str_output out clob);
  procedure gen_flag_default (json_str_output out clob);
  procedure sendmail_pdf_report (json_str_input in clob, json_str_output out clob);

end;

/
