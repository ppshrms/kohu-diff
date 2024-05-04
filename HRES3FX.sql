--------------------------------------------------------
--  DDL for Package HRES3FX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES3FX" is
-- last update: 15/04/2019 16:01

  param_msg_error     varchar2(4000 char);

  global_v_coduser    varchar2(100 char);
  global_v_codpswd    varchar2(100 char);
  global_v_lang       varchar2(10 char) := '102';

  b_index_codempid    varchar2(4000 char);
  b_index_dtest       date;
  b_index_dteen       date;
  b_index_codcomp     varchar2(4000 char);
  b_index_dteeffec    date;
  b_index_numseq      number;
  ctrl_codcomp        varchar2(4000 char);

  procedure initial_value(json_str in clob);
  procedure check_index;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_data(json_str_output out clob);
  procedure get_popup(json_str_input in clob, json_str_output out clob);
  procedure gen_popup(json_str_output out clob);

END; -- Package spec

/
