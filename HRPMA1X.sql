--------------------------------------------------------
--  DDL for Package HRPMA1X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMA1X" is
/* Cust-Modify: KOHU-HE2301 */
-- last update: 17/04/2024 09:51 
--ST11 redmine649/SEA-HR2201||03/02/2023||17:16
  param_msg_error         varchar2(4000 char);
  global_v_coduser        varchar2(100 char);
  global_v_codempid       varchar2(100 char);
  global_v_lang           varchar2(10 char) := '102';

  global_v_chken          varchar2(10 char) := hcm_secur.get_v_chken;
  global_chken            varchar2(100 char);
  global_v_zminlvl  	  number;
  global_v_zwrklvl  	  number;
  global_v_numlvlsalst 	  number;
  global_v_numlvlsalen 	  number;
  v_zupdsal   		      varchar2(4 char);

  p_codapp                varchar2(20)  := 'HRPMA1X';
  p_comgrp                tcompgrp.codcodec%type;
  p_codcomp               tcenter.codcomp%type;
  p_staemp                tlistval.list_value%type;
  p_codrep                trepdsph.codrep%type;

  p_showimg               varchar2(5);
  p_table_selected        treport.codtable%type;
  numYearReport           number;

  procedure initial_value(json_str_input in clob);
  procedure get_codrep_detail(json_str_input in clob,json_str_output out clob);
  procedure get_detail(json_str_input in clob,json_str_output out clob);
  procedure get_detail_head_desc(json_str_input in clob,json_str_output out clob);
  procedure gen_detail_head_desc(json_str_output out clob);
  procedure get_list_fields(json_str_input in clob,json_str_output out clob);
  procedure get_format_fields(json_str_input in clob,json_str_output out clob);
-- << KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1799
  procedure post_delete_codrep(json_str_input in clob,json_str_output out clob);
  procedure gen_delete_codrep(json_str_output out clob);
-- >> KOHU-SS2301 | 000537-Boy-Apisit-Dev | 19/03/2024 | issue kohu 4449: #1799
--  procedure gen_style_column (v_objrow in json, v_img varchar2);
  function  get_item_property (p_table in varchar2,p_field  in varchar2) return varchar2;

end hrpma1x;

/
