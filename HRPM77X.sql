--------------------------------------------------------
--  DDL for Package HRPM77X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPM77X" is

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          number;
  v_zupdsal                 varchar2(4 char);

  pa_codempid               thispun.codempid%type;
  pa_month1                 varchar2(10 char);
  pa_year1                  varchar2(10 char);
  pa_month2                 varchar2(10 char);
  pa_year2                  varchar2(10 char);
  pa_codpush                thispun.codpunsh%type;
  pa_dtestrt                thispun.dtestart%type;
  pa_dteend                 thispun.dteend%type;
  numYearReport             number;

  p_codform       tfmrefr2.codform%type;
  p_codempid      thismist.codempid%type;
  p_codmove       thismist.codmist%type;
  p_dteeffec      thismist.dteeffec%type;
  p_numseq        thispun.numseq%type;
  p_numhmref      tdocinf.numhmref%type;
  p_dateprint     tdocinf.dtehmref%type;
  p_type_move     tcodmove.codcodec%type;
  p_namimglet     tfmrefr.namimglet%type;
	p_url		        varchar2(1000 char);
  itemSelected		json_object_t;
  type arr_1d is table of varchar2(4000 char) index by binary_integer;

  procedure initial_value (json_str in clob);
  procedure vadidate_variable_getindex(json_str_input in clob);
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure print_report(json_str_input in clob, json_str_output out clob);
  procedure gen_report_data( json_str_output out clob);

end HRPM77X;

/
