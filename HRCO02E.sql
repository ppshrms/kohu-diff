--------------------------------------------------------
--  DDL for Package HRCO02E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO02E" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  p_indexid                 VARCHAR2(20 char);
  p_codcompy                VARCHAR2(40 char);
  p_list_value              VARCHAR2(15 char);
  p_typsign                 VARCHAR2(1 char);
  p_coddoc                  VARCHAR2(15 char);
  p_codempid_query          VARCHAR2(10 char);
  p_codcomp                 VARCHAR2(40 char);
  p_codpos                  VARCHAR2(4 char);
  p_signname                VARCHAR2(150 char);
  p_posname                 VARCHAR2(150 char);
  p_namsign                 VARCHAR2(100 char);
  p_dtecreate               date;
  p_codcreate               VARCHAR2(50 char);
  p_dteupd                  date;
  p_coduser                 VARCHAR2(50 char);

  p_rowid                   VARCHAR2(10 CHAR);
  p_flg                     VARCHAR2(10 CHAR);

  v_count               number;

  procedure get_data(json_str_input in clob, json_str_output out clob);
  procedure get_tsetsign(json_str_input in clob, json_str_output out clob);
  procedure edit_tsetsign(json_str_input in clob, json_str_output out clob);

END HRCO02E;

/
