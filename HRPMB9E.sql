--------------------------------------------------------
--  DDL for Package HRPMB9E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMB9E" is
--15/08/2019
	global_v_coduser	        varchar2(100 char);
	global_v_lang		          varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
	param_msg_error		        varchar2(4000 char);
	global_v_zminlvl	        number;
	global_v_zwrklvl	        number;
	global_v_numlvlsalst	    number;
	global_v_numlvlsalen	    number;
	obj_data		              json_object_t;
	obj_row			              json_object_t;
	obj_row_header		        json_object_t;
	obj_row_body		          json_object_t;
	obj_row_footer		        json_object_t;
	obj_child_row		          json_object_t;
	p_formheader		          json_object_t;
	p_formheader1		          json_object_t;
	p_formbody		            json_object_t;
	p_formbody1		            json_object_t;
	p_formfooter		          json_object_t;
	p_formfooter1		          json_object_t;
	param_json_row		        json_object_t;

  p_codapp                  varchar2(20 char);
	p_codtable		            TCOLDESC.CODTABLE%TYPE;
	p_typfm			              TLISTVAL.LIST_VALUE%TYPE;
	p_isCopy			            varchar2(2 char);
	p_codform		              TFMPARAM.CODFORM%TYPE;
	p_codform_to		          TFMPARAM.CODFORM%TYPE;
	p_codlang		              TFMREFR.CODLANG%TYPE;
	p_namfm			              TFMREFR.NAMFME%TYPE;
  p_namfme	                tfmrefr.namfme%type;
  p_namfmt	                tfmrefr.namfmt%type;
  p_namfm3	                tfmrefr.namfm3%type;
  p_namfm4	                tfmrefr.namfm4%type;
  p_namfm5	                tfmrefr.namfm5%type;
	p_flgstd		              TFMREFR.FLGSTD%TYPE;
	p_message		              TFMREFR.MESSAGE%TYPE;
	p_namfile		              TFMREFR.NAMFILE%TYPE;
	p_namimglet		            varchar2(4000 char);
	p_typemsg		              TFMREFR2.TYPEMSG%TYPE;
	p_message2		            TFMREFR2.MESSAGE%TYPE;
	p_message3		            TFMREFR3.MESSAGE%TYPE;
	p_message_display	        TFMREFR.MESSAGEDSP%TYPE;
	p_message_display2	      TFMREFR2.MESSAGEDSP%TYPE;
	p_message_display3	      TFMREFR3.MESSAGEDSP%TYPE;

	procedure initial_value(json_str in clob);
	procedure get_index(json_str_input in clob, json_str_output out clob);
	procedure delete_index(json_str_input in clob,json_str_output out clob);

	procedure get_index_form(json_str_input in clob, json_str_output out clob);
	procedure get_detail(json_str_output out clob);

	procedure get_index_header_form(json_str_input in clob, json_str_output out clob);
	procedure get_header_detail(json_str_output out clob);

	procedure get_index_body_form(json_str_input in clob, json_str_output out clob);
	procedure get_body_detail(json_str_output out clob);

	procedure get_index_footer_form(json_str_input in clob, json_str_output out clob);
	procedure get_footer_detail(json_str_output out clob);

	procedure get_index_message(json_str_input in clob, json_str_output out clob);
	procedure get_message_detail(json_str_output out clob);

    procedure check_save;
    procedure save_data(json_str_input in clob,json_str_output out clob);

	procedure copy_codform(json_str_input in clob,json_str_output out clob);
	procedure list_codform(json_str_input in clob,json_str_output out clob);
	procedure list_codtable_typfm(json_str_input in clob,json_str_output out clob);
	procedure get_tcoldesc(json_str_input in clob,json_str_output out clob);
	procedure get_json_obj(json_str_input in clob);

	function get_tfmrefr_name (p_codform IN TFMREFR.CODFORM%TYPE ,p_codlang IN TFMREFR.CODLANG%TYPE )return	varchar2;
    function get_clob(str_json in clob, key_json in varchar2) RETURN CLOB ;
    function esc_json(message in clob)return clob;
    procedure get_error_labels(json_str_input in clob,json_str_output out clob);

    procedure get_popup_detail(json_str_input in clob,json_str_output out clob);
    procedure get_list_typfm(json_str_input in clob, json_str_output out clob);
end HRPMB9E;

/
