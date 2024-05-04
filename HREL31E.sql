--------------------------------------------------------
--  DDL for Package HREL31E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HREL31E" as

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  p_codapp                  varchar2(10 char) := 'HREL31E';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  global_v_zupdsal          varchar2(10 char);

  json_obj          json_object_t;

  p_codcatexm       tvtest.codcatexm%type;
  p_codexam         tvtest.codexam%type;
  p_codexamCopy     tvtest.codexam%type;
  p_isCopy          varchar2(1 char);
  p_typeexam        tvquest.typeexam%type;
  p_numques         tvquestd1.numques%type;
  p_qtyans          number;

  p_codcomp         ttestemp.codcomp%type;
  p_datest          ttestemp.dtetest%type;
  p_dateen          ttestemp.dtetest%type;
  p_typtest         varchar2(1);
  p_codcours        ttestemp.codcours%type;
  p_codquest        tvquestd1.codquest%type;
  p_codempid_query  ttestemp.codempid%type;
  p_dtetest         ttestemp.dtetest%type;
  param_json        json_object_t;
  v_zupdsal         varchar2(4 char);

  procedure initial_value (json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_copylist(json_str_input in clob,json_str_output out clob);
  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure get_detail_tab2(json_str_input in clob,json_str_output out clob);
  procedure post_save_detail(json_str_input in clob,json_str_output out clob);
  procedure post_save_detail_tab2(json_str_input in clob,json_str_output out clob);
  procedure post_save_detail_tab2_all(json_str_input in clob,json_str_output out clob);
  procedure post_save_index(json_str_input in clob,json_str_output out clob);
  procedure post_delete_question(json_str_input in clob,json_str_output out clob);

end HREL31E;

/
