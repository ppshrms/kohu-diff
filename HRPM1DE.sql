--------------------------------------------------------
--  DDL for Package HRPM1DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM1DE" is

  global_v_coduser	varchar2(100 char);
	global_v_lang		varchar2(10 char) := '102';
	param_msg_error		varchar2(4000 char);
	global_v_zminlvl	number;
	global_v_zwrklvl	number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	obj_data		json_object_t;
	obj_row			json_object_t;

	p_flg			varchar2(10 char);
	p_codasset		tasetinf.codasset%type;
	p_dtercass		TASSETS.DTERCASS%TYPE;
	p_dtertass		TASSETS.DTERTASS%TYPE;
	p_remark		TASSETS.REMARK%TYPE;
	p_codcomp		varchar2(100 char);
	p_codempid		varchar2(100 char);
	p_stacaselw		varchar2(1 char);
	p_dtestr		date;
	p_dteend		date;
	v_zupdsal		varchar2(10 char);

	procedure get_index(json_str_input in clob, json_str_output out clob);
	procedure initial_value(json_str in clob);
	procedure check_index;
	procedure gen_data(json_str_output out clob);
	procedure get_index_detail(json_str_input in clob, json_str_output out clob);
	procedure gen_data_detail(json_str_output out clob);
	procedure check_getindex;
	procedure get_assetinf_index(json_str_input in clob, json_str_output out clob);
	procedure get_assetinf_detail(json_str_output out clob);
	procedure get_assets_index(json_str_input in clob, json_str_output out clob);
	procedure get_assets_detail(json_str_output out clob);
	procedure save_data(json_str_input in clob,json_str_output out clob);
	procedure delete_index(json_str_input in clob,json_str_output out clob);
end HRPM1DE;

/
