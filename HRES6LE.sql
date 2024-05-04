--------------------------------------------------------
--  DDL for Package HRES6LE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES6LE" as
  --para
  param_msg_error       varchar2(600);

  --global
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_zupdsal      varchar2(4 char);

  global_v_coduser      varchar2(100);
  global_v_codpswd      varchar2(100);
  global_v_codempid     varchar2(100);
  global_v_empid        varchar2(100);
  global_v_lang         varchar2(100);
  global_v_zyear        number  := 0;
  global_v_chken        varchar2(10) := hcm_secur.get_v_chken;
  global_v_codapp       varchar2(4000 char);

  p_codempid_query      temploy1.codempid%type;
  p_dteyear             number;
  p_dtereq              date;
  p_qtyavgwk            tcontral.qtyavgwk%type;
  v_amtday	          number;
  type t_arr_number is table of number index by binary_integer;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure save_detail(json_str_input in clob,json_str_output out clob);
end;

/
