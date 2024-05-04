--------------------------------------------------------
--  DDL for Package HRAP3KX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP3KX" is
-- last update: 10/08/2020 13:45

  v_chken               varchar2(100 char);
  param_msg_error       varchar2(4000 char);

  global_v_coduser      varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '101';

  b_index_codcomp       tcenter.codcomp%type;
  b_index_dteyreap      number;
  b_index_typpayroll    varchar2(100 char);
  b_index_periodpay     number;
  b_index_dtemthpay     number;
  b_index_dteyrepay     number;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure check_index(json_str_output out clob);
END; -- Package spec

/
