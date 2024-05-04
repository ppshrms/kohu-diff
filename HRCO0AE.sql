--------------------------------------------------------
--  DDL for Package HRCO0AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO0AE" AS

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl  		    number;
  global_v_zwrklvl  		    number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  p_flg                     varchar2(10 char);

  p_codjobgrp               varchar2(10 char);
  p_namjobgrp               varchar2(150 char);
  p_namjobgrpe              varchar2(150 char);
  p_namjobgrpt              varchar2(150 char);
  p_namjobgrp3              varchar2(150 char);
  p_namjobgrp4              varchar2(150 char);
  p_namjobgrp5              varchar2(150 char);

  p_codtency                varchar2(4 char);
  p_namtncy                 varchar2(150 char);
  p_namtncye                varchar2(150 char);
  p_namtncyt                varchar2(150 char);
  p_namtncy3                varchar2(150 char);
  p_namtncy4                varchar2(150 char);
  p_namtncy5                varchar2(150 char);
  p_codskill                varchar2(10 char);
  p_old_codskil             varchar2(10 char);


  TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  p_text                    data_error;
  p_error_code              data_error;
  p_numseq                  data_error;


  procedure get_tcodjobgrp(json_str_input in clob, json_str_output out clob);
  procedure get_import_process(json_str_input in clob, json_str_output out clob);
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);
  procedure delete_tcodjobgrp(json_str_input in clob, json_str_output out clob);
  procedure get_codjobgrp(json_str_input in clob, json_str_output out clob);
  procedure get_tcodjobgrp_detail(json_str_input in clob,json_str_output out clob);
  procedure get_tcomptnc_detail(json_str_input in clob,json_str_output out clob);
  procedure get_tcompskil(json_str_input in clob, json_str_output out clob);
  procedure save_tcodjobgrp(json_str_input in clob, json_str_output out clob);
  procedure save_tjobgroup(json_str_input in clob, json_str_output out clob);


END HRCO0AE;

/
