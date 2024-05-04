--------------------------------------------------------
--  DDL for Package HRPM21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM21E" 
AS
    param_msg_error         varchar2(4000 char);
    v_chken                 varchar2(10 char);
    global_v_coduser        varchar2(100 char);
    global_v_codpswd        varchar2(100 char);
    global_v_codempid       varchar2(100 char);
    global_v_lang           varchar2(10 char) := '102';
    global_v_zyear          number := 0;
    global_v_lrunning       varchar2(10 char);
    global_v_zminlvl        number;
    global_v_zwrklvl        number;
    global_v_numlvlsalst    number;
    global_v_numlvlsalen    number;
    global_v_zupdsal        number;
    v_zupdsal   		    varchar2(4 char);

	p_date			        DATE;
	p_codcomp		        ttrehire.codcomp%TYPE;
	p_codmov		        ttrehire.codpos%TYPE;
	p_dtestr		        DATE;
	p_dteend		        DATE;
	p_codempid		        ttrehire.codempid%TYPE;
	p_datestrart		    VARCHAR2(50 CHAR);
	p_dateend		        VARCHAR2(50 CHAR);
	p_flgmove		        ttrehire.flgmove%TYPE;
	pa_flgmove		        ttrehire.flgmove%TYPE;
	p_keycodempid		    ttrehire.codempid%TYPE;
    global_v_chken		    varchar2(10 char) := hcm_secur.get_v_chken;
	p_newcodempid		    ttrehire.codnewid%TYPE;
	p_flgtaemp		        ttrehire.staemp%TYPE;
	p_datetrans		        DATE;
	p_datetranso		    DATE;
	p_daytest		        VARCHAR2(50 CHAR);
	p_numreqst		        ttrehire.numreqst%TYPE;
	p_codsend		        ttrehire.codsend%TYPE;
	p_flgreemp		        ttrehire.flgreemp%TYPE;
	p_codpos		        ttrehire.codpos%TYPE;
    p_codbrlc               ttrehire.codbrlc%TYPE;
	p_codempmt		        ttrehire.codempmt%TYPE;
	p_typemp		        ttrehire.typemp%TYPE;
	p_codcalen		        ttrehire.codcalen%TYPE;
	p_codjob		        ttrehire.codjob%TYPE;
	p_jobgrade		        ttrehire.jobgrade%TYPE;
	p_codgrpgl		        ttrehire.codgrpgl%TYPE;
	p_numlvl			    ttrehire.numlvl%TYPE;
	p_savetime		        ttrehire.flgatten%TYPE;
	p_idp			        ttrehire.codempid%TYPE;
	detail_codcomp		    ttrehire.codcomp%TYPE;
	detail_codempid		    ttrehire.codempid%TYPE;
	p_typpayroll		    ttrehire.typpayroll%type;
	p_paramsdelete		    JSON_object_t;
	pa_codempid		        ttrehire.codempid%TYPE;
	p_codcompindex		    ttrehire.codcomp%TYPE;
	p_flag                  VARCHAR(1);
	flgContinue		        varchar(10);
    p_codexemp              ttrehire.codexemp%type;
    p_codcurr               ttrehire.codcurr%type;
    p_objectsal             JSON_object_t;
    p_amtincom1             number;

	procedure initial_value (json_str in clob);
	procedure get_index21e (json_str_input in clob,json_str_output out clob);
	procedure gen_index21e (json_str_output out clob);
	procedure get_detail21e (json_str_input in clob,json_str_output out clob);
	procedure gen_detail21e (json_str_output out clob);
  
  procedure gen_id (json_str_input in clob,json_str_output out clob);
  
  procedure genallowance(json_str_input in clob, json_str_output out clob);
  
	procedure get_save_21e (json_str_input in clob,json_str_output out clob);
	procedure save_data21e (json_str_output out clob);
	procedure get_delete21e (json_str_input in clob,json_str_output out clob);
  procedure get_list_typrehire(json_str_input in clob, json_str_output out clob);
  procedure get_list_namhir(json_str_input in clob, json_str_output out clob);
	procedure funcsendmail (json_str_input in clob, json_str_output out clob);

  procedure getincome(json_str_input in clob, json_str_output out clob);

END hrpm21e;

/
