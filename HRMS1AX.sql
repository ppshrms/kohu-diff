--------------------------------------------------------
--  DDL for Package HRMS1AX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRMS1AX" is
-- last update: 15/04/2019 17:51

  param_msg_error       varchar2(4000 char);
  global_v_coduser      varchar2(100 char);
  global_v_codpswd      varchar2(100 char);
  global_v_lang         varchar2(10 char) := '102';
  global_v_codcomp      varchar2(50 char);
  global_v_codempid     temploy1.codempid%type;
  global_v_zminlvl  		number;
  global_v_zwrklvl  		number;
  global_v_numlvlsalst 	number;
  global_v_numlvlsalen 	number;
  v_zupdsal   			    varchar2(4 char);

  b_index_codempid      varchar2(4000 char);
  b_index_codcomp       varchar2(4000 char);
  b_index_codcalen      varchar2(4000 char);
  b_index_dtestrt       date;
  b_index_dteend        date;

  p_path                varchar2(4000 char);

--  function get_index(json_str_input in clob) return t_hrms1ax;
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index(json_str_output out clob);

end; -- Package spec

/
