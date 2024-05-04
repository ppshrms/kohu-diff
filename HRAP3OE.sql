--------------------------------------------------------
--  DDL for Package HRAP3OE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP3OE" as
  v_chken      varchar2(100 char);

  param_msg_error     varchar2(4000 char);

  global_v_coduser      varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
	global_v_zupdsal		      varchar2(4 char);

  p_dteyreap            tappasgn.dteyreap%type;
  p_numtime             tappasgn.numtime%type;
  p_codcomp             tappasgn.codcomp%type;
  p_codempid            tappasgn.codempid%type;
  p_codaplvl            tappasgn.codaplvl%type;
  p_dteyreapQuery       tappasgn.dteyreap%type;
  p_numtimeQuery        tappasgn.numtime%type;
  p_codempid_query      temploy1.codempid%type;
  p_isCopy              varchar2(2 char) := 'N';
  p_isEdit              varchar2(2 char) := 'Y';

  TYPE data_error IS TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;
  p_text                    data_error;
  p_error_code              data_error;
  p_numseq                  data_error;

  procedure initial_value(json_str in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_copy_list(json_str_input in clob, json_str_output out clob);
  procedure get_tappfm_data(json_str_input in clob, json_str_output out clob);
  procedure post_save(json_str_input in clob, json_str_output out clob);
  procedure save_data(json_str_input in clob);
  procedure post_process(json_str_input in clob, json_str_output out clob);
  procedure post_import_process(json_str_input in clob, json_str_output out clob);
  procedure format_text_json(json_str_input in clob, v_rec_tran out number, v_rec_error out number);
  procedure get_head( v_tmp_codcomp in varchar2,
                      v_tmp_codpos in varchar2,
                      v_tmp_codcomph out varchar2,
                      v_tmp_codposh out varchar2,
                      v_tmp_codempidh out varchar2,
                      v_tmp_stapost out varchar2);
  procedure get_conap(v_tmp_codcomp in varchar2,
                      v_tmp_codpos in varchar2,
                      v_tmp_codempid in varchar2,
                      taplvl_codcomp out varchar2,
                      taplvl_codaplvl out varchar2,
                      v_flgpass out boolean);
end hrap3oe;

/
