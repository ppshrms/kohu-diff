--------------------------------------------------------
--  DDL for Package HRPM4DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM4DE" is

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
	global_v_zupdsal	    number;
	global_v_chken		    varchar2(10 char) := hcm_secur.get_v_chken;
	P_flag                  varchar(10);
	p_countday              varchar(10);
	p_codempid		        TTMOVEMT.CODEMPID%TYPE;
	p_numseq		        TTMOVEMT.NUMSEQ%TYPE;
	p_dteeffec		        TTMOVEMT.DTEEFFEC%TYPE;
	p_codtrn		        TTMOVEMT.CODTRN%TYPE;
	p_codcreate		        TTMOVEMT.CODCREATE%TYPE;
	p_stapost2		        TTMOVEMT.STAPOST2%TYPE;
	p_dteduepr		        TTMOVEMT.DTEDUEPR%TYPE;
	p_dteend		        TTMOVEMT.DTEEND%TYPE;
	p_numreqst		        TTMOVEMT.NUMREQST%TYPE;
	pa_amtothr		        number;
	p_flgduepr		        TTMOVEMT.FLGDUEPR%TYPE;
	p_codcreate_username    varchar(100);
	p_desnote		        TTMOVEMT.DESNOTE%TYPE;
    p_codempid_query        TTMOVEMT.CODEMPID%TYPE;
    p_index_codcomp         TTMOVEMT.CODCOMP%TYPE;
    p_index_codtrn          TTMOVEMT.codtrn%TYPE;
    p_index_dtestr          date;
    p_index_dteend          date;
	p_dteeffpos		        TTMOVEMT.DTEEFFPOS%TYPE;
	detail_dteeffec		    TTMOVEMT.dteeffec%TYPE;
	detail_codempid		    TTMOVEMT.codempid%TYPE;
	detail_numseq		    TTMOVEMT.numseq%TYPE;
	detail_codtrn		    TTMOVEMT.codtrn%TYPE;
	detail_flag             varchar(100);
	obj_row1		        TTMOVEMT.CODCOMPT%TYPE;
	obj_row2		        TTMOVEMT.CODPOSNOW%TYPE;
	obj_row3		        TTMOVEMT.NUMLVLT%TYPE;
	obj_row4		        TTMOVEMT.CODJOBT%TYPE;
	obj_row5		        TTMOVEMT.CODEMPMTT%TYPE;
	obj_row6		        TTMOVEMT.TYPEMPT%TYPE;
	obj_row7		        TTMOVEMT.TYPPAYROLT%TYPE;
	obj_row8		        TTMOVEMT.CODBRLCT%TYPE;
	obj_row9		        TTMOVEMT.FLGATTET%TYPE;
	obj_row10		        TTMOVEMT.CODCALET%TYPE;
	obj_row11		        TTMOVEMT.JOBGRADET%TYPE;
	obj_row12		        TTMOVEMT.CODGRPGLT%TYPE;
	pa_codcurr		        TTMOVEMT.codcurr%type;
	modal_codpos		    temploy1.codpos%type;
	modal_codcomp		    temploy1.codcomp%type;
    v_zupdsal		        varchar2(10 char);
    flgsecur                boolean;

	procedure genallowance(json_str_input in clob, json_str_output out clob);

	procedure initial_value (json_str in clob);

	procedure get_index(json_str_input in clob, json_str_output out clob);

	procedure gen_index(json_str_output out clob);

	procedure saveData(json_str_input in clob, json_str_output out clob);

    procedure GetDetailModal(json_str_input in clob, json_str_output out clob);

    procedure check_index(json_str_input in clob);

	procedure getDetail(json_str_input in clob, json_str_output out clob);

	procedure genDetail(json_str_output out clob);

	procedure getDelete(json_str_input in clob, json_str_output out clob);

	procedure getIncome(json_str_input in clob, json_str_output out clob);

	procedure getSendMail(json_str_input in clob, json_str_output out clob);

	function get_msgerror(v_errorno in varchar2, v_lang in varchar2) return varchar2;
end HRPM4DE;

/
