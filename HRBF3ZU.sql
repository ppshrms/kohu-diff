--------------------------------------------------------
--  DDL for Package HRBF3ZU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF3ZU" is
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

  p_codcomp             temploy1.codcomp%type;
  p_dtestr              date;
  p_dteend              date;
  p_numisr              tchgins1.numisr%type;

  p_codempid_query      temploy1.codempid%type;
  p_dtechng             tchgins1.dtechng%type;
  p_index_rows          json_object_t;

  p_codpos              tpromote.codpos%type;
  p_dtereq              tpromote.dtereq%type;

  p_condition           varchar2(10 char);
  p_stasuccr            tsuccpln.stasuccr%type;
  p_numseq              tsuccpln.numseq%type;
  p_dteposdue           tposempd.dteposdue%type;
  p_codemprq            tpromote.codemprq%type;


  p_selected_rows            json_object_t;
  p_flg                 varchar2(50);

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);
  procedure get_index_approve(json_str_input in clob, json_str_output out clob);
  procedure gen_index_approve(json_str_output out clob);
  procedure get_date(json_str_input in clob, json_str_output out clob);
  procedure send_approve(json_str_input in clob, json_str_output out clob);

  procedure check_index;

  procedure get_change_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_change_detail(json_str_output out clob);
  procedure get_list_insured(json_str_input in clob, json_str_output out clob);
  procedure gen_list_insured(json_str_output out clob);
  procedure get_beneficiary(json_str_input in clob, json_str_output out clob);
  procedure gen_beneficiary(json_str_output out clob);
END; -- Package spec

/
