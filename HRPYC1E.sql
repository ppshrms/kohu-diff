--------------------------------------------------------
--  DDL for Package HRPYC1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPYC1E" as

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';

  param_json        json_object_t;
  -- index
  p_codcompy        varchar2(4 char);
  p_typretmt        varchar2(4 char);
  p_flgretire       varchar2(4 char);
  p_dteeffec        date;


  procedure get_flg_status (json_str_input in clob, json_str_output out clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);

end HRPYC1E;

/
