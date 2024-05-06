--------------------------------------------------------
--  DDL for Package HRRC21E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC21E" is
  param_msg_error           varchar2(4000 char);
  param_flgwarn             varchar2(10 char);
  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;

  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  param_numreqst            varchar2(4000 char);
  param_codpos              varchar2(4000 char);
  parameter_groupid         varchar2(100);
  parameter_year            number;
  parameter_month           number;
  parameter_running         varchar2(100);

  ---document tab---
  type document_type is table of tappldoc%ROWTYPE index by binary_integer;
    document_tab    document_type;
  type flg_del_doc_type is table of varchar2(50 char) index by binary_integer;
    p_flg_del_doc   flg_del_doc_type;

  ---p others---
  p_o_staemp		    varchar2(4000 char);
  b_index_numappl   varchar2(4000 char);

  procedure get_blacklist_data(json_str_input in clob, json_str_output out clob);
  procedure gen_blacklist_data(json_str_input in clob, json_str_output out clob);

  procedure get_applinf(json_str_input in clob, json_str_output out clob);

  procedure get_emergency_contact(json_str_input in clob, json_str_output out clob);

  procedure get_document(json_str_input in clob, json_str_output out clob);

  procedure check_tab_document(json_str_input in clob, json_str_output out clob);

  procedure save_applinf(json_str_input in clob, json_str_output out clob);
  procedure delete_applinf(json_str_input in clob, json_str_output out clob);
  procedure update_filedoc( p_codempid  varchar2,
                            p_filedoc   varchar2,
                            p_namedoc   varchar2,
                            p_type_doc  varchar2,
                            p_coduser   varchar2,
                            p_numrefdoc in out varchar2);
  procedure get_msg_warning(json_str_input in clob, json_str_output out clob);
end;

/
