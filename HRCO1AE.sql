--------------------------------------------------------
--  DDL for Package HRCO1AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO1AE" is

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

  p_indexid     varchar2(40 char);
  p_codcompy    varchar2(4 char);
  p_dtestrt     date;
  p_dteend      date;
  p_subjecte    varchar2(150 char);
  p_subjectt    varchar2(150 char);
  p_subject3    varchar2(150 char);
  p_subject4    varchar2(150 char);
  p_subject5    varchar2(150 char);
  p_messagee    clob;
  p_messaget    clob;
  p_message3    clob;
  p_message4    clob;
  p_message5    clob;

  p_rowid                   VARCHAR2(20 CHAR);
  p_flg                     VARCHAR2(10 CHAR);

  procedure get_data(json_str_input in clob, json_str_output out clob);
  procedure get_dataedit(json_str_input in clob, json_str_output out clob);
  procedure get_dropdown(json_str_input in clob,json_str_output out clob);
  procedure edit_data(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);


end HRCO1AE;

/
