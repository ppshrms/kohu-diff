--------------------------------------------------------
--  DDL for Package HRPY59R
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY59R" as

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
  p_dtemthpay               ttaxcur.dtemthpay%type;
  p_dteyrepay               ttaxcur.dteyrepay%type;
  p_codbrsoc                tcodsoc.codbrsoc%type;
  p_typpayroll              ttaxcur.typpayroll%type;
  p_typreport               varchar2(1 char);

  function get_date_label (v_numseq number,v_lang varchar2)return varchar2;
  function get_label (v_codapp varchar2,v_lang varchar2,v_numseq number) return varchar2;
  function get_name_report (v_lang varchar2,v_appl varchar2)return varchar2;
  procedure del_temp(v_codapp varchar2,v_coduser varchar2);
  procedure initial_value (json_str in clob);
  procedure check_index;
  --
  procedure get_data (json_str_input in clob, json_str_output out clob);
  procedure gen_data (json_str_output out clob);
  procedure temp_report;
  procedure insert_temp(json_obj json_object_t);
end HRPY59R;

/
