--------------------------------------------------------
--  DDL for Package HRPY2EE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPY2EE" is
-- last update: 24/08/2018 16:15

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
  global_v_zupdsal          varchar2(100 char);

  p_codapp                  varchar2(100 char) := 'HRPY2EE';
  -- index
  p_codempid                temploy1.codempid%type;
  p_codpay                  tinexinf.codpay%type;
  p_codcompy                varchar2(100 char);
  -- save
  json_params               json_object_t;
  -- import
  p_flgimport               varchar2(1 char);
  p_json_str_row            clob;
  p_flgerror                boolean := false;
  p_flgdisp_err_table       boolean := true; -- for check html in error

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_descpay (json_str_input in clob, json_str_output out clob);
  procedure check_codpay (b_codpay in varchar2);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure save_tempinc (json_obj in json_object_t);
  procedure get_import_process(json_str_input in clob, json_str_output out clob);
  function get_flgform (v_codpay varchar2) return varchar2;
  function get_formula_name(v_formula varchar2) return varchar2;
end HRPY2EE;

/
