--------------------------------------------------------
--  DDL for Package HRBF5AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF5AX" AS
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
  p_zupdsal                 varchar2(100 char);

  p_codcomp                 temploy1.codcomp%type;
  p_dtestrt                 date;
  p_dteend                  date;
  p_codempid                tloaninf.codempid%type;
  p_numcont                 tloaninf.numcont%type;

  -- report
  p_additional_year         number := 0;
  json_params               json_object_t;
  isInsertReport            boolean := false;
  p_codapp                  varchar2(10 char) := 'HRBF5AX';

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_tloancol (json_str_input in clob, json_str_output out clob);
  procedure gen_tloancol (json_str_output out clob);
  procedure get_tloangar (json_str_input in clob, json_str_output out clob);
  procedure gen_tloangar (json_str_output out clob);
  procedure get_report (json_str_input in clob, json_str_output out clob);
  procedure gen_report (json_str_output out clob);
  procedure insert_ttemprpt (v_table varchar2, json_str_input clob);
END HRBF5AX;


/
