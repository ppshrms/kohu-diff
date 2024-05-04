--------------------------------------------------------
--  DDL for Package STD_APPLINF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "STD_APPLINF" as 
  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;

  v_zupdsal                 varchar2(10 char);
  p_numcont                 tloaninf.numcont%type; 
  p_numappl                 tapplinf.numappl%type; 

  procedure initial_value (json_str in clob);  
  --loaninf
  procedure get_tapplinf(json_str_input in clob, json_str_output out clob);
  procedure gen_tapplinf(json_str_output out clob);
  --tapplref
  procedure get_tapplref(json_str_input in clob, json_str_output out clob);
  procedure gen_tapplref(json_str_output out clob);  
  --teducatn
  procedure get_teducatn(json_str_input in clob, json_str_output out clob);
  procedure gen_teducatn(json_str_output out clob);
  --tappldoc
  procedure get_tappldoc(json_str_input in clob, json_str_output out clob);
  procedure gen_tappldoc( json_str_output out clob);
  --tapphinv
  procedure get_tapphinv(json_str_input in clob, json_str_output out clob);
  procedure gen_tapphinv( json_str_output out clob);
  --tapplwex
  procedure get_tapplwex(json_str_input in clob, json_str_output out clob);
  procedure gen_tapplwex( json_str_output out clob);
  --ttrainbf
  procedure get_ttrainbf(json_str_input in clob, json_str_output out clob);
  procedure gen_ttrainbf( json_str_output out clob);
  --tcmptncy
  procedure get_tcmptncy(json_str_input in clob, json_str_output out clob);
  procedure gen_tcmptncy( json_str_output out clob);
  --applhistory
  procedure get_applhistory(json_str_input in clob, json_str_output out clob);
  procedure gen_applhistory( json_str_output out clob);
  --tapplfm
  procedure get_tapplfm(json_str_input in clob, json_str_output out clob);
  procedure gen_tapplfm( json_str_output out clob);
  --tapploth
  procedure get_tapploth(json_str_input in clob, json_str_output out clob);
  procedure gen_tapploth( json_str_output out clob);
  --tlangabi
  procedure get_tlangabi(json_str_input in clob, json_str_output out clob);
  procedure gen_tlangabi( json_str_output out clob);
  --tapplref
  procedure get_tapplrel(json_str_input in clob, json_str_output out clob);
  procedure gen_tapplrel(json_str_output out clob);  

end std_applinf;

/
