--------------------------------------------------------
--  DDL for Package HCM_LOV_PY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_PY" is
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

  param_msg_error       varchar2(4000 char);
  param_flg_secur       varchar2(4000 char);
  param_where           varchar2(4000 char);

  procedure initial_value(json_str in clob);
  function get_type_payslip(json_str_input in clob) return T_LOV;
  function get_type_branch_socialsecurity(json_str_input in clob) return T_LOV;
  function get_type_branch_number(json_str_input in clob) return clob;
  function get_fund_code(json_str_input in clob) return clob;      -- List of P/F
  function get_policy_codes(json_str_input in clob) return clob;   -- List of Policy Code
  function get_account_codes(json_str_input in clob) return clob;   -- List of Account Code
  function get_cost_center(json_str_input in clob) return clob;   -- List of Cost Center
  function get_account_group(json_str_input in clob) return clob;   -- Account Group
  function get_deduct(json_str_input in clob) return clob;   -- List Of Deduct
  function get_tax_exemption(json_str_input in clob) return clob;   -- List Of Tax Exemption
  function get_tax_deduction(json_str_input in clob) return clob;   -- List Of Tax Deduction
  function get_other_deduction(json_str_input in clob) return clob;        -- List Of Other Deduction
  function get_investment_plan_code(json_str_input in clob) return clob;   -- List Of Investment Plan Code
end;

/
