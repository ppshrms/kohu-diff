--------------------------------------------------------
--  DDL for Package HRSC01E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC01E" as
-- last update: 14/11/2018 22:31

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  -- index
  p_coduser                 tusrprof.coduser%type;
  p_codempid                temploy1.codempid%type;
  p_codcomp                 temploy1.codcomp%type;
  p_typeauth                tusrprof.typeauth%type;
  p_typeuser                tusrprof.typeuser%type;
  -- save index
  json_params               json_object_t;

  p_codsecu                 tsecurh.codsecu%type;
  p_codproc                 tprocess.codproc%type;
  -- save detail
  tusrprof_coduser          tusrprof.coduser%type;
  tusrprof_codempid         tusrprof.codempid%type;
  tusrprof_userdomain       tusrprof.userdomain%type;
  tusrprof_flgact           tusrprof.flgact%type;
  tusrprof_codpswd          varchar2(4000 char);
  p_codpswd_hash            varchar2(4000 char);
  tusrprof_flgauth          tusrprof.flgauth%type;
  tusrprof_codsecu          tusrprof.codsecu%type;
  tusrprof_timepswd         tusrprof.timepswd%type;
  tusrprof_typeauth         tusrprof.typeauth%type;
  tusrprof_typeuser         tusrprof.typeuser%type;
  tusrprof_numlvlst         tusrprof.numlvlst%type;
  tusrprof_numlvlen         tusrprof.numlvlen%type;
  tusrprof_numlvlsalst      tusrprof.numlvlsalst%type;
  tusrprof_numlvlsalen      tusrprof.numlvlsalen%type;
  -- save tusrlog
  tusrlog_seqnum            tusrlog.seqnum%type;
  -- specific report
  isInsertReport            boolean := false;
  json_coduser              json_object_t;
  p_codapp                  varchar2(10 char) := 'HRSC01E';
  type t_array_var2 is table of varchar2(2000 char) index by binary_integer;
    p_column_label    t_array_var2;
    p_column_value    t_array_var2;
    p_column_width    t_array_var2;
    p_text_align      t_array_var2;
  p_max_column  number  := 15;

  procedure initial_value (json_str in clob);

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_currentusertypauth (json_str_input in clob, json_str_output out clob);
  procedure gen_currentusertypauth (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_emp_data (json_str_input in clob, json_str_output out clob);
  procedure gen_emp_data (json_str_output out clob);
  procedure get_emp_data_tusrcom (json_str_input in clob, json_str_output out clob);
  procedure gen_emp_data_tusrcom (json_str_output out clob);
  procedure get_tusrcom (json_str_input in clob, json_str_output out clob);
  procedure gen_tusrcom (json_str_output out clob);
  procedure get_tusrproc (json_str_input in clob, json_str_output out clob);
  procedure gen_tusrproc (json_str_output out clob);
  procedure get_tprocapp (json_str_input in clob, json_str_output out clob);
  procedure gen_tprocapp (json_str_output out clob);
  procedure post_send_mail (json_str_input in clob, json_str_output out clob);
  procedure gen_report(json_str_input in clob, json_str_output out clob);
  procedure insert_ttemprpt(obj_data in json_object_t);
  procedure insert_ttemprpt_comp(obj_data in json_object_t);
  procedure insert_ttemprpt_proc(obj_data in json_object_t);
  procedure get_codproc_all(json_str_input in clob, json_str_output out clob);
end HRSC01E;

/
