--------------------------------------------------------
--  DDL for Package HRTR7LX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRTR7LX" AS
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

  p_codempid                tidpplan.codempid%type;
  p_codcomp                 tidpplan.codcomp%type;
  p_codpos                  tidpplan.codpos%type;
  p_dteyear1                tidpplan.dteyear%type;
  p_dteyear2                tidpplan.dteyear%type;
  p_dteyear3                tidpplan.dteyear%type;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail (json_str_input in clob, json_str_output out clob);
  procedure gen_detail (json_str_output out clob);
  procedure get_detail_avglst (json_str_input in clob, json_str_output out clob);
  procedure gen_detail_avglst (json_str_output out clob);
END HRTR7LX;


/
