--------------------------------------------------------
--  DDL for Package HCM_GRAPH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_GRAPH" AS
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';

  procedure get_hcm_graph_params(json_str_input in clob, json_str_output out clob);

  procedure get_hcm_graph(json_str_input in clob, json_str_output out clob);
  procedure get_hcm_graph_multi_chart(json_str_input in clob, json_str_output out clob);

END HCM_GRAPH;

/
