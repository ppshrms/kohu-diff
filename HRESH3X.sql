--------------------------------------------------------
--  DDL for Package HRESH3X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRESH3X" as 

  param_msg_error         varchar2(4000 char);
  global_v_coduser        varchar2(100 char);
  global_v_codempid       varchar2(100 char);
  global_v_lang           varchar2(10 char) := '102';
  global_v_zminlvl        number;
  global_v_zwrklvl        number;
  global_v_numlvlsalst    number;
  global_v_numlvlsalen    number;

  v_zupdsal               varchar2(4 char);
  p_codapp                varchar2(10 char) := 'HRBF1GX';
  p_codempid              tclnsinf.codempid%type;
  p_monreqst              varchar2(2 char);
  p_yeareqst              varchar2(4 char);
  p_monreqen              varchar2(2 char);
  p_yeareqen              varchar2(4 char);

  procedure initial_value(json_str_input in clob);

  procedure get_index_medical (json_str_input in clob, json_str_output out clob);
  procedure gen_index_medical (json_str_output out clob);
  
end hresh3x;

/
