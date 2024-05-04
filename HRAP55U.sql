--------------------------------------------------------
--  DDL for Package HRAP55U
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP55U" is
-- last update: 07/08/2020 09:40

  v_chken               varchar2(100 char);

  param_msg_error       varchar2(4000 char);
  param_msg_error_mail  varchar2(4000 char);

  global_v_coduser      varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_codempid     temploy1.codempid%type;
  global_v_lang         varchar2(10 char) := '102';
  global_v_chken        varchar2(10 char) := hcm_secur.get_v_chken;

  p_dteyreap            tbonus.dteyreap%type;
  p_numtime             tbonus.numtime%type;
  p_codcomp             tbonus.codcomp%type;
  p_codbon              tbonus.codbon%type;
  p_codempid_query      tappempta.codempid%type;

  p_index_rows          json_object_t;

  p_selected_rows       json_object_t;
  p_flg                 varchar2(50);
  v_check               varchar2(500 char);

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_tappempta(json_str_input in clob, json_str_output out clob);
  procedure gen_tappempta(json_str_output out clob);

  procedure get_tappempmt(json_str_input in clob, json_str_output out clob);
  procedure gen_tappempmt(json_str_output out clob);

  procedure get_index_popup(json_str_input in clob, json_str_output out clob);
  procedure gen_index_popup(json_str_output out clob);

  procedure get_index_approve(json_str_input in clob, json_str_output out clob);
  procedure gen_index_approve(json_str_output out clob);

  procedure send_approve(json_str_input in clob, json_str_output out clob);

  procedure check_index;

END; -- Package spec

/
