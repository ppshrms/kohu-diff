--------------------------------------------------------
--  DDL for Package HCM_LOV_CO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HCM_LOV_CO" is
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

  function get_form_workflow(json_str_input in clob) return clob;                  -- LOV for Workflow
  function get_interview_eval_position(json_str_input in clob) return clob;        -- LOV for Interview Evaluation Position
  function get_format_letter_form(json_str_input in clob) return clob;             -- LOV for Format of Letter Form
  function get_interview_grade(json_str_input in clob) return clob;                -- LOV for Interview Grade
  function get_routing_number(json_str_input in clob) return clob;                 -- Lov for Routing Number
  function get_list_item_label(json_str_input in clob) return clob;                -- Lov for List Item Label
  function get_company_rule(json_str_input in clob) return clob;                   -- Lov for Topic
  function get_budget_group(json_str_input in clob) return clob;                   -- Lov for group budget
  function get_mail_form(json_str_input in clob) return clob;                      -- Lov for List Mail Form
  function get_job_group(json_str_input in clob) return clob;                      -- Lov for Job Group Code
  function get_development_code(json_str_input in clob) return clob;               -- Lov for Development code
  function get_report_code(json_str_input in clob) return clob;                    -- Lov for Report Code
  function get_subject_name(json_str_input in clob) return clob;                   -- Lov for Subject Name
  function get_category_code(json_str_input in clob) return clob;                  -- Lov for Category Code
  function get_province_group(json_str_input in clob) return clob;                 -- Lov for Province Group
  function get_country_group(json_str_input in clob) return clob;                  -- Lov for Country Group
  function get_skill_score(json_str_input in clob) return clob;                    -- Lov for Skill Score
  function get_customer_code(json_str_input in clob) return clob;                  -- Lov for Customer code
end;

/
