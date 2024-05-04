--------------------------------------------------------
--  DDL for Package HRPMB1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRPMB1E" is
  param_msg_error           varchar2(4000 char);

  global_v_chken            varchar2(10 char) := hcm_secur.get_v_chken;
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_codempid         varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(1);

  tsetdeflt_codapp        tsetdeflt.codapp%type;
  tsetdeflt_numpage       tsetdeflt.numpage%type;
  tsetdeflt_seqno         tsetdeflt.seqno%type;
  tsetdeflt_tablename     tsetdeflt.tablename%type;
  tsetdeflt_fieldname     tsetdeflt.fieldname%type;
  tsetdeflt_flgdisp       tsetdeflt.flgdisp%type;
  tsetdeflt_defaultval    tsetdeflt.defaultval%type;

  procedure get_default_value(json_str_input in clob,json_str_output out clob);
  procedure gen_default_value(json_str_output out clob);
  procedure post_default_value(json_str_input in clob,json_str_output out clob);
  procedure chk_save(json_str_input in clob); --User37 #5440 Final Test Phase 1 V11 05/03/2021  
  procedure save_default_value(json_str_input in clob);
end HRPMB1E;

/
