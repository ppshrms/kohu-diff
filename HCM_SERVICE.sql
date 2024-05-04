--------------------------------------------------------
--  DDL for Package HCM_SERVICE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_SERVICE" is

  global_v_coduser    varchar2(100 char);
  global_v_codempid   varchar2(100 char);
  global_v_lang       varchar2(10 char) := '102';
  param_msg_error     varchar2(4000 char);

  function get_numseq(json_str in clob) return varchar2;
  function get_empname(json_str in clob) return varchar2;
end;

/
