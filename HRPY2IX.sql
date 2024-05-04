--------------------------------------------------------
--  DDL for Package HRPY2IX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY2IX" as

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
  p_codapp                  varchar2(100 char) := 'HRPY5HX';

  -- get parameter search index
  p_codcomp                 temploy1.codcomp%type;
  p_codlegald               tlegalexe.codlegald%type;
  p_codlegald_x             tlegalexe.codlegald%type;
  p_dtemthpay               tlegalprd.dtemthpay%type;
  p_dteyrepay               tlegalprd.dteyrepay%type;
  p_data                    json_object_t;

  isInsertReport            boolean := false;
  procedure initial_value (json_str in clob);
  procedure check_index;
  --
  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  procedure clear_ttemprpt;
  procedure get_report(json_str_input in clob,json_str_output out clob);
  procedure insert_ttemprpt_data(obj_data in json_object_t);
end HRPY2IX;

/
