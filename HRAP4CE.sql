--------------------------------------------------------
--  DDL for Package HRAP4CE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP4CE" is

  param_msg_error           varchar2(4000 char);

  b_index_dteyreap          tkpidph.dteyreap%type;
  b_index_numtime           tkpidph.numtime%type;
  b_index_codcomp           tkpidph.codcomp%type;
  p_codkpino                tkpidph.codkpino%type;
  p_codeva                  tkpidph.codeva%type;
  p_dteeva                  tkpidph.dteeva%type;
  p_codappr                 tkpidph.codappr%type;
  p_dteappr                 tkpidph.dteappr%type;

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4000 char);

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);

  procedure post_detail(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob);

end hrap4ce;

/
