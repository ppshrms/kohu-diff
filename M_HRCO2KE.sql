--------------------------------------------------------
--  DDL for Package M_HRCO2KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRCO2KE" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;
  global_v_zupdsal            varchar2(100 char);

  p_codapp                  VARCHAR2(10 CHAR);  --???????????
  p_codempid_query          VARCHAR2(10 CHAR);  --???????????
  p_codcomp                 VARCHAR2(40 char);  --????????
  p_codpos                  VARCHAR2(4 CHAR);   --???????
  p_routeno                 VARCHAR2(10 CHAR);
  p_dtecreate               DATE;
  p_codcreate               VARCHAR2(50 CHAR);
  p_dteupd                  DATE;
  p_coduser                 VARCHAR2(50 CHAR);

  p_rowid                   VARCHAR2(20 CHAR);
  p_flg                     VARCHAR2(10 CHAR);

  p_codappr1                VARCHAR2(10 CHAR);
  p_pctotreq1               NUMBER(5, 2);
  p_codappr2                VARCHAR2(10 CHAR);
  p_pctotreq2               NUMBER(5, 2);
  p_codappr3                VARCHAR2(10 CHAR);
  p_pctotreq3               NUMBER(5, 2);
  p_codappr4                VARCHAR2(10 CHAR);
  p_pctotreq4               NUMBER(5, 2);

  type data_error is table of varchar2(4000 char) index by binary_integer;
  p_text                      data_error;
  p_error_code                data_error;
  p_numseq                    data_error;

  v_codempid 	   varchar2(10 char);
  v_codapp         tempflow.codapp%type;
  v_codappr1       tempflow.codappr1%type;  
  v_pctotreq1      tempflow.pctotreq1%type;  
  v_codappr2       tempflow.codappr2%type;  
  v_pctotreq2      tempflow.pctotreq2%type;  
  v_codappr3       tempflow.codappr3%type;  
  v_pctotreq3      tempflow.pctotreq3%type;  
  v_codappr4       tempflow.codappr4%type;  
  v_pctotreq4      tempflow.pctotreq4%type;  

  procedure get_data(json_str_input in clob, json_str_output out clob);
  procedure get_tempflow(json_str_input in clob, json_str_output out clob);
  procedure edit_temproute(json_str_input in clob, json_str_output out clob);
  procedure edit_tempflow(json_str_input in clob, json_str_output out clob);
  procedure get_import_process(json_str_input in clob, json_str_output out clob);
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);
  procedure get_work_import_process(json_str_input in clob, json_str_output out clob);  -- mo-kohu-sm2301
  procedure format_work_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number); -- mo-kohu-sm2301
  procedure insert_tempflow;
end M_HRCO2KE;

/
