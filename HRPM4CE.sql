--------------------------------------------------------
--  DDL for Package HRPM4CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM4CE" is
	-- last update: 1/10/2019
	param_msg_error		        varchar2(4000 char);

	v_chken			            varchar2(10 char);
	global_v_coduser	        varchar2(100 char);
	global_v_codpswd	        varchar2(100 char);
	global_v_lang		        varchar2(10 char) := '102';
	global_v_zyear		        number := 0;
	global_v_lrunning	        varchar2(10 char);
	global_v_zminlvl	        number;
	global_v_zwrklvl	        number;
	global_v_numlvlsalst	    number;
	global_v_numlvlsalen	    number;
	global_v_codempid	        varchar2(100 char);
	v_zupdsal		            varchar2(10 char);
	global_v_chken		        varchar2(10 char) := hcm_secur.get_v_chken;
	p_codcompy		            ttmovemt.codcomp%type;
	v_codempid		            ttmovemt.codempid%type;
	p_codcomp		            ttmovemt.codcomp%type;
	p_codpos		            ttmovemt.codpos%type;
	p_coduser		            ttmovemt.codempid%type;
	p_dtecancel		            date;
	p_dteeffec		            date;
	p_dteend		            date;
	p_seqcancel		            ttmovemt.numseq%type;
	datenow			            date;
	p_codcurr		            ttmovemt.codcurr%type;
	p_viewsalary		        varchar2(1 char);
	v_codusershow		        ttmovemt.codreq%type;
	-- save
	p_mode			            varchar2(100 char);
	p_codtrn		            TTMOVEMT.CODTRN%type;
	p_desnote		            TTMOVEMT.DESNOTE%type;
	p_numseq		            TTMOVEMT.NUMSEQ%type;
	p_codjob		            TTMOVEMT.CODJOBT%type;
	p_codbrlc		            TTMOVEMT.CODBRLCT%type;
	p_numlvl		            TTMOVEMT.NUMLVLT%type;
	p_indexSelectedDtecancel	date;
	p_indexselectenumseq	    TSECPOS.NUMSEQ%type;
	v_rowid                     rowId;
    flgsecur                    boolean;

	procedure getIndex (json_str_input in clob, json_str_output out clob);

	procedure vadidate_variable_getindex(json_str_input in clob);

	procedure genIndex (json_str_output out clob);

	procedure init_Detail (json_str_input in clob);

	procedure getDetail (json_str_input in clob, json_str_output out clob);

	procedure genDetail (json_str_output out clob);

	procedure init_DetailTable (json_str_input in clob);

	procedure getDetailTable (json_str_input in clob, json_str_output out clob);

	procedure genDetailTable (json_str_output out clob);

	procedure getDetailWageIncome(json_str_input in clob, json_str_output out clob);

	procedure genDetailWageIncome(v_in_detailtable in clob,json_str_output out clob);

	procedure getRefreshDetailWageIncome(json_str_input in clob, json_str_output out clob);

	procedure genRefreshDetailWageIncome(v_in_detailtable in json_object_t, json_str_output out clob);

	procedure init_save (json_str_input in clob);

	procedure post_save (json_str_input in clob, json_str_output out clob);

	procedure init_delete(json_str_input in clob);

	procedure post_delete (json_str_input in clob, json_str_output out clob);

	procedure init_send_mail (json_str_input in clob);

	procedure validate_send_mail(json_str_input in clob);

	procedure send_mail(json_str_input in clob,json_str_output out clob);

	procedure post_sendmail(json_str_input in clob, json_str_output out clob);

	procedure init_amtincom (
		v_listof_getincome	in json_object_t,
		v_codempid		in varchar2,
		v_ttmovemt_amtincom1	out ttmovemt.amtincom1%type,
		v_ttmovemt_amtincom2	out ttmovemt.amtincom2%type,
		v_ttmovemt_amtincom3	out ttmovemt.amtincom3%type,
		v_ttmovemt_amtincom4	out ttmovemt.amtincom4%type,
		v_ttmovemt_amtincom5	out ttmovemt.amtincom5%type,
		v_ttmovemt_amtincom6	out ttmovemt.amtincom6%type,
		v_ttmovemt_amtincom7	out ttmovemt.amtincom7%type,
		v_ttmovemt_amtincom8	out ttmovemt.amtincom8%type,
		v_ttmovemt_amtincom9	out ttmovemt.amtincom9%type,
		v_ttmovemt_amtincom10	out ttmovemt.amtincom10%type);

	procedure init_amtincadj (
		v_listof_getincome	in json_object_t,
		v_codempid		in varchar2,
		v_ttmovemt_amtincadj1	out ttmovemt.amtincadj1%type,
		v_ttmovemt_amtincadj2	out ttmovemt.amtincadj2%type,
		v_ttmovemt_amtincadj3	out ttmovemt.amtincadj3%type,
		v_ttmovemt_amtincadj4	out ttmovemt.amtincadj4%type,
		v_ttmovemt_amtincadj5	out ttmovemt.amtincadj5%type,
		v_ttmovemt_amtincadj6	out ttmovemt.amtincadj6%type,
		v_ttmovemt_amtincadj7	out ttmovemt.amtincadj7%type,
		v_ttmovemt_amtincadj8	out ttmovemt.amtincadj7%type,
		v_ttmovemt_amtincadj9	out ttmovemt.amtincadj9%type,
		v_ttmovemt_amtincadj10	out ttmovemt.amtincadj10%type);
	function get_max_running(v_codempid in varchar, v_dtecancel in date) return number;

	function get_msgerror(v_errorno in varchar2, v_lang in varchar2) return varchar2;
	function get_amtmax_by_codincome (obj_row_codincome in json_object_t,v_item_codincom in varchar2) return number;

	function get_clob(str_json in clob, key_json in varchar2) RETURN CLOB ;
end HRPM4CE ;

/
