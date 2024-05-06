--------------------------------------------------------
--  DDL for Package HRCO3CB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO3CB" as
-- last update: 20/04/2018 10:30:00

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

  v_flg                     varchar2(100 char);
  v_seqno                   number;
  v_flgappr                 varchar2(1 char);
  v_codcompap               varchar2(40 char);
  v_codposap                varchar2(4 char);
  v_codempap                varchar2(50 char);
  v_message                 varchar2(4000 char);

  -- special
  v_text_key                varchar2(100 char) := '';
  v_fd_key                  varchar2(100 char) := 'HRCO3CB';
  type arr_1d is table of clob index by binary_integer;

  procedure initial_value (json_str in clob);

  procedure runscript (json_str_input in clob, json_str_output out clob) ;
  procedure compile_invalid (json_str_input in clob, json_str_output out clob) ;
  procedure msgerror (json_str_input in clob, json_str_output out clob) ;


end HRCO3CB;

/
