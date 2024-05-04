--------------------------------------------------------
--  DDL for Package M_HRPMZ3X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRPMZ3X" as
/* Cust-Modify: KOHU-HR2301 */
-- last update: 12/06/2023 11:15

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  p_codempid                varchar2(100 char);
  p_typedata                varchar2(100 char);
  p_status                  varchar2(100 char);
  p_dteimpt                 date;
  p_dtestrt                 date;
  p_dteend                  date;
  p_namefile                varchar2(400 char);

  procedure initial_value (json_str in clob);

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);

  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
end M_HRPMZ3X;

/
