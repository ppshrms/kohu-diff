--------------------------------------------------------
--  DDL for Package HRPM31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM31E" IS
--28/01/2023||SEA-HR2201||redmine680  
  param_msg_error		    VARCHAR2(4000 CHAR);
  v_chken			        VARCHAR2(10 CHAR);
  global_v_coduser	        VARCHAR2(100 CHAR);
  global_v_codpswd	        VARCHAR2(100 CHAR);
  global_v_codempid	        VARCHAR2(100 CHAR);
  global_v_lang		        VARCHAR2(10 CHAR) := '102';
  global_v_zyear		    NUMBER := 0;
  global_v_lrunning	        VARCHAR2(10 CHAR);
  global_v_zminlvl	        NUMBER;
  global_v_zwrklvl	        NUMBER;
  global_v_numlvlsalst	    NUMBER;
  global_v_numlvlsalen	    NUMBER;
  global_v_zupdsal	        NUMBER;
  global_v_codapp	        VARCHAR2(100 CHAR);

  p_codempid_query	        temploy1.codempid%TYPE;
  p_dtestr		            temploy1.dteempmt%TYPE;
  p_dteend		            temploy1.dteduepr%TYPE;
  p_codcomp		            temploy1.codcomp%TYPE;
  p_codpos		            temploy1.codpos%TYPE;
  p_typproba                ttprobat.typproba%TYPE;
  p_dteduepr		        temploy1.dteduepr%TYPE;

  p_flgfixcodempid          boolean;

  p_modal_numseq		    number;
  p_modal_dteeffec		    date;

  detail_flag_tab3	        boolean;
  display_codeval		    ttprobat.codeval%TYPE;
  detail_codempid_37x	    temploy1.codempid%TYPE;
  dteduepr_37x		        tappbath.dteduepr%type;
  detail_image              VARCHAR(500);
  detail_codempid           VARCHAR(500);
  detail_nameemp            VARCHAR(500);
  detail_det                VARCHAR(500);
  detail_pos                VARCHAR(500);
  detail_type               VARCHAR(500);
  detail_dtestrt		    temploy1.dteempmt%TYPE;
  detail_dteend		        temploy1.dteduepr%TYPE;
  detail_sta                VARCHAR(500);

  detail_codcomp            VARCHAR(500);
  detail_codpos             VARCHAR(500);
  detail_typproba           VARCHAR(1);
  detail_flag               VARCHAR(10);
  detail_numseq		        NUMBER;
  detail_numtime		    NUMBER;
  detail_dtestrt_leave	    temploy1.dteempmt%TYPE;
  detail_dteend_leave	    temploy1.dteduepr%TYPE;
  tab3_dtestrt		        DATE;
  tab3_dteend		        DATE;

  r_numtime                 VARCHAR(500);
  r_numseq_data             VARCHAR(500);
  r_codeval                 VARCHAR(500);
  isInsertReport		    boolean := false;
  r_numseq		            number := 0;
  numYearReport		        number;
  r_codempid		        temploy1.codempid%type;
  str_de_dteeffec		    temploy1.codempid%type;
  r_codcomp                 VARCHAR(500);
  r_codpos                  VARCHAR(500);
  r_typproba                VARCHAR(500);
  p_numseq                  tappbath.numseq%type;
  p_numtime                 tappbath.numtime%type;
  p_codempcondition         varchar2(4000);
  p_flgsubmit_disable       boolean;
  p_formtype                varchar2(1);
  v_type                    VARCHAR(500);
  v_zupdsal               VARCHAR(1 CHAR);

	PROCEDURE initial_value(json_str IN CLOB);
    PROCEDURE get_index(json_str_input IN CLOB,json_str_output OUT CLOB);
	PROCEDURE gen_index(json_str_output OUT CLOB);

    PROCEDURE get_codevallist(json_str_input IN CLOB,json_str_output OUT CLOB);
	PROCEDURE gen_codevallist(json_str_output OUT CLOB);

	PROCEDURE getdetail(json_str_input IN CLOB,json_str_output OUT CLOB);
	PROCEDURE gendetail(json_str_output OUT CLOB);
	PROCEDURE savedetail(json_str_input IN CLOB,json_str_output OUT CLOB);
    PROCEDURE insert_tappbath(p_codempid VARCHAR2, p_dteduepr date, p_numtime NUMBER, p_typproba VARCHAR2);
	PROCEDURE send_mail_appr(p_codempid	VARCHAR2, p_dteduepr date, p_numtime NUMBER,p_numseq	NUMBER ,p_typproba VARCHAR2);
	PROCEDURE send_mail_apprco(p_codempid VARCHAR2, p_dteduepr	DATE, p_approvno NUMBER);
	PROCEDURE send_mailappr(json_str_input IN CLOB,json_str_output OUT CLOB);
    PROCEDURE getdelete(json_str_input IN CLOB,json_str_output OUT CLOB);
    PROCEDURE gen_report(json_str_input in clob, json_str_output out clob);
    PROCEDURE get_detail_report;
    PROCEDURE get_detail_report_forms;
    PROCEDURE clear_ttemprpt;
	PROCEDURE getTab3(json_str_input IN CLOB,json_str_output OUT CLOB);
	FUNCTION gen_codeval(p_codempid	VARCHAR2,p_dteduepr	DATE,p_numtime NUMBER,p_numseq NUMBER,p_codappr VARCHAR2,p_typproba VARCHAR2) RETURN VARCHAR2;
    FUNCTION func_get_grade(p_codform in VARCHAR2, p_grade_item IN NUMBER) return VARCHAR2;
    FUNCTION func_get_intscor (p_codform IN VARCHAR2) RETURN  json_object_t;
    FUNCTION func_get_choose_ans (
        p_codempid IN temploy1.codempid%type,
        p_dteduepr IN tappbati.dteduepr%type,
        p_numgrup IN tappbati.numgrup%type,
        p_numtime IN tappbati.numtime%type,
        p_numseq IN tappbati.numseq%type,
        p_numitem IN tappbati.numitem%type,
        tappbati_grdscor in OUT tappbati.grdscor%type ,
        tappbati_qtyscor in OUT tappbati.qtyscor%type
    ) RETURN  boolean;
    FUNCTION func_get_qtyavgwk (p_codcomp IN temploy1.codcomp%type) RETURN tcontral.qtyavgwk%type;
    PROCEDURE getDetailPopup(json_str_input IN CLOB,json_str_output OUT CLOB);
    PROCEDURE genDetailPopup(json_str_output OUT CLOB);

    function get_max_numtime (p_codempid IN VARCHAR2,p_dteduepr IN date) RETURN  number;
    function get_max_numseq (p_codempid IN VARCHAR2,p_dteduepr IN date, p_numtime number) RETURN  number;

END HRPM31E;

/
