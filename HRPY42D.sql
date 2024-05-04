--------------------------------------------------------
--  DDL for Package HRPY42D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY42D" as
-- last update: 10/02/2021 16:01 redmine#3405

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(4):= check_emp(get_emp) ;
  v_zyear                   number:= 0;
  global_v_coduser          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  p_numperiod               number;
  p_dtemthpay               number;
  p_dteyrepay               number;
  p_codcomp                 varchar2(100 char);
  p_typpayroll              varchar2(100 char);
  p_codempid                varchar2(100 char);

  b_var_codempid            temploy1.codempid%type;
  b_var_codcompy            tcompny.codcompy%type;
  b_var_typpayroll          temploy1.typpayroll%type;
  b_var_dtebeg              date;
  b_var_dteend              date;
  b_index_lastperd          number;
  b_index_lstmnt            number;
  b_index_lstyear           number;

  procedure get_process(json_str_input in clob, json_str_output out clob);
  procedure process_data(json_str_output out clob);
  procedure clear_olddata (p_var_codempid in varchar2,p_numrec in out number);
end HRPY42D;

/
