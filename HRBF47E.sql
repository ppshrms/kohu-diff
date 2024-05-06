--------------------------------------------------------
--  DDL for Package HRBF47E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRBF47E" AS
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

  p_codobf                  tobfsum.codobf%type;
  p_dteyre                  tobfsum.dteyre%type;
  p_codempid_query          tobfsum.codempid%type;

  -- save index
--  p_codobf                  tobfsum.codobf%type;
  p_qtytwidrw               tobfsum.qtytwidrw%type;
  p_qtywidrw                tobfsum.qtywidrw%type;
  p_amtvalue                tobfcftd.amtvalue%type;
  p_amtwidrw                tobfsum.amtwidrw%type;
  p_typepay                 tobfcde.typepay%type;
  p_qtyalw                  tobfsum.qtyalw%type;
  p_qtytalw                 tobfsum.qtytalw%type;

  --> Peerasak || #9245 || 17032023
  p_dtemth                  tobfsum.dtemth%type;
  p_qtywidrwOld             tobfsum.qtywidrw%type;
  p_qtytwidrwOld            tobfsum.qtytwidrw%type;

  type array_t is table of varchar2(4000 char) index by varchar2(100 char);
  array_tobflog             array_t;
  --> Peerasak || #9245 || 17032023

  p_warning                 varchar(10 char);
  json_params               json_object_t;

  procedure get_index (json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_tobfcft (json_str_input in clob, json_str_output out clob);
  procedure gen_tobfcft (json_str_output out clob);
  procedure save_index (json_str_input in clob, json_str_output out clob);
END HRBF47E;

/
