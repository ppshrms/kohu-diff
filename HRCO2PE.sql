--------------------------------------------------------
--  DDL for Package HRCO2PE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2PE" is
-- last update: 09/02/2021 14:01 #2331

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  json_params               json_object_t;
  -- index

--  p_codcompy        varchar2(4000);
--  p_desc_codcomp    varchar2(4000);
--  p_codcomp         varchar2(4000);
--  p_naminit         varchar2(4000);
--  p_status          varchar2(4000);
--  p_costcent        varchar2(4000);
--  p_compgrp         varchar2(4000);
--  p_codposr         varchar2(4000);
--  p_dteeffec        date;
  p_dteappr         date;
  p_codappr         varchar2(4000);
--  p_comparent       varchar2(4000);
--  p_codcom1         varchar2(4000);
--  p_codcom2         varchar2(4000);
--  p_codcom3         varchar2(4000);
--  p_codcom4         varchar2(4000);
--  p_codcom5         varchar2(4000);
--  p_codcom6         varchar2(4000);
--  p_codcom7         varchar2(4000);
--  p_codcom8         varchar2(4000);
--  p_codcom9         varchar2(4000);
--  p_codcom10        varchar2(4000);
--  p_comlevel        varchar2(4000);
--  p_old_codcomp        varchar2(4000);
--  p_new_desc_codcomp   varchar2(4000);
--  p_new_naminit        varchar2(4000);

  p_numseq          varchar2(2);
  p_codapp          varchar2(100);
  p_codappap        varchar2(100);
  p_codform         varchar2(100);
  p_codformno       varchar2(100);

  --index
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  --detail table
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  
  procedure get_detail2 (json_str_input in clob, json_str_output out clob);
  procedure gen_detail2 (json_str_output out clob);
  
  procedure get_detail_table(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_table(json_str_output out clob) ;

  -- save detail
  procedure save_detail(json_str_input in clob, json_str_output out clob) ;
  procedure save_detail2(json_str_input in clob, json_str_output out clob) ;
  procedure save_index_tfwmailh (json_str_input in clob, json_str_output out clob);
--  procedure save_tfwmailh (json_str_input in clob, json_str_output out clob);
--  procedure save_index_tfwmailc (json_str_input in clob, json_str_output out clob) ;
--  procedure save_tfwmailc (json_str_input in clob, json_str_output out clob) ;
--  procedure get_tfwmailc_detail (json_str_input in clob, json_str_output out clob) ;
--  procedure gen_tfwmailc_detail (json_str_output out clob) ;
--  procedure get_index_tfwmaild(json_str_input in clob, json_str_output out clob) ;
--  procedure gen_index_tfwmaild(json_str_output out clob) ;
--  procedure save_index_tfwmaild (json_str_input in clob, json_str_output out clob) ;

  procedure get_list_flgappr(json_str_input in clob, json_str_output out clob);


end HRCO2PE;

/
