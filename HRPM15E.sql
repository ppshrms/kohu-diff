--------------------------------------------------------
--  DDL for Package HRPM15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM15E" is
-- last update: 04/03/2019 11:25
  param_msg_error       varchar2(4000 char);
  v_chken               varchar2(10 char);
  global_v_coduser      varchar2(100 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zyear        number := 0;
  global_v_lrunning     varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;

  p_codcompy    varchar2(100 char);
  p_coduser     tsempidh.coduser%type;
  p_codempid    tsempidh.coduser%type;
  p_lang        varchar2(5 char);
  p_groupid     tsempidh.groupid%type;
  p_dteeffec    date;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure get_search (json_str_input in clob, json_str_output out clob);
  procedure delete_data (json_str_input in clob, json_str_output out clob);
  procedure save_data (json_str_input in clob, json_str_output out clob);

end HRPM15E;

/
