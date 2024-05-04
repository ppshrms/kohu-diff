--------------------------------------------------------
--  DDL for Package HRCO03E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO03E" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  json_params               json_object_t;

  p_codapp                  tappprof.codapp%type;
  p_codproc                 tappprof.codproc%type;


  p_codcompy        varchar2(4000);
  p_desc_codcomp    varchar2(4000);
  p_codcomp         varchar2(4000);
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
  p_comlevel        varchar2(4000);
  p_old_codcomp        varchar2(4000);
  p_new_desc_codcomp   varchar2(4000);
  p_new_naminit        varchar2(4000);

  p_numseq           varchar2(10);
  p_qtycode          varchar2(1);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure get_flgdisable (json_str_input in clob, json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_detail_index(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_index(json_str_output out clob);
  procedure save_detail_index (json_str_input in clob, json_str_output out clob);
  procedure save_tsetcomp (json_str_input in clob, json_str_output out clob) ;

end HRCO03E;

/
