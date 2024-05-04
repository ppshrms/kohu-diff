--------------------------------------------------------
--  DDL for Package HRPM55R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM55R" AS 
  --07/10/2019
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

	p_codcompy		    ttmovemt.codcomp%type;
	p_codfrm		      varchar2(100 char);
	p_numlettr		    varchar2(1000 char);
	p_dteeffec		    date;
	p_cod_comp		    tcenter.codcomp%type;
	p_cod_empid		    temploy1.codempid%type;
	p_dtestrt		      varchar2(50 char);
	p_dteend		      varchar2(50 char);
	p_date_from		    date;
	p_date_to		      date;
	p_codform		      tfmrefr.codform%type;
  p_typfm           tfmrefr.typfm%type;
  p_namimglet       tfmrefr.namimglet%type;
	p_html_head       clob;
	p_html_body       clob;
	p_html_footer     clob;
	p_data_selected		json_object_t;
	p_dateprint		    varchar2(12 char);
	p_numberdocument  clob;
	p_namesigner		  varchar2(50 char);
	p_fullnamesigner	varchar2(100 char);
	p_companysigner		varchar2(100 char);
	p_url		          varchar2(1000 char);

	p_codempid		    temploy1.codempid%type; 
	p_codcomp		      temploy1.codcomp%type;
	p_dteempmt		    temploy1.dteempmt%type;
  p_codempmt		    temploy1.codempmt%type; 
	p_codpos		      temploy1.codpos%type; 
	p_codjob		      temploy1.codjob%type;
	p_numlvl		      temploy1.numlvl%type;
	p_select_condition_codcomp	boolean;

	p_detail_obj	            json_object_t;
	p_dataSelectedObj	        json_object_t;
	p_resultfparam		        json_object_t;
	p_data_sendmail	          json_object_t;
	p_dateprint_str		        varchar2(10 char);
	p_dateprint_date	        date;
  type arr_1d is table of varchar2(4000 char) index by binary_integer;

  procedure validate_getIndex(json_str_input in clob);
  procedure getIndex (json_str_input in clob,json_str_output out clob);
  procedure genIndex (json_str_output out clob);
  procedure get_data_initial(json_str_input in clob, json_str_output out clob);

  procedure genIndexconditioncodcomp(json_str_output out clob);
  procedure genIndexconditioncodempid(json_str_output out clob);
  procedure gen_html_form(p_codform in varchar2,o_message1 out clob,o_typemsg1 out varchar2,o_message2 out clob,o_typemsg2 out varchar2,o_message3 out clob);
  procedure get_html_message(json_str_input in clob, json_str_output out clob);
  procedure gen_html_message(json_str_input in clob, json_str_output out clob);
  procedure initial_prarameterreport (json_str in clob);
  procedure validate_v_getprarameterreport(json_str_input in clob);
  procedure get_prarameterreport(json_str_input in clob, json_str_output out clob);
  procedure gen_prarameterreport(json_str_output out clob);

  procedure validateprintreport(json_str_input in clob);
  procedure printreport(json_str_input in clob, json_str_output out clob);
  procedure gen_report_data (json_str_output out clob);

  procedure check_numdoc (p_codempid in varchar2, p_codcomp in varchar2);
  function std_replace (p_message in clob,p_codform in varchar2,p_section in number,p_itemson in json_object_t) return clob ;
  function std_get_value_replace (v_in_statmt in	long, p_in_itemson in json_object_t, v_codtable in varchar2) return long ;
  function get_item_property (p_table in varchar2,p_field in varchar2) return varchar2 ;
  function name_in (objItem in json_object_t , bykey varchar2) return varchar2 ; 
  function esc_json(message in clob)return clob;
  function append_clob_json (v_original_json in json_object_t, v_key in varchar2 , v_value in clob  ) return json_object_t;
  function add_value_other(v_in_item_json in json_object_t) return json_object_t ;

  procedure gen_file_send_mail ( json_str_input in clob,json_str_output out clob);
  procedure send_mail ( json_str_input in clob,json_str_output out clob);
END HRPM55R;

/
