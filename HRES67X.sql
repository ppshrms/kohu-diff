--------------------------------------------------------
--  DDL for Package HRES67X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES67X" AS

 param_msg_error     varchar2(4000 char);

  v_chken           varchar2(10 char) := hcm_secur.get_v_chken;
  v_zyear           number;
  global_v_coduser  varchar2(100 char);
  global_v_codpswd  varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  global_v_codempid      varchar2(100 char);

  b_index_codempid  varchar2(4000 char);
  b_index_stdate    date;
  b_index_endate    date;
  b_index_total     varchar2(4000 char);
  p_start           varchar2(4000 char);
  p_end             varchar2(4000 char);
  p_limit           varchar2(4000 char);

  v_view_codapp     varchar2(100 char);

  procedure initial_value(json_str in clob);
  procedure check_index;
  --tab1
  procedure get_index_tab1(json_str_input in clob, json_str_output out clob);
  procedure gen_data_tab1(json_str_output out clob);

  --tab2
  procedure get_index_tab2(json_str_input in clob, json_str_output out clob);
  procedure gen_data_tab2(json_str_output out clob);

  --tab3
  procedure get_index_tab3(json_str_input in clob, json_str_output out clob);
  procedure gen_data_tab3(json_str_output out clob);

  --tab4
  procedure get_index_tab4(json_str_input in clob, json_str_output out clob);
  procedure gen_data_tab4(json_str_output out clob);

  function  call_formattime(ptime varchar2) return varchar2;

END HRES67X;

/
