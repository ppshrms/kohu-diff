--------------------------------------------------------
--  DDL for Package HRBF3YU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF3YU" is
-- last update: 31/08/2020 18:16

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

  p_codcomp                 ttpminf.codcomp%type;
  p_numisr                  tinsrer.numisr%type;
  p_month                   number;
  p_year                    number;

  obj_row                   json_object_t;

  v_codapp                  tprocapp.codapp%type:= 'HRBF3YU';
  procedure initial_value(json_str in clob);
--show data
  procedure get_process(json_str_input in clob, json_str_output out clob);
END; -- Package spec

/
