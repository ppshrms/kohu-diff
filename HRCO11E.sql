--------------------------------------------------------
--  DDL for Package HRCO11E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO11E" is

  param_msg_error           varchar2(4000 char);
--  param_msg_error_check           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  p_codcompy                VARCHAR2(4 CHAR);
  p_typdoc                  VARCHAR2(4 CHAR);
  p_codinitie               VARCHAR2(4 CHAR);
  p_codinitit               VARCHAR2(4 CHAR);
  p_codiniti3               VARCHAR2(4 CHAR);
  p_codiniti4               VARCHAR2(4 CHAR);
  p_codiniti5               VARCHAR2(4 CHAR);
  p_dtelstprn               date;
  p_numlastdoc              number;
  p_dtecreate               date;
  p_codcreate               VARCHAR2(50 CHAR);
  p_dteupd                  date;
  p_coduser                 VARCHAR2(50 CHAR);

  p_rowid                   VARCHAR2(20 CHAR);
  p_flg                     VARCHAR2(10 CHAR);

  procedure get_data(json_str_input in clob, json_str_output out clob);
  procedure edit_data(json_str_input in clob, json_str_output out clob);

end HRCO11E;

/
