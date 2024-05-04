--------------------------------------------------------
--  DDL for Package HRPM32U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM32U" is
--31/03/2022 17:00
	param_msg_error		    varchar2(4000 char);
	v_chken			        varchar2(10 char);
	global_v_coduser	    varchar2(100 char);
	global_v_codpswd	    varchar2(100 char);
	global_v_codempid	    varchar2(100 char);
	global_v_lang		    varchar2(10 char) := '102';
	global_v_zyear		    number := 0;
	global_v_lrunning	    varchar2(10 char);
	global_v_zminlvl	    number;
	global_v_zwrklvl	    number;
	global_v_numlvlsalst	number;
	global_v_numlvlsalen	number;
	global_v_zupdsal        varchar(10);
	global_v_chken		    varchar2(10 char) := hcm_secur.get_v_chken;
	pa_codempid		        ttprobat.codempid%type;
	pa_dtestr		        date;
	pa_dteend		        date;
	pa_codcomp		        ttprobat.codcomp%type;
	key_codempid		    ttprobat.codempid%type;
	pa_dteduepr		        varchar2(50);
	flag_ga			        number;
	pa_flg                  varchar(1);
	pa_typproba		        tproasgn.typproba%type;
	pa_codpos		        tproasgn.codpos%type;
	flg			            number;
	pa_numtime		        number;
	pa_numseq		        number;
	dataRowsHasFlg          varchar(1);

    p_codcomp               ttprobat.codcomp%type;
    p_codempid_query        ttprobat.codempid%type;
    p_dtestr                ttprobat.dteduepr%type;
    p_dteend                ttprobat.dteduepr%type;
    p_dteduepr              ttprobatd.dteduepr%type;
    p_dteeffec              ttmovemt.dteeffec%type;
    p_typproba		        ttprobat.typproba%type;
    p_numseq		        tapprobat.approvno%type;

	procedure genallowance(json_str_input in clob, json_str_output out clob);

	procedure getIncome(json_str_input in clob, json_str_output out clob);

	procedure initial_value (json_str in clob);

	procedure saveDetail(json_str_input in clob, json_str_output out clob);

	procedure get_index(json_str_input in clob, json_str_output out clob);
	procedure gen_index(json_str_output out clob);

	procedure get_popupinfo(json_str_input in clob, json_str_output out clob);
	procedure gen_popupinfo(json_str_output out clob);

	procedure get_numseq(json_str_input in clob, json_str_output out clob);
	procedure gen_numseq(json_str_output out clob);

	procedure get_detail(json_str_input in clob, json_str_output out clob);
	procedure gen_detail(json_str_output out clob);

end HRPM32U;

/
