--------------------------------------------------------
--  DDL for Package HRRC24X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC24X" is

  param_msg_error         varchar2(4000 char);
  global_v_coduser        varchar2(100 char);
  global_v_codempid       varchar2(100 char);
  global_v_lang           varchar2(10 char) := '102';

  global_v_chken          varchar2(10 char) := hcm_secur.get_v_chken;
  global_chken            varchar2(100 char);
  global_v_zminlvl  	    number;
  global_v_zwrklvl  	    number;
  global_v_numlvlsalst 	  number;
  global_v_numlvlsalen     number;
  v_zupdsal               varchar2(4 char);

  p_codapp                varchar2(20)  := 'HRRC24X';
  p_codrep                trepdsph.codrep%type;
  p_dtestrt               varchar2(100 char);
  p_dteend                varchar2(100 char);

  p_table_selected        treport.codtable%type;
  numYearReport           number;

  procedure initial_value(json_str_input in clob);
  procedure get_codrep_detail(json_str_input in clob,json_str_output out clob);
  procedure gen_codrep_detail(json_str_output out clob);
  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure get_list_fields(json_str_input in clob,json_str_output out clob);
  procedure gen_list_fields(json_str_output out clob);
  procedure get_dropdown_list(json_str_input in clob,json_str_output out clob);
  procedure gen_dropdown_list(json_str_output out clob);
  procedure get_format_fields(json_str_input in clob,json_str_output out clob);
  function  get_item_property (p_table in varchar2,p_field  in varchar2) return varchar2;

end HRRC24X;

/
