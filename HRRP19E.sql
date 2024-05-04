--------------------------------------------------------
--  DDL for Package HRRP19E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP19E" is

  param_msg_error           varchar2(4000 char);

  p_codapp                  varchar2(10 char) := 'hrrp19e';
  p_codempid                temploy1.codempid%type;
  p_numpath                 tposplnd.numpath%type;
  p_dteeffec                thisorg.dteeffec%type;

  p_shorttrm                tposemph.shorttrm%type;
  p_midterm                tposemph.midterm%type;
  p_longtrm                tposemph.longtrm%type;
  p_codreview                tposemph.codreview%type;
  p_dtereview                tposemph.dtereview%type;
  p_descstr                tposemph.descstr%type;
  p_descweek                tposemph.descweek%type;
  p_descoop                tposemph.descoop%type;
  p_descthreat                tposemph.descthreat%type;
  p_descdevp               tposemph.descdevp%type;
  p_codpos                  tposplnd.codpos%type;
  p_codcomp                 tposplnd.codcomp%type;
  p_codskill                tcompskil.codskill%type;


  json_obj    json_object_t;

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_v_zminlvl	        number;
  global_v_zwrklvl	        number;
  global_v_numlvlsalst	    number;
  global_v_numlvlsalen	    number;
  global_v_zupdsal		    varchar2(4 char);

  procedure initial_value (json_str in clob);
--  procedure check_index;

  procedure get_detail (json_str_input in clob,json_str_output out clob);
  procedure get_detail_tab1 (json_str_input in clob,json_str_output out clob);
  procedure get_detail_tab2 (json_str_input in clob,json_str_output out clob);
  procedure get_detail_tab3 (json_str_input in clob,json_str_output out clob);
  procedure get_detail_tab3_table (json_str_input in clob,json_str_output out clob);
  procedure get_detail_tab4_table1 (json_str_input in clob,json_str_output out clob);
  procedure get_detail_tab4_table2 (json_str_input in clob,json_str_output out clob);
  procedure post_save_detail (json_str_input in clob,json_str_output out clob);
  procedure get_path_no (json_str_input in clob,json_str_output out clob);
  procedure get_career_path (json_str_input in clob,json_str_output out clob);
  procedure get_codtency (json_str_input in clob,json_str_output out clob);
  procedure post_delete_detail (json_str_input in clob,json_str_output out clob);
  procedure get_career_path_plan (json_str_input in clob,json_str_output out clob);
  procedure get_career_path_plan_table (json_str_input in clob,json_str_output out clob);
  --<<User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
  procedure get_career_tab2 (json_str_input in clob,json_str_output out clob);
  procedure get_career_tab3 (json_str_input in clob,json_str_output out clob);
  procedure get_career_tab3_table (json_str_input in clob,json_str_output out clob);
  procedure get_career_tab4_table1 (json_str_input in clob,json_str_output out clob);
  procedure get_career_tab4_table2 (json_str_input in clob,json_str_output out clob);
  function check_gap(pa_codempid in varchar,pa_codcomp in varchar2,pa_codpos in varchar2) return varchar2;
  -->>User37 #4561 #4559 #4552 1. RP Module 16/12/2021 
end hrrp19e;

/
