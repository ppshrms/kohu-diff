--------------------------------------------------------
--  DDL for Package HRPM4GE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM4GE" is
	-- last update: 1/10/2019
	param_msg_error		    varchar2(4000 char);

	v_chken			        varchar2(10 char);
	global_v_codempid	    varchar2(100 char);
	global_v_coduser	    varchar2(100 char);
	global_v_codpswd	    varchar2(100 char);
	global_v_lang		    varchar2(10 char) := '102';
	global_v_zyear		    number := 0;
	global_v_lrunning	    varchar2(10 char);
	global_v_zminlvl	    number;
	global_v_zwrklvl	    number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	v_zupdsal		        varchar2(4 char);
	global_v_chken		    varchar2(10 char) := hcm_secur.get_v_chken;
	p_codempid		        temploy1.codempid%type;
    p_codcomp               temploy1.codcomp%type;
	p_dtestr                ttmistk.dteeffec%type;
	p_dteend                ttmistk.dteeffec%type;

	p_dteeffec		        date;

	procedure getIndex (json_str_input in clob, json_str_output out clob);
	procedure genIndex (json_str_output out clob);
	procedure calTotal (json_str_input in clob, json_str_output out clob);
	procedure getDetail (json_str_input in clob, json_str_output out clob);
	procedure genDetail (json_str_output out clob);
	procedure getDetailHead (json_str_input in clob, json_str_output out clob);
	procedure genDetailHead (json_str_output out clob);
	procedure getDetailDropdown (json_str_input in clob, json_str_output out clob);
	procedure genDetailDropdown (json_str_output out clob);
	procedure getDetailTable (json_str_input in clob, json_str_output out clob);
	procedure genDetailTable (listofttpunsh in json_object_t,json_str_output out clob);
	procedure getIndexSelect (json_str_input in clob, json_str_output out clob);
	procedure genIndexSelect (json_str_output out clob);
	procedure init_post_save (json_str_input in clob);
	procedure vadidate_tab1(json_str_input in clob, v_out_objtab1 out json_object_t);
	procedure vadidate_tab2(json_str_input in clob, v_out_objtab2 out json_object_t);
	procedure vadidate_tab3(json_str_input in clob,v_out_objtab1 in json_object_t,v_in_objtab2 in json_object_t, v_out_objtab3 out json_object_t);
	procedure post_save (json_str_input in clob, json_str_output out clob);
	procedure post_delete (json_str_input in clob, json_str_output out clob);
	procedure getSendmail (json_str_input in clob, json_str_output out clob);
	procedure getamtincom ( v_codempid in varchar2,
		v_dteeffec		    in date,
		v_codcompy		    in varchar2,
		v_codempmt		    in varchar2,
		v_codpunsh		    in varchar2,
		v_lang			    in varchar2,
		v_chken			    in varchar2,
		v_out_objrow		out json_object_t,
		v_out_amtdoth		out number,
		v_out_sum_in_period	out number,
		v_out_sum_period	out number,
		v_out_dteyearst		out ttpunded.dteyearst%type,
		v_out_dtemthst		out ttpunded.dtemthst%type,
		v_out_numprdst		out ttpunded.numprdst%type,
		v_out_dteyearen		out ttpunded.dteyearen%type,
		v_out_dtemthen		out ttpunded.dtemthen%type,
		v_out_numprden		out ttpunded.numprden%type,
		v_out_codempid		out ttpunded.codempid%type,
		v_out_dteeffec		out ttpunded.dteeffec%type,
		v_out_codpunsh		out ttpunded.codpunsh%type,
		v_out_codpay		out ttpunded.codpay%type,
		v_out_amtded		out ttpunded.amtded%type,
		v_out_amttotded		out ttpunded.amttotded%type,
		v_out_mode		    out varchar2 );

    procedure init_default_detailtable (json_str_input in clob);
    procedure get_default_detailtable (json_str_input in clob, json_str_output out clob);
    procedure gen_default_detailtable (json_str_input in clob, json_str_output out clob);
