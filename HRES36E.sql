--------------------------------------------------------
--  DDL for Package HRES36E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES36E" AS
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  p_dtestrt                  trefreq.dtereq%type;
  p_dteend                   trefreq.dtereq%type;

  -- save & detail
  p_dtereq                   trefreq.dtereq%type;
  p_dtereq2save              trefreq.dtereq%type;
  p_numseq                   trefreq.numseq%type;
  p_desnote                  trefreq.desnote%type;
  --User37 NXP-HR2101 #6370 ST11 28/07/2021 p_flginc                   trefreq.flginc%type;
  p_dteuse                   trefreq.dteuse%type;
  --User37 NXP-HR2101 #6370 ST11 28/07/2021 p_codtypcrt                trefreq.typcertif%type;
  p_codform                  trefreq.codform%type;--User37 NXP-HR2101 #6370 ST11 28/07/2021 
  p_staappr                  trefreq.staappr%type;
  p_travel_period            trefreq.travel_period%type;
  p_country                  trefreq.country%type;

  p_dtecancel                trefreq.dtecancel%type;
  p_codappr                  trefreq.codappr%type;
  p_dteappr                  trefreq.dteappr%type;
  p_remarkap                 trefreq.remarkap%type;
  p_approvno                 trefreq.approvno%type;
  p_routeno                  trefreq.routeno%type;




  procedure initial_value (json_str in clob);
  function gen_numseq(v_dtereq date) return number;
  procedure get_numseq (json_str_input in clob, json_str_output out clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
  procedure cancel_request (json_str_input in clob, json_str_output out clob);
  function get_codtypcrt(json_str_input in clob) return clob;
END HRES36E;

/
