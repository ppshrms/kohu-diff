--------------------------------------------------------
--  DDL for Package HRAL1KE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL1KE" is

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;

  b_index_codcomp       varchar2(100 char);
  b_index_codcalen      varchar2(10 char);
  b_index_dteeffec      date;

  v_dteeffec            date;
  v_startday            varchar2(2 char);
  v_codcalen            varchar2(10 char);
  v_codcomp             varchar2(100 char);
  --v_numseq              number;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure get_detail2(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob, json_str_output out clob);
--  procedure delete_data(json_str_input in clob, json_str_output out clob);

end HRAL1KE;

/
