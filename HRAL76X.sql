--------------------------------------------------------
--  DDL for Package HRAL76X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL76X" is
-- last update: 08/05/2019 16:15

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

  p_codapp                  varchar2(100 char) := 'HRAL76X';
  -- index
  p_codcomp                 varchar2(100 char);
  p_comgrp                  tcenter.compgrp%type;
  p_typpayroll              tpaysum.typpayroll%type;
  p_codrep                  tinitregh.codrep%type;
  p_namrep                  tinitregh.descode%type;
  p_namrepe                 tinitregh.descode%type;
  p_namrept                 tinitregh.descodt%type;
  p_namrep3                 tinitregh.descod3%type;
  p_namrep4                 tinitregh.descod4%type;
  p_namrep5                 tinitregh.descod5%type;
  p_typcode                 varchar2(1 char);

  p_codempid                tpaysum.codempid%type;
  p_flgtransfer             tpaysum.flgtran%type;
  p_flgrpttype              varchar2(1 char);


  -- detail
  p_dteyrepay               number;
  p_dtemthpay               number;
  p_numperiod               number;

  p_codinc                  json_object_t;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_codpay (json_str_input in clob, json_str_output out clob);
  procedure gen_codpay (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
end HRAL76X;

/
