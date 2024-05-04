--------------------------------------------------------
--  DDL for Package HRCO3DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO3DE" IS
-- last update: 20/11/2017 11:19

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


  p_codapp                  tapplscr.codapp%type;  --??????????????
  p_codapp_query            tapplscr.codapp%type;  --?????????????? query
  p_codproc                 VARCHAR2(10 char);  --?????????
  p_numseq                  tapplscr.numseq%type; --????????
  p_desclabele              tapplscr.desclabele%type;
  p_desclabelt              tapplscr.desclabelt%type;
  p_desclabel3              tapplscr.desclabel3%type;
  p_desclabel4              tapplscr.desclabel4%type;
  p_desclabel5              tapplscr.desclabel5%type;
--
  p_rowid                 VARCHAR2(10 CHAR);
  p_flg                   VARCHAR2(10 CHAR);
--
  procedure get_data(json_str_input in clob, json_str_output out clob);
  procedure get_header_info (json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);

END HRCO3DE;

/
