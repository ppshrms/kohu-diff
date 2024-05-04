--------------------------------------------------------
--  DDL for Package HRCO1BE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO1BE" is
-- last update: 20/11/2017 11:19

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;


  p_codcomp                 VARCHAR2(40 char);  --????????
  p_dteeffec                DATE;   --????????????
  p_numseq                  number; --????????
  p_typemsg                 tannounce.typemsg%type;

  p_dtestrt                 DATE;
  p_dteend                  DATE;
  p_subjecte                VARCHAR2(4000 CHAR);
  p_subjectt                VARCHAR2(4000 CHAR);
  p_subject3                VARCHAR2(4000 CHAR);
  p_subject4                VARCHAR2(4000 CHAR);
  p_subject5                VARCHAR2(4000 CHAR);
  p_messagee                clob;
  p_messaget                clob;
  p_message3                clob;
  p_message4                clob;
  p_message5                clob;
  p_filename                clob;

  p_namimgnews     tannounce.namimgnews%type;
  p_url                     tannounce.url%type;
  p_codappr                 VARCHAR2(10 CHAR);
  p_dteappr                 DATE;
  p_desc_codappr            VARCHAR2(500 CHAR);

  p_rowid                 VARCHAR2(10 CHAR);
  p_flg                   VARCHAR2(10 CHAR);

  procedure get_data(json_str_input in clob, json_str_output out clob);
  procedure get_dropdown(json_str_input in clob,json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure delete_data(json_str_input in clob, json_str_output out clob);
--  procedure edit_temproute(json_str_input in clob, json_str_output out clob);

end HRCO1BE;

/
