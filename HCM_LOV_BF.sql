--------------------------------------------------------
--  DDL for Package HCM_LOV_BF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_BF" is
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
  function get_codec(p_table in varchar2, p_where in varchar2, p_code_name in varchar2 default 'codcodec', p_desc_name in varchar2 default 'descod') return clob;
  function get_hospital(json_str_input in clob) return clob;                     --LOV for Hospital
  function get_code_of_welfare(json_str_input in clob) return clob;              --List of Code of Welfare
  function get_no_insurance(json_str_input in clob) return clob;                 --List of Insurance Policy
  function get_desc_insurance_policy(json_str_input in clob) return clob;        --List of List of Insurance Plan Details
  function get_loan_types(json_str_input in clob) return clob;                   --List of loan types
  function get_no_loan_contract(json_str_input in clob) return clob;             --List of No.Loan Contract
  function get_disease_code(json_str_input in clob) return clob;                 --List of Disease Code
  function get_people_relationship(json_str_input in clob) return clob;          --List of People by Relationship
  function get_health_checkup_programs(json_str_input in clob) return clob;      --List of Health Check-up Programs
  function get_health_check_code(json_str_input in clob) return clob;            --List of Health Check Code
  function get_bill_number(json_str_input in clob) return clob;                  --List of Bill Number
  function get_requisition_number(json_str_input in clob) return clob;           --List of Requisition Number
  function get_parents(json_str_input in clob) return clob;                      --List of Parents
  function get_mail_alert_number_bf(json_str_input in clob) return clob;         --LOV for Mail Alert Number BF
  function get_req_number_other_benefits(json_str_input in clob) return clob;    --LOV for Requisition Number Other benefits
  function get_req_number_other_benefits_group(json_str_input in clob) return clob;    --LOV for Requisition Number Other benefits in groups
  function get_referral_no(json_str_input in clob) return clob;                  --LOV for Referral No.
  function get_travel_reimbursement_units(json_str_input in clob) return clob;   --LOV List of travel reimbursement units
end;

/
