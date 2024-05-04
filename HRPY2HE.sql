--------------------------------------------------------
--  DDL for Package HRPY2HE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY2HE" as

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
  p_codcomp                 temploy1.codcomp%type;
  p_codlegald               tlegalexe.codlegald%type;
  p_dtemthpay               tlegalprd.dtemthpay%type;
  p_dteyrepay               tlegalprd.dteyrepay%type;

--  -- get parameter json table
--  p_codempid                tlegalprd.codempid%type;
--  p_numtime                 tlegalprd.numtime%type;
--  p_amtded                  tlegalprd.amtded%type;
--  p_dtepay                  tlegalprd.dtepay%type;
--  p_typpaymt                tlegalprd.typpaymt%type;
--  p_numref                  tlegalprd.numref%type;

  procedure initial_value (json_str in clob);
--  procedure check_date;
  procedure check_index;
  --
  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  --
  procedure save_index(json_str_input in clob, json_str_output out clob);
end HRPY2HE;

/
