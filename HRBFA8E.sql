--------------------------------------------------------
--  DDL for Package HRBFA8E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFA8E" AS
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

  p_codempid                thealinf1.codempid%type;
  p_dteyear                 thealinf1.dteyear%type;
  p_codcomp                 thealinf1.codcomp%type;
  p_codprgheal              thealinf1.codprgheal%type;
  p_syncond                 thealcde.syncond%type;
  p_qtymth                  thealcde.qtymth%type;

  -- save detail
  p_codcln                  thealinf1.codcln%type;
  p_dteheal                 thealinf1.dteheal%type;
  p_dtehealen               thealinf1.dtehealen%type;
  p_amtheal                 thealcde.amtheal%type;
  json_params               json_object_t;

  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_thealinf1 (json_str_input in clob, json_str_output out clob);
  procedure gen_thealinf1 (json_str_output out clob);
  procedure get_thealinf1_data (json_str_input in clob, json_str_output out clob);
  procedure gen_thealinf1_data (json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
END HRBFA8E;

/
