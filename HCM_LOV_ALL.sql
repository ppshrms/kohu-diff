--------------------------------------------------------
--  DDL for Package HCM_LOV_ALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_ALL" is
/* Cust-Modify: KOHU-HR2301 */
-- last update: 07/08/2023 15:22

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
  function get_punishment(json_str_input in clob) return clob;          --LOV for Punishment
  function get_resign(json_str_input in clob) return clob;              --LOV for Employee Resign
  function get_emp_movement(json_str_input in clob) return clob;        --LOV for Emp Movement
  function get_position(json_str_input in clob) return clob;            --LOV for Position
  function get_job_description(json_str_input in clob) return clob;     --LOV for Job Description
  function get_emp_type(json_str_input in clob) return clob;            --LOV for Employment Type
  function get_emp_category(json_str_input in clob) return clob;        --LOV for Employee Category
  function get_emp_typpayroll(json_str_input in clob) return clob;          --LOV for Employee typpayroll
  function get_branch_location(json_str_input in clob) return clob;     --LOV for Branch Location
  function get_work_group(json_str_input in clob) return clob;          --LOV for Working Group
  function get_jobgrade(json_str_input in clob) return clob;            --LOV for Job Grade
  function get_glgroup(json_str_input in clob) return clob;             --LOV for GL Group
  function get_currency(json_str_input in clob) return clob;            --LOV for currency
  function get_codcompy(json_str_input in clob) return clob;            --LOV for codcompy
  function get_diligence_allowance(json_str_input in clob) return clob; --LOV for Diligence Allowance --a??a?sa??a??a??a??a??a??a??
  function get_change_time_stamp(json_str_input in clob) return clob;   --LOV for Reason of Change Time Stamp --a??a?<a??a??a??a?Ya??a??a?#a??a??a??a??a??a??a??a?Ya??a??a??a??a??-a?-a?-a??
  function get_ot_request_reason(json_str_input in clob) return clob;   --LOV for O.T Request Reason --a??a??a??a?<a??a??a??a??a?#a??a?-
  function get_appraise_group(json_str_input in clob) return clob;      --LOV for Appraise Group --a??a?Ya??a??a?!a??a??a?#a??a?#a??a??a?!a?'a??
  function get_asset(json_str_input in clob) return clob;               --LOV for Asset --a??a?#a??a?za??a??a??a?'a??a??a?-a??a?sa?#a?'a??a??a??
  function get_province(json_str_input in clob) return clob;            --LOV for Province --a??a??a??a?<a??a??a??
  function get_educate_level(json_str_input in clob) return clob;       --LOV for Educate Level --a?#a??a??a??a?sa??a??a??a?'a??a??a?#a??a??a??a??a??
  function get_institute(json_str_input in clob) return clob;           --LOV for Institute Code --a??a??a??a?sa??a??
  function get_skill(json_str_input in clob) return clob;               --LOV for Skill --a??a??a??a?!a??a??a?!a??a?#a??/a??a?#a??a??a?sa??a??a?#a??a??/a??a??a??a?!a?Sa??a??a??a??
  function get_application_information(json_str_input in clob) return clob;   --LOV for Application Information ---a??a??a?-a?!a??a?Ya??a??a?#a??a?!a??a??a?#
  function get_emp_all(json_str_input in clob) return clob;             --LOV for Employee All
  function get_type_emp_all(json_str_input in clob) return T_LOV;             --LOV for Employee All
  function get_evaluation_score(json_str_input in clob) return clob;    --LOV for Evaluation Score (KPI)
  function get_function_type(json_str_input in clob) return clob;   --LOV for Function Type
  function get_menu_link_approve(json_str_input in clob) return clob;   --LOV for Menu link to approve
  function get_provident_fund_compn(json_str_input in clob) return clob; --LOV for Provident Fund Compensation
  function get_district(json_str_input in clob) return clob;            --LOV for District
  function get_sub_district(json_str_input in clob) return clob;        --LOV for Sub District
  function get_type_sub_district(json_str_input in clob) return T_LOV;        --LOV for Sub District
  function get_country(json_str_input in clob) return clob;             --LOV for Country
  function get_disabled(json_str_input in clob) return clob;            --LOV for Disabled
  function get_race(json_str_input in clob) return clob;                --LOV for Race
  function get_religion(json_str_input in clob) return clob;            --LOV for Religion
  function get_nationality(json_str_input in clob) return clob;         --LOV for Nationality
  function get_bank(json_str_input in clob) return clob;                --LOV for Bank
  function get_degree(json_str_input in clob) return clob;              --LOV for Degree
  function get_education_major(json_str_input in clob) return clob;     --LOV for Education Major
  function get_education_minor(json_str_input in clob) return clob;     --LOV for Reward
  function get_occupation(json_str_input in clob) return clob;          --LOV for Occupation
  function get_collateral(json_str_input in clob) return clob;          --LOV for Collateral
  function get_reward(json_str_input in clob) return clob;              --LOV for Reward
  function get_type_document(json_str_input in clob) return clob;       --LOV for Type Documnet
  function get_mail_alert_number(json_str_input in clob) return clob;   --LOV for Mail Alert Number
  function get_bus_no(json_str_input in clob) return clob;              --LOV for Bus No.
  function get_bus_route(json_str_input in clob) return clob;           --LOV for Bus Route
  function get_type_of_resignment(json_str_input in clob) return clob;  --LOV for Type of Resignment
  function get_process(json_str_input in clob) return clob;             --LOV for Work Process
  function get_company_group(json_str_input in clob) return clob;       --LOV for Company Group
  function get_report_names(json_str_input in clob) return clob;        --LOV for Report Names
  function get_revenue_report(json_str_input in clob) return clob;      --LOV for Revenue Report Code
  function get_lang(json_str_input in clob) return clob;                --LOV for Langauge Ability Code
  function get_mistake(json_str_input in clob) return clob;             --LOV for Mistake Code
  function get_movement_type(json_str_input in clob) return clob;       --LOV for Movement Type
  function get_investment_plan(json_str_input in clob) return clob;     --LOV for Investment Plan Codes
  function get_list_table_name(json_str_input in clob) return clob;     --LOV for List Table name
  function get_certificate_taxes(json_str_input in clob) return clob;   --LOV for Type of Certificate for Taxes
  function get_payslip(json_str_input in clob) return clob;             --LOV for List of Income/Deduct Code
  function get_list_user_name(json_str_input in clob) return clob;      --LOV for List of User Name
  function get_security_group(json_str_input in clob) return clob;      --LOV for List of Security Group
  function get_application_work_process(json_str_input in clob) return clob;      --LOV for List of Application Name
  function get_type_code(json_str_input in clob) return clob;           --LOV for List of Type Code
  function get_type_code_m_hrpmz1e(json_str_input in clob) return clob;           --LOV for List of Type Code m_hrpmz1e
  function get_type_competency(json_str_input in clob) return clob;     --LOV for List of Type of Competency
  function get_table_name(json_str_input in clob) return clob;          --LOV for List of Table Name
  function get_unit(json_str_input in clob) return clob;                --LOV for List of Unit
  function get_size(json_str_input in clob) return clob;                --LOV for List of Size
  function get_travel_cost(json_str_input in clob) return clob;         --LOV for List of Travel Cost
  function get_payslip_deduction(json_str_input in clob) return clob;   --LOV for List of Deduction Code
  function get_company_level(json_str_input in clob) return clob;       --LOV for List of Company Level
  function get_skill_code(json_str_input in clob) return clob;          --LOV for List of Code Skill 
  function get_menu_link_approve_typ_form(json_str_input in clob) return clob;    --LOV for Menu link to approve
  function get_securities_code(json_str_input in clob) return clob;     --LOV for List of Securities Code
end;

/
