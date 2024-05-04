--------------------------------------------------------
--  DDL for Package HRESH6E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRESH6E" is
-- last update: 26/07/2016 13:16
  param_msg_error     varchar2(4000 char);

  v_chken                   varchar2(10 char) := hcm_secur.get_v_chken;
  v_zyear                   number;
  global_v_coduser          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codcomp          tcenter.codcomp%type ;
  global_v_codpaypy1        tinexinf.codpay%type;
  global_v_lrunning         varchar2(10 char);
  global_v_key              varchar2(4000 char);

  param_json                json_object_t;

  p_codempid_query          temploy1.codempid%type;
  p_dteyreap                tobjemp.dteyreap%type;
  p_numtime                 tobjemp.numtime%type;


  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure post_save_detail(json_str_input in clob,json_str_output out clob);

END; -- Package spec

/
