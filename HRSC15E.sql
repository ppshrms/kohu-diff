--------------------------------------------------------
--  DDL for Package HRSC15E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRSC15E" is
-- last update: 12/11/2018 21:12

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_lrunning         varchar2(10 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  global_v_zupdsal          varchar2(100 char);

  -- p_codapp                  varchar2(100 char) := 'HRSC15E';
  -- index
  p_codproc                 tprocess.codproc%type;
  p_codprocQuery            tprocess.codproc%type;
  -- save detail
  p_desproc                 tprocess.desproce%type;
  p_desproce                tprocess.desproce%type;
  p_desproct                tprocess.desproct%type;
  p_desproc3                tprocess.desproc3%type;
  p_desproc4                tprocess.desproc4%type;
  p_desproc5                tprocess.desproc5%type;
  p_codimage                tprocess.codimage%type;
  p_linkurl                 tprocess.linkurl%type;
  p_flgcreate               tprocess.flgcreate%type;
  -- save index
  json_params               json_object_t;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_tprocess (json_str_input in clob, json_str_output out clob);
  procedure gen_tprocess (json_str_output out clob);
  procedure get_tprocapp (json_str_input in clob, json_str_output out clob);
  procedure gen_tprocapp (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
  procedure save_detail (json_str_input in clob, json_str_output out clob);
end HRSC15E;

/
