--------------------------------------------------------
--  DDL for Package HRRC33X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC33X" as

  param_msg_error           varchar2(4000 char);
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  v_chken                   varchar2(10 char);
  v_zupdsal                 varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_zupdsal		      varchar2(4 char);

  TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  p_text                    data_error;
  p_error_code              data_error;
  p_numseq                  data_error;

  p_codcomp     tapplcfm.codcomp%type;
  p_codpos      tapplcfm.codposc%type;
  p_dtestrt     tapplcfm.dteappr%type;
  p_dteend      tapplcfm.dteappr%type;
  p_codexam     ttestemp.codexam%type;
  p_codempid    ttestemp.codempid%type;
  p_typtest     ttestemp.typtest%type;
  p_typetest    ttestemp.typetest%type;
  p_dtetest     ttestemp.dtetest%type;

  procedure initial_value(json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure get_index_popup(json_str_input clob, json_str_output out clob);
  procedure gen_index_popup(json_str_output out clob);
  procedure post_import_process(json_str_input in clob, json_str_output out clob);
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);

end hrrc33x;

/
