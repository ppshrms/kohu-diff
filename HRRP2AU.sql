--------------------------------------------------------
--  DDL for Package HRRP2AU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP2AU" as
  --para
  param_msg_error           varchar2(4000);
  param_msg_error_mail      varchar2(4000 char);

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

  b_index_year          number;
  b_index_codcompy      tcompny.codcompy%type;
  b_index_codlinef      torgprt.codlinef%type;
  b_index_codcomp       tcenter.codcomp%type;
  b_index_codpos        tpostn.codpos%type;
  b_index_dtereq        date;
  global_qtyexman       number;

  type t_arr_number is table of number index by binary_integer;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure get_detail_approve(json_str_input in clob,json_str_output out clob);
  procedure approve(json_str_input in clob,json_str_output out clob);
end;

/
