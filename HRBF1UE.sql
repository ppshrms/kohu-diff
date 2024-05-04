--------------------------------------------------------
--  DDL for Package HRBF1UE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF1UE" as

--date        : 28/01/2021 15:01  redmine#4176

  param_msg_error           varchar2(4000 char);
  param_msg_error_mail      varchar2(4000 char);
  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         temploy1.codempid%type;
  global_v_lang             varchar2(10 char) := '102';
  global_v_zminlvl	        number;
  global_v_zwrklvl	        number;
  global_v_numlvlsalst	    number;
  global_v_numlvlsalen	    number;
  global_v_zupdsal		      varchar2(4 char);

  p_codcomp                 tcenter.codcomp%type;
  p_dtestrt                 date;
  p_dteend                  date;
  p_numvcher                tclnsinf.numvcher%type;

  type arr_1d is table of varchar2(4000 char) index by binary_integer;
  procedure initial_value (json_str in clob);
  procedure check_index;

  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure get_detail_approve(json_str_input in clob, json_str_output out clob);
  procedure process_approve(json_str_input in clob, json_str_output out clob);
  function explode(p_delimiter varchar2, p_string long, p_limit number default 1000) return arr_1d;
end hrbf1ue;

/
