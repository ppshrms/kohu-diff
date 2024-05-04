--------------------------------------------------------
--  DDL for Package HCM_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_VALIDATE" is
  param_msg_error         varchar2(4000 char);
  global_v_coduser        varchar2(100 char);
  global_v_codpswd        varchar2(100 char);
  global_v_lang           varchar2(100 char) := '102';

  function check_date (p_date in varchar2) return boolean;
  function check_number (p_number in varchar2) return boolean;
  function check_time (p_time in varchar2) return boolean;
  function check_length (p_item   in varchar2,p_table in varchar2,p_column in varchar2,p_max out number) return boolean;
  function check_tcodcodec(p_table  varchar2,p_where  varchar2)  return boolean;
  function validate_lov(p_codapp in varchar2, p_value in varchar2, p_lang in varchar2) return varchar2;
end;

/
