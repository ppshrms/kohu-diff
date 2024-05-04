--------------------------------------------------------
--  DDL for Package HRESH2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRESH2X" as 

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  p_zupdsal                 varchar2(100 char);

  p_codempid_query          tobfsum.codempid%type;
  p_dteyrest                tobfsum.dteyre%type;
  p_dteyreen                tobfsum.dteyre%type;
  p_flginput                varchar2(1 char);
  p_dteyre                  tobfsum.dteyre%type;
  p_dtemth                  tobfsum.dtemth%type;
  p_codobf                  tobfsum.codobf%type;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_tobfinf (json_str_input in clob, json_str_output out clob);
  procedure gen_tobfinf (json_str_output out clob);
end hresh2x;

/
