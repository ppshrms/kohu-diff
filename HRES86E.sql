--------------------------------------------------------
--  DDL for Package HRES86E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRES86E" AS
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

  p_dtestrt                 tresreq.dtereq%type;
  p_dteend                  tresreq.dtereq%type;

  -- save & detail
  p_codempid                tresreq.codempid%type;
  p_dtereq                  tresreq.dtereq%type;
  p_dtereq2save             tresreq.dtereq%type;
  p_numseq                  tresreq.numseq%type;
  p_dteeffec                tresreq.dteeffec%type;
  p_codexemp                tresreq.codexemp%type;
  p_desnote                 tresreq.desnote%type;
  p_staappr                 tresreq.staappr%type;
  p_intwno                  tresreq.intwno%type;
  p_codpos                  temploy1.codpos%type;

  json_intw                 json_object_t;

  p_dtecancel               tresreq.dtecancel%type;
  p_codappr                 tresreq.codappr%type;
  p_dteappr                 tresreq.dteappr%type;
  p_remarkap                tresreq.remarkap%type;
  p_approvno                tresreq.approvno%type;
  p_routeno                 tresreq.routeno%type;

  procedure initial_value (json_str in clob);
  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_texintw (json_str_input in clob, json_str_output out clob);
  procedure gen_texintw (json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
  procedure cancel_request (json_str_input in clob, json_str_output out clob);
  function get_codexem(json_str_input in clob) return clob;
  procedure get_popup_link1(json_str_input in clob, json_str_output out clob);
  procedure get_popup_link2(json_str_input in clob, json_str_output out clob);
  procedure get_popup_link3(json_str_input in clob, json_str_output out clob);
  procedure get_popup_link4(json_str_input in clob, json_str_output out clob);
END HRES86E;

/
