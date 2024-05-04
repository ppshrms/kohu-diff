--------------------------------------------------------
--  DDL for Package HCM_TEMPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_TEMPLATE" is

  param_msg_error    varchar2(4000 char);
  v_error            varchar2(10) := 'ERROR';
  global_v_lang      varchar2(100 char) := '102';

  p_codapp           varchar2(4000 char);

  procedure get_tinitial(json_str_input in clob,json_str_output out clob);
  procedure get_tfolder(json_str_input in clob,json_str_output out clob);
end;

/
