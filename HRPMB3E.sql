--------------------------------------------------------
--  DDL for Package HRPMB3E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMB3E" is
  param_msg_error		varchar2(4000 char);
	global_v_lang		varchar2(10 char) := '102';
	global_v_coduser	varchar2(100 char);
	obj_detail		json_object_t;
	p_detail clob;

	p_numoffid		  temploy2.NUMOFFID%type;
	p_cardid		    varchar2(13 char);
	p_title			    tbcklst.codtitle%type;
	p_firstname		  varchar2(30 char);
	p_firstnamee		tbcklst.namfirste%type;
	p_firstnamet		tbcklst.namfirstt%type;
	p_firstname3		tbcklst.namfirst3%type;
	p_firstname4		tbcklst.namfirst4%type;
	p_firstname5		tbcklst.namfirst5%type;
	p_lastname		  varchar2(30 char);
	p_lastnamet		  tbcklst.namlastt%type;
	p_lastnamee		  tbcklst.namlaste%type;
	p_lastname3		  tbcklst.namlast3%type;
	p_lastname4		  tbcklst.namlast4%type;
	p_lastname5		  tbcklst.namlast5%type;
	p_applyno		    tbcklst.numappl%type;
	p_birthday		  date;
	p_passportno		tbcklst.numpasid%type;
	p_company		    tbcklst.namlcompy%type;
	p_depart		    tbcklst.namlcomp%type;
	p_position		  tbcklst.namlpos%type;
	p_attendance		date;
	p_resignation		date;
	p_causeofdischarge	tbcklst.desexemp%type;
	p_sex			      tbcklst.codsex%type;
	p_mode			    varchar2(5 char);
	p_empid			    tbcklst.codempid%type;
	p_filename		  tbcklst.NAMIMAGE%type;
	p_codempid		  tbcklst.codempid%type;
	p_desinfo		    tbcklst.desinfo%type;
	p_desnote		    tbcklst.desnote%type;

	procedure initial_value (json_str in clob);
	procedure get_index (json_str_input in clob, json_str_output out clob);
	procedure gen_index (json_str_output out clob);
	procedure get_detail (json_str_input in clob, json_str_output out clob);
	procedure gen_detail (json_str_output out clob);
	procedure get_list_title(json_str_input in clob, json_str_output out clob);
	procedure post_save (json_str_input in clob, json_str_output out clob);
	procedure save_data_main;
	procedure post_delete (json_str_input in clob, json_str_output out clob);
	procedure delete_data (json_str_input in clob, json_str_output out clob) ;
	procedure get_subdetail (json_str_input in clob, json_str_output out clob);
	procedure gen_subdetail (json_str_output out clob);
    
END HRPMB3E;

/
