--------------------------------------------------------
--  DDL for Package HRPM36X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM36X" is
--3/09/2019
	global_v_coduser	    varchar2(100 char);
	global_v_lang		      varchar2(10 char) := '102';
	param_msg_error		    varchar2(4000 char);
	global_v_zminlvl	    number;
	global_v_zwrklvl	    number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	obj_data		      json_object_t;
	obj_row			      json_object_t;
  p_codemployid     temploy1.codempid%type;
	p_codcomp		      varchar2(100 char);
	p_codempid		    varchar2(100 char);
	p_typproba		    varchar2(100 char);
	p_staupd		      varchar2(100 char);
	p_dteduepr_str	  date;
	p_dteduepr_end	  date;
	v_rcnt			      number;
  v_codeval         varchar2(100 char);
  p_name            varchar2(50 char);

  v_qtymax_g        number;

  v_codcompap       varchar2(1000 char);
  v_codposap        varchar2(1000 char);
  v_codempap        varchar2(1000 char);
  v_desc_codempap   varchar2(1000 char);



	procedure initial_value(json_str in clob);
	procedure get_index_with_empid(json_str_input in clob, json_str_output out clob);
	procedure gen_data_with_empid(json_str_output out clob);
	procedure get_index(json_str_input in clob, json_str_output out clob);
  function chk_probation(p_codempid in varchar2) return number;

  function func_get_next_assessment (p_codcomp IN VARCHAR2 , p_codpos IN VARCHAR2 , p_codempid IN VARCHAR2 , p_typproba IN VARCHAR2) RETURN  date;
	procedure check_getindex;

	procedure gen_data_1(json_str_output out clob);
	procedure gen_data_2(json_str_output out clob);
	procedure gen_data_3(json_str_output out clob);
	procedure gen_data_4(json_str_output out clob);
	procedure gen_data_5(json_str_output out clob);
	procedure gen_data_6(json_str_output out clob);
	procedure gen_data_7(json_str_output out clob);
	procedure gen_data_8(json_str_output out clob);
	procedure gen_data_9(json_str_output out clob);
	procedure gen_data_10(json_str_output out clob);
	procedure gen_data_11(json_str_output out clob);
	procedure gen_data_12(json_str_output out clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);

  function get_qtymax(v_codcomp in varchar2, v_codpos in varchar2, v_codempid in varchar2, p_typproba in varchar2) return number;
  function get_dtedueprn(v_codcomp in varchar2, v_codpos in varchar2,v_codempid in varchar2, v_dteduepr in date, v_numtime in number,v_dteempmt in date) return varchar2;
  function get_numtime(v_codempid in varchar2, v_dteduepr in varchar2, v_numtime in number) return number;
  procedure get_next_appr(v_codcomp in varchar2, v_codpos in varchar2, v_codempid in varchar2, v_dteduepr in date, v_numtime in number);
end HRPM36X;

/
