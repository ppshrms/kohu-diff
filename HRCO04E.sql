--------------------------------------------------------
--  DDL for Package HRCO04E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO04E" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  json_params       json_object_t;
  json_params_formlevel json_object_t;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  p_codempid        varchar2(4000);
  p_codcompy        varchar2(4000);
  p_codcomp         varchar2(4000);
  pp_dteeffec       varchar2(4000);

  p_desc_codcomp    varchar2(4000);
  p_naminit         varchar2(4000);
  p_status          varchar2(4000);
  p_costcent        varchar2(4000);
  p_compgrp         varchar2(4000);
  p_codposr         varchar2(4000);
  p_dteeffec        date;
  p_dteappr         date;
  p_codappr         varchar2(4000);
  p_comparent       varchar2(4000);
  p_codcom1         varchar2(4000);
  p_codcom2         varchar2(4000);
  p_codcom3         varchar2(4000);
  p_codcom4         varchar2(4000);
  p_codcom5         varchar2(4000);
  p_codcom6         varchar2(4000);
  p_codcom7         varchar2(4000);
  p_codcom8         varchar2(4000);
  p_codcom9         varchar2(4000);
  p_codcom10        varchar2(4000);
--  p_comlevel        varchar2(4000);
  p_old_codcomp        varchar2(4000);
  p_new_desc_codcomp   varchar2(4000);
  p_new_naminit        varchar2(4000);
  TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  p_text                    data_error;
  p_error_code              data_error;
  p_numseq                  data_error;
  p_comlevel      number;
  p_parent_comlevel   number;
  p_flgtype       varchar2(10);
  p_flgact          tcenter.flgact%type;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure gen_detail_index(json_str_output out clob);
  procedure get_detail_index(json_str_input in clob, json_str_output out clob);
  procedure save_detail_index (json_str_input in clob, json_str_output out clob) ;
  procedure save_detail_tcenter (json_str_input in clob, json_str_output out clob);
  procedure get_detail_tcenter (json_str_input in clob, json_str_output out clob);
  procedure gen_detail_tcenter(json_str_output out clob);
  procedure get_dteeffec_by_codcomp (json_str_input in clob, json_str_output out clob);
--  procedure start_process(json_str_input in clob, json_str_output out clob);
--  procedure start_process_auto;
--  procedure gen_process(json_str_output out clob);
  procedure get_default_tcenter(json_str_input in clob, json_str_output out clob);
  procedure gen_default_tcenter(json_str_output out clob);
  procedure get_tcenter_popup(json_str_input in clob, json_str_output out clob);
  procedure gen_tcenter_popup(json_str_output out clob);
  procedure get_comlevel_name(json_str_input in clob, json_str_output out clob);
  procedure get_comlevel_detail(json_str_input in clob, json_str_output out clob);
  procedure get_import_process(json_str_input in clob, json_str_output out clob);
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);
  procedure get_dropdowns(json_str_input in clob, json_str_output out clob);
  procedure gen_dropdowns(json_str_output out clob);
  procedure save_formlevel (json_str_input in clob, json_str_output out clob);
  
  function get_codcomp_parent (p_codcomp varchar2,p_comlevel number) return varchar2;

end HRCO04E;

/
