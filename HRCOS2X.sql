--------------------------------------------------------
--  DDL for Package HRCOS2X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCOS2X" is

  param_msg_error   varchar2(4000 char);
  global_v_coduser  varchar2(100 char);
  global_v_codempid varchar2(100 char);
  global_v_lang     varchar2(10 char) := '102';
  json_params       json_object_t;

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);
  global_v_chken            varchar2(100 char);
  v_zupdsal         varchar2(4 char);

  p_codempid        varchar2(100 char);
  p_codcompy        varchar2(100 char);
  p_codcomp         varchar2(100 char);
  p_codsys          varchar2(100 char);
  p_rep_id          tquery.rep_id%type;
  p_rep_table       tqtable.rep_table%type;

  procedure get_tquery_index(json_str_input in clob, json_str_output out clob) ;
  procedure gen_tquery_index (json_str_output out clob) ;
  procedure get_tqfield(json_str_input in clob, json_str_output out clob) ;
  procedure gen_tqfield (json_str_output out clob) ;
  procedure get_tqsort_index(json_str_input in clob, json_str_output out clob) ;
  procedure gen_tqsort_index(json_str_output out clob) ;
  procedure get_tquery (json_str_input in clob, json_str_output out clob);
  procedure gen_tquery (json_str_output out clob);
  procedure gen_report (json_str_input in clob, json_str_output out clob) ;
  procedure gen_report_rec (json_str_output out clob) ;
  procedure gen_header_report (json_str_input in clob, json_str_output out clob) ;
  procedure check_report_secur (json_str_input in clob, json_str_output out clob) ;
  function get_desc_function(p_rep_cal in varchar2,p_rep_id in varchar2) return varchar2 ;

end HRCOS2X;

/
