--------------------------------------------------------
--  DDL for Package HRRP64X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRP64X" is
-- last update: 15/09/2020 17:30 

  v_chken                   varchar2(100 char);
  param_msg_error       varchar2(4000 char);
  global_v_coduser        varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst    number;
  global_v_numlvlsalen 	  number;
  v_zupdsal                 varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang            varchar2(10 char) := '102';

  --block b_index
  b_index_grpcompy    thisorg.codcompy%TYPE;
  b_index_codcompy    thisorg.codcompy%TYPE;
  b_index_codlinef        thisorg.codlinef%TYPE;  
  b_index_year1          number;
  b_index_year2          number;
  b_index_year3          number;

  --block drilldown
  b_index_codcompp    tcenter.codcomp%type;
  b_index_dteeffec       date;

  procedure initial_value(json_str in clob);
  procedure check_index ;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_input in clob, json_str_output out clob);

  procedure get_chart (json_str_input in clob,json_str_output out clob);
  procedure gen_chart (json_str_output out clob);
END; -- Package spec

/
