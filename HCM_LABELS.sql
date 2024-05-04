--------------------------------------------------------
--  DDL for Package HCM_LABELS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LABELS" is
-- last update: 01/12/2017 13:57
  global_v_coduser    varchar2(100 char);
  global_v_codpswd    varchar2(100 char);
  global_v_lang       varchar2(10 char) := '102';
  param_msg_error     varchar2(4000 char);

  function get_labels(json_str_input clob) return clob;
end;

/
