--------------------------------------------------------
--  DDL for Package HRES7OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES7OE" is
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
  p_registeren              varchar2(10 char);
  p_registerst              varchar2(10 char);
  p_latitude                thotelif.latitude%type;
  p_longitude               thotelif.longitude%type;
--  p_accuracy                

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure post_save_checkin(json_str_input in clob,json_str_output out clob);

END; -- Package spec

/
