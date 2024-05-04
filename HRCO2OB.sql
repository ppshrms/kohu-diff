--------------------------------------------------------
--  DDL for Package HRCO2OB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRCO2OB" is
  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(1000 char);
  global_v_coduser          varchar2(1000 char) := 'AUTO';
  global_v_codpswd          varchar2(1000 char);
  global_v_codempid         varchar2(1000 char);
  global_v_lang             varchar2(1000 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(1000 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  p_functype                varchar2(2 char);
  p_typeapp                 twkflowd.typeapp%type;
  p_codposo                 tempaprq.codposap%type;
  p_codcompao               tempaprq.codcompap%type;
  p_codempido               tempaprq.codempap%type;
  p_codcompan               tempaprq.codcompap%type;
  p_codposn                 tempaprq.codposap%type;
  p_codempidn               tempaprq.codempap%type;
  p_codapp                  tempaprq.codapp%type;

  procedure data_process(json_str_input in clob, json_str_output out clob);
end HRCO2OB;

/
