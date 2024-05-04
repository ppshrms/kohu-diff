--------------------------------------------------------
--  DDL for Package HRCO1CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO1CE" is
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char);
  global_v_zyear            number := 0;
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;
  p_call_from               varchar2(100);

  p_intwno            texintwh.intwno%type;
  p_namintwe          texintwh.namintwe%type;
  p_namintwt          texintwh.namintwt%type;
  p_namintw3          texintwh.namintw3%type;
  p_namintw4          texintwh.namintw4%type;
  p_namintw5          texintwh.namintw5%type;
  p_codposst          texintwh.codposst%type;
  p_codposen          texintwh.codposen%type;

  p_numcate           texintws.numcate%type;
  p_namcatee          texintws.namcatee%type;
  p_namcatet          texintws.namcatet%type;
  p_namcate3          texintws.namcate3%type;
  p_namcate4          texintws.namcate4%type;
  p_namcate5          texintws.namcate5%type;
  p_typeques          texintws.typeques%type;

  p_numseq            texintwd.numseq%type;
  p_detailse          texintwd.detailse%type;
  p_detailst          texintwd.detailst%type;
  p_details3          texintwd.details3%type;
  p_details4          texintwd.details4%type;
  p_details5          texintwd.details5%type;

  p_numans            texintwc.numans%type;
  p_detailse_ans      texintwc.detailse%type;
  p_detailst_ans      texintwc.detailst%type;
  p_details3_ans      texintwc.details3%type;
  p_details4_ans      texintwc.details4%type;
  p_details5_ans      texintwc.details5%type;

  procedure check_save;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_category_table(json_str_input in clob,json_str_output out clob);
  procedure get_category_question(json_str_input in clob,json_str_output out clob);
  procedure get_question_choice(json_str_input in clob,json_str_output out clob);
  procedure save_index(json_str_input in clob,json_str_output out clob);
  procedure save_category(json_str_input in clob,json_str_output out clob);
  procedure save_question(json_str_input in clob,json_str_output out clob);
  procedure save_choice(json_str_input in clob,json_str_output out clob);
end;

/
