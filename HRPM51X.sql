--------------------------------------------------------
--  DDL for Package HRPM51X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM51X" is
-- 07/10/2019
  param_msg_error          varchar2(4000 char);
  v_chken                  varchar2(10 char);
  global_v_coduser         varchar2(100 char);
  global_v_codpswd         varchar2(100 char);
  global_v_codempid        varchar2(100 char);
  global_v_lang            varchar2(10 char) := '102';
  p_maillang                varchar2(10 char) := '102';
  global_v_zyear           number := 0;
  global_v_lrunning        varchar2(10 char);
  global_v_zminlvl         number;
  global_v_zwrklvl         number;
  global_v_numlvlsalst     number;
  global_v_numlvlsalen     number;
  global_v_zupdsal         varchar2(4 char);

  p_codempid              temploy1.codempid%type;
  p_codcomp               temploy1.codcomp%type;
  p_codpos                temploy1.codpos%type;
  p_codmove               varchar2(4 char);
  p_dteffecst             date;
  p_dteffecen             date;
  numYearReport           number;
  type arr_1d is table of varchar2(4000 char) index by binary_integer;

  p_dtestr                date;
  p_dteend                date;
  p_type_data             varchar2(1 char);
  p_type_move             tcodmove.typmove%type;
  p_codcodec              tcodmove.codcodec%type;
  p_dtestr_str            varchar2(12 char);
  p_dteend_str            varchar2(12 char);
  p_flagnotic             tdocinf.flgnotic%type;
	p_url		                varchar2(1000 char);
	p_namimglet		          varchar2(1000 char);
  chknum                  number;
  v_chk                   number;

  p_dteprint              date;
  p_flgpost               varchar2(1 char);

  p_html_head             clob;
  p_html_body             clob;
  p_html_footer           clob;
  p_typemsg1              varchar2(100 char);
  p_typemsg2              varchar2(100 char);
  p_data_selected		      json_object_t;
  p_data_parameter	      json_object_t;
  p_tfmrefr_typfm         tfmrefr.typfm%type;
  p_dtprint               varchar2(12 char);
  p_stacaselw             varchar2(5 char);
  p_codform               varchar2(10 char);
  p_numhmref              tdocinf.numhmref%type;
  p_typdoc                tdocinf.typdoc%type;
  p_dateprint		          date;
  p_numberdocument        clob;
  p_sendemail		          varchar2(1 char);
  p_send_mail_by_emp      boolean;
  p_send_mail_by_specify  boolean;
  p_mail_specify1         temploy1.email%type;
  p_mail_specify2         temploy1.email%type;
  p_mail_specify3         temploy1.email%type;
  p_mail_from_email       temploy1.email%type;
  p_mail_from_date        date;
  p_day_display_dateprint   number;
  p_month_display_dateprint varchar2(50 char);
  p_year_disaplay_dateprint number;
  p_display_dateprint       varchar2(100 char);
  p_objdata_genword         json_object_t;
  --
  p_detail_obj	            json_object_t;
	p_dataSelectedObj	        json_object_t;
	p_resultfparam		        json_object_t;
	p_data_sendmail	          json_object_t;
	p_sendMailInfo	          json_object_t;
  --
  procedure initial_value (json_str in clob);
  procedure validate_getindex (json_str_input in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_data_initial(json_str_input in clob, json_str_output out clob);

  procedure initial_prarameterreport  (json_str in clob);
  procedure validate_v_getprarameterreport(json_str_input in clob);
  procedure get_prarameterreport(json_str_input in clob, json_str_output out clob);
  procedure gen_prarameterreport(json_str_output out clob);

  procedure get_html_message(json_str_input in clob, json_str_output out clob);
  procedure gen_html_form(p_codform in varchar2,o_message1 out clob,o_typemsg1 out varchar2,o_message2 out clob,o_typemsg2 out varchar2,o_message3 out clob);
  procedure gen_html_message(json_str_input in clob, json_str_output out clob);
  procedure print_report(json_str_input in clob, json_str_output out clob);
  procedure initial_word(json_str_input in clob);
  procedure gen_report_data( json_str_output out clob);
  procedure gen_numannou (v_codcodec in varchar2,
                          v_typemove in varchar2,
                          v_codempid in varchar2, 
                          v_codcomp in varchar2, 
                          v_dteeffec in varchar2, 
                          v_numseq in varchar2, 
                          v_numlett out varchar2);
  function get_typemsg_by_codform(p_codform in varchar2)return varchar2;
  function get_tfmtrfr_typfm (v_codform  in varchar2) return varchar2;
  function std_replace (p_message in clob,p_codform in varchar2,p_section in number,p_itemson in json_object_t) return clob ;
  function std_get_value_replace (v_in_statmt in	long, p_in_itemson in json_object_t, v_codtable in varchar2) return long ;
  function get_item_property (p_table in varchar2,p_field  in varchar2) return varchar2 ;
  function name_in (objItem in json_object_t , bykey varchar2) return varchar2 ;
  function esc_json(message in clob)return clob;
  function append_clob_json (v_original_json in json_object_t, v_key in varchar2 , v_value in clob  ) return json_object_t;

  procedure gen_file_send_mail ( json_str_input in clob,json_str_output out clob);
  procedure send_mail ( json_str_input in clob,json_str_output out clob);
  procedure send_mail2 ( json_str_input in clob,json_str_output out clob);
  function get_codpos_by_codempid (codempid in VARCHAR2) return VARCHAR2 ;
	function get_email_by_codempid (codempid in VARCHAR2) return VARCHAR2 ;
--  procedure check_numdoc (p_codempid in varchar2, p_codcomp in varchar2);
--  procedure never_print( json_str_output out clob);
--  procedure never_print_single_form( json_str_output out clob);
--  procedure never_print_group_form( json_str_output out clob);

--  procedure insert_info_and_detail_numdoc  (
--                                            v_numseq_running number,
--                                            v_codcodec in varchar2,
--                                            v_typemove in varchar2,
--                                            v_objdata_itemselected in json_object_t,
--                                            v_objdata_itemparameterkeyin in json_object_t,
--                                            v_out_objdetail_gen_numannou in json_object_t,
--                                            v_objrow_infodetailnumdoc out json_object_t);


--  procedure initial_genword(json_str_input in clob);
--  procedure post_genword(json_str_input in clob, json_str_output out clob);
--  procedure insert_parameter_keyin (v_numannou in varchar2);


--  procedure insert_tdocinf_key (
--    numseq in number ,
--    v_out_objdetail_gen_numannou in json_object_t,
--    v_codempid_ in varchar2,
--    v_codcodec in varchar2,
--    v_codcomp_ in varchar2);

--   procedure insert_parameter_fix (v_numhmref in varchar2,
--                                                  v_typdoc in varchar2,
--                                                  v_codempid  in varchar2,
--                                                  v_fparam  in varchar2,
--                                                  v_fvalue  in varchar2 );

--  procedure replaceword (
--  v_html_head_original     in  clob,
--  v_html_body_original     in  clob,
--  v_html_footer_original    in   clob,
--  v_codform         in varchar2,
--  v_objdata_item_selected  in   json_object_t,
--  v_objrow_infodetailnumdoc  in   json_object_t,
--  v_objrow_parameter_keyin in json_object_t,
--  v_out_html_head out  clob,
--  v_out_html_body out  clob,
--  v_out_html_footer out  clob
--  );

--  procedure insert_template_table (
--   v_codform in varchar2,
--   v_numseq in number,
--   v_html_head in  clob,
--   v_html_body in  clob,
--   v_html_footer in  clob
--  );

--  procedure get_param_signpic( v_objrow_parameter_keyin in json_object_t , v_out_img out varchar2);

--  procedure getnamereport  ( json_str_input in clob,json_str_output out clob);

--  procedure get_where_typfm (json_str_input in clob,json_str_output out clob);

--  function add_value_other(v_in_item_json in json_object_t) return json_object_t ;
--  function parametrfix_to_json (v_keyparameterfix in varchar2, v_valueparameterfix in varchar2) return json_object_t;
--  function get_label_tcodmist (v_codcodec  in varchar2, v_lang in varchar2) return varchar2;

--  function get_clob(str_json in clob, key_json in varchar2) RETURN CLOB ;
end HRPM51X;

/