--Redmine #5559    procedure check_tdtepay (v_codcomp in varchar2,v_typpayroll in varchar2 , v_periodstr in varchar2 ,v_periodend in varchar2);
	procedure check_tdtepay(p_codcomp   in varchar2, p_typpayroll in varchar2 ,
                            p_dteyearst in number ,  p_dtemthst in number , p_numprdst in number ,
                            p_dteyearen in number ,  p_dtemthen in number , p_numprden in number);
--Redmine #5559
    procedure check_tinexinfc (v_codcomp in varchar2, v_codpay in varchar2);
    procedure check_tinexinf (v_codpay in varchar2);
    procedure save_ttmistk (v_objdatatab1 in json_object_t);
    procedure save_ttpunsh (v_objdatatab1 in json_object_t,v_objdatatab2 in json_object_t,v_objdatatab3 in json_object_t);

	procedure save_ttpunded (
		v_index			in number,
		v_mode			in varchar2,
		v_codpunsh		in varchar2,
        v_codpunshold   in varchar2,
        v_dteeffec      date,
		v_codcomp		in varchar2,
		v_objdatatab1	in json_object_t,v_objdatatab2 in json_object_t,v_objdatatab3 in json_object_t);

	procedure delete_ttpunsh (json_str_input in clob);

	procedure delete_ttpunded (
		v_codempid		ttpunded.codempid%type,
		v_dteeffec		ttpunded.dteeffec%type,
		v_codpunsh		ttpunded.codpunsh%type );

	procedure init_amtincom_amtincded (
		v_item_ttpunded		in json_object_t,
		v_codempid		    in varchar2,
		v_amtincom1		    out ttpunded.amtincom1%type,
		v_amtincom2		    out ttpunded.amtincom2%type,
		v_amtincom3		    out ttpunded.amtincom3%type,
		v_amtincom4		    out ttpunded.amtincom4%type,
		v_amtincom5		    out ttpunded.amtincom5%type,
		v_amtincom6		    out ttpunded.amtincom6%type,
		v_amtincom7		    out ttpunded.amtincom7%type,
		v_amtincom8		    out ttpunded.amtincom8%type,
		v_amtincom9		    out ttpunded.amtincom9%type,
		v_amtincom10		out ttpunded.amtincom10%type,
		v_amtincded1		out ttpunded.amtincded1%type,
		v_amtincded2		out ttpunded.amtincded2%type,
		v_amtincded3		out ttpunded.amtincded3%type,
		v_amtincded4		out ttpunded.amtincded4%type,
		v_amtincded5		out ttpunded.amtincded5%type,
		v_amtincded6		out ttpunded.amtincded6%type,
		v_amtincded7		out ttpunded.amtincded7%type,
		v_amtincded8		out ttpunded.amtincded8%type,
		v_amtincded9		out ttpunded.amtincded9%type,
		v_amtincded10		out ttpunded.amtincded10%type);

	function find_max_seq_ttpunsh (
		v_codempid		in ttpunsh.codempid%type,
		v_dteeffec		in ttpunsh.dteeffec%type,
		v_codpunsh		in ttpunsh.codpunsh%type
	) return number;

	function calculate_amtincadj (v_objrow in json_object_t) return boolean;

	function get_count_tdtepay( v_codempid in varchar2,
		v_dteyearst		in ttpunded.dteyearst%type,
		v_dtemthst		in ttpunded.dtemthst%type,
		v_numprdst		in ttpunded.numprdst%type,
		v_dteyearen		in ttpunded.dteyearen%type,
		v_dtemthen		in ttpunded.dtemthen%type,
		v_numprden		in ttpunded.numprden%type) return number;

	function get_msgerror(v_errorno in varchar2, v_lang in varchar2) return varchar2;
--Redmine #5559
  procedure msg_err2(p_error in varchar2);
--Redmine #5559
end;

/
