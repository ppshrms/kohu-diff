--------------------------------------------------------
--  DDL for Package HRPM1EE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM1EE" 
AS
  param_msg_error		VARCHAR2(4000 CHAR);
	-- global var
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl	    number;
	global_v_zwrklvl	    number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	p_source		tasetinf.SRCASSET%TYPE;

	p_typasset		  tasetinf.typasset%TYPE;
	p_flgasset		  tasetinf.flgasset%TYPE;
	p_dateimport		VARCHAR2(50 CHAR);
	p_status		    tasetinf.STAASSET%TYPE;
	p_details		    tasetinf.DESNOTE%TYPE;
	str_pk			    tasetinf.codasset%TYPE;
	p_codasset		  tasetinf.codasset%TYPE;
	p_filename		  tasetinf.NAMIMAGE%TYPE;
	p_idp			      tasetinf.CODASSET%TYPE;
	p_pk			      tasetinf.CODASSET%TYPE;
	p_flag          VARCHAR(10 CHAR);

  TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  p_text                    data_error;
  p_error_code              data_error;
  p_numseq                  data_error;

	PROCEDURE initial_value (
		json_str IN CLOB);

	PROCEDURE get_index (json_str_input IN CLOB,json_str_output OUT CLOB);
	PROCEDURE get_detail (json_str_input IN CLOB,json_str_output OUT CLOB);
	PROCEDURE save_index (json_str_input IN CLOB,json_str_output OUT CLOB);
	PROCEDURE save_detail (json_str_input IN CLOB,json_str_output OUT CLOB);
  procedure get_import_process(json_str_input in clob, json_str_output out clob);
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);
END hrpm1ee;

/
