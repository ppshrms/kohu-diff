--------------------------------------------------------
--  DDL for Package HRRC35X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRRC35X" as

  param_msg_error           varchar2(4000 char);
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	    number;
  global_v_numlvlsalen 	    number;

  v_chken                   varchar2(10 char);
  v_zupdsal                 varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;

  p_data_row    json_object_t;
  p_details     json_object_t;
  p_data_fparam json_object_t;

  p_codcomp     tapplcfm.codcomp%type;
  p_codpos      tapplcfm.codposc%type;
  p_dtestrt     tapplcfm.dteappr%type;
  p_dteend      tapplcfm.dteappr%type;
  p_stasign     tapplcfm.stasign%type;
  p_numappl     tapplcfm.numappl%type;
  p_numreqrq    tapplcfm.numreqrq%type;
  p_codform     tapplcfm.codform%type;
  p_dteprint    tapplcfm.dteprint%type;
	p_url		      varchar2(1000 char);
  type arr_1d is table of varchar2(4000 char) index by binary_integer;

  procedure initial_value(json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure get_detail_tab1 (json_str_input in clob, json_str_output out clob);
  procedure get_detail_tab2 (json_str_input in clob, json_str_output out clob);
  procedure get_detail_tab3 (json_str_input in clob, json_str_output out clob);

  procedure get_parameter_report (json_str_input in clob, json_str_output out clob);
  procedure get_html_message(json_str_input in clob, json_str_output out clob);

  procedure print_report(json_str_input in clob, json_str_output out clob);
  procedure print_report_detail(json_str_input in clob, json_str_output out clob);
  function std_replace_exist (p_message in clob, v_numappl in varchar2, v_numreqrq in varchar2, v_codposrq in varchar2) return clob ;
  function std_replace (p_message in clob,p_codform in varchar2,p_section in number,p_itemson in json_object_t,
                        v_numappl in varchar2, v_numreqrq in varchar2, v_codposrq in varchar2) return clob ;
  function esc_json(message in clob)return clob;
  function append_clob_json (v_original_json in json_object_t, v_key in varchar2 , v_value in clob  ) return json_object_t;
  function std_get_value_replace (v_in_statmt in	long, p_in_itemson in json_object_t, v_codtable in varchar2) return long ;
  function get_item_property (p_table in varchar2,p_field in varchar2) return varchar2 ;
  procedure send_mail(json_str_input in clob, json_str_output out clob);
end hrrc35x;

/
