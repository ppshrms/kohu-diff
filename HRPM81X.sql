--------------------------------------------------------
--  DDL for Package HRPM81X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM81X" is

  param_msg_error           varchar2(4000 char);

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) ;
--  global_v_lang             varchar2(10 char) := '102';
  global_v_chken		    varchar2(10 char) := hcm_secur.get_v_chken;

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zyear		    number := 0;
  global_v_zupdsal          varchar2(4000 char);
  pa_logic                  json_object_t;
  pa_logic_des              varchar2(4000 char);
  pa_type_report             varchar2(4000 char);
  p_params                  varchar2(4000 char);
  pa_codcomp                temploy1.codcomp%type;
  pa_codempid               temploy1.codempid%type;
  json_data                 varchar2(4000 char);
  str_data                  varchar2(4000 char);
  p_flag                    varchar2(4000 char);
  p_report                  varchar2(4000 char);

  json_codempid		        json_object_t;
  json_numcaselw		    json_object_t;
  isInsertReport		    boolean := false;
  v_numseq		            number := 0;
  numYearReport             number;
  r_codempid                temploy1.codempid%type;
  r_codcomp                 temploy1.codcomp%type;
  str_main                  clob;
  permision_salary          boolean;

  procedure initial_value (json_str in clob);

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

  procedure getPopup(json_str_input in clob, json_str_output out clob);
  procedure genPopup(json_str_output out clob);
  procedure get_update_popup(json_str_input in clob, json_str_output out clob);

  procedure get_groupname(p_codinf in varchar2, p_lang in varchar2, str_groupname out varchar2);

  procedure gen_report(json_str_input in clob,json_str_output out clob);
  procedure gen_report_resume(v_codempid in varchar2);

  procedure clear_ttemprpt;
  procedure clear_ttemprpt_resume;

  procedure validation_secur1;

  procedure get_detail_report(json_str_output out clob);
  FUNCTION get_age_label ( p_dtest DATE , p_dtend  DATE)RETURN VARCHAR2;
  FUNCTION get_age_job ( p_dtest DATE , p_dtend  DATE)RETURN VARCHAR2;
  FUNCTION get_format_telphone ( string_telnumber varchar2)RETURN VARCHAR2;
  function get_format_hhmm(p_qtyhour    number) return varchar2;
  procedure get_addr_label(p_empid in varchar2, p_lang in varchar2, p_type in varchar2, str_addr_label out varchar2);
  procedure get_temphead (p_codempid_query in varchar2,p_codcomp in varchar2,p_codpos in varchar2,p_codcomph out varchar2,p_codposh out varchar2,p_codempidh out varchar2,p_stapost out varchar2);
end HRPM81X;

/
