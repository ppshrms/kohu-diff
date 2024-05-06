--------------------------------------------------------
--  DDL for Package HRSC20E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC20E" is
-- last update: 07/11/2020 16:55

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
  p_codcomp                 temploy1.codcomp %type;
  p_typeuser                tusrprof.typeuser%type;  
-- DetailIno
  p_emp_coduser             twidgetusr.coduser%type;
  p_codempid                temploy1.codempid%type;      
    -- save index
  -- save index
  json_params               json_object_t;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_AssignWidget (json_str_input in clob, json_str_output out clob);
  procedure gen_AssignWidget (json_str_output out clob);  
  procedure reset_widget (json_str_input in clob, json_str_output out clob);  
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure get_twidgetusr (json_str_input in clob, json_str_output out clob);
end HRSC20E;

/
