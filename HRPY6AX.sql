--------------------------------------------------------
--  DDL for Package HRPY6AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY6AX" is
-- last update: 24/08/2018 16:15

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  p_codapp                  varchar2(100 char) := 'HRPY6AX';
  json_params               json_object_t;
  -- detail
  json_params_maxpay        json_object_t;
  p_codcomp                 varchar2(100 char);
  p_typpayroll              varchar2(100 char);
  p_dteyear                 number;

  p_amtday                  varchar2(100);
  p_amtmon                  varchar2(100);
  isInsertReport            boolean := false;

  procedure get_tab1 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab1 (json_str_output out clob);
  procedure get_tab2 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab2 (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  function save return varchar2;
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure chk_tinexinf (v_code in tinexinf.codpay%type);
  function chk_pctsoc (v_codempid temploy1.codempid%type) return varchar2;
  procedure gen_report(json_str_input in clob,json_str_output out clob);
  function get_date_label (v_numseq number,v_lang varchar2)return varchar2;  
  procedure insert_temp(json_obj json_object_t);
  procedure temp_rpt_header;
end HRPY6AX;

/
