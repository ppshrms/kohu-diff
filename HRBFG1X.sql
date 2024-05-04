--------------------------------------------------------
--  DDL for Package HRBFG1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFG1X" as
  --para
  param_msg_error       varchar2(4000);

  --global
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_zupdsal      varchar2(4 char);

  global_v_coduser      varchar2(100);
  global_v_codempid     varchar2(100);
  global_v_lang         varchar2(100);
  global_v_zyear        number  := 0;
  global_v_chken        varchar2(10) := hcm_secur.get_v_chken;

  b_index_dteyear       tpotentp.dteyear%type;
  b_index_codcomp       tcenter.codcomp%type;
  b_index_codcompy      tcompny.codcompy%type;
  b_index_comlevel      tcenter.comlevel%type;
  b_index_typdata       varchar2(1000);

  procedure initial_value(json_str in clob);
  procedure get_accumulated_benefit(json_str_input in clob,json_str_output out clob);
  procedure get_expense_by_department(json_str_input in clob,json_str_output out clob);
  procedure get_expense_by_month(json_str_input in clob,json_str_output out clob);
  procedure get_top_ten_diseases_expense(json_str_input in clob,json_str_output out clob);
end;


/
