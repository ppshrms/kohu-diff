--------------------------------------------------------
--  DDL for Package HRES79E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES79E" is
-- last update: 22/02/2022 14:00
  param_msg_error     varchar2(4000 char);

  global_v_coduser          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  b_index_dtereq_st         date;
  b_index_dtereq_en         date;
  p_dtereq                  tatkpcr.dtereq%type;
  p_dtetest                 tatkpcr.dtetest%type;
  p_numseq                  tatkpcr.numseq%type;
  p_typetest                tatkpcr.typetest%type;
  p_result                  tatkpcr.result%type;
  p_remark                  tatkpcr.remark%type;
  p_filename                tatkpcr.filename%type;
  p_param_json                json_object_t;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail_create(json_str_input in clob, json_str_output out clob);
  procedure gen_detail_create (json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  
  procedure post_save(json_str_input in clob,json_str_output out clob);
  procedure save_tatkpcr(json_str_input in clob,json_str_output out clob);
  
  procedure post_delete(json_str_input in clob, json_str_output out clob);

END; -- Package spec

/
