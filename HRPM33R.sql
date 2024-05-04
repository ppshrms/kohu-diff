--------------------------------------------------------
--  DDL for Package HRPM33R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM33R" is

	param_msg_error		    varchar2(4000 char); 
	v_chken			          varchar2(10 char);
	global_v_coduser	    varchar2(100 char);
	global_v_codpswd	    varchar2(100 char);
	global_v_lang		      varchar2(10 char) := '102';
	global_v_zyear		    number := 0;
	global_v_lrunning	    varchar2(10 char);
	global_v_zminlvl	    number;
	global_v_zwrklvl	    number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	global_v_zupdsal		  varchar2(4 char);
  numYearReport             number;
  
	obj_data		          json_object_t;
	obj_row			          json_object_t;
	p_codempid_list		    json_object_t;
	param_json_row		    json_object_t;
  p_resultfparam        json_object_t;
  p_details             json_object_t;
  p_data_sendmail       json_object_t;

	p_codcomp		      temploy1.codcomp%type;
	p_codempid		    temploy1.codempid%type;
	p_month			      varchar2(10 char);
	p_year			      varchar2(10 char);
	p_namtpro		      varchar2(10 char);
	p_nameval		      varchar2(10 char);
	p_url		          varchar2(1000 char);
  
	p_dteduepr_str		date;
	p_dteduepr_end		date;
  
	p_codform		      tfmrefr.codform%type;
  p_dteprint		    varchar2(100 char);
  
	p_numlettr		    varchar2(100 char);
	p_codpos		      varchar2(100 char);
	p_fileseq		      varchar2(100 char);
	p_dteempmt		    date;
	p_dteduepr		    date;
	p_dteoccup		    date;
	p_qtyexpand		    number;
	v_zupdsal		      varchar2(10 char);


  p_detail_obj	            json_object_t;
	p_dataSelectedObj	        json_object_t;
--	p_resultfparam		        json_object_t;
	p_dateprint_str		        varchar2(10 char);
	p_dateprint_date	        date;
  type arr_1d is table of varchar2(4000 char) index by binary_integer;
  
	procedure initial_value(json_str in clob);
	procedure check_get_index;
	procedure get_index(json_str_input in clob, json_str_output out clob);
	procedure get_probation_form(json_str_input in clob, json_str_output out clob);
  procedure get_html_message(json_str_input in clob, json_str_output out clob);
  procedure get_data_initial(json_str_input in clob, json_str_output out clob);
  
--	procedure send_mail(p_numlettr out varchar2);
--	procedure print_document;
--	procedure gen_word(p_codapp in varchar2,p_coduser in varchar2,p_message in long);
  procedure gen_message (p_codform in varchar2,o_message1 out clob,o_namimglet out varchar2,
                         o_message2 out clob,o_typemsg2 out long,o_message3 out clob);
  procedure get_json_obj(json_str_input in clob);
--  procedure get_document(json_str_input in clob, json_str_output out clob);
--  procedure get_send_mail(json_str_input in clob, json_str_output out clob);

  procedure printreport(json_str_input in clob, json_str_output out clob);
  procedure gen_report_data (json_str_output out clob);
  function append_clob_json (v_original_json in json_object_t, v_key in varchar2 , v_value in clob  ) return json_object_t;
  function esc_json(message in clob)return clob;
  function std_replace (p_message in clob,p_codform in varchar2,p_section in number,p_itemson in json_object_t) return clob ;
  function std_get_value_replace (v_in_statmt in	long, p_in_itemson in json_object_t, v_codtable in varchar2) return long ;
  function name_in (objItem in json_object_t , bykey varchar2) return varchar2 ; 
  function get_item_property (p_table in varchar2,p_field in varchar2) return varchar2 ;
  
  procedure gen_file_send_mail ( json_str_input in clob,json_str_output out clob);
  procedure send_mail ( json_str_input in clob,json_str_output out clob);
end HRPM33R;

/
