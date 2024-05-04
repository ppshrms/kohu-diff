--------------------------------------------------------
--  DDL for Package HRPY2AE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY2AE" is

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
  global_v_zupdsal          varchar2(10 char);

  p_codcomp                 varchar2(1000 char);
  p_codempid                varchar2(1000 char);
  p_codempid2                varchar2(1000 char);
  p_dteyrepay               number;
  p_dtemthpay               number;
  p_numperiod               number;

  p_costcent                varchar2(1000 char);
  p_codpay                  varchar2(10 char);
  p_amtpay                  number;
  p_flgcharge               varchar2(1 char);

  procedure initial_value (json_str in clob);
  procedure check_index;
  procedure check_save_index(v_codcomp varchar2);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure get_codcenter(json_str_input in clob, json_str_output out clob);

  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure get_detail1(json_str_input in clob, json_str_output out clob);
  procedure gen_detail1(json_str_output out clob);
  procedure get_detail2(json_str_input in clob, json_str_output out clob);
  procedure gen_detail2(json_str_output out clob);

  procedure save_index(json_str_input in clob, json_str_output out clob);

end HRPY2AE;

/
