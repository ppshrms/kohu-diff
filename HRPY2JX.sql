--------------------------------------------------------
--  DDL for Package HRPY2JX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY2JX" as

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  -- get parameter search index
  p_codapp                  varchar2(500 char) := 'HRPY2JX';
  isInsertReport            boolean := false;
  p_codempid                tlegalprd.codempid%type;
  p_dtepayst                tlegalprd.dtepay%type;
  p_dtepayen                tlegalprd.dtepay%type;
  p_data                    json_object_t;
  p_codlegald                tlegalexe.codlegald%type;
  p_codlegald_x                 tlegalexe.codlegald%type;

  procedure initial_value (json_str in clob);
  procedure check_index;
  --
  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  procedure clear_ttemprpt;
  procedure get_report(json_str_input in clob,json_str_output out clob);
  procedure insert_ttemprpt_data(obj_data in json_object_t);
end HRPY2JX;

/
