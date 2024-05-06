--------------------------------------------------------
--  DDL for Package M_HRPMZ1E
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "M_HRPMZ1E" AS
/* Cust-Modify: KOHU-HR2301 */
-- last update: 12/06/2023 14:04

  param_msg_error           varchar2(4000 char);
  v_chken                   varchar2(10 char);
  -- global var
  global_v_coduser          varchar2(100 char);
  global_v_codpswd          varchar2(100 char);
  global_v_lang             varchar2(10 char) := '102';
  global_v_codempid         varchar2(100 char);
  global_v_zminlvl          number;
  global_v_zwrklvl          number;
  global_v_numlvlsalst      number;
  global_v_numlvlsalen      number;
  v_zupdsal                 varchar2(4 char);

  -- get val search index
  p_typcode                 varchar2(100);
  p_tablename               varchar2(100); ----
  p_lovtype                 varchar2(100); ----

  p_codcomp                 temploy1.codcomp%type;
  p_codlegald               tlegalexe.codlegald%type;
  -- block param
  v_flg                     varchar2(1000);
  v_codcodec                varchar2(4 char);
  v_typcode                 varchar2(4 char);
  v_descod                  varchar2(150 char);
  v_descode                 varchar2(150 char);
  v_descodt                 varchar2(150 char);
  v_descod3                 varchar2(150 char);
  v_descod4                 varchar2(150 char);
  v_descod5                 varchar2(150 char);
  v_flgcorr                 varchar2(1 char);
  v_flgact                  varchar2(1 char);
  v_typmove                 varchar2(10 char);
  v_table                   varchar2(100 char);
  v_stmt                    varchar2(4000 char);
  v_stmt2                    varchar2(4000 char);
  /* call procedure */
  procedure get_index(json_str_input in clob, json_str_output out clob);
  procedure gen_index (json_str_output out clob);
  procedure get_detail(json_str_input in clob, json_str_output out clob);
  procedure save_detail(json_str_input in clob, json_str_output out clob);
  procedure save_index(json_str_input in clob, json_str_output out clob);

END M_HRPMZ1E;


/
