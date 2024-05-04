--------------------------------------------------------
--  DDL for Package HRCO18E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO18E" AS

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

  TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  p_text                    data_error;
  p_error_code              data_error;
  p_numseq                  data_error;
  p_count                   number;
  p_rowid                   varchar2(20 char);
  p_flg                     varchar2(10 char);
  /*competency*/
  p_codtency                varchar2(10 char);
  p_namtncy                 varchar2(150 char);
  p_namtncye                varchar2(150 char);
  p_namtncyt                varchar2(150 char);
  p_namtncy3                varchar2(150 char);
  p_namtncy4                varchar2(150 char);
  p_namtncy5                varchar2(150 char);

  p_codskill                 varchar2(10 char);
  p_descod                  varchar2(150 char);
  p_descode                 varchar2(150 char);
  p_descodt                 varchar2(150 char);
  p_descod3                 varchar2(150 char);
  p_descod4                 varchar2(150 char);
  p_descod5                 varchar2(150 char);

  p_grade                  number;
  p_namgrad                varchar2(150 char);
  p_namgrade               varchar2(150 char);
  p_namgradt               varchar2(150 char);
  p_namgrad3               varchar2(150 char);
  p_namgrad4               varchar2(150 char);
  p_namgrad5               varchar2(150 char);
  /* TODO enter package declarations (types, exceptions, methods etc) here */
  procedure get_tcomptnc(json_str_input in clob, json_str_output out clob);
  procedure get_tcompskil(json_str_input in clob, json_str_output out clob);
  procedure get_tcomptnc_detail(json_str_input in clob,json_str_output out clob);
  procedure get_tcompskil_detail(json_str_input in clob,json_str_output out clob);
  procedure get_gradskil(json_str_input in clob, json_str_output out clob);
  procedure delete_tcomptnc(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure save_tcompskil(json_str_input in clob, json_str_output out clob);
  procedure get_import_process(json_str_input in clob, json_str_output out clob);
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);

END HRCO18E;

/
