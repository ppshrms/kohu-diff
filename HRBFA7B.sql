--------------------------------------------------------
--  DDL for Package HRBFA7B
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBFA7B" AS
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

  -- save index
  p_codcomp                 temploy1.codcomp%type;
  p_dteyear                 thealinf.dteyear%type;
  p_amtheal                 thealinf.amtheal%type;
  p_codprgheal              thealcde.codprgheal%type;
  p_codcln                  thealinf.codcln%type;
  p_fileData                json_object_t;

  procedure data_process (json_str_input in clob, json_str_output out clob);
END HRBFA7B;


/
