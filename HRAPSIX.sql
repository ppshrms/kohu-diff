--------------------------------------------------------
--  DDL for Package HRAPSIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAPSIX" is
-- last update: 19/08/2020 11:00
  v_chken               varchar2(100 char);
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
	global_v_zyear		    number := 0;
  v_zupdsal             varchar2(4000 char);
  v_numseq              number := 1;
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  --block b_index
  b_index_codcomp    varchar2(4000 char);
  b_index_sql        varchar2(4000 char);
  b_index_dteyear1   varchar2(4000 char);
  b_index_dteyear2   varchar2(4000 char);
  b_index_dteyear3   varchar2(4000 char);

  b_index_v_grp1     varchar2(4000 char);
  b_index_v_grp2     varchar2(4000 char);
  b_index_v_grp3     varchar2(4000 char);

  b_index_v_graph1     varchar2(4000 char);
  b_index_v_graph2     varchar2(4000 char);

  --block drilldown
  b_index_codpos      varchar2(4000 char);

  --
  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);

  procedure gen_graph;
  procedure gen_graph2;
  procedure get_list_comlevel(json_str_input in clob, json_str_output out clob);
  procedure msg_err2(p_error in varchar2);
END; -- Package spec

/
