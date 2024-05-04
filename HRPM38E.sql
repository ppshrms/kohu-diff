--------------------------------------------------------
--  DDL for Package HRPM38E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM38E" is
	global_v_coduser	    varchar2(100 char);
	global_v_lang		      varchar2(10 char) := '102';
  global_v_codempid     varchar2(100 char);
	param_msg_error		    varchar2(4000 char);
	global_v_zminlvl	    number;
	global_v_zwrklvl	    number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	v_zupdsal		          varchar2(10 char);

--	obj_data		          json;
--	obj_row			          json;
--	p_eval_1		          json;
--	p_eval_2		          json;
--	param_json_row		    json;
--	param_json_row1		    json;
	param_json		        json_object_t;
	param_probation		    json_object_t;
	param_testPosition		json_object_t;

	p_codcomp		          tcenter.codcomp%type;
	p_codpos		          temploy1.codpos%type;
	p_codempid		        temploy1.codempid%type;

	procedure initial_value(json_str in clob);
	procedure initial_save(json_str in clob);
	procedure check_getindex;
  --tab1 detail
	procedure get_index_tproasgh_1(json_str_input in clob, json_str_output out clob);
	procedure get_tproasgh_detail_1(json_str_output out clob);
  --tab1 table
	procedure get_index_tproasgn_1(json_str_input in clob, json_str_output out clob);
	procedure get_tproasgn_detail_1(json_str_output out clob);
  ----tab2 detail
	procedure get_index_tproasgh_2(json_str_input in clob, json_str_output out clob);
	procedure get_tproasgh_detail_2(json_str_output out clob);
  --tab2 table
	procedure get_index_tproasgn_2(json_str_input in clob, json_str_output out clob);
	procedure get_tproasgn_detail_2(json_str_output out clob);

	procedure save_data(json_str_input in clob,json_str_output out clob);
	procedure delete_index(json_str_input in clob,json_str_output out clob);

    procedure get_emp_image(json_str_input in clob, json_str_output out clob);

end HRPM38E;

/
