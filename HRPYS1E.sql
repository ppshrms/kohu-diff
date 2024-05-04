--------------------------------------------------------
--  DDL for Package HRPYS1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPYS1E" as
  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codempid     varchar2(100 char);
  global_v_lang         varchar2(10 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  global_v_chken        varchar2(4000 char);
  v_zupdsal     		    varchar2(4 char);

  p_year        number;
  p_codgrbug    tcodgrbug.codcodec%type;
  p_codpay      tinexinf.codpay%type;
  param_json    json_object_t;
  p_syncond     varchar2(4000 char);
  p_statement   clob;
  p_month1      number;
  p_month2      number;
  p_month3      number;
  p_month4      number;
  p_month5      number;
  p_month6      number;
  p_month7      number;
  p_month8      number;
  p_month9      number;
  p_month10     number;
  p_month11     number;
  p_month12     number;

  procedure initial_value (json_str_input in clob);

  procedure check_index;
  procedure get_index(json_str_input in clob,json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure check_process;
  procedure get_process(json_str_input in clob,json_str_output out clob);
  procedure gen_process(json_str_output out clob);

  procedure check_save;
  procedure post_save(json_str_input in clob,json_str_output out clob);
  procedure save_data(json_str_output out clob);

  procedure check_delete;
  procedure post_delete(json_str_input in clob,json_str_output out clob);
  procedure delete_data(json_str_output out clob);

  procedure get_last_budget(json_str_input in clob,json_str_output out clob);
end hrpys1e;

/
