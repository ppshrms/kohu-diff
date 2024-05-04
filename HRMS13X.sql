--------------------------------------------------------
--  DDL for Package HRMS13X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS13X" is
-- last update: 23/05/2017 15:16

  param_msg_error       varchar2(4000 char);

  global_v_coduser      varchar2(1000 char);
  global_v_codpswd      varchar2(1000 char);
  global_v_lang         varchar2(1000 char);
  global_v_zminlvl      varchar2(10 char);
  global_v_zwrklvl      varchar2(10 char);
  global_v_zupdsal      varchar2(10 char);
  global_v_numlvlsalst  varchar2(10 char);
  global_v_numlvlsalen  varchar2(10 char);
  v_secur               boolean := null;
  v_zupdsal             varchar2(1);
  b_index_codempid      varchar2(1000 char);
  b_index_codcomp       varchar2(1000 char);
  b_index_sql_statement varchar2(1000 char);

  ttemfilt_item01   varchar2(4000 char);
  ttemfilt_item02   varchar2(4000 char);
  ttemfilt_item03   varchar2(4000 char);
  ttemfilt_item04   varchar2(4000 char);
  ttemfilt_item05   varchar2(4000 char);
  ttemfilt_date01  	date;
  ttemfilt_numseq   number;
  ttemfilt_codapp   varchar2(4000 char);
  ttemfilt_coduser  varchar2(4000 char);

  procedure initial_value(json_str in clob);
  procedure get_index(json_str in clob, json_str_output out clob);
end;

/
