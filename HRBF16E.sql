--------------------------------------------------------
--  DDL for Package HRBF16E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF16E" AS

  /* TODO enter package declarations (types, exceptions, methods etc) here */
  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_v_zminlvl	        number;
  global_v_zwrklvl	        number;
  global_v_numlvlsalst	    number;
  global_v_numlvlsalen	    number;
  global_v_zupdsal		      varchar2(4 char);

  p_codcomp                 tcenter.codcomp%type;
  p_codempid                temploy1.codempid%type;
  p_dtereq                  date;
  p_dtestrt                 date;
  p_dteend                  date;
  p_numvcher                tclnsinf.numvcher%type;
  p_codrel                  tclnsinf.codrel%type;
  p_dtecrest                tclnsinf.dtecrest%type;
  p_typamt                  tclnsinf.typamt%type;
  p_typrel                  tclnsinf.codrel%type;
  p_amtexp                  tclnsinf.amtexp%type;

  --<<wanlapa #6678 16/01/2023
  p_amtpaid                 tclnsinf.amtpaid%type;
  p_flag                    number;
  -->>wanlapa #6678 16/01/2023

  p_flgdocmt		        tclnsinf.flgdocmt%type;--User37 #6678 24/08/2021

  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure check_save(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure get_detail_table(json_str_input in clob, json_str_output out clob);
  procedure get_relation(json_str_input in clob, json_str_output out clob);
  procedure get_credit(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure send_mail (json_str_input in clob, json_str_output out clob);
  procedure gen_numvcher (p_codcomp in varchar2, p_lang in varchar2, v_numvcher in out varchar2 );--user37 #6841 07/09/2021 function gen_numvcher(v_codcomp in varchar2)return varchar2;
END HRBF16E;

/
