--------------------------------------------------------
--  DDL for Package HRPM44U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM44U" IS
    param_msg_error		    VARCHAR2(4000 CHAR);
    v_chken			        VARCHAR2(10 CHAR);
    global_v_coduser	    VARCHAR2(100 CHAR);
    global_v_codpswd	    VARCHAR2(100 CHAR);
    global_v_codempid	    VARCHAR2(100 CHAR);
    global_v_lang		    VARCHAR2(10 CHAR) := '102';
    global_v_zyear		    NUMBER := 0;
    global_v_lrunning	    VARCHAR2(10 CHAR);
    global_v_zminlvl	    NUMBER;
    global_v_zwrklvl	    NUMBER;
    global_v_numlvlsalst	NUMBER;
    global_v_numlvlsalen	NUMBER;
    global_v_zupdsal        varchar(10);
    p_codcomp		        VARCHAR2(4000 CHAR);
    p_dtestr		        VARCHAR2(4000 CHAR);
    p_dteend		        VARCHAR2(4000 CHAR);
    v_tresintw_numqes	    NUMBER;
    v_tresintw_numqes_now	NUMBER := 0;
    p_codempid_query		        VARCHAR2(4000 CHAR);
    p_dteeffec		        VARCHAR2(4000 CHAR);
    p_table		        VARCHAR2(4000 CHAR);
    p_numseq		        NUMBER;
    call_from               varchar(10);
    v_secur2		        BOOLEAN;
    flg_numseq		        NUMBER;
    v_flgpass		        BOOLEAN;
    global_v_chken		    VARCHAR2(10 CHAR) := hcm_secur.get_v_chken;
    p_codmist		        ttmistk.codmist%TYPE;
    p_dtereq                tresreq.dtereq%type;
--    p_numseq                tresreq.numseq%type;
    p_intwno                tresreq.intwno%type;
    flgsecur        boolean;
    v_zupdsal       varchar2(4 char);

	PROCEDURE initial_value ( json_str IN CLOB );

	PROCEDURE get_index ( json_str_input IN CLOB, json_str_output OUT CLOB );

	PROCEDURE gen_index ( json_str_output OUT CLOB );

	PROCEDURE getupdate ( json_str_input IN CLOB, json_str_output OUT CLOB );

	PROCEDURE getdetail ( json_str_input IN CLOB, json_str_output OUT CLOB );

	PROCEDURE gendetail ( json_str_output OUT CLOB );

	PROCEDURE gendetail_ttexempt ( json_str_output OUT CLOB );

	PROCEDURE gendetail_ttmistk ( json_str_output OUT CLOB );

	PROCEDURE gendetail_ttmovemt0007 ( json_str_output OUT CLOB );

    procedure get_exintw_detail (json_str_input in clob, json_str_output out clob);
    procedure gen_exintw_detail (json_str_output out clob);

    procedure get_texintw (json_str_input in clob, json_str_output out clob);
    procedure gen_texintw (json_str_output out clob);

END hrpm44u;

/
