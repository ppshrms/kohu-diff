--------------------------------------------------------
--  DDL for Package HRAP17E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAP17E" is
-- last update: 07/08/2020 09:40

  v_chken               varchar2(100 char);

  param_msg_error       varchar2(4000 char);

  global_v_coduser      varchar2(100 char);
  global_v_zminlvl      number;
  global_v_zwrklvl      number;
  global_v_numlvlsalst  number;
  global_v_numlvlsalen 	number;
  v_zupdsal             varchar2(4000 char);
  global_v_codpswd      varchar2(100 char);
  global_v_codempid     temploy1.codempid%type;
  global_v_lang         varchar2(10 char) := '102';

  p_codcomp             tpromote.codcomp%type;
  p_codpos              tpromote.codpos%type;
  p_dtereq              tpromote.dtereq%type;

  p_condition           varchar2(10 char);
  p_stasuccr            tsuccpln.stasuccr%type;
  p_numseq              tsuccpln.numseq%type;
  p_dteposdue           tposempd.dteposdue%type;
  p_codemprq            tpromote.codemprq%type;

  p_codempid_query      temploy1.codempid%type;
  p_datarows            json_object_t;
  p_flg                 varchar2(50);

  p_codcompy            tattpreh.codcompy%type;
  p_codaplvl            tattpreh.codaplvl%type;
  p_dteeffec            tattpreh.dteeffec%type;
  p_codgrplv            tattprelv.codgrplv%type;
  p_codpunsh            tattpre4.codpunsh%type;

  p_break_json          json_object_t;
  p_leave_json          json_object_t;

  procedure initial_value(json_str in clob);

  procedure get_leave(json_str_input in clob, json_str_output out clob);
  procedure gen_leave(json_str_output out clob);

  procedure get_grpleave(json_str_input in clob, json_str_output out clob);
  procedure gen_grpleave(json_str_output out clob);

  procedure get_breakdiscipline(json_str_input in clob, json_str_output out clob);
  procedure gen_breakdiscipline(json_str_output out clob);

  procedure get_punsh(json_str_input in clob, json_str_output out clob);
  procedure gen_punsh(json_str_output out clob);  

  procedure save_index(json_str_input in clob, json_str_output out clob);

  procedure check_index;

END; -- Package spec

/
