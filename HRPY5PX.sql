--------------------------------------------------------
--  DDL for Package HRPY5PX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5PX" is
-- last update: 24/08/2018 16:15

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  p_codapp                  varchar2(100 char) := 'HRPY5PX';
  -- index
  p_codcomp                 varchar2(100 char);
  p_comgrp                  varchar2(100 char);
  p_typpayroll              varchar2(100 char);
  p_codrep                  varchar2(4 char);
  p_namrep                  varchar2(150 char);
  p_namrepe                 varchar2(150 char);
  p_namrept                 varchar2(150 char);
  p_namrep3                 varchar2(150 char);
  p_namrep4                 varchar2(150 char);
  p_namrep5                 varchar2(150 char);
  p_typcode                 varchar2(1 char);

  -- detail
  p_dteyrepay               number;
  p_dtemthpay               number;
  p_numperiod               number;

  p_codinc                  json_object_t;
  p_codded                  json_object_t;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_codpay (json_str_input in clob, json_str_output out clob);
  procedure gen_codpay (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
end HRPY5PX;

/
