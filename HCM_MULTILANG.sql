--------------------------------------------------------
--  DDL for Package HCM_MULTILANG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_MULTILANG" as 

  /* TODO enter package declarations (types, exceptions, methods etc) here */ 
  global_v_coduser    varchar2(100 char);
  global_v_codpswd    varchar2(100 char);
  global_v_lang       varchar2(10 char) := '102';
  param_msg_error     varchar2(4000 char);

  function get_multilang(json_str_input clob) return clob;
end hcm_multilang;

/
