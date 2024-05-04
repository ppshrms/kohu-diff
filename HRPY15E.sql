--------------------------------------------------------
--  DDL for Package HRPY15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY15E" as

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  global_v_empname  varchar2(100 char);

  param_json              json_object_t;

  procedure initial_value(json_str_input in clob);

  procedure get_index(json_str_input in clob, json_str_output out clob);

  procedure save_index(json_str_input in clob, json_str_output out clob);

  procedure check_save(json_str_input in clob);

  procedure get_income(json_str_input in clob, json_str_output out clob);

  function check_codpay(p_codpay varchar2,error_code varchar2,p_codcompy varchar2,p_typpay1 varchar2,p_typpay2 varchar2 default null) return boolean;

  function check_salary(p_amtminsoc varchar2,p_amtmaxsoc varchar2) return boolean;

  function check_has_codcompy(p_codcompy varchar2) return boolean;

  function check_dteeffec_index(p_codcompy varchar2,p_dteeffec date) return boolean;

end HRPY15E;

/
