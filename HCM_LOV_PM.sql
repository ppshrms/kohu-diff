--------------------------------------------------------
--  DDL for Package HCM_LOV_PM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_PM" is
  global_v_coduser      varchar2(1000 char);
  global_v_codempid     varchar2(1000 char);
  global_v_lang         varchar2(100 char) := '102';
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen  number;
  v_zupdsal             varchar2(4000 char);
  v_chken               varchar2(10 char);

  v_cursor			        number;
  v_dummy               integer;
  v_stmt			          varchar2(5000 char);

  param_flg_secur       varchar2(4000 char);
  param_where           varchar2(4000 char);

  procedure initial_value(json_str in clob);
  --function get_emp_all(json_str_input in clob) return clob;             --LOV for All employee (LOV_PM.LOV_EMP)
  function get_emp_new(json_str_input in clob) return clob;             --LOV for New employee (LOV_PM.LOV_EMP2 =>> Staemp=0)
  function get_emp_probation(json_str_input in clob) return clob;       --LOV for Probation employee (LOV_PM.LOV_EMP3 =>> Staemp=1)
  function get_emp_current(json_str_input in clob) return clob;         --LOV for Current employee (LOV_PM.LOV_EMP4 =>> Staemp=3)
  function get_emp_retire(json_str_input in clob) return clob;          --LOV for Retire employee (LOV_PM.LOV_EMP5 =>> Staemp=9)
  function get_emp_pro_curr_retire(json_str_input in clob) return clob; --LOV for Probation+Current+Retire employee (LOV_PM.LOV_EMP1 =>> Staemp=1 or 3 or 9)
  function get_emp_pro_curr(JSON_STR_INPUT in clob) return clob;        --LOV for Probation+Current employee(LOV_PM.LOV_EMP6 =>> Staemp=1 or 3)

  function get_type_emp_new(json_str_input in clob) return T_LOV;             --LOV for New employee (LOV_PM.LOV_EMP2 =>> Staemp=0)
  function get_type_emp_probation(json_str_input in clob) return T_LOV;       --LOV for Probation employee (LOV_PM.LOV_EMP3 =>> Staemp=1)
  function get_type_emp_current(json_str_input in clob) return T_LOV;         --LOV for Current employee (LOV_PM.LOV_EMP4 =>> Staemp=3)
  function get_type_emp_retire(json_str_input in clob) return T_LOV;          --LOV for Retire employee (LOV_PM.LOV_EMP5 =>> Staemp=9)
  function get_type_emp_pro_curr_retire(json_str_input in clob) return T_LOV; --LOV for Probation+Current+Retire employee (LOV_PM.LOV_EMP1 =>> Staemp=1 or 3 or 9)
  function get_type_emp_pro_curr(JSON_STR_INPUT in clob) return T_LOV;        --LOV for Probation+Current employee(LOV_PM.LOV_EMP6 =>> Staemp=1 or 3)

  function get_personal_req1(JSON_STR_INPUT in clob) return clob;        --LOV for Interview Evaluation Form-HRRC11E (LOV_PM.LOV_req1)--show numReq./codcomp
  function get_movement_req3(json_str_input in clob) return clob;        --LOV for Interview Evaluation Form-HRPM4DE (LOV_PM.LOV_req3)--show numReq./codcomp/position
  function get_case_number(json_str_input in clob) return clob;          --LOV for Case Number Form-HRPM61E (LOV_PM.LOV_NUMCASELW)--show numcaselw./desc_codempid
  function get_law_enforcement_office(json_str_input in clob) return clob;   --LOV for Law enforcement office Form-HRPM61E (LOV_PM.LOV_CODLEGALD)--show codlegald./desc_codlegald
  function get_company_asset_code(json_str_input in clob) return clob;   --LOV for List of Company Asset Code Form-HRPM1EE (LOV_PM.LOV_ASET)--show typasset./desc_typasset
  function get_condition(json_str_input in clob) return clob;            --LOV for List of Condition Form-HRPMA1X (LOV_PM.LOV_REP)--show codrepdh./desc_codrepdh
  function get_memo_no(json_str_input in clob) return clob;              --LOV for List of Mail Alert (LOV_PM.LOV_MAIL)
  function get_condition_code(json_str_input in clob) return clob;       --LOV for List of Condition Code (LOV_PM.LOV_CODFRM)
  function get_group_id(json_str_input in clob) return clob;             --LOV for List of Format Group Code Emp. (LOV_PM.LOV_GROUP)
  function get_list_form(json_str_input in clob) return clob;            --LOV for List of Form. (LOV_PM.LOV_CODFM)
  function get_mail_alert_number_pm(json_str_input in clob) return clob;       --LOV for Mail Alert Number PM
  function get_approval_request_number(json_str_input in clob) return clob;    --LOV for List of Approval Request number
  function get_approval_request_number_io(json_str_input in clob) return clob; --LOV for List of Approval Request number (I,O)
end;

/
