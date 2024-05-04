--------------------------------------------------------
--  DDL for Package HRTR75X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR75X" is
-- last update: 11/09/2020 15:45

  v_chken      varchar2(100 char); 

  param_msg_error           varchar2(4000 char);

  global_v_coduser          varchar2(100 char);
  global_v_codempid         varchar2(100 char);

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  v_zupdsal                 varchar2(4000 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  v_codapp                  tprocapp.codapp%type:= 'HRTR75X';
  p_dteyear                 thisclss.dteyear%type;
  p_codcompy                thisclss.codcompy%type;
  p_codcours                thisclss.codcours%type;
  p_numclseq                thisclss.numclseq%type;
  p_codinst                 thisinst.codinst%type;
  p_codsubj                 thisinst.codsubj%type;
  p_codform                 thisclss.codform%type;
  p_numgrup                 tintvews.numgrup%type;

  procedure initial_value(json_str in clob);
--show data 
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure get_course_internal(json_str_input in clob, json_str_output out clob);
  procedure gen_course_internal (json_str_output out clob);

  -- Detail Internal
  procedure get_training_class(json_str_input in clob, json_str_output out clob);
  procedure gen_training_class(json_str_output out clob);  

  procedure get_expense_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_expense_detail(json_str_output out clob);  
  procedure get_expense_table(json_str_input in clob, json_str_output out clob);
  procedure gen_expense_table(json_str_output out clob);   

  procedure get_employee_training_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_employee_training_detail(json_str_output out clob);  
  procedure get_employee_training_table(json_str_input in clob, json_str_output out clob);
  procedure gen_employee_training_table(json_str_output out clob);

  procedure get_course_evaluation_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_course_evaluation_detail(json_str_output out clob);  
  procedure get_course_evaluation_table1(json_str_input in clob, json_str_output out clob);
  procedure gen_course_evaluation_table1(json_str_output out clob);   
  procedure get_course_evaluation_table2(json_str_input in clob, json_str_output out clob);
  procedure gen_course_evaluation_table2(json_str_output out clob);  

  procedure get_instructor_evaluation(json_str_input in clob, json_str_output out clob);
  procedure gen_instructor_evaluation(json_str_output out clob);  

  procedure get_summary_information(json_str_input in clob, json_str_output out clob);
  procedure gen_summary_information(json_str_output out clob);  

  procedure get_other_information(json_str_input in clob, json_str_output out clob);
  procedure gen_other_information(json_str_output out clob);  

  procedure get_instructor_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_instructor_detail(json_str_output out clob);  
  procedure get_instructor_table(json_str_input in clob, json_str_output out clob);
  procedure gen_instructor_table(json_str_output out clob);

  procedure get_subcourse_evaluation(json_str_input in clob, json_str_output out clob);
  procedure gen_subcourse_evaluation(json_str_output out clob);

  procedure get_sub_instructor(json_str_input in clob, json_str_output out clob);
  procedure gen_sub_instructor(json_str_output out clob);
  function get_format_hhmm(p_qtyhour    number) return varchar2;
END; -- Package spec


/
