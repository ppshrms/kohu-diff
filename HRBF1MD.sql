--------------------------------------------------------
--  DDL for Package HRBF1MD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1MD" is
-- last update: 17/11/2022 17:01 ||redmine-8653 

  v_chken      varchar2(100 char);

  param_msg_error           varchar2(4000 char);

  global_v_coduser          varchar2(100 char);
  global_v_codempid         varchar2(100 char);

  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen 	    number;
  v_zupdsal                 varchar2(4000 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';

  p_datarows                json_object_t;
  obj_row                   json_object_t;

  v_codapp                  tprocapp.codapp%type:= 'HRBF1OX';
  v_numseq                  number := 0;

  p_codcomp                 temploy1.codcomp%type;
  p_codempid_query          temploy1.codempid%type;
  p_dtestr                  date;
  p_dteend                  date;
  p_numvcher                tclnsinf.numvcher%type;
  p_dtecancl                tclnslog.dtecancl%type;
  p_descancl                tclnslog.descancl%type;
  p_codcancl                tclnslog.codcancl%type;

  procedure initial_value(json_str in clob);
--show data
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure gen_detail(json_str_output out clob);
  procedure post_detailsave(json_str_input in clob, json_str_output out clob);
END; -- Package spec

/
