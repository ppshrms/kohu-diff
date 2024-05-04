--------------------------------------------------------
--  DDL for Package HRPM4ZR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM4ZR" is

  v_chken                varchar2(10 char);
  global_v_coduser	     varchar2(100 char);
	global_v_lang		       varchar2(10 char) := '102';
	param_msg_error		     varchar2(4000 char);
	global_v_zminlvl	     number;
	global_v_zwrklvl	     number;
	global_v_numlvlsalst	 number;
	global_v_numlvlsalen	 number;
  global_v_zupdsal          number;
	obj_data		           json_object_t;
	obj_main		           json_object_t;
	obj_main1		           json_object_t;
	obj_row			           json_object_t;
	obj_row1		           json_object_t;
	obj_row2		           json_object_t;
	obj_row3		           json_object_t;
	obj_row4		           json_object_t;
  p_list_value           json_object_t;
  obj_list               json_object_t;

	p_codcodec		varchar2(100 char);
	v_codcodec		varchar2(100 char);
	p_codcomp		varchar2(100 char);
	p_staupd		varchar2(10 char);
	p_dtestr		date;
	p_dteend		date;
	v_codincom1		varchar2(100);
	v_codincom2		varchar2(100);
	v_codincom3		varchar2(100);
	v_codincom4		varchar2(100);
	v_codincom5		varchar2(100);
	v_codincom6		varchar2(100);
	v_codincom7		varchar2(100);
	v_codincom8		varchar2(100);
	v_codincom9		varchar2(100);
	v_codincom10		varchar2(100);

	v_codcomp		varchar2(100);
	v_codpos		varchar2(100);
	v_codjob		varchar2(100);
	v_numlvl		varchar2(100);
	v_codempmt		varchar2(100);
	v_typemp		varchar2(100);
	v_typpayroll		varchar2(100);
	v_codbrlc		varchar2(100);
	v_flgatten		varchar2(100);
	v_codcalen		varchar2(100);
	v_codpunsh		varchar2(100);
	v_codexemp		varchar2(100);
	v_jobgrade		varchar2(100);
	v_codgrpgl		varchar2(100);
	v_amtincom1		varchar2(100);
	v_amtincom2		varchar2(100);
	v_amtincom3		varchar2(100);
	v_amtincom4		varchar2(100);
	v_amtincom5		varchar2(100);
	v_amtincom6		varchar2(100);
	v_amtincom7		varchar2(100);
	v_amtincom8		varchar2(100);
	v_amtincom9		varchar2(100);
	v_amtincom10		varchar2(100);
	v_codempid		varchar2(100);
	v_dteeffec		DATE;
    v_numseq            number;--User37 #4951 Final Test Phase 1 V11 15/03/2021
	p_codcomp_check		varchar2(1);
	p_codpos_check		varchar2(1);
	p_codjob_check		varchar2(1);
	p_numlvl_check		varchar2(1);
	p_codempmt_check	varchar2(1);
	p_typemp_check		varchar2(1);
	p_typpayroll_check	varchar2(1);
	p_codbrlc_check		varchar2(1);
	p_flgatten_check	varchar2(1);
	p_codcalen_check	varchar2(1);
	p_codpunsh_check	varchar2(1);
	p_codexemp_check	varchar2(1);
	p_jobgrade_check	varchar2(1);
	p_codgrpgl_check	varchar2(1);
	p_amtincom1_check	varchar2(1);
	p_amtincom2_check	varchar2(1);
	p_amtincom3_check	varchar2(1);
	p_amtincom4_check	varchar2(1);
	p_amtincom5_check	varchar2(1);
	p_amtincom6_check	varchar2(1);
	p_amtincom7_check	varchar2(1);
	p_amtincom8_check	varchar2(1);
	p_amtincom9_check	varchar2(1);
	p_amtincom10_check	varchar2(1);
  p_length            varchar2(100);

  v_param0         varchar2(10);
  v_param1         varchar2(10);
  v_param2         varchar2(10);
  v_param3         varchar2(10);
  v_param4         varchar2(10);
  v_param5         varchar2(10);
  v_param6         varchar2(10);
  v_param7         varchar2(10);
  v_param8         varchar2(10);
  v_param9         varchar2(10);
  v_param10         varchar2(10);
  v_param11         varchar2(10);
  v_param12         varchar2(10);
  v_param13         varchar2(10);
  v_param14         varchar2(10);
  v_param15         varchar2(10);
  v_param16         varchar2(10);
  v_param17         varchar2(10);
  v_param18         varchar2(10);
  v_param19        varchar2(10);
  v_param20         varchar2(10);
  v_param21         varchar2(10);
  v_param22         varchar2(10);
  v_param23         varchar2(10);


	v_zupdsal		varchar2(10 char);

	procedure get_index_field_name(json_str_input in clob, json_str_output out clob);

	procedure initial_value(json_str in clob);

	procedure check_getindex;

	procedure gen_field_name(json_str_output out clob);

	procedure get_codincom;

	procedure get_index(json_str_input in clob, json_str_output out clob);

	procedure initial_value_check(json_str in clob);

	procedure gen_data(json_str_output out clob);

end HRPM4ZR;

/
