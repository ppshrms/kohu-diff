--------------------------------------------------------
--  DDL for Package HRES84X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES84X" is
-- last update: 26/07/2016 13:16
  param_msg_error     varchar2(4000 char);

  v_chken           varchar2(10 char) := hcm_secur.get_v_chken;
  v_zyear           number;
  global_v_coduser  varchar2(100 char);
  global_v_codpswd  varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  global_v_codcomp  tcenter.codcomp%type ;
  global_v_codpaypy1 tinexinf.codpay%type;
  global_v_lrunning varchar2(10 char);
  global_v_key      varchar2(4000 char);

  b_index_codempid  varchar2(4000 char);
  b_index_dteyrepay number;

  v_view_codapp     varchar2(100 char);

  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);

END; -- Package spec

/
