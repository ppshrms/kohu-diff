--------------------------------------------------------
--  DDL for Package HRPY23E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY23E" is
-- last update: 17/09/2018 16:30

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
  v_zupdsal                 varchar2(4 char);

  p_numperiod               number;
  p_dtemthpay               number;
  p_dterepay                number;
  p_codempid                varchar2(100 char);
  p_codcomp                 varchar2(100 char);

  p_qtypayda                number;
  p_qtypayhr                number;
  p_qtypaysc                number;

  forceAdd                  varchar2(1 char) := 'N';
  v_flgadd                  boolean := false;

  json_input_obj            json_object_t;

  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_tab1 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab1 (json_str_output out clob);
  procedure get_tab2 (json_str_input in clob, json_str_output out clob);
  procedure gen_tab2 (json_str_output out clob);

  procedure save_detail (json_str_input in clob, json_str_output out clob);
  procedure save_tab1 (json_str_output out clob);
  procedure save_tab2 (json_str_output out clob);

  procedure get_codcenter(json_str_input in clob, json_str_output out clob);
  procedure get_amtpay(json_str_input in clob, json_str_output out clob);
  procedure check_lov_codpay (p_codcodec varchar2);
  procedure check_dtepay (p_codpay varchar2);


end HRPY23E;

/
