--------------------------------------------------------
--  DDL for Package HRPY5XX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5XX" as

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);


  p_codcomp                 varchar2(100 char);
  p_typpayroll              varchar2(100 char);
  p_coddeduct               json_object_t;
  p_file_dir                varchar2(4000 char) := 'UTL_FILE_DIR';
  p_file_path               varchar2(4000 char) := get_tsetup_value('PATHEXCEL');
  v_codapp                  varchar2(100 char) := 'HRPY5XX';
  --v_codempid                varchar2(100 char);

  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_deduct(json_str_input in clob, json_str_output out clob);
  procedure get_textfile(json_str_input in clob, json_str_output out clob);
  procedure gen_textfile(json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);

end HRPY5XX;

/
