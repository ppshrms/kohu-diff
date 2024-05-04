--------------------------------------------------------
--  DDL for Package HRAL53E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "HRAL53E" is
-- last update: 20/02/2018 12:02

  param_msg_error           varchar2(4000 char);

  v_chken                   varchar2(10 char);
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zyear            number := 0;
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);
  -- index
  p_codcompy                varchar2(100 char);
  p_dteeffec                date;
  p_dteeffecOld             date;
  p_dteupd                  date;
  p_desc_coduser           varchar2(400 char);
  p_codempid                varchar2(20 char);
  -- tab1
  p_flgmthvac               varchar2(1000 char);
  p_daylevst                number;
  p_mthlevst                number;
  p_dayleven                number;
  p_mthleven                number;
  p_qtyday                  number;
  p_flgcal                  varchar2(1000 char);
  p_typround                varchar2(1000 char);
  -- new requirement --
  p_flgresign               varchar2(10 char);
  p_flguse                  varchar2(10 char);
  -- tab2
  p_json_tab1               json_object_t;
  p_isAddOrigin             varchar2(10 char);
  isEdit                    boolean := false;
  isAdd                     boolean := false;
  isAddOrigin               boolean := false;

  procedure initial_value(json_str in clob);
  procedure initial_value_detail(json_str_input in clob);
  procedure check_index;

  procedure get_flg_status (json_str_input in clob, json_str_output out clob);
  procedure gen_flg_status;

  procedure get_tab1(json_str_input in clob, json_str_output out clob);
  procedure gen_tab1(json_str_output out clob);

  procedure get_tab2(json_str_input in clob, json_str_output out clob);
  procedure gen_tab2(json_str_output out clob);

  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure save_detail_tab1;
  procedure save_detail_tab2;

end HRAL53E;

/
