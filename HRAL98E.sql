--------------------------------------------------------
--  DDL for Package HRAL98E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL98E" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';

  b_index_typmatch  varchar2(500 char);
  p_typmatch        varchar2(500 char);
  p_nammatch        varchar2(500 char);
  p_codest          number;
  p_codeen          number;
  p_flagst          number;
  p_flagen          number;
  p_dayst           number;
  p_dayen           number;
  p_monthst         number;
  p_monthen         number;
  p_yearst          number;
  p_yearen          number;
  p_hourst          number;
  p_houren          number;
  p_minst           number;
  p_minen           number;
  p_mchnost         number;
  p_mchnoen         number;
  p_codrecin        varchar2(10 char);
  p_codrecout       varchar2(10 char);
  p_pathfrom        varchar2(200 char);
  p_pathto          varchar2(200 char);
  p_patherror       varchar2(200 char);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
  procedure delete_data(json_str_input in clob, json_str_output out clob);

end HRAL98E;

/
