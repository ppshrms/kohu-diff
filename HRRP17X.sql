--------------------------------------------------------
--  DDL for Package HRRP17X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP17X" as
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

  b_index_comgrp        tcompgrp.codcodec%type;
  b_index_codcompy      tcompny.codcompy%type;
  b_index_codlinef      torgprt.codlinef%type;
  b_index_dteeffec      date;
  b_index_dteeffec2     date;
  b_index_codcompst     tcenter.codcomp%type;
  b_index_comlevel      tcenter.comlevel%type;
  b_index_flgemp        varchar2(10);
  b_index_flgrate       varchar2(10);
  b_index_flgjob        varchar2(10);

  type t_arr_number is table of number index by binary_integer;

  procedure initial_value(json_str in clob);
  procedure get_chart(json_str_input in clob,json_str_output out clob);
  procedure get_qty_emp_detail(json_str_input in clob,json_str_output out clob);
  procedure get_qty_emp_table(json_str_input in clob,json_str_output out clob);
  procedure get_list_emp(json_str_input in clob,json_str_output out clob);
end;

/
