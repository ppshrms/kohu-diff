--------------------------------------------------------
--  DDL for Package HRAP4DE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP4DE" is

  param_msg_error           varchar2(4000 char);

  b_index_dteyreap          tkpicmphs.dteyreap%type;
  b_index_numtime           tkpicmphs.numtime%type;
  b_index_codcompy          tkpicmphs.codcompy%type;
  p_codkpi                  tkpicmppl.codkpi%type;
  p_codeva                  tkpicmphs.codeva%type;
  p_dteeva                  tkpicmphs.dteeva%type;
  p_codappr                 tkpicmphs.codappr%type;
  p_dteappr                 tkpicmphs.dteappr%type;

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);

  procedure post_detail(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob);

end hrap4de;

/
