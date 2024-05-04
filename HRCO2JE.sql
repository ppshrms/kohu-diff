--------------------------------------------------------
--  DDL for Package HRCO2JE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2JE" is
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

  p_indexid                 VARCHAR2(20 CHAR);
  p_codapp                  VARCHAR2(10 CHAR);
  p_codfrmto                VARCHAR2(10 CHAR);
  p_codfrmcc                VARCHAR2(10 CHAR);
  p_codappap                VARCHAR2(10 CHAR);
  p_codempid_query          VARCHAR2(10 CHAR);
  p_codempid_tmp            VARCHAR2(10 CHAR);
  p_dtetotal                VARCHAR2(20 CHAR);
  p_hrtotal                 VARCHAR2(20 CHAR);
  p_dtecreate               date;
  p_codcreate               VARCHAR2(50 CHAR);
  p_dteupd                  date;
  p_coduser                 VARCHAR2(50 CHAR);
  p_seqno                   number;
  p_syncond                 VARCHAR2(1000 CHAR);
  p_statement               clob;
  p_routeno                 VARCHAR2(10 CHAR);
  p_replyapp                VARCHAR2(1 CHAR);
  p_codfrmap                VARCHAR2(10 CHAR);
  p_typreplya               VARCHAR2(1 CHAR);
  p_replyno                 VARCHAR2(1 CHAR);
  p_codfrmno                VARCHAR2(10 CHAR);
  p_typreplyn               VARCHAR2(1 CHAR);
  p_typreplyar              VARCHAR2(1 CHAR);
  p_typreplynr              VARCHAR2(1 CHAR);
  p_strseq                  number;
  p_numseq                  number;

  p_count                   number;

  p_rowid                   VARCHAR2(20 CHAR);
  p_flg                     VARCHAR2(10 CHAR);
  p_lstseqno                number;
  procedure get_data(json_str_input in clob, json_str_output out clob);
  procedure get_twkflpf(json_str_input in clob, json_str_output out clob);
  procedure get_twkflph(json_str_input in clob, json_str_output out clob);
  procedure get_twkflpr(json_str_input in clob, json_str_output out clob);

  procedure save_data(json_str_input in clob, json_str_output out clob);

  procedure delete_index(json_str_input in clob, json_str_output out clob);

END HRCO2JE;

/
