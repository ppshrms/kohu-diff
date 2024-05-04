--------------------------------------------------------
--  DDL for Package HRCO2IE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2IE" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char);
  global_v_zyear            number := 0;
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  p_indexid                 VARCHAR2(20 char);
  p_routeno                 VARCHAR2(10 CHAR);
  p_routeno_into            VARCHAR2(10 CHAR);
  p_desroute                VARCHAR2(150 CHAR);
  p_desroutt                VARCHAR2(150 CHAR);
  p_desrout3                VARCHAR2(150 CHAR);
  p_desrout4                VARCHAR2(150 CHAR);
  p_desrout5                VARCHAR2(150 CHAR);

  p_codempid                VARCHAR2(10 CHAR);
  p_codempid_query          VARCHAR2(10 CHAR);

  p_namlabele               VARCHAR2(150 CHAR);
  p_namlabelt               VARCHAR2(150 CHAR);
  p_namlabel3               VARCHAR2(150 CHAR);
  p_namlabel4               VARCHAR2(150 CHAR);
  p_namlabel5               VARCHAR2(150 CHAR);

  p_tcenter_name            VARCHAR2(150 CHAR);
  p_tpostn_name             VARCHAR2(150 CHAR);

  p_approvno                number;
  p_dtecreate               DATE;
  p_codcreate               VARCHAR2(50 CHAR);
  p_dteupd                  DATE;
  p_coduser                 VARCHAR2(50 CHAR);

  p_numseq                  number;
  p_numseq_appr             number;
  p_typeapp                 VARCHAR2(1 CHAR);
  p_codcompa                VARCHAR2(40 CHAR);
  p_codposa                 VARCHAR2(4 CHAR);
  p_codempa                 VARCHAR2(10 CHAR);
  p_typecc                  VARCHAR2(1 CHAR);
  p_codcompc                VARCHAR2(40 CHAR);
  p_codposc                 VARCHAR2(4 CHAR);
  p_codempc                 VARCHAR2(10 CHAR);

  p_rowid                   VARCHAR2(20 CHAR);
  p_flg                     VARCHAR2(10 CHAR);
  p_call_from_appr          varchar2(1) := 'N';

  procedure get_index (json_str_input in clob, json_str_output out clob);

  procedure get_route_detail (json_str_input in clob, json_str_output out clob);
  procedure get_route_table (json_str_input in clob, json_str_output out clob);

  procedure get_approver (json_str_input in clob, json_str_output out clob);
  procedure get_emp_detail (json_str_input in clob, json_str_output out clob);

  procedure save_route (json_str_input in clob, json_str_output out clob);
  procedure save_approver (json_str_input in clob, json_str_output out clob);

  procedure delete_index (json_str_input in clob, json_str_output out clob);

  procedure upd_tempaprq (json_str_input in clob, json_str_output out clob);
END HRCO2IE;

/
