--------------------------------------------------------
--  DDL for Package HRCO15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO15E" AS

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

  p_codcompy                VARCHAR2(4 CHAR);
  p_codplcy                 VARCHAR2(4 CHAR);
  p_dteeffec                DATE;
  p_filename                VARCHAR2(1000 CHAR);

  p_rowid                   VARCHAR2(20 CHAR);
  p_flg                     VARCHAR2(10 CHAR);

  procedure get_data(json_str_input in clob, json_str_output out clob);
  procedure get_folder(json_str_input in clob, json_str_output out clob);
  procedure edit_tcompplcy(json_str_input in clob, json_str_output out clob);

END HRCO15E;

/
