--------------------------------------------------------
--  DDL for Package HRES65X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES65X" is
-- last update: 15/04/2019 17:22

  param_msg_error           varchar2(4000 char);

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codcomp          temploy1.codcomp%type;
  global_v_dteempmt         date;
  global_v_qtyavgwk         number;

  b_index_codempid          varchar2(4000 char);
  b_index_year              number;
  b_index_leave_type        varchar2(500 char);
  --
  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  function  cal_dhm_concat (p_qtyday in  number) return varchar2;

end; -- Package spec

/
