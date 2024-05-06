--------------------------------------------------------
--  DDL for Package HRBF91E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF91E" AS
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

  p_codcompy                tcontrbf.codcompy%type;
  p_dteeffec                tcontrbf.dteeffec%type;
  p_dteeffec_query          tcontrbf.dteeffec%type;
  p_flgEdit                 varchar2(10 char) := 'Y';
  -- save index
  p_daybfst                 tcontrbf.daybfst%type;
  p_daybfen                 tcontrbf.daybfen%type;
  p_mthbfst                 tcontrbf.mthbfst%type;
  p_mthbfen                 tcontrbf.mthbfen%type;
  p_coddisisr               tcontrbf.coddisisr%type;
  p_coddisovr               tcontrbf.coddisovr%type;
  p_codincrt                tcontrbf.codincrt%type;
  p_codinctv                tcontrbf.codinctv%type;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
END HRBF91E;

/
