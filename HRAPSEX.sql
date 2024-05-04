--------------------------------------------------------
--  DDL for Package HRAPSEX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAPSEX" is
-- last update: 19/08/2020 18:02
  v_chken               varchar2(100 char);
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  v_numseq              number := 1;
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  --block b_index
  b_index_codcomp    tcenter.codcomp%type;
  b_index_codbon     tbonus.codbon%type;
  b_index_numtime    tbonus.numtime%type;

  b_index_dteyear1   tbonus.dteyreap%type;
  b_index_dteyear2   tbonus.dteyreap%type;
  b_index_dteyear3   tbonus.dteyreap%type;
  b_index_typeof     varchar2(1 char);

  --block drilldown
  b_index_codpos      temploy1.codpos%type;
  b_index_codcompy    tcenter.codcompy%type;
  --
  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);
  procedure get_data_sumary(v_year in varchar2, v_grade in varchar2, v_numcond in number,
                            v_desc out varchar2,
                            v_qty_policy out number,
                            v_qty_actual out number);
  procedure gen_graph;
  procedure gen_graph2;

END; -- Package spec

/
