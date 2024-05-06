--------------------------------------------------------
--  DDL for Package HRPY5BU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY5BU" as 

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

  p_codapp          varchar2(10 char) := 'HRPY5BU';
  p_codcompy        tdedlnslf.codcompy%type;
  p_dtemthpay       tdedlnslf.dtemthpay%type;
  p_dteyrepay       tdedlnslf.dteyrepay%type;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);

end hrpy5bu;

/
