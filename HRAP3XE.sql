--------------------------------------------------------
--  DDL for Package HRAP3XE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP3XE" as

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(4):= check_emp(get_emp) ;
  global_v_coduser          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  p_dteyreap                number;
  p_codcomp                 temploy1.codcomp%type;
  p_codreq                  varchar2(100 char);
  p_grade                   tappraism.grade%type;
  p_param_json              json_object_t;

  b_var_codempid            temploy1.codempid%type;
  b_var_codcompy            tcompny.codcompy%type;
  b_var_typpayroll          temploy1.typpayroll%type;

  b_var_staemp              varchar2(1) := 0 ;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob) ;
  procedure get_process(json_str_input in clob, json_str_output out clob);
  procedure process_data(json_str_output out clob);
  procedure insert_data_parallel (p_codapp  in varchar2,
                                   p_coduser in varchar2,
                                   p_proc    in out number) ;
end hrap3xe;

/
